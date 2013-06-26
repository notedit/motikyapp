//
//  MOPostListViewController.m
//  Motiky
//
//  Created by notedit on 4/29/13.
//  Copyright (c) 2013 notedit. All rights reserved.
//

#import "MOPostListViewController.h"
#import "SVPullToRefresh.h"
#import "MOClient.h"
#import "MOAuthEngine.h"
#import "UIImageView+WebCache.h"
//#import "MOVideoPlayCell.h"
#import "MOVideoPlayer+AVPlayer.h"

@interface MOPostListViewController () <UITableViewDataSource,UITableViewDelegate>

@property (nonatomic,strong) MOVideoPlayer_AVPlayer *activeTableCell;
@property CGPoint            pointNow;
@property (nonatomic,strong) NSMutableArray *postList;

@end

@implementation MOPostListViewController

{
    
    int page;
    
    BOOL loaded;
    
    MOVideoPlayer_AVPlayer *firstCell;
}

@synthesize tableView = _tableView;
@synthesize postList = _postList;
@synthesize listType = _listType;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    
    self.tableView.dataSource = self;
    self.tableView.delegate = self;
    
    __weak MOPostListViewController *weakSelf = self;
    
    [self.tableView addPullToRefreshWithActionHandler:^{
        [weakSelf loadPostList:NO];
    }];
    
    [self.tableView addInfiniteScrollingWithActionHandler:^{
        [weakSelf loadPostList:YES];
        
    }];
    
    loaded = NO;
    
    [self addObserver:self forKeyPath:@"activeTableCell" options:NSKeyValueObservingOptionInitial | NSKeyValueObservingOptionNew | NSKeyValueObservingOptionOld context:nil];


}

-(void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [self.tableView triggerPullToRefresh];
}




-(void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    if (self.activeTableCell && [self.activeTableCell isKindOfClass:[MOVideoPlayer_AVPlayer class]]) {
        [(MOVideoPlayer_AVPlayer *)self.activeTableCell cleanupMoviePlayer];
    }
    
    //[self removeObserver:self forKeyPath:@"activeTableCell"];
}

-(void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - delegate 

-(NSInteger) numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.postList.count > 0 ? self.postList.count : 0;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    static NSString *CellIdentifier = @"Cell";
    
    MOVideoPlayer_AVPlayer *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[MOVideoPlayer_AVPlayer alloc] initWithStyle:UITableViewCellStyleDefault
                                      reuseIdentifier:CellIdentifier];
    }
    
    Post *post = self.postList[indexPath.row];
    cell.post = post;

    return cell;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 420;
}


- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    
    [self checkActiveCell:scrollView];
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    
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



-(void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    id newItem = [change objectForKey:NSKeyValueChangeNewKey];

        
    id oldCell = [change objectForKey:NSKeyValueChangeOldKey];
    if (oldCell == (id)[NSNull null]) {
            
    } else if([oldCell isKindOfClass:[MOVideoPlayer_AVPlayer class]]) {
        [oldCell cleanupMoviePlayer];
            
    }
        
    if ([newItem isKindOfClass:[MOVideoPlayer_AVPlayer class]]) {
        [(MOVideoPlayer_AVPlayer*)newItem startPlay];
    }
        
    
}

#pragma mark - user actions




-(void)loadPostList:(BOOL)isLoadMore
{
    if (self.listType == kTagPostList) {
        
        if (!isLoadMore) {
            [MOClient fetchTagWithTag:self.tag page:1 withContinuation:^(BOOL success, int nextPage, NSArray *array) {
                
                if (success) {
                    page = nextPage;
                    _postList = [NSMutableArray arrayWithArray:array];
                }
                
                dispatch_async(dispatch_get_main_queue(), ^{
                    [_tableView.pullToRefreshView stopAnimating];
                    if (success) {
                        [_tableView reloadData];
                    }
                });
                
            }];
        } else {
            [MOClient fetchTagWithTag:self.tag page:page withContinuation:^(BOOL success, int nextPage, NSArray *array) {
                
                if (success) {
                    page = nextPage;
                    [_postList addObjectsFromArray:array];
                }
                
                dispatch_async(dispatch_get_main_queue(), ^{
                    [_tableView.infiniteScrollingView stopAnimating];
                    if (success) {
                        [_tableView reloadData];
                    }
                });
                
            }];
        }
        
    } else if(self.listType == kUserPostList){
        
        if (!isLoadMore) {
            [MOClient fetchPostForUser:self.user page:1 continuation:^(BOOL success, int nextPage, NSArray *array) {
                
                if (success) {
                    page = nextPage;
                    _postList = [NSMutableArray arrayWithArray:array];
                }
                
                dispatch_async(dispatch_get_main_queue(), ^{
                    [_tableView.pullToRefreshView stopAnimating];
                    if (success) {
                        [_tableView reloadData];
                    }
                });
             
            }];
            
        } else {
            
            [MOClient fetchPostForUser:self.user page:page continuation:^(BOOL success, int nextPage, NSArray *array) {
                
                if (success) {
                    page = nextPage;
                    [_postList addObjectsFromArray:array];
                }
                
                dispatch_async(dispatch_get_main_queue(), ^{
                    [_tableView.infiniteScrollingView stopAnimating];
                    if (success) {
                        [_tableView reloadData];
                    }
                });
                
            }];
            
        }
        
    } else if(self.listType == kUserLikedPostList) {
        
        if (!isLoadMore) {
            
            [MOClient fetchLikedPostsWithUserId:self.user.id page:1 withContinuation:^(BOOL success, int nextPage, NSArray *array) {
                
                if (success) {
                    page = nextPage;
                    _postList = [NSMutableArray arrayWithArray:array];
                }
                
                dispatch_async(dispatch_get_main_queue(), ^{
                    [_tableView.pullToRefreshView stopAnimating];
                    if (success) {
                        [_tableView reloadData];
                    }
                });
                
            }];
            
        } else {
            
            [MOClient fetchLikedPostsWithUserId:self.user.id page:page withContinuation:^(BOOL success, int nextPage, NSArray *array) {
                
                if (success) {
                    page = nextPage;
                    [_postList addObjectsFromArray:array];
                }
                
                dispatch_async(dispatch_get_main_queue(), ^{
                    [_tableView.infiniteScrollingView stopAnimating];
                    if (success) {
                        [_tableView reloadData];
                    }
                });
            }];
        }
    }

}


@end














