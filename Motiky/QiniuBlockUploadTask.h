//
//  QiniuBlockUploadTask.h
//  QiniuSDK
//
//  Created by Qiniu Developers on 13-3-8.
//  Copyright (c) 2013 Shanghai Qiniu Information Technologies Co., Ltd. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ASIHTTPRequest/ASIFormDataRequest.h"

// ------------------------------------------------------------------------------------
// Block upload delegates.

@protocol QiniuBlockUploadDelegate <NSObject>

// Progress updated. 1.0 indicates 100%.
- (void)uploadProgressUpdated:(int)blockIndex didSendBytes:(long)bytes;

// Block upload completed successfully.
- (void)uploadSucceeded:(int)blockIndex host:(NSString *)host ctx:(NSString *)ctx;

// Block upload failed.
- (void)uploadFailed:(int)blockIndex error:(NSError *)error;

@end

// ------------------------------------------------------------------------------------
// Deal with the upload a single block.

@interface QiniuBlockUploadTask : NSOperation<ASIHTTPRequestDelegate, ASIProgressDelegate>
{
    NSString *_token;
    int _blockIndex;
    int _blockSize;
    NSData *_fileData;
    
    // Upload progress info.
    NSString *_host; // The current selected upload host, might vary chunk to chunk, theoretically.
    
    int _chunkIndex;
    int _remainingBytes;
    NSString *_context;
    NSString *_checksum;
    
    // For progress info only.
    int _sentChunkBytes; // _chunkIndex * kChunkSize + _sentChunkBytes == total bytes sent for this block.
    
    int _retriedTimes;
    
    bool _taskCompleted;

    ASIHTTPRequest *_request;
}

@property (assign, nonatomic) id<QiniuBlockUploadDelegate> delegate;

// Returns a properly initialized QiniuBlockUploadTask instance. Auto-released.
//
// If you want to keep the instance for more than one message cycle, please use retain.
//
+ (id) task:(NSString *)token fileData:(NSData *)_fileData blockIndex:(int)blockIndex;

@end

