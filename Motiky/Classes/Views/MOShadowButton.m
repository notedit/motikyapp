//
//  MOShadowButton.m
//  Motiky
//
//  Created by notedit on 5/25/13.
//  Copyright (c) 2013 notedit. All rights reserved.
//

#import "MOShadowButton.h"
#import <QuartzCore/QuartzCore.h>

@implementation MOShadowButton

-(void)setupView{
    
    self.layer.shadowColor = [UIColor blackColor].CGColor;
    self.layer.shadowOpacity = 0.8;
    self.layer.shadowRadius = 5;
    self.layer.masksToBounds = NO;
    self.layer.shadowOffset = CGSizeMake(3.0f, 3.0f);
    
    self.layer.cornerRadius = 8.0;
    
    self.titleLabel.textColor = [UIColor whiteColor];
    self.backgroundColor = [UIColor colorWithRed:35/255.0 green:181/255.0 blue:116/255.0 alpha:1];
    
}



- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        
        [self setupView];
    }
    return self;
}


-(id)initWithCoder:(NSCoder *)aDecoder{
    if((self = [super initWithCoder:aDecoder])){
        [self setupView];
    }
    
    return self;
}

-(void) touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event{
    self.contentEdgeInsets = UIEdgeInsetsMake(1.0,1.0,-1.0,-1.0);
    self.layer.shadowOffset = CGSizeMake(1.0f, 1.0f);
    self.layer.shadowOpacity = 0.8;
    
    [super touchesBegan:touches withEvent:event];
    
}

-(void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event{
    self.contentEdgeInsets = UIEdgeInsetsMake(0.0,0.0,0.0,0.0);
    self.layer.shadowOffset = CGSizeMake(2.0f, 2.0f);
    self.layer.shadowOpacity = 0.5;
    
    [super touchesEnded:touches withEvent:event];
    
}



/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

@end
