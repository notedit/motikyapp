//
//  MOAuthEngine.m
//  ModelTest
//
//  Created by notedit on 3/9/13.
//  Copyright (c) 2013 notedit. All rights reserved.
//

#import "MOAuthEngine.h"
#import "MOAppDelegate.h"
#import "MOClient.h"

#define USER_WEIBO_AUTH_KEY @"USER_WEIBO_AUTH_KEY"

@implementation MOAuthEngine {
    
    void (^logInContinuation)(BOOL,NSError *);
    void (^logOutContinuation)(BOOL);
    void (^getUserInfoContinuation)(NSDictionary *);
    
}

@synthesize sinaWeibo = _sinaWeibo;
@synthesize userInfo = _userInfo;
@synthesize currentUser = _currentUser;

- (id)init {
    self = [super init];
    if (self) {
        _userInfo = nil;
        _appKey = kAppKey;
        _appSecret = kAppSecret;
        _sinaWeibo = [[SinaWeibo alloc]initWithAppKey:_appKey appSecret:_appSecret appRedirectURI:kAppRedirectURI andDelegate:self];
        //_sinaWeibo.ssoCallbackScheme = @"";
    }
    
    [self readAuthorizeData];
    return self;
}

+ (MOAuthEngine *)sharedAuthEngine {
    static MOAuthEngine *_sharedEngine = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _sharedEngine = [[MOAuthEngine alloc] init];
    });
    return _sharedEngine;
}


- (NSString *)sinaWeiboID {
    return _sinaWeibo.userID;
}

- (NSString *)sinaWeiboIDAccessToken {
    return _sinaWeibo.accessToken;
}

- (BOOL) isValid {
    NSLog(@"userinfo: %@",_userInfo);
    return _sinaWeibo.isAuthValid && [[_userInfo objectForKey:@"id"] integerValue];
}

- (void)readAuthorizeData
{
    NSDictionary *sinaweiboInfo = [[NSUserDefaults standardUserDefaults] objectForKey:USER_WEIBO_AUTH_KEY];
    _userInfo = [sinaweiboInfo objectForKey:@"UserInfo"] ? [sinaweiboInfo objectForKey:@"UserInfo"] : nil ;
    _currentUser = _userInfo ? [[User alloc] initWithDictionary:_userInfo]:nil;
    _sinaWeibo.accessToken = [sinaweiboInfo objectForKey:@"AccessToken"];
    _sinaWeibo.expirationDate = [sinaweiboInfo objectForKey:@"ExpirationDate"];
    _sinaWeibo.userID = [sinaweiboInfo objectForKey:@"UserId"];
}

- (void) saveAuthorizeData
{
    NSMutableDictionary *userInfo = [_userInfo mutableCopy];
    NSArray *userInfoKeys = userInfo.allKeys;
    for (NSString *key in userInfoKeys) {
        id obj = [userInfo valueForKey:key];
        if ([obj isKindOfClass:[NSNull class]]) {
            [userInfo removeObjectForKey:key];
        }
    }
    
    NSDictionary *sinaweiboInfo = @{@"AccessToken":_sinaWeibo.accessToken,
                                    @"ExpirationDate":_sinaWeibo.expirationDate,
                                    @"UserId":_sinaWeibo.userID,
                                    @"UserInfo":userInfo};
    
    [[NSUserDefaults standardUserDefaults] setObject:sinaweiboInfo forKey:USER_WEIBO_AUTH_KEY];
    [[NSUserDefaults standardUserDefaults] synchronize];
    
}

- (void) deleteAuthorizeData
{
    _sinaWeibo.userID = nil;
    _sinaWeibo.accessToken = nil;
    _sinaWeibo.expirationDate = nil;
    _userInfo = @{};
    NSDictionary *sinaweiboInfo = @{};
    [[NSUserDefaults standardUserDefaults] setObject:sinaweiboInfo forKey:USER_WEIBO_AUTH_KEY];
    [[NSUserDefaults standardUserDefaults] synchronize];
}


- (void) inValidAuth
{
    [self deleteAuthorizeData];
}

