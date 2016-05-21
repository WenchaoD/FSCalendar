//
//  NSDate+FSExtension.m
//  Pods
//
//  Created by Wenchao Ding on 29/1/15.
//
//

#import "NSDate+FSExtension.h"

@implementation NSDate (FSExtension)

- (NSInteger)fs_year
{
    NSCalendar *calendar = [NSCalendar fs_sharedCalendar];
    NSDateComponents *component = [calendar components:NSCalendarUnitYear fromDate:self];
    return component.year;
}

- (NSInteger)fs_month
{
    NSCalendar *calendar = [NSCalendar fs_sharedCalendar];
    NSDateComponents *component = [calendar components:NSCalendarUnitMonth
                                              fromDate:self];
    return component.month;
}

- (NSInteger)fs_day
{
    NSCalendar *calendar = [NSCalendar fs_sharedCalendar];
    NSDateComponents *component = [calendar components:NSCalendarUnitDay
                                              fromDate:self];
    return component.day;
}

- (NSInteger)fs_weekday
{
    NSCalendar *calendar = [NSCalendar fs_sharedCalendar];
    NSDateComponents *component = [calendar components:NSCalendarUnitWeekday fromDate:self];
    return component.weekday;
}

- (NSInteger)fs_weekOfYear
{
    NSCalendar *calendar = [NSCalendar fs_sharedCalendar];
    NSDateComponents *component = [calendar components:NSCalendarUnitWeekOfYear fromDate:self];
    return component.weekOfYear;
}

- (NSInteger)fs_hour
{
    NSCalendar *calendar = [NSCalendar fs_sharedCalendar];
    NSDateComponents *component = [calendar components:NSCalendarUnitHour
                                              fromDate:self];
    return component.hour;
}

- (NSInteger)fs_minute
{
    NSCalendar *calendar = [NSCalendar fs_sharedCalendar];
    NSDateComponents *component = [calendar components:NSCalendarUnitMinute
                                              fromDate:self];
    return component.minute;
}

- (NSInteger)fs_second
{
    NSCalendar *calendar = [NSCalendar fs_sharedCalendar];
    NSDateComponents *component = [calendar components:NSCalendarUnitSecond
                                              fromDate:self];
    return component.second;
}

- (NSDate *)fs_dateByIgnoringTimeComponents
{
    NSCalendar *calendar = [NSCalendar fs_sharedCalendar];
    NSDateComponents *components = [calendar components:NSCalendarUnitYear|NSCalendarUnitMonth|NSCalendarUnitDay fromDate:self];
    return [calendar dateFromComponents:components];
}

- (NSDate *)fs_firstDayOfMonth
{
    NSCalendar *calendar = [NSCalendar fs_sharedCalendar];
    NSDateComponents *components = [calendar components:NSCalendarUnitYear|NSCalendarUnitMonth| NSCalendarUnitDay fromDate:self];
    components.day = 1;
    return [calendar dateFromComponents:components];
}

- (NSDate *)fs_lastDayOfMonth
{
    NSCalendar *calendar = [NSCalendar fs_sharedCalendar];
    NSDateComponents *components = [calendar components:NSCalendarUnitYear|NSCalendarUnitMonth|NSCalendarUnitDay fromDate:self];
    components.month++;
    components.day = 0;
    return [calendar dateFromComponents:components];
}

- (NSDate *)fs_firstDayOfWeek
{
    NSCalendar *calendar = [NSCalendar fs_sharedCalendar];
    NSDateComponents *weekdayComponents = [calendar components:NSCalendarUnitWeekday fromDate:self];
    NSDateComponents *componentsToSubtract = [NSDateComponents fs_sharedDateComponents];
    componentsToSubtract.day = - (weekdayComponents.weekday - calendar.firstWeekday);
    NSDate *beginningOfWeek = [calendar dateByAddingComponents:componentsToSubtract toDate:self options:0];
    NSDateComponents *components = [calendar components:NSCalendarUnitYear|NSCalendarUnitMonth|NSCalendarUnitDay fromDate:beginningOfWeek];
    beginningOfWeek = [calendar dateFromComponents:components];
    componentsToSubtract.day = NSIntegerMax;
    return beginningOfWeek;
}

