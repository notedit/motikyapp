//
//  QiniuSimpleUploader.m
//  QiniuSimpleUploader
//
//  Created by Qiniu Developers on 12-11-14.
//  Copyright (c) 2012 Shanghai Qiniu Information Technologies Co., Ltd. All rights reserved.
//

#import "QiniuConfig.h"
#import "QiniuSimpleUploader.h"
#import "QiniuUtils.h"
#import "ASIHTTPRequest/ASIFormDataRequest.h"
#import "GTMBase64/GTMBase64.h"
#import "JSONKit/JSONKit.h"

#define kFilePathKey @"filePath"
#define kHashKey @"hash"
#define kExtraParamsKey @"extraParams"


NSString *prepareExtraParamsString(NSDictionary *extraParams) {
    
    NSMutableString *params = [NSMutableString string];
    
    NSObject *mimeTypeObj = [extraParams objectForKey:kMimeTypeKey];
    if (mimeTypeObj) {
        [params appendString:@"/mimeType/"];
        [params appendString:urlsafeBase64String((NSString *)mimeTypeObj)];
    }
    
    NSObject *customMetaObj = [extraParams objectForKey:kCustomMetaKey];
    if (customMetaObj) {
        [params appendString:@"/meta/"];
        [params appendString:urlsafeBase64String((NSString *)customMetaObj)];
    }
    
    NSObject *crc32Obj = [extraParams objectForKey:kCrc32Key];
    if (crc32Obj) {
        [params appendString:@"/crc32/"];
        [params appendString:(NSString *)crc32Obj];
    }
    
    NSObject *customerObj = [extraParams objectForKey:kCustomerKey];
    if (customerObj) {
        [params appendString:@"/customer/"];
        [params appendString:(NSString *)customerObj];
    }
    
    NSObject *rotateObj = [extraParams objectForKey:kRotateKey];
    if (rotateObj) {
        [params appendString:@"/rotate/"];
        [params appendString:(NSString *)rotateObj];
    }
    
    return params;
}


// ------------------------------------------------------------------------------------------

@implementation QiniuSimpleUploader

//@synthesize delegate;

+ (id) uploaderWithToken:(NSString *)token {
    return [[[self alloc] initWithToken:token] autorelease];
}

// Must always override super's designated initializer.
- (id)init {
    return [self initWithToken:nil];
}

- (id)initWithToken:(NSString *)token {
    if (self = [super init]) {
        _token = [token copy];
        _request = nil;
    }
    return self;
}

- (void) dealloc
{
    self.delegate = nil;

    [_token release];
    if (_request) {
        [_request clearDelegatesAndCancel];
        [_request release];
    }
    [_filePath  release];
    [_key release];
    [super dealloc];
}

- (void)setToken:(NSString *)token
{
    [_token autorelease];
    _token = [token copy];
}

- (id)token
{
    return _token;
}

- (void) upload:(NSString *)filePath
         bucket:(NSString *)bucket
            key:(NSString *)key
    extraParams:(NSDictionary *)extraParams
{
    // If upload is called multiple times, we should cancel previous procedure.
    if (_request) {
        [_request clearDelegatesAndCancel];
        [_request release];
    }
    
    if (_filePath) {
        [_filePath  release];
    }
    _filePath = [filePath copy];
    
    if (_bucket) {
        [_bucket release];
    }
    _bucket = [bucket copy];
    
    if (_key) {
        [_key release];
    }
    _key = [key copy];
    
    NSString *url = [NSString stringWithFormat:@"%@/upload", kUpHost];
    
    NSString *encodedEntry = urlsafeBase64String([NSString stringWithFormat:@"%@:%@", bucket, key]);

    // Prepare POST body fields.
    NSMutableString *action = [NSMutableString stringWithFormat:@"/rs-put/%@", encodedEntry];
    
    // All of following fields are optional.
    if (extraParams) {
        [action appendString:prepareExtraParamsString(extraParams)];
    }
    
    _request = [[ASIFormDataRequest alloc] initWithURL:[NSURL URLWithString:url]];
    _request.delegate = self;
    _request.uploadProgressDelegate = self;
    
    [_request addPostValue:action forKey:@"action"];
    [_request addFile:filePath forKey:@"file"];
    
    if (_token) {
        [_request addPostValue:_token forKey:@"auth"];
    }
    
    if (extraParams) {
        NSObject *callbackParamsObj = [extraParams objectForKey:kCallbackParamsKey];
        if (callbackParamsObj != nil) {
            NSDictionary *callbackParams = (NSDictionary *)callbackParamsObj;
            
            [_request addPostValue:urlParamsString(callbackParams) forKey:@"params"];
        }
    }
    
    [_request startAsynchronous];
}

// Progress
- (void) request:(ASIHTTPRequest *)request didSendBytes:(long long)bytes
{
    if (!self.delegate || ![self.delegate respondsToSelector:@selector(uploadProgressUpdated:percent:)]) {
        return;
    }
    
    _sentBytes += bytes;
    
    if (_fileSize > 0) {
        double percent = (double)_sentBytes / _fileSize;
        [self.delegate uploadProgressUpdated:_filePath percent:percent];
    }
}

// Finished. This does not indicate a OK result.
- (void) requestFinished:(ASIHTTPRequest *)request
{
    if (!request) {
        [self reportFailure:nil]; // Make sure a failure message is sent.
        return;
    }
    
    int statusCode = [request responseStatusCode];
    if (statusCode / 100 == 2) { // Success!
        
        if (self.delegate && [self.delegate respondsToSelector:@selector(uploadProgressUpdated:percent:)]) {
            [self.delegate uploadProgressUpdated:_filePath
                                         percent:1.0]; // Ensure a 100% progress message is sent.
        }
            
        if (self.delegate && [self.delegate respondsToSelector:@selector(uploadSucceeded:body:)]) {
            NSString *responseString = [request responseString];
            NSDictionary *body = nil;
            if (responseString) {
                //NSDictionary *dic = [responseString objectFromJSONString];
                body = [responseString objectFromJSONString];
                //NSObject *hashObj = [dic objectForKey:kHashKey];
                //if (hashObj) {
                //    hash = (NSString *)hashObj;
                //}
            }
            [self.delegate uploadSucceeded:_filePath body:body]; // No matter hash is nil or not, send this event.
        }
    } else { // Server returns an error code.
        [self reportFailure:request];
    }
}

// Failed.
- (void) requestFailed:(ASIHTTPRequest *)request
{
    [self reportFailure:request];
}

- (void) reportFailure:(ASIHTTPRequest *)request
{
    if (!self.delegate || ![self.delegate respondsToSelector:@selector(uploadFailed:error:)]) {
        return;
    }
    
    NSError *error = prepareRequestError(request);
    
    [self.delegate uploadFailed:_filePath error:error];
}

@end
