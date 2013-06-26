//
//  MOClient.m
//  Motiky
//
//  Created by notedit on 2/16/13.
//  Copyright (c) 2013 notedit. All rights reserved.
//

#import <CommonCrypto/CommonDigest.h>
#import <CommonCrypto/CommonHMAC.h>
#import <AFJSONRequestOperation.h>
#import <AFNetworkActivityIndicatorManager.h>

#import "MOClient.h"
#import "MOAuthEngine.h"

static NSString * const APIBASEURL = @"http://api.motiky.com";
static NSString * const APPSECRET = @"lifeistooshorttowait";

// user
static NSString * const NEW_USER_URL = @"user";
static NSString * const GET_PUT_USER_URL = @"user/%@";
static NSString * const INSTALL_URL = @"install";
static NSString * const USER_FOLLOW_URL = @"user/follow";
static NSString * const USER_UNFOLLOW_URL = @"user/follow/%@";
static NSString * const USER_IS_FOLLOWING_URL = @"user/isfollowing/%@";
static NSString * const USER_FOLLOWING_URL = @"user/following/%@";
static NSString * const USER_FOLLOWER_URL = @"user/follower/%@";
static NSString * const USER_PROFILE_URL = @"user/profile/%@";

static NSString * const USER_LIKE_POST_URL = @"post/like";
static NSString * const USER_UNLIKE_POST_URL = @"post/unlike";

// post
static NSString * const NEW_POST_URL = @"post";
static NSString * const GET_PUT_DEL_POST_URL = @"post/%@";
static NSString * const USER_POSTS_URL = @"posts/user/%@";
static NSString * const USER_LIKED_POSTS_URL = @"posts/user/%@/liked";

// tag

static NSString * const GET_TAGS = @"tags";
static NSString * const GET_TAG_URL = @"tag/%@";

// feeds

static NSString * const GET_USER_FEEDS = @"feeds/%@";

// activity

static NSString * const GET_USER_ACTIVITY_URL = @"/user/%@/activity";
static NSString * const GET_USER_ACTIVITY_COUNT_URL = @"/user/%@/activity/count";

// comment

static NSString * const NEW_COMMENT_URL = @"comment";
static NSString * const DELETE_COMMENT_URL = @"comment/%@";
static NSString * const GET_POST_COMMENT_URL = @"post/%@/comment";

@implementation MOClient

+ (MOClient *) sharedClient {
    
    static MOClient *_sharedClient = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _sharedClient = [[MOClient alloc] initWithBaseURL:[NSURL URLWithString:APIBASEURL]];
        [_sharedClient registerHTTPOperationClass:[AFJSONRequestOperation class]];
        [_sharedClient setDefaultHeader:@"Accept" value:@"application/json"];
        [_sharedClient setParameterEncoding:AFJSONParameterEncoding];
    });
    
    [AFNetworkActivityIndicatorManager sharedManager].enabled = YES;
    return _sharedClient;
}


+ (void) incrementActivityCount {
    
    [MOClient sharedClient];
    [[AFNetworkActivityIndicatorManager sharedManager] incrementActivityCount];
    
}


+ (void) decrementActivityCount{
    
    [[AFNetworkActivityIndicatorManager sharedManager] decrementActivityCount];
    
}

