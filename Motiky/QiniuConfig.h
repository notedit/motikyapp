//
//  QiniuConfig.h
//  QiniuSDK
//
//  Created by Qiniu Developers on 12-11-14.
//  Copyright (c) 2012 Shanghai Qiniu Information Technologies Co., Ltd. All rights reserved.
//

#import <Foundation/Foundation.h>

#define kUpHost @"http://up.qbox.me"

#define kBlockSize (4 * 1024 * 1024)  // 4MB
#define kChunkSize (128 * 1024) // 128KB

#define kRetryTimes 3

#define kMaxConcurrentUploads 4