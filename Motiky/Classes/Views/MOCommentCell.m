//
//  MOCommentCell.m
//  Motiky
//
//  Created by notedit on 4/28/13.
//  Copyright (c) 2013 notedit. All rights reserved.
//

#import "MOCommentCell.h"
#import "UIImageView+WebCache.h"
#import <NSAttributedString+Attributes.h>

@implementation MOCommentCell

@synthesize comment = _comment;
@synthesize userPhotoImage = _userPhotoImage;
@synthesize dateLabel = _dateLabel;
@synthesize commentContentLabel = _commentContentLabel;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
    }
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

+(CGFloat)heightOfComment:(Comment *)comment withTextConstrainedToWidth:(CGFloat)width
{
    NSString *commentString = [NSString stringWithFormat:@"%@ %@",comment.user.username,comment.content];
    NSMutableAttributedString *text = [NSMutableAttributedString attributedStringWithString:commentString];
    
    [text setFont:[UIFont systemFontOfSize:12]];
    [text setFont:[UIFont boldSystemFontOfSize:12] range:NSMakeRange(0, comment.user.username.length)];
    
    CGSize size = [text sizeConstrainedToSize:CGSizeMake(width, CGFLOAT_MAX)];
    
    return size.height;
}


-(void)setComment:(Comment *)comment
{
    _comment = comment;
    
    NSString *commentString = [NSString stringWithFormat:@"%@ %@",comment.user.username,comment.content];
    NSMutableAttributedString *text = [NSMutableAttributedString attributedStringWithString:commentString];
    
    
    [text setFont:[UIFont systemFontOfSize:12]];
    [text setTextColor:[UIColor blackColor]];
    [text setFont:[UIFont boldSystemFontOfSize:12] range:NSMakeRange(0, comment.user.username.length)];
    
    self.commentContentLabel.attributedText = text;
 //   self.commentContentLabel.numberOfLines = 0;
//    self.commentContentLabel.text = @"fjskdfjdskf";
//    self.commentContentLabel.backgroundColor = [UIColor redColor];
    
    [self.userPhotoImage setImageWithURL:[NSURL URLWithString:comment.user.photo_url] placeholderImage:nil];
    
    [self updateAge];
    
}

-(void)updateAge
{
    
    NSDate *dateCreate = nil;
    if ([self.comment.date_create isKindOfClass:[NSString class]]) {
        dateCreate = [[Comment dateFormatter] dateFromString:(NSString*)_comment.date_create];
    } else {
        dateCreate = _comment.date_create;
    }
    
    NSTimeInterval age = [[NSDate date] timeIntervalSinceDate:dateCreate];
    
    NSTimeInterval refreshIn = 0;
    
    if (isnan(age) || age < 0) {
        self.dateLabel.text = @"--";
    } else if (age < 60) {
        self.dateLabel.text = [NSString stringWithFormat:@"%d 秒前",(int)age];
        refreshIn = 1.0;
    } else if (age < 60*60) {
        self.dateLabel.text = [NSString stringWithFormat:@"%d 分钟前",(int)(age/60)];
        refreshIn = 60;
    } else if(age < 60*60*24){
        self.dateLabel.text = [NSString stringWithFormat:@"%d 小时前",(int)(age/60/60)];
    } else {
        self.dateLabel.text = [NSString stringWithFormat:@"%d 天前",(int)(age/60/60/24)];
    }

    if(refreshIn){
        __weak MOCommentCell *cell = self;
        Comment *comment = self.comment;
        int64_t delayInSeconds = refreshIn;
        dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, delayInSeconds * NSEC_PER_SEC);
        dispatch_after(popTime, dispatch_get_main_queue(), ^{
            if(cell){
                if(cell.comment.id == comment.id){
                    [cell updateAge];
                }
            }
        });
    }

}


-(void)layoutSubviews
{
    [super layoutSubviews];
}

-(void)drawRect:(CGRect)rect
{
    CGContextRef c = UIGraphicsGetCurrentContext();
    
    CGFloat onePixel = 1.0 / [[UIScreen mainScreen] scale];
    CGFloat halfPixel = onePixel/2.0;
    
    if (self.backgroundColor) {
        [self.backgroundColor setFill];
        CGContextFillRect(c, rect);
    }
    
    [[UIColor colorWithWhite:183.0/255.0 alpha:1.000] setStroke];
    CGContextSetLineWidth(c, onePixel);
    
    
    CGContextMoveToPoint(c, rect.origin.x, rect.origin.y + rect.size.height - onePixel + halfPixel);
    
    CGContextAddLineToPoint(c, rect.origin.x + rect.size.width, rect.origin.y + rect.size.height - onePixel + halfPixel);
    
    CGContextDrawPath(c, kCGPathStroke);
}

@end










