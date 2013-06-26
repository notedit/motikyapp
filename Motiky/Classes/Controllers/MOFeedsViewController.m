//
//  MOFeedsViewController.m
//  Motiky
//
//  Created by notedit on 3/22/13.
//  Copyright (c) 2013 notedit. All rights reserved.
//

#import "UIImageView+WebCache.h"
#import "MOAuthEngine.h"
#import "MOClient.h"
#import "Utils.h"
#import "SVPullToRefresh.h"
#import "MOFeedsViewController.h"
//import "MOVideoPlayCell.h"
//#import "MOVideoPlayBackManager.h"
#import "MOCommentListViewController.h"
#import "MOProfileViewController.h"
#import "MOActivityViewController.h"
#import "MOVideoRecordingViewController.h"


#import "MOVideoPlayer+AVPlayer.h"

#define kFeedListSourceCacheFilename @"com.motiky.cache.feedListSource.plist"


@interface MOFeedsViewController ()<UITableViewDelegate, UITableViewDataSource>

{
    int nextPage;
    
    BOOL firstAppearance;
    BOOL isLoaded;
    
    UIButton  *activityButton;
    UIButton  *recordButton;
    
    MOVideoPlayer_AVPlayer *firstCell;
    
}

@property (nonatomic,strong)  NSMutableArray *feedListSource;
@property (nonatomic,strong)  MOVideoPlayer_AVPlayer *activeTableCell;
@property CGPoint             pointNow;

@end

@implementation MOFeedsViewController

@synthesize tableView = _tableView;
@synthesize feedListSource = _feedListSource;

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    firstAppearance = YES;
    
    __weak MOFeedsViewController *weekSelf = self;
    
    [self.tableView addPullToRefreshWithActionHandler:^{
        [weekSelf  prepareData];
    }];
    
    [self.tableView addInfiniteScrollingWithActionHandler:^{
        [weekSelf loadMore];
    }];
    
    self.tableView.dataSource = self;
    self.tableView.delegate = self;
    
    [self setupAppearance];
    
    [self addObserver:self forKeyPath:@"activeTableCell" options:NSKeyValueObservingOptionInitial | NSKeyValueObservingOptionNew | NSKeyValueObservingOptionOld context:nil];
    
    //playbackManager = [[MOVideoPlayBackManager alloc] init];
    
    [self performSelector:@selector(triggerPullRefresh) withObject:nil afterDelay:0.5];
    
}


-(void)setupAppearance
{
    
    activityButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 58, 45)];
    [activityButton setImage:[UIImage imageNamed:@"nav-icon-activity"] forState:UIControlStateNormal];
    [activityButton setImage:[UIImage imageNamed:@"nav-icon-activity-prs"] forState:UIControlStateHighlighted];
    [activityButton addTarget:self action:@selector(gotoActivity) forControlEvents:UIControlEventTouchUpInside];
    
    self.navigationItem.leftBarButtonItem.customView = activityButton;
    
    recordButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 58, 45)];
    
    [recordButton setImage:[UIImage imageNamed:@"nav-icon-add"] forState:UIControlStateNormal];
    [recordButton setImage:[UIImage imageNamed:@"nav-icon-add-prs"] forState:UIControlStateHighlighted];
    
    [recordButton addTarget:self action:@selector(gotoRecord) forControlEvents:UIControlEventTouchUpInside];
    
    self.navigationItem.rightBarButtonItem.customView = recordButton;
    
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
}


-(void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    NSLog(@"view DidAppear ======================");
    
    if (self.activeTableCell) {
        [self.activeTableCell startPlay];
    }
}

-(void)triggerPullRefresh
{
    [self.tableView triggerPullToRefresh];
    
}


-(void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    if (self.activeTableCell && [self.activeTableCell isKindOfClass:[MOVideoPlayer_AVPlayer class]]) {
        [self.activeTableCell cleanupMoviePlayer];
        //[playbackManager stopPost:self.activeTableCell.post sender:self.activeTableCell];
        //[playbackManager cleanupPlayBackManager];
    }
    
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}




