//
//  MOClient.h
//  Motiky
//
//  Created by notedit on 2/16/13.
//  Copyright (c) 2013 notedit. All rights reserved.
//

#import "AFHTTPClient.h"

#import "User.h"
#import "Post.h"
#import "Tag.h"
#import "Activity.h"
#import "Comment.h"

@interface MOClient : AFHTTPClient {
    NSString       *_APIBASESTRING;
}

+(MOClient *)sharedClient;


+ (void)incrementActivityCount;
+ (void)decrementActivityCount;

// for qiniu upload
- (NSString*)generateToken:(NSString *)uid withStamp:(NSString *)timestamp;

+ (void) createUserWithWeiboId:(NSString *)weibo token:(NSString*)token withContinuation:(void(^)(BOOL success, NSDictionary* retinfo, NSError* error))continuation;

+ (void) fetchUser:(User *)user withContinuation:(void(^)(BOOL success))continuation;
+ (void) fetchPost:(Post *)post withContinuation:(void(^)(BOOL success))continuetion;
+ (void) updateUser:(User *)user extInfo:(NSDictionary *)extInfo withContinuation:(void(^)(BOOL success))continuation;
+ (void) updatePost:(Post *)post withContinuation:(void(^)(BOOL success))continuation;

+ (void) followUser:(User *)user withContinuation:(void(^)(BOOL success))continuation;
+ (void) unfollowUser:(User *)user withContinuation:(void(^)(BOOL success))continuation;
+ (void) isFollowingUser:(User *)user withContinuation:(void(^)(BOOL success))continuation;

+ (void) fetchUserProfile:(User *)user withContinuation:(void(^)(BOOL success,NSDictionary* profileInfo))continuation;

+ (void) fetchPostForUser:(User *)user page:(int)page continuation:(void(^)(BOOL success,int nextPage,NSArray* array))continuation;

// like && unlike
+ (void)likePost:(User *)user post:(Post*)post withContinuation:(void(^)(BOOL success))continuation;
+ (void)unlikePost:(User *)user post:(Post*)post withContinuation:(void(^)(BOOL success))continuation;


// add 
+ (void) fetchLikedPostsWithUserId:(NSString*)userId page:(int)page withContinuation:(void(^)(BOOL success,int nextPage, NSArray* array))continuation;

+ (void) fetchUserFollowingWithUserId:(NSString*)userId page:(int)page withContinuation:(void(^)(BOOL success,int nextPage,NSArray* array))continuation;

+ (void) fetchUserFollowerWithUserId:(NSString*)userId page:(int)page withContinuation:(void(^)(BOOL success,int nextPage,NSArray* array))continuation;

// new install
+ (void) createUserInstallWithUserId:(NSString *)userId deviceToken:(NSString*)token;


+(void) publishPostWithVideoURL:(NSURL *)videoURL picURL:(NSURL *)picURL userid:(NSString *)userid extraParams:(NSDictionary *)params WithProgress:(void (^)(CGFloat))progressBlock withContinuation:(void (^)(BOOL, NSError *))continuation;

// tag
+ (void) fetchTagsWithContinuation:(void(^)(BOOL success,NSArray* tags))continuation;
+ (void) fetchTagWithTag:(Tag *)tag page:(int)page withContinuation:(void(^)(BOOL success,int nextPage,NSArray* array))continuation;

// feed
+ (void) fetchFeedsWithUserId:(NSString*)userId page:(int)page withContinuation:(void(^)(BOOL success,int nextPage,NSArray* array))continuation;

// activity

+ (void) fetchActivityWithUserId:(NSString*)userId withContinuation:(void(^)(BOOL success,NSArray* array))continuation;
+ (void) fetchNewActivityCountWithUserId:(NSString*)userId withContinuation:(void(^)(BOOL success,NSUInteger count))continuation;

// comment
+ (void) fetchPostComments:(NSString *)postId page:(int)page withContinuation:(void(^)(BOOL success,int nextPage,NSArray *array))continuation;

+ (void) createComment:(Comment *)comment withContinuation:(void(^)(BOOL success))continuation;

+ (void) deletePostComment:(NSString *)commentId withContinuation:(void(^)(BOOL success))continuation;


@end
