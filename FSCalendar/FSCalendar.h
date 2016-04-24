//
//  FSCalendar.h
//  FSCalendar
//
//  Created by Wenchao Ding on 29/1/15.
//  Copyright © 2016 Wenchao Ding. All rights reserved.
// 
//  https://github.com/WenchaoD
//

#import <UIKit/UIKit.h>
#import "FSCalendarAppearance.h"
#import "FSCalendarConstance.h"

/**
 * FSCalendar is a superior awesome calendar control with high performance, high customizablility and very simple usage.
 *
 * @warning All NSDate instances used in the calendar should be managed by the DateTools category. See FSCalendar+DateTools.
 *
 * @see FSCalendarDataSource
 * @see FSCalendarDelegate
 * @see FSCalendarDelegateAppearance
 * @see FSCalendarAppearance
 * @see FSCalendar+DateTools
 */

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

typedef NS_ENUM(NSUInteger, FSCalendarUnit) {
    FSCalendarUnitMonth = NSCalendarUnitMonth,
    FSCalendarUnitWeekOfYear = NSCalendarUnitWeekOfYear,
    FSCalendarUnitDay = NSCalendarUnitDay
};

NS_ASSUME_NONNULL_BEGIN

@class FSCalendar;

/**
 * FSCalendarDataSource is a source set of FSCalendar. The basic job is to provide event、subtitle and min/max day to display for calendar.
 */
@protocol FSCalendarDataSource <NSObject>

@optional

/**
 * Asks the dataSource for a subtitle for the specific date under the day text.
 */
- (nullable NSString *)calendar:(FSCalendar *)calendar subtitleForDate:(NSDate *)date;

/**
 * Asks the dataSource for an image for the specific date.
 */
- (nullable UIImage *)calendar:(FSCalendar *)calendar imageForDate:(NSDate *)date;

/**
 * Asks the dataSource the minimum date to display.
 */
- (NSDate *)minimumDateForCalendar:(FSCalendar *)calendar;

/**
 * Asks the dataSource the maximum date to display.
 */
- (NSDate *)maximumDateForCalendar:(FSCalendar *)calendar;

/**
 * Asks the dataSource the number of event dots for a specific date.
 *
 * @see
 *
 *   - (UIColor *)calendar:(FSCalendar *)calendar appearance:(FSCalendarAppearance *)appearance eventColorForDate:(NSDate *)date;
 *   - (NSArray *)calendar:(FSCalendar *)calendar appearance:(FSCalendarAppearance *)appearance eventColorsForDate:(NSDate *)date;
 */
- (NSInteger)calendar:(FSCalendar *)calendar numberOfEventsForDate:(NSDate *)date;

/**
 * This function is deprecated
 */
- (BOOL)calendar:(FSCalendar *)calendar hasEventForDate:(NSDate *)date FSCalendarDeprecated(-calendar:numberOfEventsForDate:);

@end


/**
 * The delegate of a FSCalendar object must adopt the FSCalendarDelegate protocol. The optional methods of FSCalendarDelegate manage selections、 user events and help to manager the frame of the calendar.
 */
@protocol FSCalendarDelegate <NSObject>

@optional

/**
 * Asks the delegate whether the specific date is allowed to be selected by tapping.
 */
- (BOOL)calendar:(FSCalendar *)calendar shouldSelectDate:(NSDate *)date;

/**
 * Tells the delegate a date in the calendar is selected by tapping.
 */
- (void)calendar:(FSCalendar *)calendar didSelectDate:(NSDate *)date;

/**
 * Asks the delegate whether the specific date is allowed to be deselected by tapping.
 */
- (BOOL)calendar:(FSCalendar *)calendar shouldDeselectDate:(NSDate *)date;

/**
 * Tells the delegate a date in the calendar is deselected by tapping.
 */
- (void)calendar:(FSCalendar *)calendar didDeselectDate:(NSDate *)date;

/**
 * Tells the delegate the calendar is about to change the bounding rect.
 */
- (void)calendar:(FSCalendar *)calendar boundingRectWillChange:(CGRect)bounds animated:(BOOL)animated;

/**
 * Tells the delegate the calendar is about to change the current page.
 */
- (void)calendarCurrentPageDidChange:(FSCalendar *)calendar;

/**
 * These functions are deprecated
 */
