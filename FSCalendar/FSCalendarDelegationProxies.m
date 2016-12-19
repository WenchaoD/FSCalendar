//
//  FSCalendarDelegationProxies.m
//  FSCalendar
//
//  Created by dingwenchao on 11/12/2016.
//  Copyright © 2016 Wenchao Ding. All rights reserved.
//

#import "FSCalendarDelegationProxies.h"
#import <objc/runtime.h>

@implementation FSCalendarDelegationProxy

- (instancetype)init
{
    return self;
}

- (BOOL)respondsToSelector:(SEL)selector
{
    BOOL responds = [self.delegation respondsToSelector:selector];
    if (!responds) responds = [self.delegation respondsToSelector:[self deprecatedSelectorOfSelector:selector]];
    if (!responds) responds = [super respondsToSelector:selector];
    return responds;
}

- (BOOL)conformsToProtocol:(Protocol *)protocol
{
    return [self.delegation conformsToProtocol:protocol];
}

- (void)forwardInvocation:(NSInvocation *)invocation
{
    SEL selector = invocation.selector;
    if (![self.delegation respondsToSelector:selector]) {
        selector = [self deprecatedSelectorOfSelector:selector];
        invocation.selector = selector;
    }
    if ([self.delegation respondsToSelector:selector]) {
        [invocation invokeWithTarget:self.delegation];
    }
}

- (NSMethodSignature *)methodSignatureForSelector:(SEL)sel
{
    if ([self.delegation respondsToSelector:sel]) {
        return [(NSObject *)self.delegation methodSignatureForSelector:sel];
    }
    SEL selector = [self deprecatedSelectorOfSelector:sel];
    if ([self.delegation respondsToSelector:selector]) {
        return [(NSObject *)self.delegation methodSignatureForSelector:selector];
    }
#if TARGET_INTERFACE_BUILDER
    return [NSObject methodSignatureForSelector:@selector(init)];
#endif
    struct objc_method_description desc = protocol_getMethodDescription(self.protocol, sel, NO, YES);
    const char *types = desc.types;
    return [NSMethodSignature signatureWithObjCTypes:types];
}

- (SEL)deprecatedSelectorOfSelector:(SEL)selector
{
    NSString *selectorString = NSStringFromSelector(selector);
    selectorString = self.deprecations[selectorString];
    return NSSelectorFromString(selectorString);
}

@end


#define FSCalendarSelectorEntry(SEL1,SEL2) NSStringFromSelector(@selector(SEL1)):NSStringFromSelector(@selector(SEL2))

@implementation FSCalendarDataSourceProxy

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.protocol = @protocol(FSCalendarDataSource);
        self.deprecations = @{FSCalendarSelectorEntry(calendar:numberOfEventsForDate:, calendar:hasEventForDate:)};
    }
    return self;
}

@end

@implementation FSCalendarDelegateProxy

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.protocol = @protocol(FSCalendarDelegateAppearance);
        self.deprecations = @{
                              FSCalendarSelectorEntry(calendarCurrentPageDidChange:, calendarCurrentMonthDidChange:),
                              FSCalendarSelectorEntry(calendar:shouldSelectDate:atMonthPosition:, calendar:shouldSelectDate:),
                              FSCalendarSelectorEntry(calendar:didSelectDate:atMonthPosition:, calendar:didSelectDate:),
                              FSCalendarSelectorEntry(calendar:shouldDeselectDate:atMonthPosition:, calendar:shouldDeselectDate:),
                              FSCalendarSelectorEntry(calendar:didDeselectDate:atMonthPosition:, calendar:didDeselectDate:)
                             };
    }
    return self;
}

@end

#undef FSCalendarSelectorEntry
