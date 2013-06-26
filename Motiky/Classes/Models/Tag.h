//
//  Tag.h
//  Motiky
//
//  Created by notedit on 4/16/13.
//  Copyright (c) 2013 notedit. All rights reserved.
//

#import <Mantle.h>

@interface Tag : MTLModel <MTLJSONSerializing>

@property (nonatomic) NSString  *id;
@property (nonatomic) NSString  *name;
@property (nonatomic) BOOL      show;
@property (nonatomic) NSString  *pic_url;
@property (nonatomic) NSNumber  *order_seq;
@property (nonatomic) BOOL      recommended;
@property (nonatomic) NSDate    *date_create;

@end
