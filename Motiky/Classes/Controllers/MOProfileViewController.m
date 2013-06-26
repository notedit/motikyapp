//
//  MOProfileViewController.m
//  Motiky
//
//  Created by notedit on 3/22/13.
//  Copyright (c) 2013 notedit. All rights reserved.
//

#import "MOProfileViewController.h"
#import "MOLoginViewController.h"
#import "MOAppDelegate.h"
#import "MOAuthEngine.h"

#import "MOVideoPlayCell.h"
#import "MOClient.h"
#import "SVPullToRefresh.h"
#import "Utils.h"

#import "UIImageView+WebCache.h"

#import "MOPostListViewController.h"
#import "MOUserListViewController.h"
#import "MOVideoPlayer+AVPlayer.h"


NSString *kProfileViewControllerFromLeft = @"fromLeft";
NSString *kProfileViewControllerFromRight = @"fromRight";


@interface MOProfileViewController () <UITableViewDataSource,UITableViewDelegate>
{
    BOOL userPostLoad;
    
    int page;
    int totalPage;
    
    __weak UIView *contentView;
    __weak UIButton *selectedButton;
    
    MOVideoPlayer_AVPlayer *firstCell;
    
    MOUserListViewController *followingVC;
    MOUserListViewController *followerVC;
    MOPostListViewController *userPostVC;
    MOPostListViewController *userLikePostVC;
}


@property (nonatomic,strong) MOVideoPlayer_AVPlayer *activeTableCell;
@property CGPoint            pointNow;
@property (nonatomic,strong) NSMutableArray *postList;


@end

@implementation MOProfileViewController

@synthesize headerView = _headerView;
@synthesize userPhoto = _userPhoto;
@synthesize username = _username;
@synthesize userPost = _userPost;
@synthesize controlButton = _controlButton;
@synthesize userLikedPost = _userLikedPost;
@synthesize userFollower = _userFollower;
@synthesize userFollowing = _userFollowing;
@synthesize person = _person;
@synthesize tableView = _tableView;

@synthesize userPostCount = _userPostCount;
@synthesize userLikedPostCount = _userLikedPostCount;
@synthesize userFollowingCount = _userFollowingCount;
@synthesize userFollowerCount = _userFollowerCount;



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
    
    
    if (!self.person) {
        self.person = [[MOAuthEngine sharedAuthEngine] currentUser];
    }
    
    self.tableView.dataSource = self;
    self.tableView.delegate = self;
    
    __weak MOProfileViewController *weakSelf = self;
    
    [self.tableView addPullToRefreshWithActionHandler:^{
        
        [weakSelf loadPostList:NO];
        
    }];
    
    [self.tableView addInfiniteScrollingWithActionHandler:^{
        
        [weakSelf loadPostList:YES];
    }];
    
    
    UIImage *placeholderImage = [UIImage imageNamed:@"photoPlaceHolder.png"];
    [self.userPhoto setImageWithURL:[NSURL URLWithString:self.person.photo_url]
                   placeholderImage:placeholderImage];
    
    self.userPost.selected = YES;
    selectedButton = self.userPost;
    
    self.tableView.tableHeaderView = self.headerView;
    
    self.navigationItem.title = @"个人";
    
    
    
    
}

- (void)viewWillAppear:(BOOL)animated
{
    
    [super viewWillAppear:animated];
    
   
    
    self.username.text = self.person.username;
    self.userPostCount.text = [self.person.post_count stringValue];
    self.userLikedPostCount.text = [self.person.liked_post_count stringValue];
    self.userFollowingCount.text = [self.person.following_count stringValue];
    self.userFollowerCount.text = [self.person.follower_count stringValue];
    
    [self updateUserInfo];
    
    if (self.activeTableCell) {
        [self.activeTableCell startPlay];
    }
    
    
    [self loadPostList:NO];
    
    [self addObserver:self forKeyPath:@"activeTableCell" options:NSKeyValueObservingOptionInitial | NSKeyValueObservingOptionNew | NSKeyValueObservingOptionOld context:nil];

}

-(void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
}


-(void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    if (self.activeTableCell && [self.activeTableCell isKindOfClass:[MOVideoPlayer_AVPlayer class]]) {
        [self.activeTableCell cleanupMoviePlayer];
        //[playbackManager stopPost:self.activeTableCell.post sender:self.activeTableCell];
        //[playbackManager cleanupPlayBackManager];
    }
    
    [self removeObserver:self forKeyPath:@"activeTableCell"];

}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - tableview 


