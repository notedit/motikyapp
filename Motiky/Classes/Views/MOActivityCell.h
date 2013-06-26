//
//  MOActivityCell.h
//  Motiky
//
//  Created by notedit on 4/22/13.
//  Copyright (c) 2013 notedit. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Activity.h"
#import <OHAttributedLabel.h>
#import <OHParagraphStyle.h>

@class OHAttributedLabel;

typedef void(^MOActivityCellBlock)(void);

@interface MOActivityCell : UITableViewCell


@property (nonatomic,weak) Activity *activity;

@property (strong,nonatomic) IBOutlet UIImageView  *postImageView;
@property (strong, nonatomic) IBOutlet UIImageView *portraitView;
@property (strong, nonatomic) IBOutlet UIImageView *portraitMask;
@property (strong, nonatomic) IBOutlet OHAttributedLabel *contentLabel;
@property (strong,nonatomic) IBOutlet UILabel *timeLable;
@property (strong, nonatomic) NSString *contentText;
@property (strong, nonatomic) NSDate *timestamp;

@property (copy,nonatomic) MOActivityCellBlock portraitTouched;

+ (CGFloat) heightOfText:(NSString *)text;

@end
