//
//  QiniuResumableUploader
//  QiniuSDK
//
//  Created by Qiniu Developers on 13-2-9.
//  Copyright (c) 2013 Shanghai Qiniu Information Technologies Co., Ltd. All rights reserved.
//

#import "QiniuResumableUploader.h"
#import "QiniuBlockUploadTask.h"
#import "QiniuConfig.h"
#import "QiniuUtils.h"
#import "GTMBase64/GTMBase64.h"
#import "JSONKit/JSONKit.h"

#define kHashKey @"hash"

@implementation QiniuResumableUploader

+ (id) uploaderWithToken:(NSString *)token
{
    return [[[self alloc] initWithToken:token] autorelease];
}

// Must always override super's designated initializer.
- (id)init {
    return [self initWithToken:nil];
}

- (id)initWithToken:(NSString *)token
{
    if (self = [super init]) {
        self.token = token;
    }
    return self;
}

- (void)initBlockEnv:(NSString *)filePath {
    if (_taskQueue) {
        [_taskQueue cancelAllOperations];
        [_taskQueue release];
    }
    
    _taskQueue = [[NSOperationQueue alloc] init];
    [_taskQueue setMaxConcurrentOperationCount:kMaxConcurrentUploads];
    
    _blockCount = calcBlockCount(filePath);
    if (_blockSentBytes) {
        [_blockSentBytes release];
    }
    _blockSentBytes = [[NSMutableArray alloc] initWithCapacity:_blockCount];
    if (_blockChecksums) {
        [_blockChecksums release];
    }
    _blockChecksums = [[NSMutableArray alloc] initWithCapacity:_blockCount];
    for (int i = 0; i < _blockCount; i++) {
        [_blockSentBytes addObject:[NSNumber numberWithLongLong:0]];
        [_blockChecksums addObject:@"<ChecksumPlaceholder>"];
    }
    _completedBlockCount = 0;
    _retriedTimes = 0;
}

- (void) dealloc
{
    self.delegate = nil;
    
    [_taskQueue cancelAllOperations];
    [_taskQueue release];
    [_request clearDelegatesAndCancel];
    [_request release];
    [_token release];
    [_filePath release];
    [_bucket release];
    [_key release];
    [_extraParams release];

    [_host release];
    [_mappedFile release];
    [_blockChecksums release];
    [_blockSentBytes release];
    
    [super dealloc];
}

- (void)setToken:(NSString *)token
{
    if (_token) {
        [_token release];
    }
    _token = [token copy];
}

- (id)token
{
    return _token;
}

- (void)makeFile {
    if (_request) {
        [_request clearDelegatesAndCancel];
        [_request release];
    }
    
    NSString *encodedEntry = urlsafeBase64String([NSString stringWithFormat:@"%@:%@", _bucket, _key]);

    NSMutableString *url = [NSMutableString stringWithFormat:@"%@/rs-mkfile/%@/fsize/%d", _host, encodedEntry, [_mappedFile length]];

    // All of following fields are optional.
    if (_extraParams) {
        [url appendString:prepareExtraParamsString(_extraParams)];
        
        NSObject *paramsObj = [_extraParams objectForKey:@"params"];
        if (paramsObj) {
            [url appendString:@"/params/"];
            [url appendString:urlsafeBase64String(urlParamsString((NSDictionary *)paramsObj))];
        }
    }    
    _request = [[ASIHTTPRequest alloc] initWithURL:[NSURL URLWithString:url]];
    _request.delegate = self;
    
    [_request addRequestHeader:@"Authorization" value:[NSString stringWithFormat:@"UpToken %@", _token]];
    [_request addRequestHeader:@"Content-Type" value:@"text/plain"];

    NSMutableString *ctxArray = [NSMutableString string];
    for (int i = 0; i < _blockCount; i++) {
        [ctxArray appendString:[_blockChecksums objectAtIndex:i]];
         if (i != _blockCount - 1) {
             [ctxArray appendString:@","]; // Add separator
         }
    }
    
    NSData *data = [ctxArray dataUsingEncoding:NSUTF8StringEncoding];
    
    [_request appendPostData:data];
    
    [_request startAsynchronous];
}

