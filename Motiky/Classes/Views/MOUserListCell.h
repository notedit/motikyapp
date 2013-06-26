//
//  MOUserListCell.h
//  Motiky
//
//  Created by notedit on 4/28/13.
//  Copyright (c) 2013 notedit. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "User.h"

@interface MOUserListCell : UITableViewCell

@property (nonatomic,weak) User *user;

@property (strong, nonatomic) IBOutlet UIImageView *userPhotoImage;
@property (strong, nonatomic) IBOutlet UILabel *userNameLabel;
@property (strong, nonatomic) IBOutlet UIButton *userFollowButton;

@property (nonatomic,copy) void(^followUser)(User *);

@end