- (NSDate *)fs_middleOfWeek
{
    NSCalendar *calendar = [NSCalendar fs_sharedCalendar];
    NSDateComponents *weekdayComponents = [calendar components:NSCalendarUnitWeekday fromDate:self];
    NSDateComponents *componentsToSubtract = [NSDateComponents fs_sharedDateComponents];
    componentsToSubtract.day = - (weekdayComponents.weekday - calendar.firstWeekday) + 3;
    NSDate *middleOfWeek = [calendar dateByAddingComponents:componentsToSubtract toDate:self options:0];
    NSDateComponents *components = [calendar components:NSCalendarUnitYear|NSCalendarUnitMonth|NSCalendarUnitDay fromDate:middleOfWeek];
    middleOfWeek = [calendar dateFromComponents:components];
    componentsToSubtract.day = NSIntegerMax;
    return middleOfWeek;
}

- (NSDate *)fs_tomorrow
{
    NSCalendar *calendar = [NSCalendar fs_sharedCalendar];
    NSDateComponents *components = [calendar components:NSCalendarUnitYear|NSCalendarUnitMonth|NSCalendarUnitDay fromDate:self];
    components.day++;
    return [calendar dateFromComponents:components];
}

- (NSDate *)fs_yesterday
{
    NSCalendar *calendar = [NSCalendar fs_sharedCalendar];
    NSDateComponents *components = [calendar components:NSCalendarUnitYear|NSCalendarUnitMonth|NSCalendarUnitDay fromDate:self];
    components.day--;
    return [calendar dateFromComponents:components];
}

- (NSInteger)fs_numberOfDaysInMonth
{
    NSCalendar *c = [NSCalendar fs_sharedCalendar];
    NSRange days = [c rangeOfUnit:NSCalendarUnitDay
                           inUnit:NSCalendarUnitMonth
                          forDate:self];
    return days.length;
}

+ (instancetype)fs_dateFromString:(NSString *)string format:(NSString *)format
{
    NSDateFormatter *formatter = [NSDateFormatter fs_sharedDateFormatter];
    formatter.dateFormat = format;
    return [formatter dateFromString:string];
}

+ (instancetype)fs_dateWithYear:(NSInteger)year month:(NSInteger)month day:(NSInteger)day
{
    NSCalendar *calendar = [NSCalendar fs_sharedCalendar];
    NSDateComponents *components = [NSDateComponents fs_sharedDateComponents];
    components.year = year;
    components.month = month;
    components.day = day;
    NSDate *date = [calendar dateFromComponents:components];
    components.year = NSIntegerMax;
    components.month = NSIntegerMax;
    components.day = NSIntegerMax;
    return date;
}

- (NSDate *)fs_dateByAddingYears:(NSInteger)years
{
    NSCalendar *calendar = [NSCalendar fs_sharedCalendar];
    NSDateComponents *components = [NSDateComponents fs_sharedDateComponents];
    components.year = years;
    NSDate *date = [calendar dateByAddingComponents:components toDate:self options:0];
    components.year = NSIntegerMax;
    return date;
}

- (NSDate *)fs_dateBySubtractingYears:(NSInteger)years
{
    return [self fs_dateByAddingYears:-years];
}

- (NSDate *)fs_dateByAddingMonths:(NSInteger)months
{
    NSCalendar *calendar = [NSCalendar fs_sharedCalendar];
    NSDateComponents *components = [NSDateComponents fs_sharedDateComponents];
    components.month = months;
    NSDate *date = [calendar dateByAddingComponents:components toDate:self options:0];
    components.month = NSIntegerMax;
    return date;
}

- (NSDate *)fs_dateBySubtractingMonths:(NSInteger)months
{
    return [self fs_dateByAddingMonths:-months];
}

- (NSDate *)fs_dateByAddingWeeks:(NSInteger)weeks
{
    NSCalendar *calendar = [NSCalendar fs_sharedCalendar];
    NSDateComponents *components = [NSDateComponents fs_sharedDateComponents];
    components.weekOfYear = weeks;
    NSDate *date = [calendar dateByAddingComponents:components toDate:self options:0];
    components.weekOfYear = NSIntegerMax;
    return date;
}

