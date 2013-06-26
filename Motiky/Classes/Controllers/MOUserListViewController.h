//
//  MOUserListViewController.h
//  Motiky
//
//  Created by notedit on 4/29/13.
//  Copyright (c) 2013 notedit. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "User.h"

typedef enum {
    KFollowing = 1,
    kFollier = 2,
} MOUserListType;

@interface MOUserListViewController : UIViewController


@property (strong, nonatomic) IBOutlet UITableView *tableView;
@property (strong,nonatomic) User *user;
@property (nonatomic) MOUserListType listType;


@end
