//
//  Post.h
//  Motiky
//
//  Created by notedit on 2/16/13.
//  Copyright (c) 2013 notedit. All rights reserved.
//

#import <Mantle.h>

@class User;

@interface Post : MTLModel <MTLJSONSerializing>

@property (nonatomic) NSString  *id;
@property (nonatomic) NSString  *title;
@property (nonatomic) NSString  *pic_small;
@property (nonatomic) NSString  *pic_big;
@property (nonatomic) NSString  *video_url;
@property (nonatomic) NSNumber  *author_id;
@property (nonatomic) BOOL      show;
@property (nonatomic) BOOL      recommended;
@property (nonatomic) NSNumber  *play_count;
@property (nonatomic) NSDate    *date_create;
@property (nonatomic) NSDate    *date_update;
@property (nonatomic) NSDate    *date_publish;

@property (nonatomic) BOOL      is_like;
@property (nonatomic) NSNumber  *like_count;
@property (nonatomic) NSNumber  *comment_count;

@property (nonatomic,strong) User *user;
 
+ (NSDateFormatter *)dateFormatter;

@end