#pragma mark prepare

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"recordVideoViewSegue"]) {
        if ([sender isKindOfClass:[self class]]) {
            if (self.activeTableCell && [self.activeTableCell isKindOfClass:[MOVideoPlayer_AVPlayer class]]) {
                [self.activeTableCell cleanupMoviePlayer];
               
            }
        }
    } else if ([segue.identifier isEqualToString:@"showComments"]){
        MOCommentListViewController *vc = (id)segue.destinationViewController;
        vc.post = sender;
        vc.hidesBottomBarWhenPushed = YES;
    
    } else if([segue.identifier isEqualToString:@"showUserProfile"]){
        MOProfileViewController *vc = (id)segue.destinationViewController;
        vc.person = sender;
        vc.hidesBottomBarWhenPushed = YES;
    }
}



#pragma mark - user Actions



-(NSMutableArray*)feedListSource
{
    
    if (!_feedListSource) {
        _feedListSource = [Utils loadDataFrom:kFeedListSourceCacheFilename];
        if (!_feedListSource) {
            _feedListSource = [NSMutableArray array];
        
        }
    }
    
    return _feedListSource;
}



- (void)prepareData {
    
    __weak MOFeedsViewController *weakSelf = self;
    
    [MOClient fetchFeedsWithUserId:[[MOAuthEngine sharedAuthEngine].currentUser id]
                              page:0
                  withContinuation:^(BOOL success, int nxtPage, NSArray *array) {
                      if (success) {
                          nextPage = nxtPage;
                          
                          weakSelf.feedListSource = [NSMutableArray array];
                          [weakSelf.feedListSource addObjectsFromArray:array];
                          
                      }
                      
                      dispatch_async(dispatch_get_main_queue(), ^{
                          if (success) {
                              [_tableView reloadData];
                              
                             
                              [Utils saveData:weakSelf.feedListSource to:kFeedListSourceCacheFilename];
                          }
                          [weakSelf.tableView.pullToRefreshView stopAnimating];
                      });
                  }];
}

- (void)loadMore {
    
    __weak MOFeedsViewController *weakSelf = self;
    
    [MOClient fetchFeedsWithUserId:[[MOAuthEngine sharedAuthEngine].currentUser id]
                              page:nextPage
                  withContinuation:^(BOOL success, int nxtPage, NSArray *array) {
                      if (success) {
                          nextPage = nxtPage;
                          
                          if (!weakSelf.feedListSource) {
                              weakSelf.feedListSource = [NSMutableArray array];
                          }
                          [weakSelf.feedListSource addObjectsFromArray:array];
        
                      }
     
                      dispatch_async(dispatch_get_main_queue(), ^{
                            if (success) {
                                [_tableView reloadData];
            
                            }
                            [weakSelf.tableView.infiniteScrollingView stopAnimating];
        
                        });
     
                  }];
}



#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{

    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{

    // Return the number of rows in the section.
    return self.feedListSource.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    MOVideoPlayer_AVPlayer *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    
    if (cell == nil) {
        cell = [[MOVideoPlayer_AVPlayer alloc] initWithStyle:UITableViewCellStyleDefault
                                      reuseIdentifier:CellIdentifier];
        
    }
    
    Post *post = self.feedListSource[indexPath.row];
    
    cell.post = post;
    
    __weak MOFeedsViewController *weakSelf = self;
    
    if (cell.portraitTouched == nil) {
        cell.portraitTouched = ^(id sender){
            MOFeedsViewController *strongSelf = weakSelf;
            if (strongSelf) {
                MOVideoPlayer_AVPlayer *theCell = sender;
                [strongSelf performSegueWithIdentifier:@"showUserProfile" sender:theCell.post.user];
            }
        };
    }
    
    if (cell.commentTouched == nil) {
        cell.commentTouched = ^(id sender){
            MOFeedsViewController *strongSelf = weakSelf;
            if (strongSelf) {
                MOVideoPlayer_AVPlayer *theCell = sender;
                [strongSelf performSegueWithIdentifier:@"showComments" sender:theCell.post];
            }
        };
    }
    
    if (cell.likeTouched == nil) {
        cell.likeTouched = ^(id sender){
            MOFeedsViewController *strongSelf = weakSelf;
            if (strongSelf) {
                
                MOVideoPlayer_AVPlayer *theCell = sender;
                if (theCell.userLikeButton.selected) {
                    [MOClient unlikePost:[[MOAuthEngine sharedAuthEngine] currentUser] post:theCell.post
                        withContinuation:^(BOOL success) {
                            if (success) {
                                [theCell updateLike:theCell.post.user];
                            }
                        }];
                } else {
                    [MOClient likePost:[[MOAuthEngine sharedAuthEngine] currentUser] post:theCell.post
                      withContinuation:^(BOOL success) {
                          if (success) {
                              [theCell updateLike:theCell.post.user];
                          }
                        
                    }];
                }
            }
        };
    }
     
     
    
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    return 432;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    // do nothing
}

