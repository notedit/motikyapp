//
//  MOActivityCell.m
//  Motiky
//
//  Created by notedit on 4/22/13.
//  Copyright (c) 2013 notedit. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>
#import "MOActivityCell.h"
#import "UIImageView+WebCache.h"

#import <NSAttributedString+Attributes.h>
#import "User.h"
#import "Post.h"
#import "Activity.h"

static CGFloat const kEspressoDescriptionTextFontSize = 12;
static CGFloat const kAttributedTableViewCellVerticalMargin = 10.0f;



@implementation MOActivityCell

@synthesize contentLabel = _contentLabel;
@synthesize contentText = _contentText;
@synthesize activity = _activity;
@synthesize postImageView = _postImageView;




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
    [super awakeFromNib];
    [self setup];

}

-(void)setup
{
    self.contentLabel.lineBreakMode = NSLineBreakByWordWrapping;
    self.contentLabel.numberOfLines = 0;

    
    UITapGestureRecognizer *tapGR = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(portraitTap:)];
    [self.portraitView addGestureRecognizer:tapGR];

    
}

-(void)portraitTap:(UITapGestureRecognizer *)tapGR
{
    if (self.portraitTouched) {
        self.portraitTouched();
    }
}



- (void)setContentText:(NSString *)text {
    
    //[self updateAge];
}


-(void)setActivity:(Activity *)activity
{
    _activity = activity;
    
    self.contentLabel.lineBreakMode = NSLineBreakByCharWrapping;
    self.contentLabel.numberOfLines = 0;
    
    NSMutableAttributedString *string = nil;
    
    [self.portraitView setImageWithURL:[NSURL URLWithString:activity.user.photo_url] placeholderImage:nil];
    
    if ([activity.atype isEqualToString:@"follow"]) {
        NSString *text = [NSString stringWithFormat:@"%@ 关注了你",activity.user.username];
        string = [NSMutableAttributedString attributedStringWithString:text];
        [string setFont:[UIFont systemFontOfSize:14]];
        
        self.contentLabel.attributedText = string;
    } else if ([activity.atype isEqualToString:@"comment"]) {
        NSString  *text = [NSString stringWithFormat:@"%@ 回复了你:%@",activity.user.username,activity.comment.content];
        
        string = [NSMutableAttributedString attributedStringWithString:text];
        [string setFont:[UIFont systemFontOfSize:14]];
        
        self.contentLabel.attributedText = string;
        
        [self.postImageView setImageWithURL:[NSURL URLWithString:activity.post.pic_small] placeholderImage:nil];

        
    } else if ([activity.atype isEqualToString:@"like"]){
        NSString *text = [NSString stringWithFormat:@"%@ 喜欢了你的视频",activity.user.username];
        
        string = [NSMutableAttributedString attributedStringWithString:text];
        [string setFont:[UIFont systemFontOfSize:14]];
        
        self.contentLabel.attributedText = string;
        
        [self.postImageView setImageWithURL:[NSURL URLWithString:activity.post.pic_small] placeholderImage:nil];
        
    }
    
    CGRect  currentFrame = self.contentLabel.frame;
    CGSize size =  [string sizeConstrainedToSize:CGSizeMake(200.0f, CGFLOAT_MAX)];
    currentFrame.size.height = size.height;
    
    self.contentLabel.frame = currentFrame;
    
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
        __weak MOActivityCell *cell = self;
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


+(CGFloat)heightOfText:(NSString *)text {
    NSMutableAttributedString *string = [NSMutableAttributedString attributedStringWithString:text];
    [string setFont:[UIFont systemFontOfSize:14]];
    CGSize size =  [string sizeConstrainedToSize:CGSizeMake(200.0f, CGFLOAT_MAX)];
    return size.height;
}

-(void)layoutSubviews
{
    [super layoutSubviews];
    
}


@end