- (void) logInWithContinuation:(void (^)(BOOL, NSError *))continuation
{
    [self logIn:^(BOOL success, NSError *error){
        if (success) {
            [self onLoggedIn:^(BOOL success, NSError *error) {
                if (continuation) {
                    continuation(success,error);
                }
            }];
            return;
        } else if (error.code != 21330)
        {
            
        }
        
        if (continuation) {
            continuation(success,error);
        }
    }];
}

- (void) logIn:(void (^)(BOOL, NSError *))continuation
{
    logInContinuation = [continuation copy];
    [_sinaWeibo logIn];
}

- (void) onLoggedIn:(void(^)(BOOL success,NSError *error)) block {
           
    // 创建新的用户
    [MOClient createUserWithWeiboId:self.sinaWeiboID token:self.sinaWeiboIDAccessToken withContinuation:^(BOOL success, NSDictionary *retinfo, NSError *error) {
        NSLog(@"createUserWithWeiboId:%@,%@,%@",self.sinaWeiboID,retinfo,error.domain);
        if (!success) {
            dispatch_async(dispatch_get_main_queue(), ^{
                if (block) {
                    block(NO,error);
                }
            });
            return;
        }
        // 保存用户信息
        _userInfo = retinfo;
        [self saveAuthorizeData];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            if (block) {
                block(YES,nil);
            }
        });
    }];
    
           
    
}

- (void) logOutWithContinuation:(void (^)(BOOL, NSError *))continuation
{
    logInContinuation = [continuation copy];
    [_sinaWeibo logOut];
    [self deleteAuthorizeData];
}


- (void) getWeiboUserInfo:(NSString *)userId withContinuation:(void (^)(NSDictionary *))continuation
{
    
    NSLog(@"getWeiboUserInfo:%@",userId);
    getUserInfoContinuation = [continuation copy];
    [_sinaWeibo requestWithURL:@"users/show.json"
                            params:[NSMutableDictionary dictionaryWithDictionary:@{@"uid":userId}]
                    httpMethod:@"GET" delegate:self];
    NSLog(@"send users show request");
    
}

#pragma mark - SinaWeiboDelegate


- (void)sinaweiboDidLogIn:(SinaWeibo *)sinaweibo
{
    NSLog(@"sinaweiboDidLogin");
    NSLog(@"sinaweibo expirationDate %@",sinaweibo.expirationDate);
    
    //[self saveAuthorizeData];
    
    dispatch_async(dispatch_get_main_queue(), ^{
        if (logInContinuation) {
            logInContinuation(YES,nil);
            logInContinuation = nil;
        }
    });
}

- (void)sinaweiboDidLogOut:(SinaWeibo *)sinaweibo
{
    NSLog(@"sinaweiboDidLogOut");
    
    dispatch_async(dispatch_get_main_queue(), ^{
        [self deleteAuthorizeData];
        if (logOutContinuation) {
            logOutContinuation(YES);
            logOutContinuation = nil;
        }
    });
}



- (void)sinaweibo:(SinaWeibo *)sinaweibo logInDidFailWithError:(NSError *)error
{
    NSLog(@"logInDidFailWithError %@",error);
    dispatch_async(dispatch_get_main_queue(), ^{
        if (logInContinuation) {
            logInContinuation(NO,error);
            logInContinuation = nil;
        }
    });
}

- (void)sinaweibo:(SinaWeibo *)sinaweibo accessTokenInvalidOrExpired:(NSError *)error
{
    NSLog(@"accessTokenInvalidOrExpired %@",error);
    _sinaWeibo.expirationDate = [NSDate dateWithTimeIntervalSinceNow:-60*60];
    [self saveAuthorizeData];
    
    dispatch_async(dispatch_get_main_queue(), ^{
        if (logOutContinuation) {
            logOutContinuation(YES);
            logOutContinuation = nil;
        }
    });
}

#pragma mark - SinaWeiboRequestDelegate

-(void) request:(SinaWeiboRequest *)request didFailWithError:(NSError *)error
{
    if (getUserInfoContinuation) {
        getUserInfoContinuation(nil);
    }
}

- (void) request:(SinaWeiboRequest *)request didFinishLoadingWithResult:(id)result
{
    NSLog(@"get the request result:%@",request);
    if (getUserInfoContinuation) {
        getUserInfoContinuation((NSDictionary *)result);
    }
}

@end
















