//
//  Comment.h
//  Motiky
//
//  Created by notedit on 2/16/13.
//  Copyright (c) 2013 notedit. All rights reserved.
//

#import <Mantle.h>

@class User;

@interface Comment : MTLModel <MTLJSONSerializing>

@property (nonatomic) NSString  *id;
@property (nonatomic) NSString  *post_id;
@property (nonatomic) NSString  *author_id;
@property (nonatomic) NSString  *content;
@property (nonatomic) NSDate    *date_create;

@property (nonatomic,strong) User *user;


+ (NSDateFormatter *)dateFormatter;

@end
