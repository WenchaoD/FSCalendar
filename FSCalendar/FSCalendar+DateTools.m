//
//  FSCalendar+DateTools.m
//  FSCalendar
//
//  Created by dingwenchao on 4/29/16.
//  Copyright © 2016 wenchaoios. All rights reserved.
//

#import "FSCalendar.h"
#import "FSCalendarDynamicHeader.h"

@implementation FSCalendar (DateTools)

#pragma mark - Public methods

- (NSInteger)yearOfDate:(NSDate *)date
{
    NSDateComponents *component = [self.calendar components:NSCalendarUnitYear fromDate:date];
    return component.year;
}

- (NSInteger)monthOfDate:(NSDate *)date
{
    NSDateComponents *component = [self.calendar components:NSCalendarUnitMonth
                                                   fromDate:date];
    return component.month;
}

- (NSInteger)dayOfDate:(NSDate *)date
{
    NSDateComponents *component = [self.calendar components:NSCalendarUnitDay
                                                   fromDate:date];
    return component.day;
}

- (NSInteger)weekdayOfDate:(NSDate *)date
{
    NSDateComponents *component = [self.calendar components:NSCalendarUnitWeekday fromDate:date];
    return component.weekday;
}

- (NSInteger)weekOfDate:(NSDate *)date
{
    NSDateComponents *component = [self.calendar components:NSCalendarUnitWeekOfYear fromDate:date];
    return component.weekOfYear;
}

- (NSInteger)hourOfDate:(NSDate *)date
{
    NSDateComponents *component = [self.calendar components:NSCalendarUnitHour
                                                   fromDate:date];
    return component.hour;
}

- (NSInteger)miniuteOfDate:(NSDate *)date
{
    NSDateComponents *component = [self.calendar components:NSCalendarUnitMinute
                                                   fromDate:date];
    return component.minute;
}

- (NSInteger)secondOfDate:(NSDate *)date
{
    NSDateComponents *component = [self.calendar components:NSCalendarUnitSecond
                                                   fromDate:date];
    return component.second;
}

- (NSInteger)numberOfRowsInMonth:(NSDate *)month
{
    if (!month) return 0;
    if (self.placeholderType == FSCalendarPlaceholderTypeFillSixRows) return 6;
    NSDate *firstDayOfMonth = [self beginingOfMonthOfDate:month];
    NSInteger weekdayOfFirstDay = [self weekdayOfDate:firstDayOfMonth];
    NSInteger numberOfDaysInMonth = [self numberOfDatesInMonthOfDate:month];
    NSInteger numberOfPlaceholdersForPrev = ((weekdayOfFirstDay - self.firstWeekday) + 7) % 7;
    NSInteger headDayCount = numberOfDaysInMonth + numberOfPlaceholdersForPrev;
    NSInteger numberOfRows = (headDayCount/7) + (headDayCount%7>0);
    return numberOfRows;
}

- (NSDate *)dateByIgnoringTimeComponentsOfDate:(NSDate *)date
{
    NSDateComponents *components = [self.calendar components:NSCalendarUnitYear|NSCalendarUnitMonth|NSCalendarUnitDay|NSCalendarUnitHour fromDate:date];
    components.hour = FSCalendarDefaultHourComponent;
    return [self.calendar dateFromComponents:components];
}

- (NSDate *)beginingOfMonthOfDate:(NSDate *)date
{
    NSDateComponents *components = [self.calendar components:NSCalendarUnitYear|NSCalendarUnitMonth|NSCalendarUnitDay|NSCalendarUnitHour fromDate:date];
    components.day = 1;
    return [self.calendar dateFromComponents:components];
}

- (NSDate *)endOfMonthOfDate:(NSDate *)date
{
    NSDateComponents *components = [self.calendar components:NSCalendarUnitYear|NSCalendarUnitMonth|NSCalendarUnitDay|NSCalendarUnitHour fromDate:date];
    components.month++;
    components.day = 0;
    return [self.calendar dateFromComponents:components];
}

