//
//  Utils.h
//  Motiky
//
//  Created by notedit on 4/19/13.
//  Copyright (c) 2013 notedit. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Utils : NSObject

+(NSString *)applicationDocumentsDirectory:(NSString *)filename;
+(NSString *)applicationCachesDirectory:(NSString *)filename;
+(void)saveData:(id)dataToSave to:(NSString *)filename;
+(id)loadDataFrom:(NSString *)filename;
+(CGRect)scaledRect:(CGRect)r;

+ (NSString *)dayOfMonthStringForDate:(NSDate *)date;
+ (NSString *)chineseMonthStringForDate:(NSDate *)date;
+ (NSString *)yearForDate:(NSDate *)date;


+(BOOL)date:(NSDate*)date isSameDayAsDate:(NSDate*)otherDate;
+(NSDate *)midnightStartForDate:(NSDate *)date;

@end
