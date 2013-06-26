//
//  MOCommentCell.h
//  Motiky
//
//  Created by notedit on 4/28/13.
//  Copyright (c) 2013 notedit. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Comment.h"
#import "User.h"

#import <OHAttributedLabel.h>


@interface MOCommentCell : UITableViewCell

@property (nonatomic,weak) Comment *comment;

@property (strong, nonatomic) IBOutlet UIImageView *userPhotoImage;
@property (strong, nonatomic) IBOutlet OHAttributedLabel *commentContentLabel;

@property (strong, nonatomic) IBOutlet UILabel *dateLabel;



+ (CGFloat)heightOfComment:(Comment *)comment withTextConstrainedToWidth:(CGFloat)width;

-(void)updateAge;

@end
