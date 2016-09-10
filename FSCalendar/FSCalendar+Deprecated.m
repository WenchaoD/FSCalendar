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

- (void)setShowsPlaceholders:(BOOL)showsPlaceholders
{
    self.placeholderType = showsPlaceholders ? FSCalendarPlaceholderTypeFillSixRows : FSCalendarPlaceholderTypeNone;
}

- (BOOL)showsPlaceholders
{
    return self.placeholderType == FSCalendarPlaceholderTypeFillSixRows;
}

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

@end
