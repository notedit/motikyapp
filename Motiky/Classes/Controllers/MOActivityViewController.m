//
//  MOActivityViewController.m
//  Motiky
//
//  Created by notedit on 3/22/13.
//  Copyright (c) 2013 notedit. All rights reserved.
//


#import "UIImageView+WebCache.h"
#import "MOActivityViewController.h"
#import "SVPullToRefresh.h"
#import "Utils.h"
#import "MOClient.h"
#import "MOAuthEngine.h"
#import "MOActivityCell.h"
#import "Activity.h"
#import "MOActivityLikeCell.h"
#import "MOActivityCommentCell.h"
#import "MOActivityCell.h"
#import "Comment.h"


@interface MOActivityViewController () <UITableViewDataSource,UITableViewDelegate>
{
    int theNextPage;
    
    BOOL loaded;
    
}

@property (nonatomic,strong) NSMutableArray     *activityListSource;

@end

@implementation MOActivityViewController

@synthesize activityListSource = _activityListSource;
@synthesize tableView = _tableView;

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
    
    __weak MOActivityViewController *weakSelf = self;
    
    [self.tableView addPullToRefreshWithActionHandler:^{
        [weakSelf reloadActivity];
    }];
    
    //[self.tableView addInfiniteScrollingWithActionHandler:^{
        
    //}];
    
    self.tableView.showsInfiniteScrolling = NO;
    
    self.tableView.dataSource = self;
    self.tableView.delegate = self;
    
    loaded = NO;
    
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self.tableView triggerPullToRefresh];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source delegate
-(NSInteger) numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.activityListSource.count == 0 && loaded ? 1 : self.activityListSource.count;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *meiyouIdentifier = @"meiyouCell";
    
    if (self.activityListSource.count == 0 && loaded) {
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:meiyouIdentifier];
        UILabel *label = (id)[cell viewWithTag:10000];
        UIActivityIndicatorView *indicator = (id)[cell viewWithTag:10001];
        
        label.text = @"没有新通知";
        [indicator stopAnimating];
        return cell;
    }
    
    static NSString *activityCell = @"activityCell";
    static NSString *activityLkeCell = @"activityLkeCell";
    static NSString *activityCommentCell = @"activityCommentCell";
    
    

   
    Activity *activity = [self.activityListSource objectAtIndex:indexPath.row];
     /*
    if ([activity.atype isEqualToString:@"comment"]) {
        
        MOActivityCommentCell *cell = [tableView dequeueReusableCellWithIdentifier:activityCommentCell];
        [cell setContentText:[self messageForActivity:activity]];
        [cell.portraitView setImageWithURL:[NSURL URLWithString:activity.user.photo_url]];
        cell.activity = activity;
        return cell;
            
    } else if ([activity.atype isEqualToString:@"like"]){
        
        MOActivityLikeCell *cell = [tableView dequeueReusableCellWithIdentifier:activityLkeCell];
        [cell setContentText:[self messageForActivity:activity]];
        [cell.portraitView setImageWithURL:[NSURL URLWithString:activity.user.photo_url]];
        cell.activity = activity;
        return cell;
        
        
    }*/
      
    
        
        MOActivityCell *cell = [tableView dequeueReusableCellWithIdentifier:activityCell];
        [cell setContentText:[self messageForActivity:activity]];
        [cell.portraitView setImageWithURL:[NSURL URLWithString:activity.user.photo_url]];
        cell.activity = activity;
    
        return cell;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (self.activityListSource.count == 0) return 56;
    
    Activity *activity = [self.activityListSource objectAtIndex:indexPath.row];
    CGFloat cellHeight = [MOActivityCell heightOfText:[self messageForActivity:activity]];
    return cellHeight + 40;
}


#pragma mark - table view delegate


#pragma mark - user actions

-(void)reloadActivity
{
    [MOClient fetchActivityWithUserId:[[MOAuthEngine sharedAuthEngine].currentUser id]
                     withContinuation:^(BOOL success, NSArray *array) {
                         
                         if (success) {
                             loaded = YES;
                             _activityListSource = [NSMutableArray arrayWithArray:array];
                         }
                         
                         dispatch_async(dispatch_get_main_queue(), ^{
                            [_tableView reloadData];
                            [_tableView.pullToRefreshView stopAnimating];
        
                        });
    
    }];
}


-(NSString*)messageForActivity:(Activity *)activity
{
    //NSString *who = @"你";
    
    NSLog(@"%@,%@",activity.user,[activity.user class]);
    if ([activity.atype isEqualToString:@"like"]) {
        User *user = (User*)activity.user;
        NSString *message = [[NSString stringWithFormat:@"%@: 喜欢了你的视频",user.username] precomposedStringWithCompatibilityMapping];
        return message;
    } else if([activity.atype isEqualToString:@"follow"]){
        NSString *message = [[NSString stringWithFormat:@"%@: 关注了你",activity.user.username] precomposedStringWithCompatibilityMapping];
        return message;
    } else if ([activity.atype isEqualToString:@"comment"]){
        NSString *message = [[NSString stringWithFormat:@"%@: 回复了你 %@",activity.user.username,activity.comment.content]
                             precomposedStringWithCompatibilityMapping];
        return message;
    }
    
    return @"";
}



- (IBAction)dismissActivity:(id)sender {
    [self.navigationController dismissViewControllerAnimated:YES completion:nil];
}
@end
