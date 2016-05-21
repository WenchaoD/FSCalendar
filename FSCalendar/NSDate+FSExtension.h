//
//  NSDate+FSExtension.h
//  Pods
//
//  Created by Wenchao Ding on 29/1/15.
//
//

#import <Foundation/Foundation.h>

/**
 *  This category is deprecated in this framework as it premised that the calendar should be gregorian. But feel free to use it for gregorian-only.
 */
@interface NSDate (FSExtension)

@property (readonly, nonatomic) NSInteger fs_year;
@property (readonly, nonatomic) NSInteger fs_month;
@property (readonly, nonatomic) NSInteger fs_day;
@property (readonly, nonatomic) NSInteger fs_weekday;
@property (readonly, nonatomic) NSInteger fs_weekOfYear;
@property (readonly, nonatomic) NSInteger fs_hour;
@property (readonly, nonatomic) NSInteger fs_minute;
@property (readonly, nonatomic) NSInteger fs_second;

@property (readonly, nonatomic) NSDate *fs_dateByIgnoringTimeComponents;
@property (readonly, nonatomic) NSDate *fs_firstDayOfMonth;
@property (readonly, nonatomic) NSDate *fs_lastDayOfMonth;
@property (readonly, nonatomic) NSDate *fs_firstDayOfWeek;
@property (readonly, nonatomic) NSDate *fs_middleOfWeek;
@property (readonly, nonatomic) NSDate *fs_tomorrow;
@property (readonly, nonatomic) NSDate *fs_yesterday;
@property (readonly, nonatomic) NSInteger fs_numberOfDaysInMonth;

+ (instancetype)fs_dateFromString:(NSString *)string format:(NSString *)format;
+ (instancetype)fs_dateWithYear:(NSInteger)year month:(NSInteger)month day:(NSInteger)day;

- (NSDate *)fs_dateByAddingYears:(NSInteger)years;
- (NSDate *)fs_dateBySubtractingYears:(NSInteger)years;
- (NSDate *)fs_dateByAddingMonths:(NSInteger)months;
- (NSDate *)fs_dateBySubtractingMonths:(NSInteger)months;
- (NSDate *)fs_dateByAddingWeeks:(NSInteger)weeks;
- (NSDate *)fs_dateBySubtractingWeeks:(NSInteger)weeks;
- (NSDate *)fs_dateByAddingDays:(NSInteger)days;
- (NSDate *)fs_dateBySubtractingDays:(NSInteger)days;
- (NSInteger)fs_yearsFrom:(NSDate *)date;
- (NSInteger)fs_monthsFrom:(NSDate *)date;
- (NSInteger)fs_weeksFrom:(NSDate *)date;
- (NSInteger)fs_daysFrom:(NSDate *)date;

- (BOOL)fs_isEqualToDateForMonth:(NSDate *)date;
- (BOOL)fs_isEqualToDateForWeek:(NSDate *)date;
- (BOOL)fs_isEqualToDateForDay:(NSDate *)date;

- (NSString *)fs_stringWithFormat:(NSString *)format;
- (NSString *)fs_string;

@end


@interface NSCalendar (FSExtension)

+ (instancetype)fs_sharedCalendar;

@end

@interface NSDateFormatter (FSExtension)

+ (instancetype)fs_sharedDateFormatter;

@end

@interface NSDateComponents (FSExtension)

+ (instancetype)fs_sharedDateComponents;

@end



