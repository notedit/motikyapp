//
//  MOActivityCommentCell.h
//  Motiky
//
//  Created by notedit on 5/28/13.
//  Copyright (c) 2013 notedit. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Activity.h"
#import <OHAttributedLabel.h>

typedef void(^MOActivityCellBlock)(void);

@interface MOActivityCommentCell : UITableViewCell

@property (nonatomic,weak) Activity *activity;
@property (strong, nonatomic) IBOutlet UIImageView *postImage;

@property (strong, nonatomic) IBOutlet UIImageView *portraitView;
@property (strong, nonatomic) IBOutlet UIImageView *portraitMask;
@property (strong, nonatomic) IBOutlet OHAttributedLabel *contentLabel;
@property (strong,nonatomic) IBOutlet UILabel *timeLable;
@property (strong, nonatomic) NSString *contentText;

@property (copy,nonatomic) MOActivityCellBlock portraitTouched;

+ (CGFloat) heightOfText:(NSString *)text;

@end