-(NSMutableURLRequest *)requestWithMethod:(NSString *)method
                                     path:(NSString *)path
                               parameters:(NSDictionary *)parameters {
    
    NSParameterAssert(method);
    
    if (!path) {
        path = @"";
    }
    
    // set token
    NSString * uid = @"";
    if ([[MOAuthEngine sharedAuthEngine] isValid]) {
        uid = [[MOAuthEngine sharedAuthEngine] sinaWeiboID];
    } else {
        uid = @"0000000000";
    }
    
    
    NSString *timestamp = [NSString stringWithFormat:@"%f",
                           [[NSDate date] timeIntervalSince1970]];
       
    NSString *token = [self generateToken:uid withStamp:timestamp];
    
    token = [NSString stringWithFormat:@"%@|%@|%@",uid,timestamp,token];
    
    NSURL *url = [NSURL URLWithString:path relativeToURL:self.baseURL];
	NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:url];
    [request setHTTPMethod:method];
    [request setAllHTTPHeaderFields:[self valueForKey:@"_defaultHeaders"]];
    [request addValue:token forHTTPHeaderField:@"X-MOTIKY-TOKEN"];
    
    NSLog(@" the headers:%@",[self valueForKey:@"_defaultHeaders"]);
	
    if (parameters) {
        if ([method isEqualToString:@"GET"] || [method isEqualToString:@"HEAD"] || [method isEqualToString:@"DELETE"]) {
            url = [NSURL URLWithString:[[url absoluteString] stringByAppendingFormat:[path rangeOfString:@"?"].location == NSNotFound ? @"?%@" : @"&%@", AFQueryStringFromParametersWithEncoding(parameters, self.stringEncoding)]];
            [request setURL:url];
        } else {
            NSString *charset = (__bridge NSString *)CFStringConvertEncodingToIANACharSetName(CFStringConvertNSStringEncodingToEncoding(self.stringEncoding));
            NSError *error = nil;
            
            switch (self.parameterEncoding) {
                case AFFormURLParameterEncoding:;
                    [request setValue:[NSString stringWithFormat:@"application/x-www-form-urlencoded; charset=%@", charset] forHTTPHeaderField:@"Content-Type"];
                    [request setHTTPBody:[AFQueryStringFromParametersWithEncoding(parameters, self.stringEncoding) dataUsingEncoding:self.stringEncoding]];
                    break;
                case AFJSONParameterEncoding:;
                    [request setValue:[NSString stringWithFormat:@"application/json; charset=%@", charset] forHTTPHeaderField:@"Content-Type"];
                    [request setHTTPBody:[NSJSONSerialization dataWithJSONObject:parameters options:0 error:&error]];
                    break;
                case AFPropertyListParameterEncoding:;
                    [request setValue:[NSString stringWithFormat:@"application/x-plist; charset=%@", charset] forHTTPHeaderField:@"Content-Type"];
                    [request setHTTPBody:[NSPropertyListSerialization dataWithPropertyList:parameters format:NSPropertyListXMLFormat_v1_0 options:0 error:&error]];
                    break;
            }
            
            if (error) {
                NSLog(@"%@ %@: %@", [self class], NSStringFromSelector(_cmd), error);
            }
        }
    }
    
	return request;
}


- (NSString*)generateToken:(NSString *)uid withStamp:(NSString *)timestamp
{
    
   
    NSString *hdata = [NSString stringWithFormat:@"%@%@",uid,timestamp];
    
    NSLog(@"log the hdata:%@",hdata);
    
    const char *cKey  = [APPSECRET cStringUsingEncoding:NSUTF8StringEncoding];
	const char *cData = [hdata cStringUsingEncoding:NSUTF8StringEncoding];
	unsigned char cHMAC[CC_MD5_DIGEST_LENGTH];
	CCHmac(kCCHmacAlgMD5, cKey, strlen(cKey), cData, strlen(cData), cHMAC);
	NSData *HMAC = [[NSData alloc] initWithBytes:cHMAC length:sizeof(cHMAC)];
    return [self hexStringForData:HMAC];
    
}

-(NSString *)hexStringForData:(NSData *)data {
	NSString *string = [data description];
	return [string stringByReplacingOccurrencesOfString:@"[\\(|\\)|\\+|\\-|\\W]" withString:@"" options:NSRegularExpressionSearch range:NSMakeRange(0, [string length])];
}



+(void)createUserWithWeiboId:(NSString *)weibo token:(NSString *)token withContinuation:(void (^)(BOOL, NSDictionary *, NSError *))continuation
{
    NSDictionary *weiboInfo = @{@"uid":weibo,
                                @"access_token":token};
    NSMutableDictionary *params = [weiboInfo mutableCopy];
    
    
    NSLog(@" the params is %@",params);
    
    [[MOClient sharedClient] postPath:NEW_USER_URL parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        if (continuation) {
            continuation(YES,responseObject,nil);
        }
        NSLog(@"log some thing");
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        if (continuation) {
            NSLog(@"the error is %@",error.domain);
            continuation(NO,nil,error);
        }
    }];

}


+(void) fetchUser:(User *)user withContinuation:(void (^)(BOOL))continuation
{
    NSString *path = [NSString stringWithFormat:GET_PUT_USER_URL,user.id];
    [[MOClient sharedClient] getPath:path  parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        User *ruser = [[User alloc] initWithDictionary:(NSDictionary *)responseObject];
        [user mergeValuesForKeysFromModel:ruser];
        if (continuation) {
            continuation(YES);
        }
        
        NSLog(@"log fetch user");
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"log fetch user error");
    }];
}

