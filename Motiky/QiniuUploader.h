//
//  QiniuUploader.h
//  QiniuSDK
//
//  Created by Hugh Lv on 13-3-9.
//  Copyright (c) 2013年 Shanghai Qiniu Information Technologies Co., Ltd. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol QiniuUploader <NSObject>

@required

- (id)initWithToken:(NSString *)token;

// @brief Upload a local file.
//
// Before calling this function, you need to make sure the corresponding bucket has been created.
// You can make bucket on management console: http://dev.qiniutek.com/ .
//
// Parameter extraParams is for extensibility purpose. It could contain following key-value pair:
//      Key:mimeType Value:NSString *<Custom mime type> -- E.g. "text/plain"
//          This is optional since server side can automatically determine the mime type.
//      Key:customMeta Value:NSString *<Custom meta info> -- For notes purpose.
//          Please refer to http://docs.qiniutek.com/v3/api/words/#CustomMeta
//      Key:crc32 Value:NSString *<CRC32> -- 10-digits CRC value.
//          Please refer to http://docs.qiniutek.com/v3/api/words/#FileCRC32Checksum
//      Key:callbackParams Value:NSDictionary *<Callback Params>
//          Please refer to http://docs.qiniutek.com/v3/api/io/#callback-after-uploaded
//          To use this feature, you also need to retrieve a corresponding token with appropriate authpolicy.
- (void) upload:(NSString *)filePath
         bucket:(NSString *)bucket
            key:(NSString *)key
    extraParams:(NSDictionary *)extraParams;

@end

// Following are the legal keys for extraParams field.

#define kMimeTypeKey @"mimeType"
#define kCustomMetaKey @"customMeta"
#define kCrc32Key @"crc32"
#define kCustomerKey @"customer"
#define kRotateKey @"rotate"
#define kCallbackParamsKey @"callbackParams"

// @brief Convert the extramParams from NSDictionary to a url-safe string.
//
NSString *prepareExtraParamsString(NSDictionary *extraParams);
