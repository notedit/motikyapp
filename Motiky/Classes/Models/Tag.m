//
//  Tag.m
//  Motiky
//
//  Created by notedit on 4/16/13.
//  Copyright (c) 2013 notedit. All rights reserved.
//

#import "Tag.h"

@implementation Tag

@synthesize id;
@synthesize name;
@synthesize show;
@synthesize pic_url;
@synthesize order_seq;
@synthesize recommended;
@synthesize date_create;


- (NSDictionary *)JSONKeyPathsByPropertyKey
{
    return @{
             @"id":@"id",
             @"name":@"name",
             @"show":@"show",
             @"pic_url":@"pic_url",
             @"order_seq":@"order_seq",
             @"date_create":@"date_create"
             };
}

@end
