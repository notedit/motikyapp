//
//  User.h
//  Motiky
//
//  Created by notedit on 2/16/13.
//  Copyright (c) 2013 notedit. All rights reserved.
//

#import <Mantle.h>

@interface User : MTLModel <MTLJSONSerializing>

@property (nonatomic) NSString  *id;
@property (nonatomic) NSString  *username;
@property (nonatomic) NSString  *email;
@property (nonatomic) NSString  *photo_url;
@property (nonatomic) NSString  *signature;
@property (nonatomic) NSString  *status;
@property (nonatomic) NSString  *uid;
@property (nonatomic) BOOL      push_on;
@property (nonatomic) NSString  *access_token;
@property (nonatomic) NSDate    *date_create;
@property (nonatomic) NSDate    *date_update;

@property (nonatomic) BOOL      is_follow;
@property (nonatomic) NSNumber  *following_count;
@property (nonatomic) NSNumber  *follower_count;
@property (nonatomic) NSNumber  *post_count;
@property (nonatomic) NSNumber  *liked_post_count;

@end
