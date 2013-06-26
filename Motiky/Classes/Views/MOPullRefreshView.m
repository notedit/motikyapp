//
//  MOPullRefreshView.m
//  Motiky
//
//  Created by notedit on 4/18/13.
//  Copyright (c) 2013 notedit. All rights reserved.
//

#define TEXT_COLOR	 [UIColor colorWithRed:87.0/255.0 green:108.0/255.0 blue:137.0/255.0 alpha:1.0]
#define FLIP_ANIMATION_DURATION 0.18f

#import <QuartzCore/QuartzCore.h>
#import "MOPullRefreshView.h"

@interface MOPullRefreshView ()

@property (nonatomic) MOPullRefreshState state;
@property (nonatomic, strong) UILabel *lastUpdatedLabel;
@property (nonatomic, strong) UILabel *statusLabel;
@property (nonatomic, strong) CALayer *arrowImage;
@property (nonatomic, strong) UIActivityIndicatorView *activityView;

@end

@implementation MOPullRefreshView


@synthesize delegate = _delegate;
@synthesize state = _state;
@synthesize lastUpdatedLabel = _lastUpdatedLabel;
@synthesize statusLabel = _statusLabel;
@synthesize arrowImage = _arrowImage;
@synthesize activityView = _activityView;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        self.autoresizingMask = UIViewAutoresizingFlexibleWidth;
        //        self.backgroundColor = [UIColor colorWithRed:226.0/255.0 green:231.0/255.0 blue:237.0/255.0 alpha:1.0];
        self.backgroundColor = [UIColor clearColor];
        
        self.lastUpdatedLabel = [[UILabel alloc] initWithFrame:CGRectMake(0.0f, frame.size.height - 30.0f, self.frame.size.width, 20.0f)];
		self.lastUpdatedLabel.autoresizingMask = UIViewAutoresizingFlexibleWidth;
		self.lastUpdatedLabel.font = [UIFont systemFontOfSize:12.0f];
		self.lastUpdatedLabel.textColor = TEXT_COLOR;
        self.lastUpdatedLabel.shadowColor = [UIColor colorWithWhite:0.9f alpha:1.0f];
        self.lastUpdatedLabel.shadowOffset = CGSizeMake(0.0f, 1.0f);
		self.lastUpdatedLabel.backgroundColor = [UIColor clearColor];
		//self.lastUpdatedLabel.textAlignment = UITextAlignmentCenter;
		[self addSubview:self.lastUpdatedLabel];
        
        self.statusLabel = [[UILabel alloc] initWithFrame:CGRectMake(0.0f, frame.size.height - 48.0f, self.frame.size.width, 20.0f)];
		self.statusLabel.autoresizingMask = UIViewAutoresizingFlexibleWidth;
		self.statusLabel.font = [UIFont boldSystemFontOfSize:13.0f];
		self.statusLabel.textColor = TEXT_COLOR;
        self.statusLabel.shadowColor = [UIColor colorWithWhite:0.9f alpha:1.0f];
        self.statusLabel.shadowOffset = CGSizeMake(0.0f, 1.0f);
		self.statusLabel.backgroundColor = [UIColor clearColor];
		//self.statusLabel.textAlignment = UITextAlignmentCenter;
		[self addSubview:self.statusLabel];
        
        CGFloat arrowLeftMargin = UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad ? 20.0f : 25.0f;
        
        self.arrowImage = [CALayer layer];
		self.arrowImage.frame = CGRectMake(arrowLeftMargin, frame.size.height - 55.0f, 17.0f, 42.0f);
		self.arrowImage.contentsGravity = kCAGravityResizeAspect;
		self.arrowImage.contents = (id)[UIImage imageNamed:@"blueArrow.png"].CGImage;
        self.arrowImage.edgeAntialiasingMask = kCALayerLeftEdge | kCALayerRightEdge;
		
#if __IPHONE_OS_VERSION_MAX_ALLOWED >= 40000
		if ([[UIScreen mainScreen] respondsToSelector:@selector(scale)]) {
			self.arrowImage.contentsScale = [[UIScreen mainScreen] scale];
		}
#endif
		
		[[self layer] addSublayer:self.arrowImage];
        
        CGFloat refreshLeftMargin = UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad ? 20.0f : 25.0f;
        
        self.activityView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
        self.activityView.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin;
		self.activityView.frame = CGRectMake(refreshLeftMargin, frame.size.height - 45.0f, 20.0f, 20.0f);
		[self addSubview:self.activityView];
        
        self.state = MOPullRefreshStateNormal;
        
    }
    return self;
}


