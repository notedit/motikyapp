//
//  MOScrollView.m
//  Motiky
//
//  Created by notedit on 4/11/13.
//  Copyright (c) 2013 notedit. All rights reserved.
//

#import "MOScrollView.h"

NSString *ScrollEnableControlNotification = @"ScrollEnableControlNotification";

@implementation MOScrollView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        self.pagingEnabled = YES;
        self.showsVerticalScrollIndicator = NO;
        self.showsHorizontalScrollIndicator = NO;
        self.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        
        [self setupScrollEnableNotification];
    }
    return self;
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/


- (void)setupScrollEnableNotification
{
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(changeScroll:)
                                                 name:ScrollEnableControlNotification
                                               object:nil];
}


- (void)changeScroll:(NSNotification *)notification
{
    NSDictionary* userinfo = notification.userInfo;
    BOOL enable = [[userinfo objectForKey:@"scrollEnable"] boolValue] ? YES:NO;
    self.scrollEnabled = enable;
}


- (void)layoutSubviews {
    [super layoutSubviews];
    
    if (!_statusBarPageControl) {
        
        _statusBarPageControl = [[UIPageControl alloc] initWithFrame:[[UIApplication sharedApplication] statusBarFrame]];
        _statusBarPageControl.numberOfPages = (self.contentSize.width / self.frame.size.width);
        _statusBarPageControl.backgroundColor = [UIColor clearColor];
    }
    
}

- (void)setContentOffset:(CGPoint)contentOffset {
    [super setContentOffset:contentOffset];
    
    if (self.isTracking) {
        [self _setShowsPageControl:YES];
    }
    else if (!self.isDragging) {
        [self _setShowsPageControl:NO];
    }
    
    _statusBarPageControl.currentPage = (contentOffset.x + (self.frame.size.width / 2)) / (self.frame.size.width);
}


#pragma mark - Private methods

- (void)_setShowsPageControl: (BOOL)show {
    
    [UIView animateWithDuration:0.5 animations:^{
        [[UIApplication sharedApplication] setStatusBarHidden:show withAnimation:UIStatusBarAnimationFade];
        _statusBarPageControl.alpha = show;
        
        if (show) {
            [[[UIApplication sharedApplication] keyWindow] addSubview:_statusBarPageControl];
        }
        
    } completion:^(BOOL finished) {
        if (!show) {
            [_statusBarPageControl removeFromSuperview];
        }
    }];
}


-(void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:ScrollEnableControlNotification object:nil];
}

@end