#pragma mark - Table view delegate




- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    
    [self checkActiveCell:scrollView];
}



- (void)scrollViewWillBeginDecelerating:(UIScrollView *)scrollView
{
    self.pointNow = scrollView.contentOffset;
}


-(void)checkActiveCell:(UIScrollView *)scrollView
{
    
    /*
    if (fmodf(scrollView.contentOffset.y,5.0) != 2.0) {
       
        return;
    }
     
     */
    
    NSLog(@"scrollView.contentOffset.y  %f",scrollView.contentOffset.y);
    
    NSArray* cells = self.tableView.visibleCells;
    
    NSUInteger cellCount = [cells count];
    
    if (cellCount == 0) {
        return;
    }
    
    if (cellCount == 1) {
        if (self.activeTableCell != cells[0]) {
            self.activeTableCell = cells[0];
        }
        return;
    }
    
    if (cellCount >= 2) {
        
        firstCell = self.tableView.visibleCells[0];
        
        if (scrollView.contentOffset.y > self.pointNow.y) {
            
            if (scrollView.contentOffset.y >= firstCell.frame.origin.y + 340) {
                if (self.activeTableCell != self.tableView.visibleCells[1]) {
                    self.activeTableCell = self.tableView.visibleCells[1];
                    
                    //[playbackManager playPost:self.activeTableCell.post sender:self.activeTableCell];
                    //NSLog(@"activeTable Cell change");
                }
                
            }
        } else  {
            if (scrollView.contentOffset.y < firstCell.frame.origin.y + 340) {
                if (self.activeTableCell != self.tableView.visibleCells[0]) {
                    self.activeTableCell = self.tableView.visibleCells[0];
                    //[playbackManager playPost:self.activeTableCell.post sender:self.activeTableCell];
                    //NSLog(@"activeTable Cell change");
                }
            }
            
        }
        
    }
    
}


-(void)gotoActivity
{
    UINavigationController *nc = [self.storyboard instantiateViewControllerWithIdentifier:@"activityNavigation"];
    nc.modalPresentationStyle = UIModalTransitionStylePartialCurl;
    
    [self.navigationController presentViewController:nc animated:YES completion:nil];

}


-(void)gotoRecord
{
    UINavigationController *nc = [self.storyboard instantiateViewControllerWithIdentifier:@"recordNavigation"];
    nc.modalPresentationStyle = UIModalTransitionStylePartialCurl;
    
    [self.navigationController presentViewController:nc animated:YES completion:nil];
}



-(void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context{
    
    
    dispatch_async(dispatch_get_main_queue(), ^{
        
        id newItem = [change objectForKey:NSKeyValueChangeNewKey];
        id oldCell = [change objectForKey:NSKeyValueChangeOldKey];
        if([oldCell isKindOfClass:[MOVideoPlayer_AVPlayer class]]) {
            [oldCell cleanupMoviePlayer];
            
        }
        
        if ([newItem isKindOfClass:[MOVideoPlayer_AVPlayer class]]) {
            [(MOVideoPlayer_AVPlayer*)newItem startPlay];
            //[playbackManager playPost:[(MOVideoPlayCell*)newItem post] sender:(MOVideoPlayCell*)newItem];
            
        }
        
        
    });
    
    

}
 


@end
