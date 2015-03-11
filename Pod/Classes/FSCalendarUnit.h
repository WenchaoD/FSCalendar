//
//  FSCalendarViewUnit.h
//  Pods
//
//  Created by Wenchao Ding on 29/1/15.
//
//

#import <UIKit/UIKit.h>
#import "FSCalendar.h"

@class FSCalendar;

@protocol FSCalendarUnitDataSource, FSCalendarUnitDelegate;

@interface FSCalendarUnit : UIView

@property (weak, nonatomic) id<FSCalendarUnitDataSource> dataSource;
@property (weak, nonatomic) id<FSCalendarUnitDelegate> delegate;

@property (assign, nonatomic) FSCalendarUnitAnimation animation;
@property (assign, nonatomic) FSCalendarUnitStyle style;

@property (strong, nonatomic) UIFont *subtitleFont;
@property (strong, nonatomic) UIFont *titleFont;
@property (strong, nonatomic) UIColor *eventColor;

@property (nonatomic, readonly, getter = isSelected) BOOL selected;
@property (nonatomic, readonly, getter = isPlaceholder) BOOL placeholder;
@property (nonatomic, readonly, getter = isToday) BOOL today;
@property (nonatomic, readonly, getter = isWeekend) BOOL weekend;

@property (nonatomic, readonly) FSCalendarUnitState absoluteState;

@property (strong, nonatomic) NSDate *date;

@end

@protocol FSCalendarUnitDataSource <NSObject>

- (BOOL)unitIsPlaceholder:(FSCalendarUnit *)unit;
- (BOOL)unitIsToday:(FSCalendarUnit *)unit;
- (BOOL)unitIsSelected:(FSCalendarUnit *)unit;

- (NSString *)subtitleForUnit:(FSCalendarUnit *)unit;
- (BOOL)hasEventForUnit:(FSCalendarUnit *)unit;

- (UIColor *)unitColorForUnit:(FSCalendarUnit *)unit;
- (UIColor *)titleColorForUnit:(FSCalendarUnit *)unit;
- (UIColor *)subtitleColorForUnit:(FSCalendarUnit *)unit;

@end

@protocol FSCalendarUnitDelegate <NSObject>

- (void)handleUnitTap:(FSCalendarUnit *)unit;

@end