-(NSDate *)fs_dateBySubtractingWeeks:(NSInteger)weeks
{
    return [self fs_dateByAddingWeeks:-weeks];
}

- (NSDate *)fs_dateByAddingDays:(NSInteger)days
{
    NSCalendar *calendar = [NSCalendar fs_sharedCalendar];
    NSDateComponents *components = [NSDateComponents fs_sharedDateComponents];
    components.day = days;
    NSDate *date = [calendar dateByAddingComponents:components toDate:self options:0];
    components.day = NSIntegerMax;
    return date;
}

- (NSDate *)fs_dateBySubtractingDays:(NSInteger)days
{
    return [self fs_dateByAddingDays:-days];
}

- (NSInteger)fs_yearsFrom:(NSDate *)date
{
    NSCalendar *calendar = [NSCalendar fs_sharedCalendar];
    NSDateComponents *components = [calendar components:NSCalendarUnitYear
                                               fromDate:date
                                                 toDate:self
                                                options:0];
    return components.year;
}

- (NSInteger)fs_monthsFrom:(NSDate *)date
{
    NSCalendar *calendar = [NSCalendar fs_sharedCalendar];
    NSDateComponents *components = [calendar components:NSCalendarUnitMonth
                                               fromDate:date
                                                 toDate:self
                                                    options:0];
    return components.month;
}

- (NSInteger)fs_weeksFrom:(NSDate *)date
{
    NSCalendar *calendar = [NSCalendar fs_sharedCalendar];
    NSDateComponents *components = [calendar components:NSCalendarUnitWeekOfYear
                                               fromDate:date
                                                 toDate:self
                                                options:0];
    return components.weekOfYear;
}

- (NSInteger)fs_daysFrom:(NSDate *)date
{
    NSCalendar *calendar = [NSCalendar fs_sharedCalendar];
    NSDateComponents *components = [calendar components:NSCalendarUnitDay
                                               fromDate:date
                                                 toDate:self
                                                options:0];
    return components.day;
}

- (NSString *)fs_stringWithFormat:(NSString *)format
{
    NSDateFormatter *formatter = [NSDateFormatter fs_sharedDateFormatter];
    formatter.dateFormat = format;
    return [formatter stringFromDate:self];
}

- (NSString *)fs_string
{
    return [self fs_stringWithFormat:@"yyyyMMdd"];
}


- (BOOL)fs_isEqualToDateForMonth:(NSDate *)date
{
    return self.fs_year == date.fs_year && self.fs_month == date.fs_month;
}

- (BOOL)fs_isEqualToDateForWeek:(NSDate *)date
{
    return self.fs_year == date.fs_year && self.fs_weekOfYear == date.fs_weekOfYear;
}

- (BOOL)fs_isEqualToDateForDay:(NSDate *)date
{
    return self.fs_year == date.fs_year && self.fs_month == date.fs_month && self.fs_day == date.fs_day;
}

@end


@implementation NSCalendar (FSExtension)

+ (instancetype)fs_sharedCalendar
{
    static id instance;
    static dispatch_once_t fs_sharedCalendar_onceToken;
    dispatch_once(&fs_sharedCalendar_onceToken, ^{
        instance = [NSCalendar currentCalendar];
    });
    return instance;
}

@end


@implementation NSDateFormatter (FSExtension)

+ (instancetype)fs_sharedDateFormatter
{
    static id instance;
    static dispatch_once_t fs_sharedDateFormatter_onceToken;
    dispatch_once(&fs_sharedDateFormatter_onceToken, ^{
        instance = [[NSDateFormatter alloc] init];
    });
    return instance;
}

@end

@implementation NSDateComponents (FSExtension)

+ (instancetype)fs_sharedDateComponents
{
    static id instance;
    static dispatch_once_t fs_sharedDateFormatter_onceToken;
    dispatch_once(&fs_sharedDateFormatter_onceToken, ^{
        instance = [[NSDateComponents alloc] init];
    });
    return instance;
}

@end


