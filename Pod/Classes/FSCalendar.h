//
//  FScalendar.h
//  Pods
//
//  Created by Wenchao Ding on 29/1/15.
//
//

#import <UIKit/UIKit.h>
#import "FSCalendarAppearance.h"

@class FSCalendar;

#ifndef IBInspectable
#define IBInspectable
#endif

typedef NS_ENUM(NSInteger, FSCalendarFlow) {
    FSCalendarFlowVertical ,
    FSCalendarFlowHorizontal
};


typedef NS_ENUM(NSInteger, FSCalendarCellState) {
    FSCalendarCellStateNormal      = 0,
    FSCalendarCellStateSelected    = 1,
    FSCalendarCellStatePlaceholder = 1 << 1,
    FSCalendarCellStateDisabled    = 1 << 2,
    FSCalendarCellStateToday       = 1 << 3,
    FSCalendarCellStateWeekend     = 1 << 4
};

@protocol FSCalendarDelegate <NSObject>

@optional
- (BOOL)calendar:(FSCalendar *)calendar shouldSelectDate:(NSDate *)date;
- (void)calendar:(FSCalendar *)calendar didSelectDate:(NSDate *)date;
- (void)calendarCurrentMonthDidChange:(FSCalendar *)calendar;

@end

@protocol FSCalendarDataSource <NSObject>

@optional
- (NSString *)calendar:(FSCalendar *)calendar subtitleForDate:(NSDate *)date;
- (UIImage *)calendar:(FSCalendar *)calendar imageForDate:(NSDate *)date;
- (BOOL)calendar:(FSCalendar *)calendar hasEventForDate:(NSDate *)date;
- (NSDate *)minimumDateForCalendar:(FSCalendar *)calendar;
- (NSDate *)maximumDateForCalendar:(FSCalendar *)calendar;

@end


@interface FSCalendar : UIView

@property (weak, nonatomic) IBOutlet id<FSCalendarDelegate>   delegate;
@property (weak, nonatomic) IBOutlet id<FSCalendarDataSource> dataSource;

@property (strong, nonatomic) NSDate *currentDate;
@property (strong, nonatomic) NSDate *selectedDate;
@property (strong, nonatomic) NSDate *currentMonth;

@property (assign, nonatomic) FSCalendarFlow flow;
@property (assign, nonatomic) IBInspectable NSUInteger firstWeekday;
@property (assign, nonatomic) IBInspectable CGFloat    headerHeight;

@property (readonly, nonatomic) FSCalendarAppearance *appearance;
@property (readonly, nonatomic) NSDate *minimumDate;
@property (readonly, nonatomic) NSDate *maximumDate;

- (void)reloadData;
- (void)setSelectedDate:(NSDate *)selectedDate animate:(BOOL)animate;

@end