- (void)calendarCurrentScopeWillChange:(FSCalendar *)calendar animated:(BOOL)animated FSCalendarDeprecated(-calendar:boundingRectWillChange:animated:);
- (void)calendarCurrentMonthDidChange:(FSCalendar *)calendar FSCalendarDeprecated(-calendarCurrentPageDidChange:);

@end

/**
 * FSCalendarDelegateAppearance determines the fonts and colors of components in the calendar, but more specificly. Basely, if you need to make a global customization of appearance of the calendar, use FSCalendarAppearance. But if you need different appearance for different day, use FSCalendarDelegateAppearance.
 *
 * @see FSCalendarAppearance
 */
@protocol FSCalendarDelegateAppearance <NSObject>

@optional

/**
 * Asks the delegate for a fill color in unselected state for the specific date.
 */
- (nullable UIColor *)calendar:(FSCalendar *)calendar appearance:(FSCalendarAppearance *)appearance fillDefaultColorForDate:(NSDate *)date;

/**
 * Asks the delegate for a fill color in selected state for the specific date.
 */
- (nullable UIColor *)calendar:(FSCalendar *)calendar appearance:(FSCalendarAppearance *)appearance fillSelectionColorForDate:(NSDate *)date;

/**
 * Asks the delegate for day text color in unselected state for the specific date.
 */
- (nullable UIColor *)calendar:(FSCalendar *)calendar appearance:(FSCalendarAppearance *)appearance titleDefaultColorForDate:(NSDate *)date;

/**
 * Asks the delegate for day text color in selected state for the specific date.
 */
- (nullable UIColor *)calendar:(FSCalendar *)calendar appearance:(FSCalendarAppearance *)appearance titleSelectionColorForDate:(NSDate *)date;

/**
 * Asks the delegate for subtitle text color in unselected state for the specific date.
 */
- (nullable UIColor *)calendar:(FSCalendar *)calendar appearance:(FSCalendarAppearance *)appearance subtitleDefaultColorForDate:(NSDate *)date;

/**
 * Asks the delegate for subtitle text color in selected state for the specific date.
 */
- (nullable UIColor *)calendar:(FSCalendar *)calendar appearance:(FSCalendarAppearance *)appearance subtitleSelectionColorForDate:(NSDate *)date;

/**
 * Asks the delegate for single event color for the specific date.
 */
- (nullable UIColor *)calendar:(FSCalendar *)calendar appearance:(FSCalendarAppearance *)appearance eventColorForDate:(NSDate *)date;

/**
 * Asks the delegate for multiple event colors for the specific date.
 */
- (nullable NSArray *)calendar:(FSCalendar *)calendar appearance:(FSCalendarAppearance *)appearance eventColorsForDate:(NSDate *)date;

/**
 * Asks the delegate for a border color in unselected state for the specific date.
 */
- (nullable UIColor *)calendar:(FSCalendar *)calendar appearance:(FSCalendarAppearance *)appearance borderDefaultColorForDate:(NSDate *)date;

/**
 * Asks the delegate for a border color in selected state for the specific date.
 */
- (nullable UIColor *)calendar:(FSCalendar *)calendar appearance:(FSCalendarAppearance *)appearance borderSelectionColorForDate:(NSDate *)date;

/**
 * Asks the delegate for a shape for the specific date.
 */
- (FSCalendarCellShape)calendar:(FSCalendar *)calendar appearance:(FSCalendarAppearance *)appearance cellShapeForDate:(NSDate *)date;

/**
 * These functions are deprecated
 */
- (FSCalendarCellStyle)calendar:(FSCalendar *)calendar appearance:(FSCalendarAppearance *)appearance cellStyleForDate:(NSDate *)date FSCalendarDeprecated(-calendar:appearance:cellShapeForDate:);
- (nullable UIColor *)calendar:(FSCalendar *)calendar appearance:(FSCalendarAppearance *)appearance fillColorForDate:(NSDate *)date FSCalendarDeprecated(-calendar:appearance:fillDefaultColorForDate:);
- (nullable UIColor *)calendar:(FSCalendar *)calendar appearance:(FSCalendarAppearance *)appearance selectionColorForDate:(NSDate *)date FSCalendarDeprecated(-calendar:appearance:fillSelectionColorForDate:);

@end

#pragma mark - Primary

IB_DESIGNABLE
@interface FSCalendar : UIView

/**
 * The object that acts as the delegate of the calendar.
 */
