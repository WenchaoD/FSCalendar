//
//  FSCalendarDelegationFactory.m
//  FSCalendar
//
//  Created by dingwenchao on 19/12/2016.
//  Copyright © 2016 wenchaoios. All rights reserved.
//

#import "FSCalendarDelegationFactory.h"

#define FSCalendarSelectorEntry(SEL1,SEL2) NSStringFromSelector(@selector(SEL1)):NSStringFromSelector(@selector(SEL2))

@implementation FSCalendarDelegationFactory

+ (FSCalendarDelegationProxy *)dataSourceProxy
{
    FSCalendarDelegationProxy *delegation = [[FSCalendarDelegationProxy alloc] init];
    delegation.protocol = @protocol(FSCalendarDataSource);
    delegation.deprecations = @{FSCalendarSelectorEntry(calendar:numberOfEventsForDate:, calendar:hasEventForDate:)};
    return delegation;
}

+ (FSCalendarDelegationProxy *)delegateProxy
{
    FSCalendarDelegationProxy *delegation = [[FSCalendarDelegationProxy alloc] init];
    delegation.protocol = @protocol(FSCalendarDelegateAppearance);
    delegation.deprecations = @{
                                FSCalendarSelectorEntry(calendarCurrentPageDidChange:, calendarCurrentMonthDidChange:),
                                FSCalendarSelectorEntry(calendar:shouldSelectDate:atMonthPosition:, calendar:shouldSelectDate:),
                                FSCalendarSelectorEntry(calendar:didSelectDate:atMonthPosition:, calendar:didSelectDate:),
                                FSCalendarSelectorEntry(calendar:shouldDeselectDate:atMonthPosition:, calendar:shouldDeselectDate:),
                                FSCalendarSelectorEntry(calendar:didDeselectDate:atMonthPosition:, calendar:didDeselectDate:)
                               };
    return delegation;
}

@end

#undef FSCalendarSelectorEntry

