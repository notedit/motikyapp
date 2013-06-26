//
//  QiniuBlockUploadTask.m
//  QiniuSDK
//
//  Created by Qiniu Developers on 13-3-8.
//  Copyright (c) 2013 Shanghai Qiniu Information Technologies Co., Ltd. All rights reserved.
//

#import "QiniuBlockUploadTask.h"
#import "QiniuConfig.h"
#import "QiniuUtils.h"
#import "GTMBase64/GTMBase64.h"
#import "JSONKit/JSONKit.h"

#define kContextKey @"ctx"
#define kChecksumKey @"checksum"
#define kHostKey @"host"

@implementation QiniuBlockUploadTask

+ (id)task:(NSString *)token fileData:(NSData *)fileData blockIndex:(int)blockIndex {
    return [[[self alloc] initTask:token fileData:fileData blockIndex:blockIndex] autorelease];
}

- (id)init {
    return [self initTask:nil fileData:nil blockIndex:-1];
}

- (id)initTask:(NSString *)token fileData:(NSData *)fileData blockIndex:(int)blockIndex {
    if (self = [super init]) {
        _token = [token copy];
        _fileData = [fileData retain];
        _blockIndex = blockIndex;
        long long fileSize = [fileData length];
        int blockCount = ceil((double)fileSize / kBlockSize);
        _blockSize = (blockIndex < blockCount - 1) ? kBlockSize : fileSize % kBlockSize;
        _remainingBytes = _blockSize;
        _taskCompleted = false;
    }
    return self;
}

- (void)dealloc {
    self.delegate = nil;
    
    [_request clearDelegatesAndCancel];
    [_request release];
    
    [_token release];
    [_fileData release];
    
    [_context release];
    [_checksum release];
    [_host release];
    
    [super dealloc];
}

- (void)postWithChunk:(NSString *)url chunkIndex:(int)chunkIndex {
    if (_request) {
        [_request clearDelegatesAndCancel];
        [_request release];
    }
    _request = [[ASIHTTPRequest alloc] initWithURL:[NSURL URLWithString:url]];
    _request.delegate = self;
    _request.uploadProgressDelegate = self;
    
    int chunkCount = ceil((double)_blockSize / kChunkSize);
    int chunkSize = (chunkIndex == chunkCount - 1) ? _blockSize - chunkIndex * kChunkSize : kChunkSize;
    int startPos = _blockIndex * kBlockSize + _chunkIndex * kChunkSize;
    
    NSData *bytes = [_fileData subdataWithRange:NSMakeRange(startPos, chunkSize)];
    
    [_request addRequestHeader:@"Authorization" value:[NSString stringWithFormat:@"UpToken %@", _token]];
    [_request appendPostData:bytes];
    [_request startAsynchronous];
}

// Refer to: http://docs.qiniutek.com/v3/api/io/#resumable-upload-mkblk
- (void)sendFirstChunk {
    // Reset the offset.
    _sentChunkBytes = 0;
    
    // TODO: Prepare the request
    NSString *url = [NSString stringWithFormat:@"%@/mkblk/%d", kUpHost, _blockSize];
    
    [self postWithChunk:url chunkIndex:0];
}

// Refer to: http://docs.qiniutek.com/v3/api/io/#resumable-upload-bput
- (void)sendNextChunk {
    // Reset the offset.
    _sentChunkBytes = 0;

    NSString *url = [NSString stringWithFormat:@"%@/bput/%@/%d", _host, _context, _chunkIndex * kChunkSize];
    
    [self postWithChunk:url chunkIndex:_chunkIndex];
}

// Progress
- (void)request:(ASIHTTPRequest *)request didSendBytes:(long long)bytes {
    if (!request) {
        return;
    }
    
    _sentChunkBytes += bytes;
    
    int sentBytes = _chunkIndex * kChunkSize + _sentChunkBytes;
    
    [self.delegate uploadProgressUpdated:_blockIndex didSendBytes:sentBytes];
}

- (bool)handleChunkResult:(NSString *)responseString {
    
    if (!responseString) {
        return false;
    }
    
    NSDictionary *dic = [responseString objectFromJSONString];
    if (!dic) {
        return false;
    }
    
    NSObject *ctxObj = [dic objectForKey:kContextKey];
    if (ctxObj) {
        if (_context) {
            [_context release];
        }
        _context = [(NSString *)ctxObj copy];
    }
    NSObject *checksumObj = [dic objectForKey:kChecksumKey];
    if (checksumObj) {
        if (_checksum) {
            [_checksum release];
        }
        _checksum = [(NSString *)checksumObj copy];
    }
    NSObject *hostObj = [dic objectForKey:kHostKey];
    if (hostObj) {
        if (_host) {
            [_host release];
        }
        _host = [(NSString *)hostObj copy];
    }
    return true;
}

// Finished. This does not always indicate an OK result.
- (void)requestFinished:(ASIHTTPRequest *)request {
    if (!request) {
        [self reportFailure:nil]; // Make sure a failure message is sent.
        return;
    }
    
    int statusCode = [request responseStatusCode];
    if (statusCode / 100 == 2) { // 2xx, indicates success!
        
        // Handle the response
        if (![self handleChunkResult:[request responseString]]) {
            [self reportFailure:nil];
            return;
        }
        
        //int chunkCount = ceil((double)_blockSize / kChunkSize);
        //NSLog(@"Chunk %d/%d of block %d uploaded.", _chunkIndex, chunkCount, _blockIndex);
        
        _remainingBytes -= kChunkSize;
        [self.delegate uploadProgressUpdated:_blockIndex didSendBytes:(_blockSize - _remainingBytes)];
        
        if (_remainingBytes > 0) { // More chunks to read.
            _chunkIndex++;
            [self sendNextChunk];
        } else {
            [self.delegate uploadSucceeded:_blockIndex host:_host ctx:_context];
            _taskCompleted = true; // Task completed.
        }
    } else { // All other results are regarded as failure.
        //
        if (_retriedTimes < 3) {
            _retriedTimes++;
            if (_chunkIndex == 0) { // The first chunk was not sent successfully.
                [self sendFirstChunk];
            } else {
                [self sendNextChunk];
            }
        } else { // Used out of all the retry opportunities.
            [self reportFailure:request];
        }
        return;
    }
}

- (void)reportFailure:(ASIHTTPRequest *)request {
    
    NSError *error = prepareRequestError(request);
    
    [self.delegate uploadFailed:_blockIndex error:error];
    _taskCompleted = true; // Task completed.
}

// Main entry when added to NSOperationQueue.
- (void)main {
    NSLog(@"BlockUploadTask %i started … ", _blockIndex);
    
    NSTimeInterval startTime = [[NSDate date] timeIntervalSince1970];
    
    @autoreleasepool {
        [self sendFirstChunk];
        
        while (!_taskCompleted) {
            [NSThread sleepForTimeInterval:1];
        }
    }

    NSTimeInterval endTime = [[NSDate date] timeIntervalSince1970];
    
    NSLog(@"BlockUploadTask %i completed. (size:%d time:%ldsecs host:%@ )",
          _blockIndex, _blockSize, (long)(endTime - startTime), _host);
}

@end
