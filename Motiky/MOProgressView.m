//
//  MOProgressView.m
//  testProgressBar
//
//  Created by notedit on 5/15/13.
//  Copyright (c) 2013 motiky. All rights reserved.
//

#import "MOProgressView.h"

@implementation MOProgressView
{
    //UIImageView *_trackView;
    //UIImageView *_progressbgView;
    //UIView  *_progressView;
}


@synthesize progress = _progress;

-(id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self commonInit];
    }
    
    return self;
}

-(void)awakeFromNib
{
    [self commonInit];
}

-(void)commonInit
{
    UIImage *progressImage = [UIImage imageNamed:@"full.png"];
    UIImage *trackImage = [UIImage imageNamed:@"progressbar.png"];
    _trackView = [[UIImageView alloc] initWithFrame:self.bounds];
    _trackView.image = trackImage;
    _progressbgView = [[UIImageView alloc] initWithFrame:self.bounds];
    _progressbgView.image = progressImage;
    _progressView = [[UIView alloc] initWithFrame:self.bounds];
    _progressView.clipsToBounds = YES;
    [_progressView addSubview:_progressbgView];
    [self addSubview:_trackView];
    
    [self addSubview:_progressView];
}


-(void)setProgress:(double)progress
{
    
    //if (_progress == progress) {
    //    return;
    //}
    _progress = progress;
    CGSize size = self.frame.size;
    _progressView.frame = CGRectMake(0, 0, size.width * progress, size.height);

}

@end
