//
//  FScalendar.h
//  Pods
//
//  Created by Wenchao Ding on 29/1/15.
//
//

#import <UIKit/UIKit.h>

@class FSCalendar;

#ifndef IBInspectable
#define IBInspectable
#endif

typedef NS_ENUM(NSInteger, FSCalendarFlow) {
    FSCalendarFlowVertical ,
    FSCalendarFlowHorizontal
};

typedef NS_OPTIONS(NSInteger, FSCalendarCellStyle) {
    FSCalendarCellStyleCircle      = 0,
    FSCalendarCellStyleRectangle   = 1
};

typedef NS_OPTIONS(NSInteger, FSCalendarCellState) {
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
- (BOOL)calendar:(FSCalendar *)calendar hasEventForDate:(NSDate *)date;
- (NSDate *)minimumDateForCalendar:(FSCalendar *)calendar;
- (NSDate *)maximumDateForCalendar:(FSCalendar *)calendar;

@end

@interface FSCalendar : UIView<UIAppearance>

@property (weak,   nonatomic) IBOutlet id<FSCalendarDelegate>   delegate;
@property (weak,   nonatomic) IBOutlet id<FSCalendarDataSource> dataSource;

@property (strong, nonatomic) NSDate *currentDate;
@property (strong, nonatomic) NSDate *selectedDate;
@property (strong, nonatomic) NSDate *currentMonth;

@property (assign, nonatomic) FSCalendarFlow flow;
@property (assign, nonatomic) IBInspectable NSUInteger firstWeekday;
@property (assign, nonatomic) IBInspectable BOOL       autoAdjustTitleSize;
@property (assign, nonatomic) IBInspectable CGFloat    headerHeight;
@property (assign, nonatomic) IBInspectable CGFloat    minDissolvedAlpha;
@property (assign, nonatomic) FSCalendarCellStyle cellStyle;

@property (strong, nonatomic) UIFont   *titleFont;
@property (strong, nonatomic) UIFont   *subtitleFont;
@property (strong, nonatomic) UIFont   *weekdayFont;
@property (strong, nonatomic) UIColor  *eventColor;
@property (strong, nonatomic) UIColor  *weekdayTextColor;

@property (strong, nonatomic) UIColor  *headerTitleColor;
@property (strong, nonatomic) NSString *headerDateFormat;
@property (strong, nonatomic) UIFont   *headerTitleFont;

@property (strong, nonatomic) UIColor  *titleDefaultColor;
@property (strong, nonatomic) UIColor  *titleSelectionColor;
@property (strong, nonatomic) UIColor  *titleTodayColor;
@property (strong, nonatomic) UIColor  *titlePlaceholderColor;
@property (strong, nonatomic) UIColor  *titleWeekendColor;

@property (strong, nonatomic) UIColor  *subtitleDefaultColor;
@property (strong, nonatomic) UIColor  *subtitleSelectionColor;
@property (strong, nonatomic) UIColor  *subtitleTodayColor;
@property (strong, nonatomic) UIColor  *subtitlePlaceholderColor;
@property (strong, nonatomic) UIColor  *subtitleWeekendColor;

@property (strong, nonatomic) UIColor  *selectionColor;
@property (strong, nonatomic) UIColor  *todayColor;

- (void)reloadData;

@end



