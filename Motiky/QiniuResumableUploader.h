//
//  QiniuResumableUploader
//  QiniuSDK
//
//  Created by Qiniu Developers on 13-2-9.
//  Copyright (c) 2013 Shanghai Qiniu Information Technologies Co., Ltd. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "QiniuUploadDelegate.h"
#import "QiniuUploader.h"
#import "QiniuBlockUploadTask.h"

@interface QiniuResumableUploader : NSObject<QiniuUploader, QiniuBlockUploadDelegate, ASIHTTPRequestDelegate>
{
    NSString *_token;
    NSString *_filePath;
    NSString *_bucket;
    NSString *_key;
    NSDictionary *_extraParams;
    
    NSString *_host;
    NSData *_mappedFile;
    NSOperationQueue *_taskQueue;
    
    int _blockCount;
    int _completedBlockCount;
    int _retriedTimes;
    
    NSMutableArray *_blockSentBytes; // Length: _blockCount
    NSMutableArray *_blockChecksums; // Length: _blockCount

    ASIHTTPRequest *_request;
}

// Delegates to receive events for upload progress info.
@property (assign, nonatomic) id<QiniuUploadDelegate> delegate;

// Returns a QiniuResumableUploader instance. Auto-released.
//
// If you want to keep the instance for more than one message cycle, please use retain.
//
+ (id) uploaderWithToken:(NSString *)token;

@end
