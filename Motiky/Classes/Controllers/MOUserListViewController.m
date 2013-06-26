//
//  MOUserListViewController.m
//  Motiky
//
//  Created by notedit on 4/29/13.
//  Copyright (c) 2013 notedit. All rights reserved.
//

#import "MOUserListViewController.h"
#import "SVPullToRefresh.h"
#import "MOClient.h"
#import "MOAuthEngine.h"
#import "UIImageView+WebCache.h"
#import "MOUserListCell.h"

@interface MOUserListViewController () <UITableViewDataSource,UITableViewDelegate>
{
    int page;
    BOOL loaded;
}

@property(nonatomic,strong) NSMutableArray *userList;

@end

@implementation MOUserListViewController

@synthesize tableView = _tableView;
@synthesize userList = _userList;



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
    
    __weak MOUserListViewController *weakSelf = self;
    
    [self.tableView addPullToRefreshWithActionHandler:^{
        [weakSelf loadUserListWithListType:NO];
    }];
    
    [self.tableView addInfiniteScrollingWithActionHandler:^{
        [weakSelf loadUserListWithListType:YES];
    }];
    
    self.tableView.dataSource = self;
    self.tableView.delegate = self;
    
    loaded = NO;
    
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self.tableView triggerPullToRefresh];
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
    return self.userList.count;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    /*
    static NSString *meiyouIdentifier = @"meiyouCell";
    
    if (self.userList.count == 0 && loaded) {
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:meiyouIdentifier];
        return cell;
    }
     */
    
    static NSString *cellIdentifier = @"Cell";
    
    MOUserListCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (cell == nil) {
        cell = [[MOUserListCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
    }
    
    
    User *user = [self.userList objectAtIndex:[indexPath row]];
    cell.user = user;
    
    
    __weak MOUserListViewController *weakSelf = self;
    cell.followUser = ^(User *newUser){
        
               
        if (newUser.is_follow) {
            [MOClient unfollowUser:newUser withContinuation:^(BOOL success) {
                
                MOUserListViewController *strongSelf = weakSelf;
                [strongSelf.tableView reloadData];
                
            }];
            
        } else {
            
            [MOClient followUser:newUser withContinuation:^(BOOL success) {
                
                MOUserListViewController *strongSelf = weakSelf;
                [strongSelf.tableView reloadData];
                
            }];
        }
    };

    return cell;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 52;
}

#pragma mark - user actions

-(void)loadUserListWithListType:(BOOL)isLoadMore
{
    if (self.listType == kFollier) {
        if (!isLoadMore) {
            [MOClient fetchUserFollowerWithUserId:self.user.id page:1 withContinuation:^(BOOL success, int nextPage, NSArray *array) {
                if (success) {
                    page = nextPage;
                    _userList = [NSMutableArray arrayWithArray:array];
                }
                
                dispatch_async(dispatch_get_main_queue(), ^{
                
                    [_tableView.pullToRefreshView stopAnimating];
                    if (success) {
                        [_tableView reloadData];
                    }
                
                });
                
            }];
            
        } else {
            [MOClient fetchUserFollowerWithUserId:self.user.id page:page withContinuation:^(BOOL success, int nextPage, NSArray *array) {
                
                if (success) {
                    page = nextPage;
                    [_userList addObjectsFromArray:array];
                }
                
                dispatch_async(dispatch_get_main_queue(), ^{
                    [_tableView.infiniteScrollingView stopAnimating];
                    if (success) {
                        [_tableView reloadData];
                    }
                });
             
            }];
        }
        
    } else if(self.listType == KFollowing){
        
        if (!isLoadMore) {
            [MOClient fetchUserFollowingWithUserId:self.user.id page:1 withContinuation:^(BOOL success, int nextPage, NSArray *array) {
                
                if (success) {
                    page = nextPage;
                    _userList = [NSMutableArray arrayWithArray:array];
                }
                
                dispatch_async(dispatch_get_main_queue(), ^{
                    [_tableView.pullToRefreshView stopAnimating];
                    if (success) {
                        [_tableView reloadData];
                    }
                });
             
            }];
        } else {
            [MOClient fetchUserFollowingWithUserId:self.user.id page:page withContinuation:^(BOOL success, int nextPage, NSArray *array) {
                
                if (success) {
                    page = nextPage;
                    [_userList addObjectsFromArray:array];
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
