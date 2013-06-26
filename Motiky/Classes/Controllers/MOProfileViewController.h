//
//  MOProfileViewController.h
//  Motiky
//
//  Created by notedit on 3/22/13.
//  Copyright (c) 2013 notedit. All rights reserved.
//

#import <UIKit/UIKit.h>

@class User;

@interface MOProfileViewController : UIViewController

@property (strong, nonatomic) IBOutlet UITableView *tableView;

@property (strong, nonatomic) IBOutlet UIView *headerView;
@property (strong, nonatomic) IBOutlet UIImageView *userPhoto;
@property (strong, nonatomic) IBOutlet UILabel *username;
@property (strong, nonatomic) IBOutlet UIButton *controlButton;


@property (strong, nonatomic) IBOutlet UILabel *userPostCount;
@property (strong, nonatomic) IBOutlet UILabel *userLikedPostCount;
@property (strong, nonatomic) IBOutlet UILabel *userFollowingCount;
@property (strong, nonatomic) IBOutlet UILabel *userFollowerCount;



@property (strong, nonatomic) IBOutlet UIButton *userPost;

@property (strong, nonatomic) IBOutlet UIButton *userLikedPost;
@property (strong, nonatomic) IBOutlet UIButton *userFollowing;
@property (strong, nonatomic) IBOutlet UIButton *userFollower;

- (IBAction)headerButtonTouch:(UIButton *)sender;


- (IBAction)logout:(id)sender;

@property (strong,nonatomic) User *person;

@end
