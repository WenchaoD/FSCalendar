//
//  FScalendar.h
//  Pods
//
//  Created by Wenchao Ding on 29/1/15.
//
//

#import <UIKit/UIKit.h>
#import "FSCalendarHeader.h"

@class FSCalendar;

typedef NS_ENUM(NSInteger, FSCalendarFlow) {
    FSCalendarFlowVertical ,
    FSCalendarFlowHorizontal
};

typedef NS_OPTIONS(NSInteger, FSCalendarUnitAnimation) {
    FSCalendarUnitAnimationNone  = 0,
    FSCalendarUnitAnimationScale = 1,
    FSCalendarUnitAnimationShade = 2
};

typedef NS_OPTIONS(NSInteger, FSCalendarCellStyle) {
    FSCalendarCellStyleCircle         = 0,
    FSCalendarCellStyleRectangle      = 1
};

typedef NS_OPTIONS(NSInteger, FSCalendarCellState) {
    FSCalendarCellStateNormal       = 0,
    FSCalendarCellStateSelected     = 1,
    FSCalendarCellStatePlaceholder  = 1 << 1,
    FSCalendarCellStateDisabled     = 1 << 2,
    FSCalendarCellStateToday        = 1 << 3,
    FSCalendarCellStateWeekend      = 1 << 4
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

@end

@interface FSCalendar : UIView<UIAppearance>

@property (weak, nonatomic) IBOutlet id<FSCalendarDelegate> delegate;
@property (weak, nonatomic) IBOutlet id<FSCalendarDataSource> dataSource;
@property (weak, nonatomic) IBOutlet FSCalendarHeader *header;

@property (copy,     nonatomic) NSDate *currentDate;
@property (readonly, nonatomic) NSDate *currentMonth;
@property (readonly, nonatomic) NSDate *selectedDate;

@property (assign, nonatomic) FSCalendarFlow flow;
@property (assign, nonatomic) FSCalendarCellStyle cellStyle UI_APPEARANCE_SELECTOR;
@property (assign, nonatomic) CGFloat minDissolvedAlpha UI_APPEARANCE_SELECTOR;

@property (assign, nonatomic) BOOL autoAdjustTitleSize;

@property (strong, nonatomic) UIFont   *titleFont UI_APPEARANCE_SELECTOR;
@property (strong, nonatomic) UIFont   *subtitleFont UI_APPEARANCE_SELECTOR;
@property (strong, nonatomic) UIFont   *weekdayFont UI_APPEARANCE_SELECTOR;
@property (strong, nonatomic) UIFont   *headerTitleFont UI_APPEARANCE_SELECTOR;
@property (strong, nonatomic) UIColor  *eventColor UI_APPEARANCE_SELECTOR;
@property (strong, nonatomic) UIColor  *weekdayTextColor UI_APPEARANCE_SELECTOR;

@property (nonatomic) UIColor *titleDefaultColor UI_APPEARANCE_SELECTOR;
@property (nonatomic) UIColor *titleSelectionColor UI_APPEARANCE_SELECTOR;
@property (nonatomic) UIColor *titleTodayColor UI_APPEARANCE_SELECTOR;
@property (nonatomic) UIColor *titlePlaceholderColor UI_APPEARANCE_SELECTOR;
@property (nonatomic) UIColor *titleWeekendColor UI_APPEARANCE_SELECTOR;

@property (nonatomic) UIColor *subtitleDefaultColor UI_APPEARANCE_SELECTOR;
@property (nonatomic) UIColor *subtitleSelectionColor UI_APPEARANCE_SELECTOR;
@property (nonatomic) UIColor *subtitleTodayColor UI_APPEARANCE_SELECTOR;
@property (nonatomic) UIColor *subtitlePlaceholderColor UI_APPEARANCE_SELECTOR;
@property (nonatomic) UIColor *subtitleWeekendColor UI_APPEARANCE_SELECTOR;

@property (nonatomic) UIColor *selectionColor UI_APPEARANCE_SELECTOR;
@property (nonatomic) UIColor *todayColor UI_APPEARANCE_SELECTOR;

@property (nonatomic) UIColor  *headerTitleColor UI_APPEARANCE_SELECTOR;
@property (nonatomic) NSString *headerDateFormat UI_APPEARANCE_SELECTOR;

- (void)reloadData;

@end



