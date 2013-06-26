//
//  MOProgressView.h
//  testProgressBar
//
//  Created by notedit on 5/15/13.
//  Copyright (c) 2013 motiky. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MOProgressView : UIView

@property (strong,nonatomic) UIImageView *trackView;
@property (strong,nonatomic) UIImageView *progressbgView;
@property (strong,nonatomic) UIView  *progressView;


- (id)initWithFrame:(CGRect)frame;

@property (nonatomic, assign) double progress;

@end

