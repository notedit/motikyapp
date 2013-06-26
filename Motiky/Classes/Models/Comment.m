//
//  Comment.m
//  Motiky
//
//  Created by notedit on 2/16/13.
//  Copyright (c) 2013 notedit. All rights reserved.
//

#import "Comment.h"

@implementation Comment

@synthesize id;
@synthesize post_id;
@synthesize author_id;
@synthesize content;
@synthesize date_create;

@synthesize user;

- (NSDictionary *)JSONKeyPathsByPropertyKey
{
    return @{
             @"id":@"id",
             @"post_id":@"post_id",
             @"author_id":@"author_id",
             @"content":@"content",
             @"date_create":@"date_create",
             @"user":@"user"
             };
}

+ (NSDateFormatter *)dateFormatter {
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    dateFormatter.locale = [[NSLocale alloc] initWithLocaleIdentifier:@"zh_CN"];
    dateFormatter.dateFormat = @"yyyy-MM-dd HH:mm:ss";
    return dateFormatter;
}

+ (NSValueTransformer *)date_createJSONTransformer {
    return [MTLValueTransformer reversibleTransformerWithForwardBlock:^(NSString *str) {
        return [self.dateFormatter dateFromString:str];
    } reverseBlock:^(NSDate *date) {
        return [self.dateFormatter stringFromDate:date];
    }];
}

@end
