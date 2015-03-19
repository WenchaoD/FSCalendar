//
//  NSDate+FSExtension.h
//  Pods
//
//  Created by Wenchao Ding on 29/1/15.
//
//

#import <Foundation/Foundation.h>

@interface NSDate (FSExtension)

@property (readonly, nonatomic) NSInteger fs_year;
@property (readonly, nonatomic) NSInteger fs_month;
@property (readonly, nonatomic) NSInteger fs_day;
@property (readonly, nonatomic) NSInteger fs_weekday;
@property (readonly, nonatomic) NSInteger fs_hour;
@property (readonly, nonatomic) NSInteger fs_minute;
@property (readonly, nonatomic) NSInteger fs_second;

@property (readonly, nonatomic) NSInteger fs_numberOfDaysInMonth;

- (NSDate *)fs_dateByAddingMonths:(NSInteger)months;
- (NSDate *)fs_dateBySubtractingMonths:(NSInteger)months;
- (NSDate *)fs_dateByAddingDays:(NSInteger)days;
- (NSDate *)fs_dateBySubtractingDays:(NSInteger)days;
- (NSString *)fs_stringWithFormat:(NSString *)format;

- (NSInteger)fs_yearsFrom:(NSDate *)date;
- (NSInteger)fs_monthsFrom:(NSDate *)date;
- (NSInteger)fs_daysFrom:(NSDate *)date;

- (BOOL)fs_isEqualToDateForMonth:(NSDate *)date;
- (BOOL)fs_isEqualToDateForDay:(NSDate *)date;

+ (instancetype)fs_dateFromString:(NSString *)string format:(NSString *)format;
+ (instancetype)fs_dateWithYear:(NSInteger)year month:(NSInteger)month day:(NSInteger)day;

@end
