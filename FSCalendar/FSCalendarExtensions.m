//
//  FSCalendarExtensions.m
//  FSCalendar
//
//  Created by dingwenchao on 10/8/16.
//  Copyright © 2016 wenchaoios. All rights reserved.
//

#import "FSCalendarExtensions.h"
#import <objc/runtime.h>

@implementation UIView (FSCalendarExtensions)

- (CGFloat)fs_width
{
    return CGRectGetWidth(self.frame);
}

- (void)setFs_width:(CGFloat)fs_width
{
    self.frame = CGRectMake(self.fs_left, self.fs_top, fs_width, self.fs_height);
}

- (CGFloat)fs_height
{
    return CGRectGetHeight(self.frame);
}

- (void)setFs_height:(CGFloat)fs_height
{
    self.frame = CGRectMake(self.fs_left, self.fs_top, self.fs_width, fs_height);
}

- (CGFloat)fs_top
{
    return CGRectGetMinY(self.frame);
}

- (void)setFs_top:(CGFloat)fs_top
{
    self.frame = CGRectMake(self.fs_left, fs_top, self.fs_width, self.fs_height);
}

- (CGFloat)fs_bottom
{
    return CGRectGetMaxY(self.frame);
}

- (void)setFs_bottom:(CGFloat)fs_bottom
{
    self.fs_top = fs_bottom - self.fs_height;
}

- (CGFloat)fs_left
{
    return CGRectGetMinX(self.frame);
}

- (void)setFs_left:(CGFloat)fs_left
{
    self.frame = CGRectMake(fs_left, self.fs_top, self.fs_width, self.fs_height);
}

- (CGFloat)fs_right
{
    return CGRectGetMaxX(self.frame);
}

- (void)setFs_right:(CGFloat)fs_right
{
    self.fs_left = self.fs_right - self.fs_width;
}

@end


@implementation CALayer (FSCalendarExtensions)

- (CGFloat)fs_width
{
    return CGRectGetWidth(self.frame);
}

- (void)setFs_width:(CGFloat)fs_width
{
    self.frame = CGRectMake(self.fs_left, self.fs_top, fs_width, self.fs_height);
}

- (CGFloat)fs_height
{
    return CGRectGetHeight(self.frame);
}

- (void)setFs_height:(CGFloat)fs_height
{
    self.frame = CGRectMake(self.fs_left, self.fs_top, self.fs_width, fs_height);
}

- (CGFloat)fs_top
{
    return CGRectGetMinY(self.frame);
}

- (void)setFs_top:(CGFloat)fs_top
{
    self.frame = CGRectMake(self.fs_left, fs_top, self.fs_width, self.fs_height);
}

- (CGFloat)fs_bottom
{
    return CGRectGetMaxY(self.frame);
}

- (void)setFs_bottom:(CGFloat)fs_bottom
{
    self.fs_top = fs_bottom - self.fs_height;
}

- (CGFloat)fs_left
{
    return CGRectGetMinX(self.frame);
}

- (void)setFs_left:(CGFloat)fs_left
{
    self.frame = CGRectMake(fs_left, self.fs_top, self.fs_width, self.fs_height);
}

- (CGFloat)fs_right
{
    return CGRectGetMaxX(self.frame);
}

- (void)setFs_right:(CGFloat)fs_right
{
    self.fs_left = self.fs_right - self.fs_width;
}

@end

@interface NSCalendar (FSCalendarExtensionsPrivate)

@property (readonly, nonatomic) NSDateComponents *fs_privateComponents;

@end

@implementation NSCalendar (FSCalendarExtensions)

- (nullable NSDate *)fs_firstDayOfMonth:(NSDate *)month
{
    if (!month) return nil;
    NSDateComponents *components = [self components:NSCalendarUnitYear|NSCalendarUnitMonth|NSCalendarUnitDay|NSCalendarUnitHour fromDate:month];
    components.day = 1;
    return [self dateFromComponents:components];
}

- (nullable NSDate *)fs_lastDayOfMonth:(NSDate *)month
{
    if (!month) return nil;
    NSDateComponents *components = [self components:NSCalendarUnitYear|NSCalendarUnitMonth|NSCalendarUnitDay|NSCalendarUnitHour fromDate:month];
    components.month++;
    components.day = 0;
    return [self dateFromComponents:components];
}

- (nullable NSDate *)fs_firstDayOfWeek:(NSDate *)week
{
    if (!week) return nil;
    NSDateComponents *weekdayComponents = [self components:NSCalendarUnitWeekday fromDate:week];
    NSDateComponents *components = self.fs_privateComponents;
    components.day = - (weekdayComponents.weekday - self.firstWeekday);
    components.day = (components.day-7) % 7;
    NSDate *firstDayOfWeek = [self dateByAddingComponents:components toDate:week options:0];
    firstDayOfWeek = [self dateBySettingHour:0 minute:0 second:0 ofDate:firstDayOfWeek options:0];
    components.day = NSIntegerMax;
    return firstDayOfWeek;
}

