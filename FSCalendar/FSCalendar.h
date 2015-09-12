//
//  FScalendar.h
//  Pods
//
//  Created by Wenchao Ding on 29/1/15.
//
//

#import <UIKit/UIKit.h>
#import "FSCalendarAppearance.h"

#define FSCalendarDeprecated(message) __attribute((deprecated(message)))

//! Project version number for FSCalendar.
FOUNDATION_EXPORT double FSCalendarVersionNumber;

//! Project version string for FSCalendar.
FOUNDATION_EXPORT const unsigned char FSCalendarVersionString[];

@class FSCalendar;

FSCalendarDeprecated("use \'FSCalendarScrollDirection\' instead")
typedef NS_ENUM(NSInteger, FSCalendarFlow) {
    FSCalendarFlowVertical,
    FSCalendarFlowHorizontal
};

typedef NS_ENUM(NSInteger, FSCalendarScope) {
    FSCalendarScopeMonth,
    FSCalendarScopeWeek
};

typedef NS_ENUM(NSInteger, FSCalendarScrollDirection) {
    FSCalendarScrollDirectionVertical,
    FSCalendarScrollDirectionHorizontal
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
- (BOOL)calendar:(FSCalendar *)calendar shouldDeselectDate:(NSDate *)date;
- (void)calendar:(FSCalendar *)calendar didDeselectDate:(NSDate *)date;
- (void)calendarCurrentPageDidChange:(FSCalendar *)calendar;
- (void)calendarCurrentScopeWillChange:(FSCalendar *)calendar animated:(BOOL)animated;

- (void)calendarCurrentMonthDidChange:(FSCalendar *)calendar FSCalendarDeprecated("use \'calendarCurrentPageDidChange\' instead");

@end

@protocol FSCalendarDataSource <NSObject>

@optional
- (NSString *)calendar:(FSCalendar *)calendar subtitleForDate:(NSDate *)date;
- (UIImage *)calendar:(FSCalendar *)calendar imageForDate:(NSDate *)date;
- (BOOL)calendar:(FSCalendar *)calendar hasEventForDate:(NSDate *)date;
- (NSDate *)minimumDateForCalendar:(FSCalendar *)calendar;
- (NSDate *)maximumDateForCalendar:(FSCalendar *)calendar;

@end

IB_DESIGNABLE
@interface FSCalendar : UIView

@property (weak, nonatomic) IBOutlet id<FSCalendarDelegate> delegate;
@property (weak, nonatomic) IBOutlet id<FSCalendarDataSource> dataSource;

@property (strong, nonatomic) NSDate *today;
@property (strong, nonatomic) NSDate *currentPage;
@property (strong, nonatomic) NSLocale *locale;

@property (assign, nonatomic) FSCalendarScrollDirection scrollDirection;
@property (assign, nonatomic) FSCalendarScope scope;
@property (assign, nonatomic) IBInspectable NSUInteger firstWeekday;
@property (assign, nonatomic) IBInspectable CGFloat headerHeight;
@property (assign, nonatomic) IBInspectable BOOL allowsMultipleSelection;

@property (readonly, nonatomic) FSCalendarAppearance *appearance;
@property (readonly, nonatomic) NSDate *minimumDate;
@property (readonly, nonatomic) NSDate *maximumDate;

@property (readonly, nonatomic) NSDate *selectedDate;
@property (readonly, nonatomic) NSArray *selectedDates;

- (void)reloadData;
- (CGSize)sizeThatFits:(CGSize)size;

- (void)setScope:(FSCalendarScope)scope animated:(BOOL)animated;

- (void)selectDate:(NSDate *)date;
- (void)selectDate:(NSDate *)date scrollToDate:(BOOL)scrollToDate;

- (void)setCurrentPage:(NSDate *)currentPage animated:(BOOL)animated;

@end


@interface FSCalendar (Deprecated)

@property (strong, nonatomic) NSDate *currentMonth FSCalendarDeprecated("use \'currentPage\' instead");
@property (assign, nonatomic) FSCalendarFlow flow FSCalendarDeprecated("use \'scrollDirection\' instead");

- (void)setSelectedDate:(NSDate *)selectedDate FSCalendarDeprecated("use \'selectDate:\' instead");
- (void)setSelectedDate:(NSDate *)selectedDate animate:(BOOL)animate FSCalendarDeprecated("use \'selectDate:scrollToDate:\' instead");

@end


