//
//  MOGridViewCell.h
//  Motiky
//
//  Created by notedit on 4/20/13.
//  Copyright (c) 2013 notedit. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Tag.h"
#import "KKGridViewCell.h"

@interface MOGridViewCell : KKGridViewCell

@property (strong,nonatomic) Tag *aTag;

@property (strong,nonatomic) UIImageView *tagImageView;
@property (strong,nonatomic) UILabel    *tagNameLable;
@property (strong,nonatomic) UIButton   *tagNameButton;
@property (strong,nonatomic) UIImageView *maskImageView;

@end
