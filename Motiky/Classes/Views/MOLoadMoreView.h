//
//  MOLoadMoreView.h
//  Motiky
//
//  Created by notedit on 4/18/13.
//  Copyright (c) 2013 notedit. All rights reserved.
//

#import <UIKit/UIKit.h>

#define kISSLoadMoreViewHeight 52.0f

@interface MOLoadMoreView : UIView

@property (strong, nonatomic) UILabel *loadingLabel;
@property (strong, nonatomic) UIActivityIndicatorView *activityView;

@end
