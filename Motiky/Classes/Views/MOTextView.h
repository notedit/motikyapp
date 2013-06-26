//
//  MOTextView.h
//  Motiky
//
//  Created by notedit on 5/16/13.
//  Copyright (c) 2013 notedit. All rights reserved.
//



#import <UIKit/UIKit.h>

@interface MOTextView : UITextView

@property (strong, nonatomic) NSString *placeholder;
@property (strong, nonatomic) UIColor *placeholderColor;
@property (strong, nonatomic) UIColor *borderColor;

@property (nonatomic) float cornerRadius;
@property (nonatomic) float borderWidth;

@end