+ (void)fetchUserProfile:(User *)user withContinuation:(void (^)(BOOL, NSDictionary *))continuation
{
    NSString *path = [NSString stringWithFormat:USER_PROFILE_URL,user.id];
    [[MOClient sharedClient] getPath:path parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        if (![responseObject isKindOfClass:[NSDictionary class]]) {
            NSLog(@"can not get corrent user profile");
            if (continuation) {
                continuation(NO,nil);
            }
            return;
        }
     
     
        User* newUser = [User modelWithDictionary:(NSDictionary*)responseObject];
     
     
        [user mergeValuesForKeysFromModel:newUser];
     
        if(continuation){
            continuation(YES,responseObject);
        }
     
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        
        NSLog(@" can not get correct user profile:%@",error);
        
        if (continuation) {
            continuation(NO,nil);
        }
        
    }];
}

+(void) fetchPost:(Post *)post withContinuation:(void (^)(BOOL))continuetion
{
    NSString *path = [NSString stringWithFormat:GET_PUT_DEL_POST_URL,post.id];
    [[MOClient sharedClient] getPath:path parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        Post *rpost = [[Post alloc] initWithDictionary:(NSDictionary *)responseObject];
        [post mergeValuesForKeysFromModel:rpost];
        if (continuetion) {
            continuetion(YES);
        }
        NSLog(@"fetch post");
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        if (continuetion) {
            continuetion(NO);
        }
        NSLog(@"fetch post error");
    }];
}

+(void) updateUser:(User *)user extInfo:(NSDictionary *)extInfo withContinuation:(void (^)(BOOL))continuation
{
    NSMutableDictionary *edict = [extInfo mutableCopy];
    NSString *path = [NSString stringWithFormat:GET_PUT_USER_URL,user.id];
    [[MOClient sharedClient] putPath:path parameters:edict success:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        if (continuation) {
            continuation(YES);
        }
        NSLog(@"get update user result %@",responseObject);
        NSLog(@"update user");
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"update user error");
    }];
}

+(void)followUser:(User *)user withContinuation:(void (^)(BOOL))continuation
{
    
    NSDictionary *params = @{@"user_ids":@[user.id]};
    
    [[MOClient sharedClient] postPath:USER_FOLLOW_URL parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        user.is_follow = YES;
        
        if (continuation) {
            continuation(YES);
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        if (continuation) {
            continuation(NO);
        }
    }];
}

+(void)unfollowUser:(User *)user withContinuation:(void (^)(BOOL))continuation
{
    NSString *path = [NSString stringWithFormat:USER_UNFOLLOW_URL,user.id];
    [[MOClient sharedClient] deletePath:path parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        user.is_follow = NO;
        
        if (continuation) {
            continuation(YES);
        }
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        
        if (continuation) {
            continuation(NO);
        }
        
    }];
}


+(void)isFollowingUser:(User *)user withContinuation:(void (^)(BOOL))continuation
{
    NSString *path = [NSString stringWithFormat:USER_IS_FOLLOWING_URL,user.id];
    [[MOClient sharedClient] getPath:path parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
        if (continuation) {
            continuation(YES);
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        if (continuation) {
            continuation(NO);
        }
    }];
}


+(void)createUserInstallWithUserId:(NSString *)userId deviceToken:(NSString *)token
{
    NSDictionary *params = @{
                             @"user_id":userId,
                             @"device_token":token
                             };
    
    [[MOClient sharedClient] postPath:INSTALL_URL parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        if (![responseObject isKindOfClass:[NSDictionary class]]) {
            NSLog(@"can not create install info:%@",responseObject);
        }
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        
        NSLog(@"can not create install info:%@",error);
    }];
}

