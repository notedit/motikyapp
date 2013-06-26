//
//  MOTextView.m
//  Motiky
//
//  Created by notedit on 5/16/13.
//  Copyright (c) 2013 notedit. All rights reserved.
//



#import "MOTextView.h"
#import <QuartzCore/QuartzCore.h>

@interface MOTextView() {
    BOOL shouldDrawPlaceholder;
}

@end

@implementation MOTextView

- (void)setText:(NSString *)string
{
    [super setText:string];
    [self updateShouldDrawPlaceholder];
}


- (void)setPlaceholder:(NSString *)string
{
    if ([string isEqual:_placeholder]) {
        return;
    }
    
    _placeholder = string;
    
    [self updateShouldDrawPlaceholder];
}


#pragma mark - NSObject

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UITextViewTextDidChangeNotification object:self];
}


#pragma mark - UIView

- (id)initWithCoder:(NSCoder *)aDecoder
{
    if ((self = [super initWithCoder:aDecoder])) {
        [self initialize];
    }
    return self;
}


- (id)initWithFrame:(CGRect)frame
{
    if ((self = [super initWithFrame:frame])) {
        [self initialize];
    }
    return self;
}

- (void)awakeFromNib
{
    [self initialize];
}

- (void)drawRect:(CGRect)rect
{
    [super drawRect:rect];
    
    if (shouldDrawPlaceholder) {
        [_placeholderColor set];
        [_placeholder drawInRect:CGRectMake(8.0f, 8.0f, self.frame.size.width - 16.0f, self.frame.size.height - 16.0f) withFont:self.font];
    }
}

#pragma mark - Private

- (void)initialize
{
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(_textChanged:) name:UITextViewTextDidChangeNotification object:self];
    
    self.placeholderColor = [UIColor colorWithWhite:0.702f alpha:1.0f];
    shouldDrawPlaceholder = YES;
    
    self.layer.borderWidth = self.borderWidth;
    self.layer.borderColor = [self.borderColor CGColor];
    self.layer.cornerRadius = self.cornerRadius;
}


- (void)updateShouldDrawPlaceholder
{
    BOOL prev = shouldDrawPlaceholder;
    shouldDrawPlaceholder = self.placeholder && self.placeholderColor && self.text.length == 0;
    
    if (prev != shouldDrawPlaceholder) {
        [self setNeedsDisplay];
    }
}


- (void)_textChanged:(NSNotification *)notificaiton
{
    [self updateShouldDrawPlaceholder];
}

@end
