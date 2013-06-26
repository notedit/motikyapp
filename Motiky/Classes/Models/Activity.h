//
//  Activity.h
//  Motiky
//
//  Created by notedit on 2/16/13.
//  Copyright (c) 2013 notedit. All rights reserved.
//

#import <Mantle.h>
#import "User.h"
#import "Comment.h"

@class Post,User,Comment;

@interface Activity : MTLModel <MTLJSONSerializing>

@property (nonatomic) NSString  *id;
@property (nonatomic) NSString  *post_id;
@property (nonatomic) NSString  *comment_id;
@property (nonatomic) NSString  *from_id;
@property (nonatomic) NSString  *to_id;
@property (nonatomic) NSString  *atype;
@property (nonatomic) NSDate    *date_create;


@property (nonatomic) User      *user;
@property (nonatomic) Post      *post;
@property (nonatomic) Comment   *comment;

+ (NSDateFormatter *)dateFormatter;

@end