@property (weak, nonatomic) IBOutlet id<FSCalendarDelegate> delegate;

/**
 * The object that acts as the data source of the calendar.
 */
@property (weak, nonatomic) IBOutlet id<FSCalendarDataSource> dataSource;

/**
 * A special mark will be put on today of the calendar
 */
@property (strong, nonatomic) NSDate *today;

/**
 * The current page of calendar
 *
 * @desc In week mode, current page represents the current visible week; In month mode, it means current visible month.
 */
@property (strong, nonatomic) NSDate *currentPage;

/**
 * The locale of month and weekday symbols. Change it to display them in your own language.
 *
 * e.g. To display them in Chinese:
 * 
 *    calendar.locale = [NSLocale localeWithLocaleIdentifier:@"zh-CN"];
 */
@property (strong, nonatomic) NSLocale *locale;

/**
 * Represents the NSCalendarIdentifier of calendar. Default is NSCalendarIdentifierGregorian.
 *
 * e.g. To display a Persian calendar
 *
 *    calendar.identifier = NSCalendarIdentifierPersian;
 */
@property (strong, nonatomic) NSString *identifier;

/**
 * The scroll direction of FSCalendar. 
 *
 * e.g. To make the calendar scroll vertically
 *
 *    calendar.scrollDirection = FSCalendarScrollDirectionVertical;
 */
@property (assign, nonatomic) FSCalendarScrollDirection scrollDirection;

/**
 * The scope of calendar, change scope will trigger an inner frame change, make sure the frame has been correctly adjusted in 
 *
 *    - (void)calendar:(FSCalendar *)calendar boundingRectWillChange:(CGRect)bounds animated:(BOOL)animated;
 */
@property (assign, nonatomic) FSCalendarScope scope;

/**
 * The index of the first weekday of the calendar. Give a '2' to make Monday in the first column.
 */
@property (assign, nonatomic) IBInspectable NSUInteger firstWeekday;

/**
 * The height of month header of the calendar. Give a '0' to remove the header.
 */
@property (assign, nonatomic) IBInspectable CGFloat headerHeight;

/**
 * The height of weekday header of the calendar.
 */
@property (assign, nonatomic) IBInspectable CGFloat weekdayHeight;

/**
 * A Boolean value that determines whether users can select a date.
 */
@property (assign, nonatomic) IBInspectable BOOL allowsSelection;

/**
 * A Boolean value that determines whether users can select more than one date.
 */
@property (assign, nonatomic) IBInspectable BOOL allowsMultipleSelection;

/**
 * A Boolean value that determines whether paging is enabled for the calendar.
 */
@property (assign, nonatomic) IBInspectable BOOL pagingEnabled;

/**
 * A Boolean value that determines whether scrolling is enabled for the calendar.
 */
@property (assign, nonatomic) IBInspectable BOOL scrollEnabled;

/**
 * A Boolean value that determines whether scoping animation is centered a visible selected date. Default is YES.
 */
@property (assign, nonatomic) IBInspectable BOOL focusOnSingleSelectedDate;

/**
 * A Boolean value that determines whether the calendar should show days out of month. Default is YES.
 */
@property (assign, nonatomic) IBInspectable BOOL showsPlaceholders;

/**
 * The calendar appearance used to control the global fonts、colors .etc
 */
@property (readonly, nonatomic) FSCalendarAppearance *appearance;

/**
 * A date object representing the minimum day enable、visible and selectable. (read-only)
 */
@property (readonly, nonatomic) NSDate *minimumDate;

/**
 * A date object representing the maximum day enable、visible and selectable. (read-only)
 */
@property (readonly, nonatomic) NSDate *maximumDate;

/**
 * A date object identifying the section of the selected date. (read-only)
 */
@property (readonly, nonatomic) NSDate *selectedDate;

/**
 * The dates representing the selected dates. (read-only)
 */
@property (readonly, nonatomic) NSArray *selectedDates;

/**
 * Reload the dates and appearance of the calendar.
 */
- (void)reloadData;

/**
 * Change the scope of the calendar. Make sure `-calendar:boundingRectWillChange:animated` is correctly adopted.
 *
 * @param scope The target scope to change.
 * @param animated YES if you want to animate the scoping; NO if the change should be immediate.
 */
- (void)setScope:(FSCalendarScope)scope animated:(BOOL)animated;

