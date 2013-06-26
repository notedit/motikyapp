//
//  MOFollowerViewController.m
//  Motiky
//
//  Created by notedit on 4/27/13.
//  Copyright (c) 2013 notedit. All rights reserved.
//

#import "MOFollowerViewController.h"
#import "SVPullToRefresh.h"
#import "MOClient.h"
#import "MOAuthEngine.h"
#import "UIImageView+WebCache.h"


@interface MOFollowerViewController ()<UITableViewDataSource,UITableViewDelegate>
{
    int page;
    BOOL loaded;
}

@property(nonatomic,strong) NSMutableArray *userList;

@end

@implementation MOFollowerViewController

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
    
    __weak MOFollowerViewController *weakSelf = self;
    
    [self.tableView addPullToRefreshWithActionHandler:^{
        
    }];
    
    [self.tableView addInfiniteScrollingWithActionHandler:^{
        
    }];
    
    self.tableView.dataSource = self;
    self.tableView.delegate = self;
    
    loaded = NO;
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self.tableView triggerInfiniteScrolling];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma mark  -  table view data source delegate

-(NSInteger) numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.userList.count == 0 && loaded ? 1:self.userList.count;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *meiyouIdentifier = @"meiyouCell";
    
    if (self.userList.count == 0 && loaded) {
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:meiyouIdentifier];
        return cell;
    }
    
    static NSString *cellIdentifier = @"followerCell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    
    if (self.userList.count > 0) {
        User *user = [self.userList objectAtIndex:[indexPath row]];
        // to do some info set
    }
    return cell;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 52;
}


#pragma mark - user actions

-(void) loadUser
{
    [MOClient fetchUserFollowerWithUserId:[[MOAuthEngine sharedAuthEngine].currentUser id] page:1 withContinuation:^(BOOL success, int nextPage, NSArray *array) {
        if (success) {
            page = nextPage;
            
            _userList = [NSMutableArray array];
            [_userList addObjectsFromArray:array];
        }
        
        dispatch_async(dispatch_get_main_queue(), ^{
            if (success) {
                [_tableView reloadData];
            
            }
            [_tableView.pullToRefreshView stopAnimating];
        });
    }];
}

-(void)loadMoreUser
{
    [MOClient fetchUserFollowerWithUserId:[[MOAuthEngine sharedAuthEngine].currentUser id] page:page withContinuation:^(BOOL success, int nextPage, NSArray *array) {
        
        if (success) {
            page = nextPage;
            [_userList addObjectsFromArray:array];
        }
        
        dispatch_async(dispatch_get_main_queue(), ^{
            if (success) {
                [_tableView reloadData];
            }
            [_tableView.infiniteScrollingView stopAnimating];
        });
        
    }];
}

@end
