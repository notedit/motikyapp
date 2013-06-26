//
//  User.m
//  Motiky
//
//  Created by notedit on 2/16/13.
//  Copyright (c) 2013 notedit. All rights reserved.
//

#import "User.h"

@implementation User

@synthesize id;
@synthesize username;
@synthesize email;
@synthesize photo_url;
@synthesize signature;
@synthesize status;
@synthesize uid;
@synthesize push_on;
@synthesize access_token;
@synthesize date_create;
@synthesize date_update;

@synthesize is_follow;

-(NSDictionary *)JSONKeyPathsByPropertyKey
{
    return @{
             @"id":@"id",
             @"username":@"username",
             @"email":@"email",
             @"photo_url":@"photo_url",
             @"signature":@"signature",
             @"status":@"status",
             @"uid":@"uid",
             @"push_on":@"push_on",
             @"access_token":@"access_token",
             @"date_create":@"date_create",
             @"date_update":@"date_update",
             @"is_follow":@"is_follow"
             };
}

@end