- (NSDate *)beginingOfWeekOfDate:(NSDate *)date
{
    NSDateComponents *weekdayComponents = [self.calendar components:NSCalendarUnitWeekday fromDate:date];
    NSDateComponents *componentsToSubtract = self.components;
    componentsToSubtract.day = - (weekdayComponents.weekday - self.calendar.firstWeekday);
    componentsToSubtract.day = (componentsToSubtract.day-7) % 7;
    NSDate *beginningOfWeek = [self.calendar dateByAddingComponents:componentsToSubtract toDate:date options:0];
    NSDateComponents *components = [self.calendar components:NSCalendarUnitYear|NSCalendarUnitMonth|NSCalendarUnitDay|NSCalendarUnitHour fromDate:beginningOfWeek];
    beginningOfWeek = [self.calendar dateFromComponents:components];
    componentsToSubtract.day = NSIntegerMax;
    return beginningOfWeek;
}

- (NSDate *)middleOfWeekFromDate:(NSDate *)date
{
    NSDateComponents *weekdayComponents = [self.calendar components:NSCalendarUnitWeekday fromDate:date];
    NSDateComponents *componentsToSubtract = self.components;
    componentsToSubtract.day = - (weekdayComponents.weekday - self.calendar.firstWeekday) + 3;
    NSDate *middleOfWeek = [self.calendar dateByAddingComponents:componentsToSubtract toDate:date options:0];
    NSDateComponents *components = [self.calendar components:NSCalendarUnitYear|NSCalendarUnitMonth|NSCalendarUnitDay|NSCalendarUnitHour fromDate:middleOfWeek];
    middleOfWeek = [self.calendar dateFromComponents:components];
    componentsToSubtract.day = NSIntegerMax;
    return middleOfWeek;
}

- (NSDate *)tomorrowOfDate:(NSDate *)date
{
    NSDateComponents *components = [self.calendar components:NSCalendarUnitYear|NSCalendarUnitMonth|NSCalendarUnitDay|NSCalendarUnitHour fromDate:date];
    components.day++;
    components.hour = FSCalendarDefaultHourComponent;
    return [self.calendar dateFromComponents:components];
}

- (NSDate *)yesterdayOfDate:(NSDate *)date
{
    NSDateComponents *components = [self.calendar components:NSCalendarUnitYear|NSCalendarUnitMonth|NSCalendarUnitDay|NSCalendarUnitHour fromDate:date];
    components.day--;
    components.hour = FSCalendarDefaultHourComponent;
    return [self.calendar dateFromComponents:components];
}

- (NSInteger)numberOfDatesInMonthOfDate:(NSDate *)date
{
    NSRange days = [self.calendar rangeOfUnit:NSCalendarUnitDay
                                       inUnit:NSCalendarUnitMonth
                                      forDate:date];
    return days.length;
}

- (NSDate *)dateFromString:(NSString *)string format:(NSString *)format
{
    self.formatter.dateFormat = format;
    return [self.formatter dateFromString:string];
}

- (NSDate *)dateWithYear:(NSInteger)year month:(NSInteger)month day:(NSInteger)day
{
    NSDateComponents *components = self.components;
    components.year = year;
    components.month = month;
    components.day = day;
    components.hour = FSCalendarDefaultHourComponent;
    NSDate *date = [self.calendar dateFromComponents:components];
    components.year = NSIntegerMax;
    components.month = NSIntegerMax;
    components.day = NSIntegerMax;
    components.hour = NSIntegerMax;
    return date;
}

- (NSDate *)dateByAddingYears:(NSInteger)years toDate:(NSDate *)date
{
    NSDateComponents *components = self.components;
    components.year = years;
    NSDate *d = [self.calendar dateByAddingComponents:components toDate:date options:0];
    components.year = NSIntegerMax;
    return d;
}

- (NSDate *)dateBySubstractingYears:(NSInteger)years fromDate:(NSDate *)date
{
    return [self dateByAddingYears:-years toDate:date];
}

