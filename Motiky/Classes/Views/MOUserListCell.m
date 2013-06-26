//
//  MOUserListCell.m
//  Motiky
//
//  Created by notedit on 4/28/13.
//  Copyright (c) 2013 notedit. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>
#import "MOUserListCell.h"
#import "UIImageView+WebCache.h"
#import "User.h"

@implementation MOUserListCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
        [self setup];
    }
    return self;
}

-(void)awakeFromNib
{
    self.selectionStyle = UITableViewCellSelectionStyleNone;
    [self setup];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}


-(void)setup
{
    
    self.userFollowButton.layer.cornerRadius = 8.0;
    
    [self.userFollowButton setTitle:@"关注" forState:UIControlStateNormal];
    [self.userFollowButton setTitle:@"取消" forState:UIControlStateSelected];
    
    [self.userFollowButton addTarget:self action:@selector(followUserTouched:) forControlEvents:UIControlEventTouchUpInside];

    
}

-(void)setUser:(User *)user
{
    _user = user;
    
    [self.userPhotoImage setImageWithURL:[NSURL URLWithString:user.photo_url] placeholderImage:nil];
    self.userNameLabel.text = user.username;
    
        
    self.userFollowButton.selected = user.is_follow;
    
    
}

-(void)followUserTouched:(id)sender
{
    if (self.followUser) {
        self.followUser(self.user);
    }
}

@end
