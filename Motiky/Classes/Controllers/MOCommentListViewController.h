//
//  MOCommentListViewController.h
//  Motiky
//
//  Created by notedit on 4/30/13.
//  Copyright (c) 2013 notedit. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Post.h"

@interface MOCommentListViewController : UIViewController

@property (strong, nonatomic) IBOutlet UITableView *tableView;

@property (strong,nonatomic) Post *post;
@property (strong, nonatomic) IBOutlet UITextField *commentTextField;
@property (strong, nonatomic) IBOutlet UIView *commentView;

- (IBAction)addComment:(id)sender;
@end
