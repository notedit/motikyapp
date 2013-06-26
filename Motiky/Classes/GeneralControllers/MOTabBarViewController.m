//
//  MOTabBarViewController.m
//  Motiky
//
//  Created by notedit on 3/22/13.
//  Copyright (c) 2013 notedit. All rights reserved.
//

#import "MOTabBarViewController.h"

@interface MOTabBarViewController ()

@end

@implementation MOTabBarViewController

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
    
    
    UITabBarItem *feedsItem = self.tabBar.items[0];
    [feedsItem setFinishedSelectedImage:[UIImage imageNamed:@"tab-icon-home-prs"] withFinishedUnselectedImage:[UIImage imageNamed:@"tab-icon-home"]];
    
    [feedsItem setTitlePositionAdjustment:UIOffsetMake(0, 0)];
    
    UITabBarItem *exploreItem = self.tabBar.items[1];
    [exploreItem setFinishedSelectedImage:[UIImage imageNamed:@"tab-icon-explore-prs"] withFinishedUnselectedImage:[UIImage imageNamed:@"tab-icon-explore"]];
    
    [exploreItem setTitlePositionAdjustment:UIOffsetMake(0, 0)];
    
    UITabBarItem *profileItem = self.tabBar.items[2];
    [profileItem setFinishedSelectedImage:[UIImage imageNamed:@"tab-icon-profile-prs"] withFinishedUnselectedImage:[UIImage imageNamed:@"tab-icon-profile"]];
    
    [profileItem setTitlePositionAdjustment:UIOffsetMake(0, 0)];
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
