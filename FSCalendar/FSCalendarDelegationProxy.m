//
//  FSCalendarDelegationProxy.m
//  FSCalendar
//
//  Created by dingwenchao on 11/12/2016.
//  Copyright © 2016 Wenchao Ding. All rights reserved.
//

#import "FSCalendarDelegationProxy.h"
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
    return types?[NSMethodSignature signatureWithObjCTypes:types]:[NSObject methodSignatureForSelector:@selector(init)];
}

- (SEL)deprecatedSelectorOfSelector:(SEL)selector
{
    NSString *selectorString = NSStringFromSelector(selector);
    selectorString = self.deprecations[selectorString];
    return NSSelectorFromString(selectorString);
}

@end