+ (void)fetchPostForUser:(User *)user page:(int)page continuation:(void (^)(BOOL, int, NSArray *))continuation
{
     NSString *path = [NSString stringWithFormat:USER_POSTS_URL,user.id];
    [[MOClient sharedClient] getPath:path parameters:page > 1 ? @{@"page":[NSNumber numberWithInt:page]}:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        NSLog(@"user post is:%@",responseObject);
        if (![responseObject isKindOfClass:[NSDictionary class]]) {
            NSLog(@"can not get user posts");
            continuation(NO,0,nil);
            return;
        }
        
        
        id nextPage = [responseObject objectForKey:@"page"];
        if (![nextPage isKindOfClass:[NSNumber class]]) {
            nextPage = nil;
        } else {
            nextPage = [NSNumber numberWithInt:[(NSNumber*)nextPage intValue] + 1];
        }
        
        responseObject = [responseObject objectForKey:@"posts"];
        if (![responseObject isKindOfClass:[NSArray class]]) {
            NSLog(@"can not get user posts");
            continuation(NO,0,nil);
            return;
        }
        
        NSMutableArray *postList = [NSMutableArray array];
        for (id item in responseObject) {
            if (![item isKindOfClass:[NSDictionary class]]) {
                continue;
            }
            
            Post *post =  [Post modelWithDictionary:(NSDictionary *)item];
            id userItem = [item objectForKey:@"user"];
            if (![userItem isKindOfClass:[NSDictionary class]]) continue;
            
            User* user = [[User alloc] initWithDictionary:(NSDictionary *)userItem];
            post.user = user;
            
            [postList addObject:post];
        }
        
        if (continuation) {
            continuation(YES,[nextPage intValue],postList);
        }

        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        
        NSLog(@"can not get user posts:%@",error);
        if (continuation) {
            continuation(NO,0,nil);
        }
    }];
}

+ (void) fetchLikedPostsWithUserId:(NSString*)userId page:(int)page withContinuation:(void(^)(BOOL success,int nextPage, NSArray* array))continuation
{
    NSString *path = [NSString stringWithFormat:USER_LIKED_POSTS_URL,userId];
    [[MOClient sharedClient] getPath:path parameters:page > 1? @{@"page":[NSNumber numberWithInteger:page]}:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        if (![responseObject isKindOfClass:[NSDictionary class]]) {
            NSLog(@"can not get user liked posts");
            continuation(NO,0,nil);
            return;
        }
        
        
        id nextPage = [responseObject objectForKey:@"page"];
        if (![nextPage isKindOfClass:[NSNumber class]]) {
            nextPage = nil;
        } else {
            nextPage = [NSNumber numberWithInt:[(NSNumber*)nextPage intValue] + 1];
        }
        
        responseObject = [responseObject objectForKey:@"posts"];
        if (![responseObject isKindOfClass:[NSArray class]]) {
            NSLog(@"can not get user liked posts");
            continuation(NO,0,nil);
            return;
        }
        
        NSMutableArray *postList = [NSMutableArray array];
        for (id item in responseObject) {
            if (![item isKindOfClass:[NSDictionary class]]) {
                continue;
            }
            
            Post *post =  [Post modelWithDictionary:(NSDictionary *)item];
            
            id userItem = [item objectForKey:@"user"];
            if (![userItem isKindOfClass:[NSDictionary class]]) continue;
            
            User* user = [[User alloc] initWithDictionary:(NSDictionary *)userItem];
            post.user = user;
            
            [postList addObject:post];
        }
        
        if (continuation) {
            continuation(YES,[nextPage intValue],postList);
        }
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        
        NSLog(@"can not get user like posts:%@",error);
        if (continuation) {
            continuation(NO,0,nil);
        }
    }];
}



// add post like post unlike

+ (void) likePost:(User *)user post:(Post*)post withContinuation:(void (^)(BOOL))continuation
{
    NSDictionary *params = @{@"user_id":user.id,
                             @"post_id":post.id};
    
    [[MOClient sharedClient] postPath:USER_LIKE_POST_URL parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        if (![responseObject isKindOfClass:[NSDictionary class]]) {
            if (continuation) {
                continuation(NO);
            }
        }
        
        id likeCount = [responseObject objectForKey:@"like_count"];
        if (likeCount && [likeCount isKindOfClass:[NSNumber class]]) {
            post.like_count = likeCount;
            post.is_like = YES;
            if (continuation) {
                continuation(YES);
            }
        } else {
            if (continuation) {
                continuation(NO);
            }
        }
     
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        
        if (continuation) {
            continuation(NO);
        }
    }];
}

+ (void) unlikePost:(User *)user post:(Post *)post withContinuation:(void (^)(BOOL))continuation
{
    
    NSDictionary *params = @{@"user_id":user.id,
                             @"post_id":post.id};
    
    [[MOClient sharedClient] postPath:USER_UNLIKE_POST_URL parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        if (![responseObject isKindOfClass:[NSDictionary class]]) {
            if (continuation) {
                continuation(NO);
            }
        }
        id likeCount = [responseObject objectForKey:@"like_count"];
        if (likeCount && [likeCount isKindOfClass:[NSNumber class]]) {
            post.like_count = likeCount;
            post.is_like = NO;
            if (continuation) {
                continuation(YES);
            }
        } else {
            if (continuation) {
                continuation(NO);
            }
        }
        
     
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        
        if (continuation) {
            continuation(NO);
        }
        
    }];
    
    
}


