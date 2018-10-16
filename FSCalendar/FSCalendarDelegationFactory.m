//
//  FSCalendarDelegationFactory.m
//  FSCalendar
//
//  Created by dingwenchao on 19/12/2016.
//  Copyright © 2016 wenchaoios. All rights reserved.
//

#import "FSCalendarDelegationFactory.h"

@implementation FSCalendarDelegationFactory

+ (FSCalendarDelegationProxy *)dataSourceProxy
{
    FSCalendarDelegationProxy *delegation = [[FSCalendarDelegationProxy alloc] init];
    delegation.protocol = @protocol(FSCalendarDataSource);
    return delegation;
}

+ (FSCalendarDelegationProxy *)delegateProxy
{
    FSCalendarDelegationProxy *delegation = [[FSCalendarDelegationProxy alloc] init];
    delegation.protocol = @protocol(FSCalendarDelegateAppearance);
    return delegation;
}

@end

#undef FSCalendarSelectorEntry

