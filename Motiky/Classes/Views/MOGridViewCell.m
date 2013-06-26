//
//  MOGridViewCell.m
//  Motiky
//
//  Created by notedit on 4/20/13.
//  Copyright (c) 2013 notedit. All rights reserved.
//

#import "MOGridViewCell.h"
#import <NSAttributedString+Attributes.h>

@implementation MOGridViewCell

@synthesize tagImageView = _tagImageView;
@synthesize maskImageView = _maskImageView;
@synthesize tagNameButton = _tagNameButton;
@synthesize tagNameLable = _tagNameLable;
@synthesize aTag = _aTag;

- (id)initWithFrame:(CGRect)frame reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithFrame:frame reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
        self.tagImageView = [[UIImageView alloc] initWithFrame:self.bounds];
        self.tagImageView.contentMode = UIViewContentModeScaleAspectFill;
        self.tagImageView.clipsToBounds = YES;
        self.tagImageView.backgroundColor = [UIColor clearColor];
        [self.contentView addSubview:self.tagImageView];
        
        self.maskImageView = [[UIImageView alloc] initWithFrame:self.bounds];
        
        self.maskImageView.image = [[UIImage imageNamed:@"explore-item-shadow"] resizableImageWithCapInsets:UIEdgeInsetsMake(0, 0, 0, 0)];
        
        [self.contentView addSubview:self.maskImageView];
        
        /*
        self.tagNameLable = [[UILabel alloc] initWithFrame:CGRectMake(6, CGRectGetHeight(self.bounds) - 6 - 20, CGRectGetWidth(self.bounds) - 12, 20)];
        self.tagNameLable.backgroundColor = [UIColor clearColor];
        self.tagNameLable.textColor = [UIColor grayColor];
        self.tagNameLable.font = [UIFont systemFontOfSize:12.0f];
        //self.tagNameLable.textAlignment = UITextAlignmentCenter;
        [self.contentView addSubview:self.tagNameLable];
        
         */
        
        UIView *selectedBackgroundView = [[UIView alloc] initWithFrame:self.bounds];
        selectedBackgroundView.backgroundColor = [UIColor clearColor];
        self.selectedBackgroundView = selectedBackgroundView;
        
        self.contentView.backgroundColor = [UIColor clearColor];
        self.backgroundView.backgroundColor = [UIColor clearColor];
    }
    return self;
}


-(void)setATag:(Tag *)aTag
{
    NSString *tagString = [NSString stringWithFormat:@"#%@#",aTag.name];
    
    NSMutableAttributedString *string = [NSMutableAttributedString attributedStringWithString:tagString];
    [string setFont:[UIFont systemFontOfSize:12]];
    [string setTextColor:[UIColor whiteColor]];
    
    CGSize size =  [string sizeConstrainedToSize:CGSizeMake(120.0f, CGFLOAT_MAX)];
    
    self.tagNameButton = [[UIButton alloc] initWithFrame:CGRectMake(10, 10, size.width + 40, 22)];
    [self.tagNameButton setBackgroundImage:[[UIImage imageNamed:@"explore-tag-bg"] resizableImageWithCapInsets:UIEdgeInsetsMake(0, 4, 0, 4)] forState:UIControlStateNormal];
    
    [self.tagNameButton setTitle:tagString forState:UIControlStateNormal];
    [self.tagNameButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    
    [self.contentView addSubview:self.tagNameButton];
    
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