+ (void) fetchUserFollowingWithUserId:(NSString*)userId page:(int)page withContinuation:(void(^)(BOOL success,int nextPage,NSArray* array))continuation
{
    NSString *path = [NSString stringWithFormat:USER_FOLLOWING_URL,userId];
    
    [[MOClient sharedClient] getPath:path parameters:page > 1 ? @{@"page":[NSNumber numberWithInteger:page]} : nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        if (![responseObject isKindOfClass:[NSDictionary class]]) {
            NSLog(@"can not get user following");
            continuation(NO,1,nil);
            return;
        }
        
        id nextPage = [responseObject objectForKey:@"page"];
        if (![nextPage isKindOfClass:[NSNumber class]]) {
            nextPage = nil;
        } else {
            nextPage = [NSNumber numberWithInt:[(NSNumber*)nextPage intValue] + 1];
        }
        
        responseObject = [responseObject objectForKey:@"users"];
        if (![responseObject isKindOfClass:[NSArray class]]) {
            NSLog(@"can not get user following ");
            continuation(NO,1,nil);
            return;
        }
        
        NSMutableArray *userList = [NSMutableArray array];
        for (id item in responseObject){
            if (![item isKindOfClass:[NSDictionary class]]) {
                continue;
            }
            User *user = [User modelWithDictionary:(NSDictionary *)item];
            [userList addObject:user];
        }
     
        if(continuation){
            continuation(YES,[nextPage intValue],userList);
        }

     
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        
        if (continuation) {
            continuation(NO,1,nil);
        }
        
    }];

}

+ (void) fetchUserFollowerWithUserId:(NSString*)userId page:(int)page withContinuation:(void(^)(BOOL success,int nextPage,NSArray* array))continuation
{
    NSString *path = [NSString stringWithFormat:USER_FOLLOWER_URL,userId];
    [[MOClient sharedClient] getPath:path parameters:page > 1 ? @{@"page":[NSNumber numberWithInteger:page]} : nil success:^(AFHTTPRequestOperation *operation, id responseObject) {

        if (![responseObject isKindOfClass:[NSDictionary class]]) {
            NSLog(@"can not get user follower");
            continuation(NO,0,nil);
            return;
        }
        
        id nextPage = [responseObject objectForKey:@"page"];
        if (![nextPage isKindOfClass:[NSNumber class]]) {
            nextPage = nil;
        } else {
            nextPage = [NSNumber numberWithInt:[(NSNumber*)nextPage intValue] + 1];
        }
        
        responseObject = [responseObject objectForKey:@"users"];
        if (![responseObject isKindOfClass:[NSArray class]]) {
            NSLog(@"can not get user follower ");
            continuation(NO,0,nil);
            return;
        }
        
        NSMutableArray *userList = [NSMutableArray array];
        for (id item in responseObject){
            if (![item isKindOfClass:[NSDictionary class]]) {
                continue;
            }
            User *user = [User modelWithDictionary:(NSDictionary *)item];
            [userList addObject:user];
        }
        
        if(continuation){
            continuation(YES,[nextPage intValue],userList);
        }
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        
        if (continuation) {
            continuation(NO,1,nil);
        }
    }];

// todo
}


+(void) updatePost:(Post *)post withContinuation:(void (^)(BOOL))continuation
{
    NSLog(@"update post");
}




+(void)fetchTagsWithContinuation:(void (^)(BOOL, NSArray *))continuation
{
    [[MOClient sharedClient] getPath:GET_TAGS parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        NSLog(@"fetch tags %@",responseObject);
        
        if (![responseObject isKindOfClass:[NSDictionary class]]) {
            NSLog(@"can not fetch tags");
            if (continuation) {
                continuation(NO,nil);
            }
            return;
        }     
     
        id tags = [responseObject objectForKey:@"results"];
     
        if(![tags isKindOfClass:[NSArray class]]){
            NSLog(@"can not fetch tags");
            if (continuation) {
                continuation(NO,nil);
            }
            return;
        }
     
        NSMutableArray *tagsList = [NSMutableArray array];

        for (id tagItem in tags) {
            Tag* tag = [[Tag alloc] initWithDictionary:(NSDictionary*)tagItem];
            [tagsList addObject:tag];
        }
        
        if (continuation) {
            continuation(YES,tagsList);
        }
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        
        if (continuation) {
            continuation(NO,nil);
        }
        
    }];
}