/**
 * Selects a given date in the calendar.
 *
 * @param date A date in the calendar.
 */
- (void)selectDate:(NSDate *)date;

/**
 * Selects a given date in the calendar, optionally scrolling the date to visible area.
 *
 * @param date A date in the calendar.
 * @param scrollToDate A Boolean value that determines whether the calendar should scroll to the selected date to visible area.
 */
- (void)selectDate:(NSDate *)date scrollToDate:(BOOL)scrollToDate;

/**
 * Deselects a given date of the calendar.
 * @param date A date in the calendar.
 */
- (void)deselectDate:(NSDate *)date;

/**
 * Changes the current page of the calendar.
 *
 * @param currentPage Representing weekOfYear in week mode, or month in month mode.
 * @param animated YES if you want to animate the change in position; NO if it should be immediate.
 */
- (void)setCurrentPage:(NSDate *)currentPage animated:(BOOL)animated;

/**
 * Returns the frame for a non-placeholder cell relative to the super view of the calendar.
 *
 * @param date A date is the calendar.
 */
- (CGRect)frameForDate:(NSDate *)date;

/**
 * Returns the midpoint for a non-placeholder cell relative to the super view of the calendar.
 *
 * @param date A date is the calendar.
 */
- (CGPoint)centerForDate:(NSDate *)date;

@end

#pragma mark - DateTools

/**
 * Job for this category:
 *
 *  1. Manage date object simplier、faster
 *  2. Bring date object into a no-timezone system.
 *
 * @warning All NSDate instances used in the calendar should be created by:
 *
 *    - (NSDate *)dateFromString:(NSString *)string format:(NSString *)format;
 *    - (NSDate *)dateWithYear:(NSInteger)year month:(NSInteger)month day:(NSInteger)day;
 *
 */
@interface FSCalendar (DateTools)

/**
 * Returns the number of year of the given date
 */
- (NSInteger)yearOfDate:(NSDate *)date;

/**
 * Returns the number of month of the given date
 */
- (NSInteger)monthOfDate:(NSDate *)date;

/**
 * Returns the number of day of the given date
 */
- (NSInteger)dayOfDate:(NSDate *)date;

/**
 * Returns the number of weekday of the given date
 */
- (NSInteger)weekdayOfDate:(NSDate *)date;

/**
 * Returns the number of weekOfYear of the given date
 */
- (NSInteger)weekOfDate:(NSDate *)date;

/**
 * Returns the number of hour of the given date
 */
- (NSInteger)hourOfDate:(NSDate *)date;

/**
 * Returns the number of minite of the given date
 */
- (NSInteger)miniuteOfDate:(NSDate *)date;

/**
 * Returns the number of seconds of the given date
 */
- (NSInteger)secondOfDate:(NSDate *)date;

/**
 * Returns the number of rows of the given month
 */
- (NSInteger)numberOfRowsInMonth:(NSDate *)month;

/**
 * Zeronizing hour、minute and second components of the given date
 */
- (NSDate *)dateByIgnoringTimeComponentsOfDate:(NSDate *)date;

/**
 * Returns the first day of month of the given date
 */
- (NSDate *)beginingOfMonthOfDate:(NSDate *)date;

/**
 * Returns the last day of month of the given date
 */
- (NSDate *)endOfMonthOfDate:(NSDate *)date;

/**
 * Returns the first day of week of the given date
 */
- (NSDate *)beginingOfWeekOfDate:(NSDate *)date;

/**
 * Returns the middle day of week of the given date
 */
- (NSDate *)middleOfWeekFromDate:(NSDate *)date;

/**
 * Returns the next day of the given date
 */
- (NSDate *)tomorrowOfDate:(NSDate *)date;

/**
 * Returns the previous day of the given date
 */
- (NSDate *)yesterdayOfDate:(NSDate *)date;

/**
 * Returns the number of days in the month of the given date
 */
- (NSInteger)numberOfDatesInMonthOfDate:(NSDate *)date;

/**
 * Instantiating a date by given string and date format.
 *
 * e.g.
 *
 *    NSDate *date = [calendar dateFromString:@"2000-10-10" format:@"yyyy-MM-dd"];
 */
- (NSDate *)dateFromString:(NSString *)string format:(NSString *)format;

/**
 * Instantiating a date by given numbers of year、month and day.
 *
 * e.g.
 *
 *    NSDate *date = [calendar dateWithYear:2000 month:10 day:10];
 */
