//
//  FScalendar.h
//  Pods
//
//  Created by Wenchao Ding on 29/1/15.
//
//

#import <UIKit/UIKit.h>
#import "FSCalendarAppearance.h"
#import "FSCalendarConstance.h"

//! Project version number for FSCalendar.
FOUNDATION_EXPORT double FSCalendarVersionNumber;

//! Project version string for FSCalendar.
FOUNDATION_EXPORT const unsigned char FSCalendarVersionString[];

typedef NS_ENUM(NSUInteger, FSCalendarScope) {
    FSCalendarScopeMonth,
    FSCalendarScopeWeek
};

typedef NS_ENUM(NSUInteger, FSCalendarScrollDirection) {
    FSCalendarScrollDirectionVertical,
    FSCalendarScrollDirectionHorizontal
};


@class FSCalendar;
@protocol FSCalendarDelegateDeprecatedProtocol,FSCalendarDelegateAppearanceDeprecatedProtocol;

@protocol FSCalendarDelegate <FSCalendarDelegateDeprecatedProtocol>

@optional
- (BOOL)calendar:(FSCalendar *)calendar shouldSelectDate:(NSDate *)date;
- (void)calendar:(FSCalendar *)calendar didSelectDate:(NSDate *)date;
- (BOOL)calendar:(FSCalendar *)calendar shouldDeselectDate:(NSDate *)date;
- (void)calendar:(FSCalendar *)calendar didDeselectDate:(NSDate *)date;
- (void)calendarCurrentPageDidChange:(FSCalendar *)calendar;
- (void)calendarCurrentScopeWillChange:(FSCalendar *)calendar animated:(BOOL)animated;

@end

@protocol FSCalendarDataSource <NSObject>

@optional
- (NSString *)calendar:(FSCalendar *)calendar subtitleForDate:(NSDate *)date;
- (UIImage *)calendar:(FSCalendar *)calendar imageForDate:(NSDate *)date;
- (BOOL)calendar:(FSCalendar *)calendar hasEventForDate:(NSDate *)date;
- (NSDate *)minimumDateForCalendar:(FSCalendar *)calendar;
- (NSDate *)maximumDateForCalendar:(FSCalendar *)calendar;

@end

@protocol FSCalendarDelegateAppearance <FSCalendarDelegateAppearanceDeprecatedProtocol>

@optional
- (UIColor *)calendar:(FSCalendar *)calendar appearance:(FSCalendarAppearance *)appearance selectionColorForDate:(NSDate *)date;
- (UIColor *)calendar:(FSCalendar *)calendar appearance:(FSCalendarAppearance *)appearance titleDefaultColorForDate:(NSDate *)date;
- (UIColor *)calendar:(FSCalendar *)calendar appearance:(FSCalendarAppearance *)appearance titleSelectionColorForDate:(NSDate *)date;
- (UIColor *)calendar:(FSCalendar *)calendar appearance:(FSCalendarAppearance *)appearance subtitleDefaultColorForDate:(NSDate *)date;
- (UIColor *)calendar:(FSCalendar *)calendar appearance:(FSCalendarAppearance *)appearance subtitleSelectionColorForDate:(NSDate *)date;
- (UIColor *)calendar:(FSCalendar *)calendar appearance:(FSCalendarAppearance *)appearance eventColorForDate:(NSDate *)date;
- (UIColor *)calendar:(FSCalendar *)calendar appearance:(FSCalendarAppearance *)appearance borderDefaultColorForDate:(NSDate *)date;
- (UIColor *)calendar:(FSCalendar *)calendar appearance:(FSCalendarAppearance *)appearance borderSelectionColorForDate:(NSDate *)date;
- (FSCalendarCellShape)calendar:(FSCalendar *)calendar appearance:(FSCalendarAppearance *)appearance cellShapeForDate:(NSDate *)date;

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
@property (assign, nonatomic) IBInspectable CGFloat weekdayHeight;
@property (assign, nonatomic) IBInspectable BOOL allowsSelection;
@property (assign, nonatomic) IBInspectable BOOL allowsMultipleSelection;
@property (assign, nonatomic) IBInspectable BOOL pagingEnabled;
@property (assign, nonatomic) IBInspectable BOOL scrollEnabled;

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
- (void)deselectDate:(NSDate *)date;

- (void)setCurrentPage:(NSDate *)currentPage animated:(BOOL)animated;

@end

#pragma mark - Deprecate

@interface FSCalendar (Deprecated)
@property (strong, nonatomic) NSDate *currentMonth FSCalendarDeprecated("use \'currentPage\' instead");
@property (assign, nonatomic) FSCalendarFlow flow FSCalendarDeprecated("use \'scrollDirection\' instead");
- (void)setSelectedDate:(NSDate *)selectedDate FSCalendarDeprecated("use \'selectDate:\' instead");
- (void)setSelectedDate:(NSDate *)selectedDate animate:(BOOL)animate FSCalendarDeprecated("use \'selectDate:scrollToDate:\' instead");
@end

@protocol FSCalendarDelegateDeprecatedProtocol <NSObject>
@optional
- (void)calendarCurrentMonthDidChange:(FSCalendar *)calendar FSCalendarDeprecated("use \'calendarCurrentPageDidChange\' instead");
@end

@protocol FSCalendarDelegateAppearanceDeprecatedProtocol <NSObject>
@optional
- (FSCalendarCellStyle)calendar:(FSCalendar *)calendar appearance:(FSCalendarAppearance *)appearance cellStyleForDate:(NSDate *)date FSCalendarDeprecated("use \'calendar:appearance:cellShapeForDate:\' instead");
@end

