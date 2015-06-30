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
    NSDateComponents *component = [calendar components:NSSecondCalendarUnit
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

- (NSInteger)fs_numberOfDaysInMonth
{
    NSCalendar *c = [NSCalendar fs_sharedCalendar];
    NSRange days = [c rangeOfUnit:NSCalendarUnitDay
                           inUnit:NSCalendarUnitMonth
                          forDate:self];
    return days.length;
}

- (NSString *)fs_stringWithFormat:(NSString *)format
{
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    formatter.dateFormat = format;
    return [formatter stringFromDate:self];
}

- (NSDate *)fs_dateByAddingYears:(NSInteger)years
{
    NSCalendar *calendar = [NSCalendar fs_sharedCalendar];
    NSDateComponents *components = [[NSDateComponents alloc] init];
    [components setYear:years];
    
    return [calendar dateByAddingComponents:components toDate:self options:0];
}

- (NSDate *)fs_dateBySubtractingYears:(NSInteger)years
{
    return [self fs_dateByAddingYears:-years];
}

- (NSDate *)fs_dateByAddingMonths:(NSInteger)months
{
    NSCalendar *calendar = [NSCalendar fs_sharedCalendar];
    NSDateComponents *components = [[NSDateComponents alloc] init];
    [components setMonth:months];
    
    return [calendar dateByAddingComponents:components toDate:self options:0];
}

- (NSDate *)fs_dateBySubtractingMonths:(NSInteger)months
{
    return [self fs_dateByAddingMonths:-months];
}

- (NSDate *)fs_dateByAddingWeeks:(NSInteger)weeks
{
    NSCalendar *calendar = [NSCalendar fs_sharedCalendar];
    NSDateComponents *components = [[NSDateComponents alloc] init];
    [components setWeekOfYear:weeks];

    return [calendar dateByAddingComponents:components toDate:self options:0];
}

-(NSDate *)fs_dateBySubtractingWeeks:(NSInteger)weeks
{
    return [self fs_dateByAddingWeeks:-weeks];
}

- (NSDate *)fs_dateByAddingDays:(NSInteger)days
{
    NSCalendar *calendar = [NSCalendar fs_sharedCalendar];
    NSDateComponents *components = [[NSDateComponents alloc] init];
    [components setDay:days];
    return [calendar dateByAddingComponents:components toDate:self options:0];
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

+ (instancetype)fs_dateFromString:(NSString *)string format:(NSString *)format
{
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    formatter.dateFormat = format;
    return [formatter dateFromString:string];
}

+ (instancetype)fs_dateWithYear:(NSInteger)year month:(NSInteger)month day:(NSInteger)day
{
    NSCalendar *calendar = [NSCalendar fs_sharedCalendar];
    NSDateComponents *components = [[NSDateComponents alloc] init];
    components.year = year;
    components.month = month;
    components.day = day;
    return [calendar dateFromComponents:components];
}

@end


@implementation NSCalendar (FSExtension)

+ (instancetype)fs_sharedCalendar
{
    static id instance;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [NSCalendar currentCalendar];
    });
    return instance;
}

@end