- (nullable NSDate *)fs_lastDayOfWeek:(NSDate *)week
{
    if (!week) return nil;
    NSDateComponents *weekdayComponents = [self components:NSCalendarUnitWeekday fromDate:week];
    NSDateComponents *components = self.fs_privateComponents;
    components.day = - (weekdayComponents.weekday - self.firstWeekday);
    components.day = (components.day-7) % 7 + 6;
    NSDate *lastDayOfWeek = [self dateByAddingComponents:components toDate:week options:0];
    lastDayOfWeek = [self dateBySettingHour:0 minute:0 second:0 ofDate:lastDayOfWeek options:0];
    components.day = NSIntegerMax;
    return lastDayOfWeek;
}

- (nullable NSDate *)fs_middleDayOfWeek:(NSDate *)week
{
    if (!week) return nil;
    NSDateComponents *weekdayComponents = [self components:NSCalendarUnitWeekday fromDate:week];
    NSDateComponents *componentsToSubtract = self.fs_privateComponents;
    componentsToSubtract.day = - (weekdayComponents.weekday - self.firstWeekday) + 3;
    NSDate *middleDayOfWeek = [self dateByAddingComponents:componentsToSubtract toDate:week options:0];
    NSDateComponents *components = [self components:NSCalendarUnitYear|NSCalendarUnitMonth|NSCalendarUnitDay|NSCalendarUnitHour fromDate:middleDayOfWeek];
    middleDayOfWeek = [self dateFromComponents:components];
    componentsToSubtract.day = NSIntegerMax;
    return middleDayOfWeek;
}

- (NSInteger)fs_numberOfDaysInMonth:(NSDate *)month
{
    if (!month) return 0;
    NSRange days = [self rangeOfUnit:NSCalendarUnitDay
                                        inUnit:NSCalendarUnitMonth
                                       forDate:month];
    return days.length;
}

