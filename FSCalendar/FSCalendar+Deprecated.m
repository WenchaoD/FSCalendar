//
//  FSCalendar+Deprecated.m
//  FSCalendar
//
//  Created by dingwenchao on 4/29/16.
//  Copyright © 2016 wenchaoios. All rights reserved.
//

#import "FSCalendar.h"
#import "FSCalendarDynamicHeader.h"

#pragma mark - Deprecate

@implementation FSCalendar (Deprecated)

- (void)setCurrentMonth:(NSDate *)currentMonth
{
    self.currentPage = currentMonth;
}

- (NSDate *)currentMonth
{
    return self.currentPage;
}

- (void)setFlow:(FSCalendarFlow)flow
{
    self.scrollDirection = (FSCalendarScrollDirection)flow;
}

- (FSCalendarFlow)flow
{
    return (FSCalendarFlow)self.scrollDirection;
}

- (void)setSelectedDate:(NSDate *)selectedDate
{
    [self selectDate:selectedDate];
}

- (void)setSelectedDate:(NSDate *)selectedDate animate:(BOOL)animate
{
    [self selectDate:selectedDate scrollToDate:animate];
}

- (BOOL)date:(NSDate *)date sharesSameMonthWithDate:(NSDate *)anotherDate
{
    return [self yearOfDate:date] == [self yearOfDate:anotherDate] && [self monthOfDate:date] == [self monthOfDate:anotherDate];
}

- (BOOL)date:(NSDate *)date sharesSameWeekWithDate:(NSDate *)anotherDate
{
    return [self yearOfDate:date] == [self yearOfDate:anotherDate] && [self weekOfDate:date] == [self weekOfDate:anotherDate];
}

- (BOOL)date:(NSDate *)date sharesSameDayWithDate:(NSDate *)anotherDate
{
    return [self yearOfDate:date] == [self yearOfDate:anotherDate] && [self monthOfDate:date] == [self monthOfDate:anotherDate] && [self dayOfDate:date] == [self dayOfDate:anotherDate];
}

@end