+(void)fetchTagWithTag:(Tag *)tag page:(int)page withContinuation:(void (^)(BOOL, int, NSArray *))continuation
{
    NSString *path = [NSString stringWithFormat:GET_TAG_URL,tag.id];
    [[MOClient sharedClient] getPath:path parameters:@{@"page":[NSNumber numberWithInt:page]} success:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        if (![responseObject isKindOfClass:[NSDictionary class]]) {
            if (continuation) {
                continuation(NO,1,nil);
            }
            return;
        }
     
        id posts = [responseObject objectForKey:@"posts"];
     
        if(![posts isKindOfClass:[NSArray class]]){
            NSLog(@"can not fetch posts");
            if (continuation) {
                continuation(NO,1,nil);
            }
            return;
        }
     
        NSMutableArray *postsList = [NSMutableArray array];
     
        for (id postItem in posts){
            if (![postItem isKindOfClass:[NSDictionary class]]) {
                continue;
            }
            Post* post = [Post modelWithDictionary:(NSDictionary *)postItem];
            
            id userItem = [postItem objectForKey:@"user"];
            if (![userItem isKindOfClass:[NSDictionary class]]) continue;
            
            User* user = [[User alloc] initWithDictionary:(NSDictionary *)userItem];
            post.user = user;

         
            [postsList addObject:post];
        }
        
        int page = 1;
        if(postsList.count > 0){
            id pageItem = [responseObject objectForKey:@"page"];
            if (![pageItem isKindOfClass:[NSNumber class]]) {
                if (continuation) {
                    continuation(NO,1,nil);
                }
                return;
            }
            page = [pageItem integerValue] + 1;
         
        } else {
            page = 1;
        }
        
        id tagItem = [responseObject objectForKey:@"tag"];
        if(![tagItem isKindOfClass:[NSDictionary class]]){
            if (continuation) {
                continuation(NO,1,nil);
            }
            return;
        }
     
        Tag *newTag = [Tag modelWithDictionary:(NSDictionary *)tagItem];
     
        [tag mergeValuesForKeysFromModel:newTag];
     
        if(continuation){
            continuation(YES,page,postsList);
        }
     
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        
        if (continuation) {
            continuation(NO,1,nil);
        }
    }];

}



+(void)fetchActivityWithUserId:(NSString *)userId withContinuation:(void (^)(BOOL, NSArray *))continuation
{
    NSString* path = [NSString stringWithFormat:GET_USER_ACTIVITY_URL,userId];
    [[MOClient sharedClient] getPath:path parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        NSLog(@"fetch user activitys %@",responseObject);
        
        if (![responseObject isKindOfClass:[NSDictionary class]]) {
            NSLog(@"can not fetch activitys");
            if (continuation) {
                continuation(NO,nil);
            }
            return;
        }
     
        id activitys = [responseObject objectForKey:@"results"];
     
        if(![activitys isKindOfClass:[NSArray class]]) {
            NSLog(@"can not fetch activitys");
            if (continuation) {
                continuation(NO,nil);
            }
            
        }
     
        NSMutableArray *activityList = [NSMutableArray array];
     
        for( id activityItem in activitys){
            Activity* activity = [Activity modelWithDictionary:(NSDictionary*)activityItem];
            
            if ([activity.atype isEqualToString:@"like"]) {
                id userItem = [activityItem objectForKey:@"user"];
                id postItem = [activityItem objectForKey:@"post"];
                if (![userItem isKindOfClass:[NSDictionary class]] || ![postItem isKindOfClass:[NSDictionary class]]) {
                    continue;
                }
                
                User *user = [User modelWithDictionary:userItem];
                Post *post = [Post modelWithDictionary:postItem];
     
                activity.user =  user;
                activity.post = post;
     
            } else if([activity.atype isEqualToString:@"follow"]){
                id userItem = [activityItem objectForKey:@"user"];
                if (![userItem isKindOfClass:[NSDictionary class]]) {
                    continue;
                }
                
                User *user = [User modelWithDictionary:userItem];
                activity.user = user;
            } else if ([activity.atype isEqualToString:@"comment"]) {
                id userItem = [activityItem objectForKey:@"user"];
                id postItem = [activityItem objectForKey:@"post"];
                id commentItem = [activityItem objectForKey:@"comment"];
                
                if (![userItem isKindOfClass:[NSDictionary class]] || ![postItem isKindOfClass:[NSDictionary class]] || ![commentItem isKindOfClass:[NSDictionary class]]) {
                    continue;
                }
                
                User *user = [User modelWithDictionary:userItem];
                Post *post = [Post modelWithDictionary:postItem];
                Comment *comment = [Comment modelWithDictionary:commentItem];
                
                activity.user =  user;
                activity.post = post;
                activity.comment = comment;
            } else {
                continue;
            }
         
            [activityList addObject:activity];
            
        }
     
        if(continuation) {
            continuation(YES,activityList);
        }
     
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        
        if (continuation) {
            continuation(NO,nil);
        }
        
    }];
}