- (NSDateComponents *)fs_privateComponents
{
    NSDateComponents *components = objc_getAssociatedObject(self, _cmd);
    if (!components) {
        components = [[NSDateComponents alloc] init];
        objc_setAssociatedObject(self, _cmd, components, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    }
    return components;
}

@end

@implementation NSCache (FSCalendarExtensions)

- (void)setObject:(nullable id)obj forKeyedSubscript:(id<NSCopying>)key
{
    if (!key) return;
    
    if (obj) {
        [self setObject:obj forKey:key];
    } else {
        [self removeObjectForKey:key];
    }
}

- (id)objectForKeyedSubscript:(id<NSCopying>)key
{
    return [self objectForKey:key];
}

@end

@implementation NSObject (FSCalendarExtensions)

- (void)fs_setVariable:(id)variable forKey:(NSString *)key
{
    Ivar ivar = class_getInstanceVariable(self.class, key.UTF8String);
    object_setIvar(self, ivar, variable);
}

- (id)fs_variableForKey:(NSString *)key
{
    Ivar ivar = class_getInstanceVariable(self.class, key.UTF8String);
    id variable = object_getIvar(self, ivar);
    return variable;
}

- (void)fs_setUnsignedIntegerVariable:(NSUInteger)value forKey:(NSString *)key
{
    Ivar ivar = class_getInstanceVariable([self class], key.UTF8String);
    ((void (*)(id, Ivar, NSUInteger))object_setIvar)(self, ivar, value);
}

- (NSUInteger)fs_unsignedIntegerVariableForKey:(NSString *)key
{
    Ivar ivar = class_getInstanceVariable([self class], key.UTF8String);
    ptrdiff_t offset = ivar_getOffset(ivar);
    unsigned char *bytes = (unsigned char *)(__bridge void*)self;
    NSUInteger value = *((NSUInteger *)(bytes+offset));
    return value;
}

- (id)fs_performSelector:(SEL)selector withObjects:(nullable id)firstObject, ...
{
    if (!selector) return nil;
    NSMethodSignature *signature = [self methodSignatureForSelector:selector];
    if (!signature) return nil;
    NSInvocation *invocation = [NSInvocation invocationWithMethodSignature:signature];
    if (!invocation) return nil;
    invocation.target = self;
    invocation.selector = selector;
    
    // Parameters
    if (firstObject) {
        int index = 2;
        va_list args;
        va_start(args, firstObject);
        if (firstObject) {
            id obj = firstObject;
            do {
                const char *argType = [signature getArgumentTypeAtIndex:index];
                if(!strcmp(argType, @encode(id))){
                    // object
                    [invocation setArgument:&obj atIndex:index++];
                } else {
                    NSString *argTypeString = [NSString stringWithUTF8String:argType];
                    if ([argTypeString hasPrefix:@"{"] && [argTypeString hasSuffix:@"}"]) {
                        // struct
#define PARAM_STRUCT_TYPES(_type,_getter,_default) \
if (!strcmp(argType, @encode(_type))) { \
    _type value = [obj respondsToSelector:@selector(_getter)]?[obj _getter]:_default; \
    [invocation setArgument:&value atIndex:index]; \
}
                        PARAM_STRUCT_TYPES(CGPoint, CGPointValue, CGPointZero)
                        PARAM_STRUCT_TYPES(CGSize, CGSizeValue, CGSizeZero)
                        PARAM_STRUCT_TYPES(CGRect, CGRectValue, CGRectZero)
                        PARAM_STRUCT_TYPES(CGAffineTransform, CGAffineTransformValue, CGAffineTransformIdentity)
                        PARAM_STRUCT_TYPES(CATransform3D, CATransform3DValue, CATransform3DIdentity)
                        PARAM_STRUCT_TYPES(CGVector, CGVectorValue, CGVectorMake(0, 0))
                        PARAM_STRUCT_TYPES(UIEdgeInsets, UIEdgeInsetsValue, UIEdgeInsetsZero)
                        PARAM_STRUCT_TYPES(UIOffset, UIOffsetValue, UIOffsetZero)
                        PARAM_STRUCT_TYPES(NSRange, rangeValue, NSMakeRange(NSNotFound, 0))
                        
#undef PARAM_STRUCT_TYPES
                        index++;
                    } else {
                        // basic type
#define PARAM_BASIC_TYPES(_type,_getter) \
if (!strcmp(argType, @encode(_type))) { \
    _type value = [obj respondsToSelector:@selector(_getter)]?[obj _getter]:0; \
    [invocation setArgument:&value atIndex:index]; \
}
                        PARAM_BASIC_TYPES(BOOL, boolValue)
                        PARAM_BASIC_TYPES(int, intValue)
                        PARAM_BASIC_TYPES(unsigned int, unsignedIntValue)
                        PARAM_BASIC_TYPES(char, charValue)
                        PARAM_BASIC_TYPES(unsigned char, unsignedCharValue)
                        PARAM_BASIC_TYPES(long, longValue)
                        PARAM_BASIC_TYPES(unsigned long, unsignedLongValue)
                        PARAM_BASIC_TYPES(long long, longLongValue)
                        PARAM_BASIC_TYPES(unsigned long long, unsignedLongLongValue)
                        PARAM_BASIC_TYPES(float, floatValue)
                        PARAM_BASIC_TYPES(double, doubleValue)
                        
#undef PARAM_BASIC_TYPES
                        index++;
                    }
                }
            } while((obj = va_arg(args, id)));
            
        }
        va_end(args);
        [invocation retainArguments];
    }
    
    // Execute
    [invocation invoke];
    
    // Return
    const char *returnType = signature.methodReturnType;
    NSUInteger length = [signature methodReturnLength];
    id returnValue;
    if (!strcmp(returnType, @encode(void))){
        // void
        returnValue = nil;
    } else if(!strcmp(returnType, @encode(id))){
        // id
        void *value;
        [invocation getReturnValue:&value];
        returnValue = (__bridge id)(value);
        return returnValue;
    } else {
        NSString *returnTypeString = [NSString stringWithUTF8String:returnType];
        if ([returnTypeString hasPrefix:@"{"] && [returnTypeString hasSuffix:@"}"]) {
            // struct
#define RETURN_STRUCT_TYPES(_type) \
if (!strcmp(returnType, @encode(_type))) { \
    _type value; \
    [invocation getReturnValue:&value]; \
    returnValue = [NSValue value:&value withObjCType:@encode(_type)]; \
}
            RETURN_STRUCT_TYPES(CGPoint)
            RETURN_STRUCT_TYPES(CGSize)
            RETURN_STRUCT_TYPES(CGRect)
            RETURN_STRUCT_TYPES(CGAffineTransform)
            RETURN_STRUCT_TYPES(CATransform3D)
            RETURN_STRUCT_TYPES(CGVector)
            RETURN_STRUCT_TYPES(UIEdgeInsets)
            RETURN_STRUCT_TYPES(UIOffset)
            RETURN_STRUCT_TYPES(NSRange)
            
#undef RETURN_STRUCT_TYPES
        } else {
            // basic
            void *buffer = (void *)malloc(length);
            [invocation getReturnValue:buffer];
#define RETURN_BASIC_TYPES(_type) \
    if (!strcmp(returnType, @encode(_type))) { \
    returnValue = @(*((_type*)buffer)); \
}
            RETURN_BASIC_TYPES(BOOL)
            RETURN_BASIC_TYPES(int)
            RETURN_BASIC_TYPES(unsigned int)
            RETURN_BASIC_TYPES(char)
            RETURN_BASIC_TYPES(unsigned char)
            RETURN_BASIC_TYPES(long)
            RETURN_BASIC_TYPES(unsigned long)
            RETURN_BASIC_TYPES(long long)
            RETURN_BASIC_TYPES(unsigned long long)
            RETURN_BASIC_TYPES(float)
            RETURN_BASIC_TYPES(double)
            
#undef RETURN_BASIC_TYPES
        }
    }
    return returnValue;
}

@end


