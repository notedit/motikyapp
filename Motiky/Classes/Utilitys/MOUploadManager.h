//
//  MOUploadManager.h
//  Motiky
//
//  Created by notedit on 5/14/13.
//  Copyright (c) 2013 notedit. All rights reserved.
//




#import <Foundation/Foundation.h>

@interface MOUploadManager : NSObject


+(MOUploadManager*)sharedManager;
-(void)addUpload:(NSDictionary *)task;
-(void)delUpload:(NSString *)identify;
-(NSArray *)getPendingUploadings;


@end