- (NSDate *)dateWithYear:(NSInteger)year month:(NSInteger)month day:(NSInteger)day;

/**
 * Returns a new NSDate object representing the time calculated by adding given number of year to a given date.
 */
- (NSDate *)dateByAddingYears:(NSInteger)years toDate:(NSDate *)date;

/**
 * Returns a new NSDate object representing the time calculated by substracting given number of year from a given date.
 */
- (NSDate *)dateBySubstractingYears:(NSInteger)years fromDate:(NSDate *)date;

/**
 * Returns a new NSDate object representing the time calculated by adding given number of month to a given date.
 */
- (NSDate *)dateByAddingMonths:(NSInteger)months toDate:(NSDate *)date;

/**
 * Returns a new NSDate object representing the time calculated by substracting given number of month from a given date.
 */
- (NSDate *)dateBySubstractingMonths:(NSInteger)months fromDate:(NSDate *)date;

/**
 * Returns a new NSDate object representing the time calculated by adding given number of week to a given date.
 */
- (NSDate *)dateByAddingWeeks:(NSInteger)weeks toDate:(NSDate *)date;

/**
 * Returns a new NSDate object representing the time calculated by substracting given number of week from a given date.
 */
- (NSDate *)dateBySubstractingWeeks:(NSInteger)weeks fromDate:(NSDate *)date;

/**
 * Returns a new NSDate object representing the time calculated by adding given number of day to a given date.
 */
- (NSDate *)dateByAddingDays:(NSInteger)days toDate:(NSDate *)date;

/**
 * Returns a new NSDate object representing the time calculated by substracting given number of day from a given date.
 */
- (NSDate *)dateBySubstractingDays:(NSInteger)days fromDate:(NSDate *)date;

/**
 * Returns the year-difference between the given dates
 */
- (NSInteger)yearsFromDate:(NSDate *)fromDate toDate:(NSDate *)toDate;

/**
 * Returns the month-difference between the given dates
 */
- (NSInteger)monthsFromDate:(NSDate *)fromDate toDate:(NSDate *)toDate;

/**
 * Returns the day-difference between the given dates
 */
- (NSInteger)daysFromDate:(NSDate *)fromDate toDate:(NSDate *)toDate;

/**
 * Returns the week-difference between the given dates
 */
- (NSInteger)weeksFromDate:(NSDate *)fromDate toDate:(NSDate *)toDate;

/**
 * Returns whether two dates are equal to a given unit of calendar.
 */
- (BOOL)isDate:(NSDate *)date1 equalToDate:(NSDate *)date2 toCalendarUnit:(FSCalendarUnit)unit;

/**
 * Returns whether the given date is in 'today' of the calendar.
 */
- (BOOL)isDateInToday:(NSDate *)date;

/**
 * Returns a string representation of a given date formatted using a specific date format.
 */
- (NSString *)stringFromDate:(NSDate *)date format:(NSString *)format;

/**
 * Returns a string representation of a given date formatted using a yyyy-MM-dd.
 */
- (NSString *)stringFromDate:(NSDate *)date;

@end

#pragma mark - Deprecate

/**
 * These attributes and functions are deprecated.
 */
@interface FSCalendar (Deprecated)
@property (strong, nonatomic) NSDate *currentMonth FSCalendarDeprecated('currentPage');
@property (assign, nonatomic) FSCalendarFlow flow FSCalendarDeprecated('scrollDirection');
- (void)setSelectedDate:(NSDate *)selectedDate FSCalendarDeprecated(-selectDate:);
- (void)setSelectedDate:(NSDate *)selectedDate animate:(BOOL)animate FSCalendarDeprecated(-selectDate:scrollToDate:);
- (BOOL)date:(NSDate *)date sharesSameMonthWithDate:(NSDate *)anotherDate FSCalendarDeprecated(-isDate:equalToDate:toCalendarUnit);
- (BOOL)date:(NSDate *)date sharesSameWeekWithDate:(NSDate *)anotherDate FSCalendarDeprecated(-isDate:equalToDate:toCalendarUnit);
- (BOOL)date:(NSDate *)date sharesSameDayWithDate:(NSDate *)anotherDate FSCalendarDeprecated(-isDate:equalToDate:toCalendarUnit);
@end

NS_ASSUME_NONNULL_END