// ------------------------------------------------------------------------------------
// @protocol ASIHTTPRequestDelegate

- (void)requestFinished:(ASIHTTPRequest *)request {
    
    if (!request) {
        [self reportFailure:nil];
        return;
    }
    
    int statusCode = [request responseStatusCode];
    if (statusCode / 100 == 2) {
        //
        NSString *responseString = [request responseString];
        NSDictionary *dic = [responseString objectFromJSONString];
        if (dic) {
            //NSObject *hashObj = [dic objectForKey:kHashKey];
            //if (hashObj) {
                [self.delegate uploadSucceeded:_filePath body:dic];
            //}
        }
        
    } else { // Non-2XX are treated as failure.
        if (++_retriedTimes <= kRetryTimes) {
            [self makeFile];
        } else {
            [self reportFailure:request];
        }
    }
}

- (void)requestFailed:(ASIHTTPRequest *)request {
    if (++_retriedTimes <= kRetryTimes) {
        [self makeFile];
    } else {
        [self reportFailure:request];
    }
}

- (void) reportFailure:(ASIHTTPRequest *)request
{
    if (!self.delegate || ![self.delegate respondsToSelector:@selector(uploadFailed:error:)]) {
        return;
    }
    
    NSError *error = prepareRequestError(request);
    
    [self.delegate uploadFailed:_filePath error:error];
}

// ------------------------------------------------------------------------------------
// @protocol QiniuBlockUploadDelegate

// Progress updated. 1.0 indicates 100%.
- (void)uploadProgressUpdated:(int)blockIndex didSendBytes:(long)bytes {

    [_blockSentBytes replaceObjectAtIndex:blockIndex withObject:[NSNumber numberWithLong:bytes]];
    
    long long totalSentBytes = 0;
    
    for (NSNumber *i in _blockSentBytes) {
        totalSentBytes += [i longLongValue];
    }
    
    double percent = (double)totalSentBytes / [_mappedFile length];
    if (percent > 1.0) {
        percent = 1.0; // Avoid improper value that greater than 100%.
    }

    [self.delegate uploadProgressUpdated:_filePath percent:percent];
}

// Block upload completed successfully.
- (void)uploadSucceeded:(int)blockIndex host:(NSString *)host ctx:(NSString *)ctx {
    
    [_blockChecksums replaceObjectAtIndex:blockIndex withObject:ctx];
    
    if (_host) {
        [_host release];
    }
    _host = [host copy];
    
    _completedBlockCount++;
    
    if (_completedBlockCount == _blockCount) { // All blocks have been uploaded.
        
        [self makeFile];
    }
}

// Block upload failed.
- (void)uploadFailed:(int)blockIndex error:(NSError *)error {
    // No need to upload other blocks any more.
    [_taskQueue cancelAllOperations];
    
    [self.delegate uploadFailed:_filePath error:error];
}

// ------------------------------------------------------------------------------------

- (void) upload:(NSString *)filePath
         bucket:(NSString *)bucket
            key:(NSString *)key
    extraParams:(NSDictionary *)extraParams {
    
    if (!filePath || !bucket || !key) {
        [self.delegate uploadFailed:_filePath error:prepareSimpleError(400, @"Invalid argument")];
        return;
    }
    
    if (_mappedFile) {
        [_mappedFile release];
    }
    
    NSError *error = nil;
    _mappedFile = [[NSData alloc] initWithContentsOfFile:filePath
                                                 options:NSDataReadingMappedIfSafe
                                                   error:&error];

    if (error) {
        [self.delegate uploadFailed:filePath error:error];
        return;
    }
    
    NSLog(@"File size: %d", [_mappedFile length]);
    
    _filePath = [filePath copy];
    _bucket = [bucket copy];
    _key = [key copy];
    if (extraParams) {
        _extraParams = [extraParams retain];
    }

    [self initBlockEnv:filePath];
    
    QiniuBlockUploadTask *task;
    for (int i = 0; i < _blockCount; i++) {
        task = [QiniuBlockUploadTask task:_token fileData:_mappedFile blockIndex:i];
        task.delegate = self;
        [_taskQueue addOperation:task];
    }
}

@end
