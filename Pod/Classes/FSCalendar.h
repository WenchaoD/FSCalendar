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

@end

@interface FSCalendar : UIView<UIAppearance>

@property (weak,   nonatomic) IBOutlet    FSCalendarHeader     *header;
@property (weak,   nonatomic) IBOutlet id<FSCalendarDelegate>   delegate;
@property (weak,   nonatomic) IBOutlet id<FSCalendarDataSource> dataSource;

@property (copy,   nonatomic) NSDate *currentDate;
@property (copy,   nonatomic) NSDate *selectedDate;
@property (copy,   nonatomic) NSDate *currentMonth;

@property (assign, nonatomic) FSCalendarFlow       flow;
@property (assign, nonatomic) NSUInteger           firstWeekday;
@property (assign, nonatomic) BOOL                 autoAdjustTitleSize;

@property (assign, nonatomic) FSCalendarCellStyle cellStyle         UI_APPEARANCE_SELECTOR;
@property (assign, nonatomic) CGFloat             minDissolvedAlpha UI_APPEARANCE_SELECTOR;

@property (strong, nonatomic) UIFont   *titleFont                UI_APPEARANCE_SELECTOR;
@property (strong, nonatomic) UIFont   *subtitleFont             UI_APPEARANCE_SELECTOR;
@property (strong, nonatomic) UIFont   *weekdayFont              UI_APPEARANCE_SELECTOR;
@property (strong, nonatomic) UIColor  *eventColor               UI_APPEARANCE_SELECTOR;
@property (strong, nonatomic) UIColor  *weekdayTextColor         UI_APPEARANCE_SELECTOR;

@property (strong, nonatomic) UIColor  *headerTitleColor         UI_APPEARANCE_SELECTOR;
@property (strong, nonatomic) NSString *headerDateFormat         UI_APPEARANCE_SELECTOR;
@property (strong, nonatomic) UIFont   *headerTitleFont          UI_APPEARANCE_SELECTOR;

@property (weak,   nonatomic) UIColor  *titleDefaultColor        UI_APPEARANCE_SELECTOR;
@property (weak,   nonatomic) UIColor  *titleSelectionColor      UI_APPEARANCE_SELECTOR;
@property (weak,   nonatomic) UIColor  *titleTodayColor          UI_APPEARANCE_SELECTOR;
@property (weak,   nonatomic) UIColor  *titlePlaceholderColor    UI_APPEARANCE_SELECTOR;
@property (weak,   nonatomic) UIColor  *titleWeekendColor        UI_APPEARANCE_SELECTOR;

@property (weak,   nonatomic) UIColor  *subtitleDefaultColor     UI_APPEARANCE_SELECTOR;
@property (weak,   nonatomic) UIColor  *subtitleSelectionColor   UI_APPEARANCE_SELECTOR;
@property (weak,   nonatomic) UIColor  *subtitleTodayColor       UI_APPEARANCE_SELECTOR;
@property (weak,   nonatomic) UIColor  *subtitlePlaceholderColor UI_APPEARANCE_SELECTOR;
@property (weak,   nonatomic) UIColor  *subtitleWeekendColor     UI_APPEARANCE_SELECTOR;

@property (weak,   nonatomic) UIColor  *selectionColor           UI_APPEARANCE_SELECTOR;
@property (weak,   nonatomic) UIColor  *todayColor               UI_APPEARANCE_SELECTOR;

- (void)reloadData;

@end



