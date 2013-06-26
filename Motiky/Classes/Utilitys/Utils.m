//
//  Utils.m
//  Motiky
//
//  Created by notedit on 4/19/13.
//  Copyright (c) 2013 notedit. All rights reserved.
//

#import "Utils.h"


static NSCalendar *gregorian = nil;

@implementation Utils


+ (NSString *)applicationDocumentsDirectory:(NSString *)filename
{
	
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,
														 NSUserDomainMask,
														 YES);
    NSString *basePath = ([paths count] > 0) ? [paths objectAtIndex:0] : nil;
	NSString *appendPath = filename;
    return [basePath stringByAppendingPathComponent:appendPath];
}

+(NSString *)applicationCachesDirectory:(NSString *)filename
{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSCachesDirectory,
														 NSUserDomainMask,
														 YES);
    NSString *basePath = ([paths count] > 0) ? [paths objectAtIndex:0] : nil;
    return [basePath stringByAppendingPathComponent:filename];
}

+(id)loadDataFrom:(NSString *)filename
{
	NSString *filePath = [Utils applicationDocumentsDirectory:filename];
	//NSLog(@"load filePath: %@", filePath);
	
	if ([[NSFileManager defaultManager] fileExistsAtPath:filePath])
	{
		NSData *data = [[NSMutableData alloc]
						initWithContentsOfFile:filePath];
		NSKeyedUnarchiver *unarchiver = [[NSKeyedUnarchiver alloc]
										 initForReadingWithData:data];
		id result = [unarchiver decodeObjectForKey:@"data"];
		[unarchiver finishDecoding];
		return result;
	}
	else
	{
		return nil;
	}
}

+(void)saveData:(id)dataToSave to:(NSString *)filename
{
    dispatch_queue_t saveQueue = dispatch_queue_create("save queue", NULL);
    dispatch_async(saveQueue, ^{
        NSMutableData *data = [[NSMutableData alloc] init];
        NSKeyedArchiver *archiver = [[NSKeyedArchiver alloc]
                                     initForWritingWithMutableData:data];
        [archiver encodeObject:dataToSave forKey:@"data"];
        [archiver finishEncoding];
        NSString *filePath = [Utils applicationDocumentsDirectory:filename];
        //NSLog(@"save filePath: %@", filePath);
        [data writeToFile:filePath atomically:YES];
    });
    
}

+(CGRect)scaledRect:(CGRect)r
{
    CGFloat hh      = 320 * 1.1;
    CGFloat ww      = 320 * 1.1;
    r.size.height   = hh;
    r.size.width    = ww;
    r.origin.y      -= (hh - 320) / 2.0;
    r.origin.x      -= (ww - 320) / 2.0;
    return r;

}


static const NSString *chineseNumber[] = {
    @"一",
    @"二",
    @"三",
    @"四",
    @"五",
    @"六",
    @"七",
    @"八",
    @"九",
    @"十",
    @"十一",
    @"十二"};


+ (NSCalendar *)calendar
{
	if (!gregorian) {static dispatch_once_t onceToken;
		dispatch_once(&onceToken, ^{
			gregorian = [[NSCalendar alloc]
						 initWithCalendarIdentifier:NSGregorianCalendar];;
		});
	}
	return gregorian;
}

+ (NSDateComponents *)dateComponentsForDate:(NSDate*)date
{
    NSDateComponents *components =
    [[self calendar] components:(NSDayCalendarUnit | NSWeekdayCalendarUnit | NSMonthCalendarUnit | NSYearCalendarUnit) fromDate:date];
    return components;
}


+ (NSString *)chineseMonthStringForDate:(NSDate *)date; {
    NSDateComponents *components = [self dateComponentsForDate:date];
    NSInteger month = [components month];
    return [NSString stringWithFormat:@"%@月", chineseNumber[month-1]];
}

+ (NSString *)dayOfMonthStringForDate:(NSDate *)date; {
    NSDateComponents *components = [self dateComponentsForDate:date];
    NSInteger day = [components day];
    return [NSString stringWithFormat:@"%d", day];
}

+ (NSString *)yearForDate:(NSDate *)date
{
    NSDateComponents *components = [self dateComponentsForDate:date];
    NSUInteger year = [components year];
    return [NSString stringWithFormat:@"%d", year];
}

+(BOOL)date:(NSDate*)date isSameDayAsDate:(NSDate*)otherDate
{
	NSDateComponents *componentsOne = [self dateComponentsForDate:date];
	NSDateComponents *componentsTwo = [self dateComponentsForDate:otherDate];
	return (([componentsOne year] == [componentsTwo year]) &&
			([componentsOne month] == [componentsTwo month]) &&
			([componentsOne day] == [componentsTwo day]));
}

+(NSDate *)midnightStartForDate:(NSDate *)date
{
	if (!date) {
		return date;
	}
	
	NSDateComponents *componentDate = [self dateComponentsForDate:date];
	NSDate *resultDate = [[self calendar] dateFromComponents:componentDate];
	return resultDate;
}

@end
