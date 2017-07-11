//
//  FSCalendarExtensions.h
//  FSCalendar
//
//  Created by dingwenchao on 10/8/16.
//  Copyright © 2016 Wenchao Ding. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN
#define FORMAT(str, ...) [NSString stringWithFormat: str, __VA_ARGS__]
#define SCREEN_HEIGHT  [[UIScreen mainScreen] bounds].size.height
#define SCREEN_WIDTH   [[UIScreen mainScreen] bounds].size.width
#define FONT_XXL [UIFont systemFontOfSize:18.0]
#define FONT_XL [UIFont systemFontOfSize:17.0]
#define FONT_L [UIFont systemFontOfSize:16.0]
#define FONT_M [UIFont systemFontOfSize:15.0]
#define FONT_LS [UIFont systemFontOfSize:14.0]
#define FONT_S [UIFont systemFontOfSize:13.0]
#define FONT_MS [UIFont systemFontOfSize:12.0]
#define FONT_XS [UIFont systemFontOfSize:11.0]

@interface UIView (FSCalendarExtensions)

@property (nonatomic) CGFloat fs_width;
@property (nonatomic) CGFloat fs_height;

@property (nonatomic) CGFloat fs_top;
@property (nonatomic) CGFloat fs_left;
@property (nonatomic) CGFloat fs_bottom;
@property (nonatomic) CGFloat fs_right;

@property(nonatomic) CGFloat fs_x;
@property(nonatomic) CGFloat fs_y;
@property(nonatomic) CGPoint fs_origin;

@end


@interface CALayer (FSCalendarExtensions)

@property (nonatomic) CGFloat fs_width;
@property (nonatomic) CGFloat fs_height;

@property (nonatomic) CGFloat fs_top;
@property (nonatomic) CGFloat fs_left;
@property (nonatomic) CGFloat fs_bottom;
@property (nonatomic) CGFloat fs_right;

@end


@interface NSCalendar (FSCalendarExtensions)

- (nullable NSDate *)fs_firstDayOfMonth:(NSDate *)month;
- (nullable NSDate *)fs_lastDayOfMonth:(NSDate *)month;
- (nullable NSDate *)fs_firstDayOfWeek:(NSDate *)week;
- (nullable NSDate *)fs_lastDayOfWeek:(NSDate *)week;
- (nullable NSDate *)fs_middleDayOfWeek:(NSDate *)week;
- (NSInteger)fs_numberOfDaysInMonth:(NSDate *)month;

@end

@interface NSMapTable (FSCalendarExtensions)

- (void)setObject:(nullable id)obj forKeyedSubscript:(id<NSCopying>)key;
- (id)objectForKeyedSubscript:(id<NSCopying>)key;

@end

@interface NSCache (FSCalendarExtensions)

- (void)setObject:(nullable id)obj forKeyedSubscript:(id<NSCopying>)key;
- (id)objectForKeyedSubscript:(id<NSCopying>)key;

@end


@interface NSObject (FSCalendarExtensions)

#define IVAR_DEF(SET,GET,TYPE) \
- (void)fs_set##SET##Variable:(TYPE)value forKey:(NSString *)key; \
- (TYPE)fs_##GET##VariableForKey:(NSString *)key;
IVAR_DEF(Bool, bool, BOOL)
IVAR_DEF(Float, float, CGFloat)
IVAR_DEF(Integer, integer, NSInteger)
IVAR_DEF(UnsignedInteger, unsignedInteger, NSUInteger)
#undef IVAR_DEF

- (void)fs_setVariable:(id)variable forKey:(NSString *)key;
- (id)fs_variableForKey:(NSString *)key;

- (nullable id)fs_performSelector:(SEL)selector withObjects:(nullable id)firstObject, ... NS_REQUIRES_NIL_TERMINATION;

@end

NS_ASSUME_NONNULL_END
