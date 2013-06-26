//
//  MOExploreViewController.m
//  Motiky
//
//  Created by notedit on 3/22/13.
//  Copyright (c) 2013 notedit. All rights reserved.
//

#import "UIImageView+WebCache.h"
#import "MOExploreViewController.h"
#import "UIScrollView+SVPullToRefresh.h"
#import "KKGridView.h"
#import "Utils.h"
#import "MOClient.h"
#import "MOAuthEngine.h"
#import "MOGridViewCell.h"
#import "MOPostListViewController.h"

@interface MOExploreViewController () <KKGridViewDelegate,KKGridViewDataSource>
{
    KKGridView *gView;
    
    NSArray *tagList;
}

@end

@implementation MOExploreViewController

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
    
    gView = [[KKGridView alloc] initWithFrame:self.view.bounds];
    gView.autoresizingMask = UIViewAutoresizingFlexibleHeight;
    gView.dataSource = self;
    gView.delegate = self;
    gView.cellSize = CGSizeMake(145, 145);
    gView.cellPadding = CGSizeMake(10, 10);
    gView.backgroundColor = [UIColor clearColor];
    [self.view addSubview:gView];
    
    __weak MOExploreViewController *weakSelf = self;
    
    [gView addPullToRefreshWithActionHandler:^{
        [weakSelf refreshTags];
    }];
    
    [gView triggerPullToRefresh];
    
}


-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    

}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma mark - KKGridView

- (NSUInteger)gridView:(KKGridView *)gridView numberOfItemsInSection:(NSUInteger)section
{
    return [tagList count];
}

- (KKGridViewCell *)gridView:(KKGridView *)gridView cellForItemAtIndexPath:(KKIndexPath *)indexPath
{
    MOGridViewCell *cell = [MOGridViewCell cellForGridView:gridView];
    Tag  *tag = [tagList objectAtIndex:indexPath.index];
    
    if (tag.pic_url || tag.name) {
        
        cell.aTag = tag;
        
        [cell.tagImageView setImageWithURL:[NSURL URLWithString:tag.pic_url] placeholderImage:nil];
    }
    
    return cell;
}

-(void)gridView:(KKGridView *)gridView didDeselectItemAtIndexPath:(KKIndexPath *)indexPath
{
    // pushViewController
}

-(void)gridView:(KKGridView *)gridView didSelectItemAtIndexPath:(KKIndexPath *)indexPath
{
    // pushViewController
    
    Tag *tag = [tagList objectAtIndex:indexPath.index];
    [self pushViewControllerWithTag:tag];
    
}



#pragma mark - User actions

- (void) refreshTags{
    
    [MOClient fetchTagsWithContinuation:^(BOOL success, NSArray *tags) {
        
        if (success) {
            
            tagList = tags;
        }
        
        dispatch_async(dispatch_get_main_queue(), ^{
        
            [gView reloadData];
            [gView.pullToRefreshView stopAnimating];
        });
    }];
    
}

-(void)pushViewControllerWithTag:(Tag *)tag
{
    
    MOPostListViewController *postListVC = [self.storyboard instantiateViewControllerWithIdentifier:@"postListIdentity"];
    postListVC.tag = tag;
    postListVC.listType = kTagPostList;
    [self.navigationController pushViewController:postListVC animated:YES];
    
}




@end
