- (NSDate *)dateByAddingMonths:(NSInteger)months toDate:(NSDate *)date
{
    NSDateComponents *components = self.components;
    components.month = months;
    NSDate *d = [self.calendar dateByAddingComponents:components toDate:date options:0];
    components.month = NSIntegerMax;
    return d;
}

- (NSDate *)dateBySubstractingMonths:(NSInteger)months fromDate:(NSDate *)date
{
    return [self dateByAddingMonths:-months toDate:date];
}

- (NSDate *)dateByAddingWeeks:(NSInteger)weeks toDate:(NSDate *)date
{
    NSDateComponents *components = self.components;
    components.weekOfYear = weeks;
    NSDate *d = [self.calendar dateByAddingComponents:components toDate:date options:0];
    components.weekOfYear = NSIntegerMax;
    return d;
}

- (NSDate *)dateBySubstractingWeeks:(NSInteger)weeks fromDate:(NSDate *)date
{
    return [self dateByAddingWeeks:-weeks toDate:date];
}

- (NSDate *)dateByAddingDays:(NSInteger)days toDate:(NSDate *)date
{
    NSDateComponents *components = self.components;
    components.day = days;
    NSDate *d = [self.calendar dateByAddingComponents:components toDate:date options:0];
    components.day = NSIntegerMax;
    return d;
}

- (NSDate *)dateBySubstractingDays:(NSInteger)days fromDate:(NSDate *)date
{
    return [self dateByAddingDays:-days toDate:date];
}

- (NSInteger)yearsFromDate:(NSDate *)fromDate toDate:(NSDate *)toDate
{
    NSDateComponents *components = [self.calendar components:NSCalendarUnitYear
                                                    fromDate:fromDate
                                                      toDate:toDate
                                                     options:0];
    return components.year;
}

- (NSInteger)monthsFromDate:(NSDate *)fromDate toDate:(NSDate *)toDate
{
    NSDateComponents *components = [self.calendar components:NSCalendarUnitMonth
                                                    fromDate:fromDate
                                                      toDate:toDate
                                                     options:0];
    return components.month;
}

- (NSInteger)weeksFromDate:(NSDate *)fromDate toDate:(NSDate *)toDate
{
    NSDateComponents *components = [self.calendar components:NSCalendarUnitWeekOfYear
                                                    fromDate:fromDate
                                                      toDate:toDate
                                                     options:0];
    return components.weekOfYear;
}

- (NSInteger)daysFromDate:(NSDate *)fromDate toDate:(NSDate *)toDate
{
    NSDateComponents *components = [self.calendar components:NSCalendarUnitDay
                                                    fromDate:fromDate
                                                      toDate:toDate
                                                     options:0];
    return components.day;
}

- (BOOL)isDate:(NSDate *)date1 equalToDate:(NSDate *)date2 toCalendarUnit:(FSCalendarUnit)unit
{
    switch (unit) {
        case FSCalendarUnitMonth:
            return [self yearOfDate:date1] == [self yearOfDate:date2] && [self monthOfDate:date1] == [self monthOfDate:date2];
        case FSCalendarUnitWeekOfYear:
            return [self yearOfDate:date1] == [self yearOfDate:date2] && [self weekOfDate:date1] == [self weekOfDate:date2];
        case FSCalendarUnitDay:
            return [self yearOfDate:date1] == [self yearOfDate:date2] && [self monthOfDate:date1] == [self monthOfDate:date2] && [self dayOfDate:date1] == [self dayOfDate:date2];
    }
    return NO;
}

- (BOOL)isDateInToday:(NSDate *)date
{
    return [self isDate:date equalToDate:self.today toCalendarUnit:FSCalendarUnitDay];
}

- (NSString *)stringFromDate:(NSDate *)date format:(NSString *)format
{
    self.formatter.dateFormat = format;
    return [self.formatter stringFromDate:date];
}

- (NSString *)stringFromDate:(NSDate *)date
{
    return [self stringFromDate:date format:@"yyyy-MM-dd"];
}

@end
