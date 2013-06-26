//
//  MOUploadManager.m
//  Motiky
//
//  Created by notedit on 5/14/13.
//  Copyright (c) 2013 notedit. All rights reserved.
//


// 写入
// 先读取plist文件 获取array 写入 并保存

// 删除一个
// 读取plist文件  获取array  删除  并保存

#import "MOUploadManager.h"
#import "Utils.h"
#import "MODefines.h"

@implementation MOUploadManager

+(MOUploadManager *)sharedManager
{
    static MOUploadManager *_uploadManager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _uploadManager = [[MOUploadManager alloc] init];
    });
    
    return _uploadManager;
}

-(void)addUpload:(NSDictionary *)task
{
    NSArray *uploads = [Utils loadDataFrom:PendingUploadingFile];
    NSMutableArray *mutableArray = nil;
    if (uploads) {
        mutableArray = [NSMutableArray array];
    } else {
        mutableArray = [NSMutableArray arrayWithArray:uploads];
    }
    
    NSString *videoURL = [task objectForKey:@"videoURL"];
    
    // 看是否有重复的
    
    for (NSDictionary* _dict in mutableArray) {
        NSString *_videoURL = [_dict objectForKey:@"videoURL"];
        if ([videoURL isEqualToString:_videoURL]) {
            return;
        }
    }
    
    [mutableArray addObject:task];
    
    [Utils saveData:mutableArray to:PendingUploadingFile];

}

-(void)delUpload:(NSString *)identify
{
    NSArray *uploads = [Utils loadDataFrom:PendingUploadingFile];
    
    if (uploads.count == 0) {
        return;
    }
    
    NSMutableArray *originalArrayOfItems = [NSMutableArray arrayWithArray:uploads];
    NSMutableArray *discardedItems = [NSMutableArray array];
    
    for (NSDictionary* _dict in originalArrayOfItems) {
        NSString *videoURL = [_dict objectForKey:@"videoURL"];
        if ([identify isEqualToString:videoURL]) {
            [discardedItems addObject:_dict];
        }
    }
    
    if (discardedItems.count == 0) {
        return;
    }
    
    [originalArrayOfItems removeObjectsInArray:discardedItems];
    
    [Utils saveData:originalArrayOfItems to:PendingUploadingFile];
}

-(NSArray *)getPendingUploadings
{
    NSArray *uploads = [Utils loadDataFrom:PendingUploadingFile];
    return uploads;
}





@end