+(void)fetchNewActivityCountWithUserId:(NSString *)userId withContinuation:(void (^)(BOOL, NSUInteger))continuation
{
    NSString* path = [NSString stringWithFormat:GET_USER_ACTIVITY_COUNT_URL,userId];
    [[MOClient sharedClient] getPath:path parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        if (![responseObject isKindOfClass:[NSDictionary class]]) {
            NSLog(@"can not fetch activity count");
            if (continuation) {
                continuation(NO,nil);
            }
            return;
        }
     
        id activityCount = [responseObject objectForKey:@"count"];
     
        if(![activityCount isKindOfClass:[NSNumber class]]){
            NSLog(@"can not fetch activity count");
            if (continuation) {
                continuation(NO,0);
            }
            return;
           
        }
     
        NSUInteger count = [(NSNumber*)activityCount integerValue];
     
        if(continuation){
            continuation(YES,count);
        }
     
     
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        
        if (continuation) {
            continuation(NO,nil);
        }
    }];
    
}


+(void) publishPostWithVideoURL:(NSURL *)videoURL picURL:(NSURL *)picURL userid:(NSString *)userid extraParams:(NSDictionary *)params WithProgress:(void (^)(CGFloat))progressBlock withContinuation:(void (^)(BOOL, NSError *))continuation
{
    NSMutableDictionary* extparams = [params mutableCopy];
    [extparams setObject:userid forKey:@"author_id"];
    
    NSURLRequest *postRequest = [[MOClient sharedClient]
                                 multipartFormRequestWithMethod:@"POST"
                                 path:NEW_POST_URL
                                 parameters:extparams
                                 constructingBodyWithBlock:^(id<AFMultipartFormData> formData) {
                                     [formData appendPartWithFileURL:videoURL name:@"video_file" error:nil];
                                     [formData appendPartWithFileURL:picURL name:@"pic_file" error:nil];
                                     
                                 }];
    AFHTTPRequestOperation *operation = [[AFJSONRequestOperation alloc] initWithRequest:postRequest];
    [operation setUploadProgressBlock:^(NSUInteger bytesWritten, long long totalBytesWritten, long long totalBytesExpectedToWrite) {
        NSLog(@"bytesWritten:%lu totalBytesWritten:%lld  totalBytesExpectedToWrite:%lld",(unsigned long)bytesWritten,totalBytesWritten,totalBytesExpectedToWrite);
        progressBlock((CGFloat)totalBytesWritten/(CGFloat)totalBytesExpectedToWrite);
    }];
    
    [operation setShouldExecuteAsBackgroundTaskWithExpirationHandler:^{}];
    
    [operation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
        if (continuation) {
            continuation(YES,nil);
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        if (continuation) {
            continuation(NO,error);
        }
    }];
    
    [operation start];
    //[[MOClient sharedClient] enqueueHTTPRequestOperation:operation];
    
}