- (void)setState:(MOPullRefreshState)state
{
    switch (state) {
		case MOPullRefreshStatePulling:
			
			self.statusLabel.text = NSLocalizedString(@"Release to refresh...", @"Release to refresh status");
			[CATransaction begin];
			[CATransaction setAnimationDuration:FLIP_ANIMATION_DURATION];
			self.arrowImage.transform = CATransform3DMakeRotation((M_PI / 180.0) * 180.0f, 0.0f, 0.0f, 1.0f);
			[CATransaction commit];
			
			break;
		case MOPullRefreshStateNormal:
			
			if (_state == MOPullRefreshStatePulling) {
				[CATransaction begin];
				[CATransaction setAnimationDuration:FLIP_ANIMATION_DURATION];
				self.arrowImage.transform = CATransform3DIdentity;
				[CATransaction commit];
			}
			
			self.statusLabel.text = NSLocalizedString(@"Pull down to refresh...", @"Pull down to refresh status");
			[self.activityView stopAnimating];
			[CATransaction begin];
			[CATransaction setValue:(id)kCFBooleanTrue forKey:kCATransactionDisableActions];
			self.arrowImage.hidden = NO;
			self.arrowImage.transform = CATransform3DIdentity;
			[CATransaction commit];
			
			[self refreshLastUpdatedDate];
			
			break;
		case MOPullRefreshStateLoading:
			
			self.statusLabel.text = NSLocalizedString(@"Loading...", @"Loading Status");
			[self.activityView startAnimating];
			[CATransaction begin];
			[CATransaction setValue:(id)kCFBooleanTrue forKey:kCATransactionDisableActions];
			self.arrowImage.hidden = YES;
			[CATransaction commit];
			
			break;
		default:
			break;
	}
	
	_state = state;
}

- (void)startRefresh
{
    if ([self.delegate respondsToSelector:@selector(pullRefreshViewDidTriggerRefresh:)]) {
        [self.delegate pullRefreshViewDidTriggerRefresh:self];
    }
    
    UIScrollView *scrollView = (UIScrollView *)self.superview;
    
    [self setState:MOPullRefreshStateLoading];
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationDuration:0.2];
    scrollView.contentInset = UIEdgeInsetsMake(60.0f, 0.0f, 0.0f, 0.0f);
    scrollView.contentOffset = CGPointMake(0, - 65.0f);
    [UIView commitAnimations];
}


- (void)refreshLastUpdatedDate
{
    if ([self.delegate respondsToSelector:@selector(pullRefreshViewDataSourceLastUpdated:)]) {
        
		NSDate *date = [self.delegate pullRefreshViewDataSourceLastUpdated:self];
		
        [NSDateFormatter setDefaultFormatterBehavior:NSDateFormatterBehaviorDefault];
		NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
        [formatter setDateStyle:NSDateFormatterShortStyle];
        [formatter setTimeStyle:NSDateFormatterShortStyle];
		[self.lastUpdatedLabel setText:[NSString stringWithFormat:@"%@: %@", NSLocalizedString(@"Last Updated", @"Last Updated"), [formatter stringFromDate:date]]];
        [[NSUserDefaults standardUserDefaults] setObject:self.lastUpdatedLabel.text forKey:@"MOTableView_LastRefresh"];
        [[NSUserDefaults standardUserDefaults] synchronize];
		
	} else {
		
		self.lastUpdatedLabel.text = nil;
		
	}
}


/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/


- (void)pullRefreshScrollViewDidScroll:(UIScrollView *)scrollView
{
    if (self.state == MOPullRefreshStateLoading) {
		
		CGFloat offset = MAX(scrollView.contentOffset.y * -1, self.insetTop);
		offset = MIN(offset, 60);
		scrollView.contentInset = UIEdgeInsetsMake(offset, 0.0f, 0.0f, 0.0f);
		
	} else if (scrollView.isDragging) {
		
		BOOL loading = NO;
		if ([self.delegate respondsToSelector:@selector(pullRefreshViewDataSourceIsLoading:)]) {
			loading = [self.delegate pullRefreshViewDataSourceIsLoading:self];
		}
		
		if (self.state == MOPullRefreshStatePulling && scrollView.contentOffset.y > -65.0f && scrollView.contentOffset.y < 0.0f && !loading) {
			[self setState:MOPullRefreshStateNormal];
		} else if (self.state == MOPullRefreshStateNormal && scrollView.contentOffset.y < -65.0f && !loading) {
			[self setState:MOPullRefreshStatePulling];
		}
		
		if (scrollView.contentInset.top != self.insetTop) {
			scrollView.contentInset = UIEdgeInsetsMake(self.insetTop, 0, 0, 0);
		}
		
	}
}

- (void)pullRefreshScrollViewDidEndDragging:(UIScrollView *)scrollView
{
    BOOL loading = NO;
	if ([self.delegate respondsToSelector:@selector(pullRefreshViewDataSourceIsLoading:)]) {
		loading = [self.delegate pullRefreshViewDataSourceIsLoading:self];
	}
	
	if (scrollView.contentOffset.y <= - 65.0f && !loading) {
		
		if ([self.delegate respondsToSelector:@selector(pullRefreshViewDidTriggerRefresh:)]) {
			[self.delegate pullRefreshViewDidTriggerRefresh:self];
		}
		
		[self setState:MOPullRefreshStateLoading];
		[UIView beginAnimations:nil context:NULL];
		[UIView setAnimationDuration:0.2];
		scrollView.contentInset = UIEdgeInsetsMake(60.0f, 0.0f, 0.0f, 0.0f);
		[UIView commitAnimations];
		
	}
}

- (void)pullRefreshScrollViewDataSourceDidFinishedLoading:(UIScrollView *)scrollView
{
    [UIView beginAnimations:nil context:NULL];
	[UIView setAnimationDuration:.3];
	[scrollView setContentInset:UIEdgeInsetsMake(self.insetTop, 0.0f, 0.0f, 0.0f)];
	[UIView commitAnimations];
	
	[self setState:MOPullRefreshStateNormal];
}

@end
