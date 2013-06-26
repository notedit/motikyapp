//
//  MOPostListViewController.h
//  Motiky
//
//  Created by notedit on 4/29/13.
//  Copyright (c) 2013 notedit. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Tag.h"
#import "User.h"

typedef enum {
    kTagPostList = 1,
    kUserPostList = 2,
    kUserLikedPostList = 3,
} MOPostListType;

@interface MOPostListViewController : UIViewController

@property (strong,nonatomic) Tag *tag;
@property (strong,nonatomic) User *user;
@property (nonatomic) MOPostListType listType;

@property (strong, nonatomic) IBOutlet UITableView *tableView;

@end
