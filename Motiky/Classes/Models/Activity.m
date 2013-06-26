//
//  Activity.m
//  Motiky
//
//  Created by notedit on 2/16/13.
//  Copyright (c) 2013 notedit. All rights reserved.
//

#import "Activity.h"

@implementation Activity


@synthesize id;
@synthesize post_id;
@synthesize comment_id;
@synthesize from_id;
@synthesize to_id;
@synthesize atype;
@synthesize date_create;

@synthesize user;
@synthesize post;
@synthesize comment;


- (NSDictionary *)JSONKeyPathsByPropertyKey
{
    return @{
             @"id":@"id",
             @"post_id":@"post_id",
             @"comment_id":@"comment_id",
             @"from_id":@"from_id",
             @"to_id":@"to_id",
             @"atype":@"atype",
             @"date_create":@"date_create",
             @"user":@"user",
             @"post":@"post",
             @"comment":@"comment"
             };
}

+ (NSDateFormatter *)dateFormatter {
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    dateFormatter.locale = [[NSLocale alloc] initWithLocaleIdentifier:@"zh_CN"];
    dateFormatter.dateFormat = @"yyyy-MM-dd HH:mm:ss";
    return dateFormatter;
}

@end