+ (void)fetchFeedsWithUserId:(NSString*)userId page:(int)page withContinuation:(void (^)(BOOL, int,NSArray *))continuation
{
    NSString* path = [NSString stringWithFormat:GET_USER_FEEDS,userId];
    [[MOClient sharedClient] getPath:path parameters:page > 1? @{@"page":[NSNumber numberWithInteger:page]}:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        
        
        if (![responseObject isKindOfClass:[NSDictionary class]]) {
            NSLog(@"can not get correct dictionary in fetch feeds");
            continuation(NO,0,nil);
            return;
        }
        
        id nextPage = [responseObject objectForKey:@"page"];
        if (![nextPage isKindOfClass:[NSNumber class]]) {
            nextPage = nil;
        } else {
            nextPage = [NSNumber numberWithInt:[(NSNumber*)nextPage intValue] + 1];
        }
        
        
        
        responseObject = [responseObject objectForKey:@"results"];
        if (![responseObject isKindOfClass:[NSArray class]]) {
            NSLog(@"can not get correct array in fetch feeds");
            continuation(NO,0,nil);
            return;
        }
        
        NSMutableArray *feedsList = [NSMutableArray array];
        for (id item in responseObject) {
            if (![item isKindOfClass:[NSDictionary class]]) {
                continue;
            }
            
            //[feedsList addObject:(NSDictionary*)item];
            Post* post = [[Post alloc] initWithDictionary:(NSDictionary *)item];
            id userItem = [item objectForKey:@"user"];
            if (![userItem isKindOfClass:[NSDictionary class]]) continue;
            
            User* user = [[User alloc] initWithDictionary:(NSDictionary *)userItem];
            post.user = user;
            [feedsList addObject:post];
            
        }
        
        if(continuation){
            continuation(YES,[nextPage intValue],feedsList);
        }
        
        
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        
        NSLog(@"can not get user feeds, the error is:%@",error.domain);
        if (continuation) {
            continuation(NO,0,nil);
        }
    }];
}

+ (void)fetchPostComments:(NSString *)postId page:(int)page withContinuation:(void (^)(BOOL, int, NSArray *))continuation
{
    NSString * path = [NSString stringWithFormat:GET_POST_COMMENT_URL,postId];
    
    [[MOClient sharedClient] getPath:path parameters:page > 1 ? @{@"page":[NSNumber numberWithInt:page]} : nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        if (![responseObject isKindOfClass:[NSDictionary class]]) {
            
            if (continuation) {
                continuation(NO,1,nil);
            }
            return;
        }
        
        id commentsItem = [responseObject objectForKey:@"comments"];
        if (![commentsItem isKindOfClass:[NSArray class]]) {
            if (continuation) {
                continuation(NO,1,nil);
            }
            return;
        }
        
        NSMutableArray *commentArray = [NSMutableArray array];
        
        for (id commentItem in commentsItem) {
            if (![commentItem isKindOfClass:[NSDictionary class]]) {
                continue;
            }
            
            Comment *comment = [Comment modelWithDictionary:(NSDictionary *)commentItem];
            
            id userItem = [commentItem objectForKey:@"user"];
            if (![userItem isKindOfClass:[NSDictionary class]]) {
                continue;
            }
            
            User *user = [User modelWithDictionary:(NSDictionary *)userItem];
            comment.user = user;
     
            [commentArray addObject:comment];
        }
     
        
        
        int page = 1;
        id pageItem = [responseObject objectForKey:@"page"];
        if ([pageItem isKindOfClass:[NSNumber class]]) {
            page = [(NSNumber *)pageItem intValue] + 1;
        }
     
        if(continuation){
            continuation(YES,page,commentArray);
        }
        
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        
        if (continuation) {
            continuation(NO,1,nil);
        }
    }];
    
}

+ (void)createComment:(Comment *)comment withContinuation:(void (^)(BOOL))continuation
{
    NSDictionary *params = @{@"author_id":[[MOAuthEngine sharedAuthEngine].currentUser id],
                             @"content":comment.content,
                             @"post_id":comment.post_id};
    
    NSLog(@"createComment params:%@",params);
    [[MOClient sharedClient] postPath:NEW_COMMENT_URL parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        if (![responseObject isKindOfClass:[NSDictionary class]]) {
            if (continuation) {
                continuation(NO);
            }
            return;
        }
        
        if ([responseObject objectForKey:@"error"]) {
            if (continuation) {
                continuation(NO);
            }
            return;
        }
        
        Comment *newComment = [Comment modelWithDictionary:(NSDictionary*)responseObject];
        [comment mergeValuesForKeysFromModel:newComment];
        
        if (continuation) {
            continuation(YES);
        }
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        
        if (continuation) {
            continuation(NO);
        }
        
    }];

}


+ (void)deletePostComment:(NSString *)commentId withContinuation:(void (^)(BOOL))continuation
{
    NSString *path = [NSString stringWithFormat:DELETE_COMMENT_URL,commentId];
    [[MOClient sharedClient] deletePath:path parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
        if (continuation) {
            continuation(YES);
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        if (continuation) {
            continuation(NO);
        }
    }];
}

@end



























