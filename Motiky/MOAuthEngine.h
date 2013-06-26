//
//  MOAuthEngine.h
//  ModelTest
//
//  Created by notedit on 3/9/13.
//  Copyright (c) 2013 notedit. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "SinaWeibo.h"
#import "User.h"


#define kAppKey             @"3346529116"
#define kAppSecret          @"79d2bb5e343bdda3bdbca3efc66e22a5"
#define kAppRedirectURI     @"http://motiky.com"

@interface MOAuthEngine : NSObject <SinaWeiboDelegate,SinaWeiboRequestDelegate> {
    NSString        *_appKey;
    NSString        *_appSecret;
    NSDictionary    *_userInfo;
    SinaWeibo       *_sinaWeibo;
}

@property (nonatomic,readonly) NSString *sinaWeiboID;
@property (nonatomic,readonly) NSString *sinaWeiboIDAccessToken;
@property (nonatomic,readonly) SinaWeibo *sinaWeibo;
@property (nonatomic,readonly) NSDictionary *userInfo;
@property (nonatomic,readonly) User*   currentUser;

+ (MOAuthEngine *)sharedAuthEngine;

- (BOOL) isValid;

- (void) inValidAuth;
- (void) logInWithContinuation: (void (^)(BOOL,NSError *))continuation;
- (void) logOutWithContinuation: (void (^)(BOOL,NSError *))continuation;
- (void) getWeiboUserInfo:(NSString *)userId withContinuation:(void (^)(NSDictionary *))continuation;

@end