-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
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
    
    MOVideoPlayer_AVPlayer *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    
    if (cell == nil) {
        cell = [[MOVideoPlayer_AVPlayer alloc] initWithStyle:UITableViewCellStyleDefault
                                             reuseIdentifier:CellIdentifier];
    }
    
    Post *post = self.postList[indexPath.row];
    
    cell.post = post;
    
    __weak  MOProfileViewController *weakSelf = self;
    
    
    if (cell.portraitTouched == nil) {
        cell.portraitTouched = ^(id sender){
            MOProfileViewController *strongSelf = weakSelf;
            if (strongSelf) {
                MOVideoPlayer_AVPlayer *theCell = sender;
                [strongSelf performSegueWithIdentifier:@"showUserProfile" sender:theCell.post.user];
            }
        };
    }
    
    if (cell.commentTouched == nil) {
        cell.commentTouched = ^(id sender){
            MOProfileViewController *strongSelf = weakSelf;
            if (strongSelf) {
                MOVideoPlayer_AVPlayer *theCell = sender;
                [strongSelf performSegueWithIdentifier:@"showComments" sender:theCell.post];
            }
        };
    }
    
    if (cell.likeTouched == nil) {
        cell.likeTouched = ^(id sender){
            MOProfileViewController *strongSelf = weakSelf;
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


-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 420;
}

-(void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    [self checkActiveCell:scrollView];
}


- (void)scrollViewWillBeginDecelerating:(UIScrollView *)scrollView
{
    self.pointNow = scrollView.contentOffset;
}


#pragma mark - user action


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


- (IBAction)headerButtonTouch:(UIButton *)button {
    
    if (button == selectedButton) {
        return;
    }
    
    //selectedButton.selected = NO;
    //selectedButton = button;
    //button.selected = YES;
    
    switch (button.tag) {
        case 0:
            break;
            
        case 1:
            if (!userLikePostVC) {
                userLikePostVC = [self.storyboard instantiateViewControllerWithIdentifier:@"postListIdentity"];
                userLikePostVC.listType = kUserLikedPostList;
                userLikePostVC.user = self.person;
            }
            
            [self.navigationController pushViewController:userLikePostVC animated:YES];
            
            break;            
        case 2:
            
            if (!followingVC) {
                followingVC = [self.storyboard instantiateViewControllerWithIdentifier:@"userListViewIdentity"];
                followingVC.listType = KFollowing;
                followingVC.user = self.person;
            }
            
            [self.navigationController pushViewController:followingVC animated:YES];
            
            break;
        case 3:
            if (!followerVC) {
                followerVC = [self.storyboard instantiateViewControllerWithIdentifier:@"userListViewIdentity"];
                followerVC.listType = kFollier;
                followerVC.user = self.person;
            }
            
            [self.navigationController pushViewController:followerVC animated:YES];
            
            break;
        default:
            break;
    }
    
    
}



- (void)followToggle:(UIButton *)sender {
    
    if (sender.selected == NO) {
        
        __weak MOProfileViewController *weakSelf = self;
        [MOClient followUser:self.person withContinuation:^(BOOL success) {
            sender.enabled = YES;
            //sender.selected =
            
            MOProfileViewController *strongSelf = weakSelf;
            
            [strongSelf updateUserInfo];
        }];
        sender.selected = YES;
        sender.enabled = NO;
        
    } else {
        
        __weak MOProfileViewController *weakSelf = self;
        [MOClient unfollowUser:self.person withContinuation:^(BOOL success) {
            
        }];
        sender.selected = NO;
        sender.enabled = NO;
    }
}


/*
 
- (IBAction)logout:(id)sender {
    [[MOAuthEngine sharedAuthEngine] inValidAuth];
    
    MOLoginViewController *loginVC = [self.storyboard instantiateViewControllerWithIdentifier:@"MOLoginViewController"];
    
    UINavigationController *nVC = [[UINavigationController alloc] initWithRootViewController:loginVC];
    [self presentViewController:nVC animated:NO completion:nil];
    
}
 
 */





-(void)setPerson:(User *)person
{
    
    if (_person != person) {
        _person = person;
        
        if ([[MOAuthEngine sharedAuthEngine] currentUser].id == person.id) {
            
            [self.controlButton setTitle:@"设置" forState:UIControlStateNormal];
            
            self.controlButton.layer.cornerRadius = 5.0;
            
            [self.controlButton addTarget:self action:@selector(showSettings:) forControlEvents:UIControlEventTouchUpInside];
            
        } else {
            
            [self.controlButton setTitle:@"关注" forState:UIControlStateNormal];
            [self.controlButton setTitle:@"取消" forState:UIControlStateSelected];
            self.controlButton.layer.cornerRadius = 5.0;
            
            self.controlButton.selected = (YES == self.person.is_follow);
            
            [self.controlButton addTarget:self action:@selector(followToggle:) forControlEvents:UIControlEventTouchUpInside];
            
            
        }
        
        // 设置相关的设置和关注按钮
        
    }
}


-(IBAction)showSettings:(id)sender
{
    // 弹出设置页面

}

-(void)updateUserInfo
{
    // 更新用户相关的信息
    // user_following user_follower
    
    [MOClient fetchUserProfile:self.person withContinuation:^(BOOL success, NSDictionary *profileInfo) {
        
        if (success) {
            
            dispatch_async(dispatch_get_main_queue(), ^{
                
                self.username.text = self.person.username;
                self.userPostCount.text = [self.person.post_count stringValue];
                self.userLikedPostCount.text = [self.person.liked_post_count stringValue];
                self.userFollowingCount.text = [self.person.following_count stringValue];
                self.userFollowerCount.text = [self.person.follower_count stringValue];
                
            });
        }
        
    }];
    
}


-(void)loadPostList:(BOOL)isLoadMore
{
    
    if (!isLoadMore) {
        [MOClient fetchPostForUser:self.person page:1 continuation:^(BOOL success, int nextPage, NSArray *array) {
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
        [MOClient fetchPostForUser:self.person page:page continuation:^(BOOL success, int nextPage, NSArray *array) {
            
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


-(void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context{
    
        
        id newItem = [change objectForKey:NSKeyValueChangeNewKey];
        id oldCell = [change objectForKey:NSKeyValueChangeOldKey];
        if([oldCell isKindOfClass:[MOVideoPlayer_AVPlayer class]]) {
            [oldCell cleanupMoviePlayer];
            
        }
        
        if ([newItem isKindOfClass:[MOVideoPlayer_AVPlayer class]]) {
            [(MOVideoPlayer_AVPlayer*)newItem startPlay];
            //[playbackManager playPost:[(MOVideoPlayCell*)newItem post] sender:(MOVideoPlayCell*)newItem];
            
        }
    
}


@end
