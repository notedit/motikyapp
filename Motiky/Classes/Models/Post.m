//
//  Post.m
//  Motiky
//
//  Created by notedit on 2/16/13.
//  Copyright (c) 2013 notedit. All rights reserved.
//

#import "Post.h"
#import "User.h"

@implementation Post

@synthesize id;
@synthesize title;
@synthesize pic_small;
@synthesize pic_big;
@synthesize video_url;
@synthesize author_id;
@synthesize show;
@synthesize recommended;
@synthesize play_count;
@synthesize date_create;
@synthesize date_update;
@synthesize date_publish;
@synthesize user;

@synthesize is_like;

- (NSDictionary *)JSONKeyPathsByPropertyKey
{
    return @{
             @"id":@"id",
             @"title":@"title",
             @"pic_small":@"pic_small",
             @"pic_big":@"pic_big",
             @"video_url":@"video_url",
             @"author_id":@"author_id",
             @"show":@"show",
             @"recommended":@"recommended",
             @"play_count":@"play_count",
             @"date_create":@"date_create",
             @"date_update":@"date_update",
             @"date_publish":@"date_publish",
             @"user":@"user",
             @"is_like":@"is_like",
             @"like_count":@"like_count",
             @"comment_count":@"comment_count"
             };
}

+ (NSDateFormatter *)dateFormatter {
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    dateFormatter.locale = [[NSLocale alloc] initWithLocaleIdentifier:@"zh_CN"];
    dateFormatter.dateFormat = @"yyyy-MM-dd HH:mm:ss";
    return dateFormatter;
}

+ (NSValueTransformer *)userJSONTransformer {
    return [NSValueTransformer mtl_JSONDictionaryTransformerWithModelClass:[User class]];
}


+ (NSValueTransformer *)date_createJSONTransformer {
    return [MTLValueTransformer reversibleTransformerWithForwardBlock:^(NSString *str) {
        return [self.dateFormatter dateFromString:str];
    } reverseBlock:^(NSDate *date) {
        return [self.dateFormatter stringFromDate:date];
    }];
}



@end
