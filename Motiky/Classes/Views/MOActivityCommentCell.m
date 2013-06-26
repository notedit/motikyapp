//
//  MOActivityCommentCell.m
//  Motiky
//
//  Created by notedit on 5/28/13.
//  Copyright (c) 2013 notedit. All rights reserved.
//

#import "MOActivityCommentCell.h"
#import <QuartzCore/QuartzCore.h>
#import "UIImageView+WebCache.h"
#import "User.h"

#import <NSAttributedString+Attributes.h>

static CGFloat const kEspressoDescriptionTextFontSize = 12;
static CGFloat const kAttributedTableViewCellVerticalMargin = 10.0f;


@implementation MOActivityCommentCell


@synthesize contentLabel = _contentLabel;
@synthesize contentText = _contentText;
@synthesize activity = _activity;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
        [self setup];
    }
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
    [self setup];
}

-(void)setup
{
    
    UITapGestureRecognizer *tapGR = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(portraitTap:)];
    [self.portraitView addGestureRecognizer:tapGR];
    
}


-(void)setContentText:(NSString *)text
{
    
    NSMutableAttributedString *string = [NSMutableAttributedString attributedStringWithString:text];
    [string setFont:[UIFont systemFontOfSize:12]];
    
    self.contentLabel.attributedText = string;
    
}

-(void)setActivity:(Activity *)activity
{
    _activity = activity;
    
    [self.portraitView setImageWithURL:[NSURL URLWithString:activity.user.photo_url] placeholderImage:nil];
    
    [self updateAge];
}


-(void)updateAge
{
    
    NSDate *dateCreate = nil;
    if ([self.activity.date_create isKindOfClass:[NSString class]]) {
        dateCreate = [[Activity dateFormatter] dateFromString:(NSString*)_activity.date_create];
    } else {
        dateCreate = _activity.date_create;
    }
    
    
    NSTimeInterval age = [[NSDate date] timeIntervalSinceDate:dateCreate];
    
    NSTimeInterval refreshIn = 0;
    
    if (isnan(age) || age < 0) {
        self.timeLable.text = @"--";
    } else if (age < 60) {
        self.timeLable.text = [NSString stringWithFormat:NSLocalizedString(@"%d seconds ago", @""), (int)age];
        refreshIn = 1.0;
    } else if (age < 60*60) {
        self.timeLable.text = [NSString stringWithFormat:NSLocalizedString(@"%d minutes ago", @""), (int)(age/60.0)];
        refreshIn = 60.0;
    } else if (age < 60*60*24) {
        self.timeLable.text = [NSString stringWithFormat:NSLocalizedString(@"%d hours ago", @""), (int)(age/(60.0*60.0))];
    } else {
        self.timeLable.text = [NSString stringWithFormat:NSLocalizedString(@"%d days ago", @""), (int)(age/(60.0*60.0*24.0))];
    }
    
    if (refreshIn) {
        __weak MOActivityCommentCell *cell = self;
        Activity *activity = self.activity;
        int64_t delayInSeconds = refreshIn;
        dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, delayInSeconds * NSEC_PER_SEC);
        dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
            if (cell) {
                if (cell.activity.id == activity.id ) {
                    [cell updateAge];
                }
            }
        });
    }
}


+(CGFloat)heightOfText:(NSString *)text
{
    NSMutableAttributedString *string = [NSMutableAttributedString attributedStringWithString:text];
    [string setFont:[UIFont systemFontOfSize:12]];
    CGSize size =  [string sizeConstrainedToSize:CGSizeMake(260.0f, CGFLOAT_MAX)];
    return size.height;
}




@end
