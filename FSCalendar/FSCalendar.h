//
//  FSCalendar.h
//  FSCalendar
//
//  Created by Wenchao Ding on 29/1/15.
//  Copyright © 2016 Wenchao Ding. All rights reserved.
// 
//  https://github.com/WenchaoD
//
//
//  FSCalendar is a superior awesome calendar control with high performance, high customizablility and very simple usage.
//
//  @see FSCalendarDataSource
//  @see FSCalendarDelegate
//  @see FSCalendarDelegateAppearance
//  @see FSCalendarAppearance
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

typedef NS_ENUM(NSUInteger, FSCalendarPlaceholderType) {
    FSCalendarPlaceholderTypeNone          = 0,
    FSCalendarPlaceholderTypeFillHeadTail  = 1,
    FSCalendarPlaceholderTypeFillSixRows   = 2
};

NS_ASSUME_NONNULL_BEGIN

@class FSCalendar;

/**
 * FSCalendarDataSource is a source set of FSCalendar. The basic job is to provide event、subtitle and min/max day to display for calendar.
 */
@protocol FSCalendarDataSource <NSObject>

@optional

/**
 * Asks the dataSource for a title for the specific date as a replacement of the day text
 */
- (nullable NSString *)calendar:(FSCalendar *)calendar titleForDate:(NSDate *)date;

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
 * Asks the dataSource for an accessibility label for the specific date's title (day number).
 */
- (nullable NSString *)calendar:(FSCalendar *)calendar accessibilityLabelForDate:(NSDate *)date;

/**
 * Asks the dataSource for an accessibility identifier for the specific date's cell.
 */
- (nullable NSString *)calendar:(FSCalendar *)calendar accessibilityIdentifierForDate:(NSDate *)date;

/**
 * Asks the dataSource for accessibility traits for the specific date's title (day number) label.
 */
- (UIAccessibilityTraits)calendar:(FSCalendar *)calendar accessibilityTraitsForDate:(NSDate *)date;

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
 * FSCalendarDelegateAppearance determines the fonts and colors of components in the calendar, but more specificly. Basically, if you need to make a global customization of appearance of the calendar, use FSCalendarAppearance. But if you need different appearance for different days, use FSCalendarDelegateAppearance.
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
 * Asks the delegate for event colors for the specific date.
 */
- (nullable NSArray<UIColor *> *)calendar:(FSCalendar *)calendar appearance:(FSCalendarAppearance *)appearance eventDefaultColorsForDate:(NSDate *)date;

/**
 * Asks the delegate for multiple event colors in selected state for the specific date.
 */
- (nullable NSArray<UIColor *> *)calendar:(FSCalendar *)calendar appearance:(FSCalendarAppearance *)appearance eventSelectionColorsForDate:(NSDate *)date;

/**
 * Asks the delegate for a border color in unselected state for the specific date.
 */
- (nullable UIColor *)calendar:(FSCalendar *)calendar appearance:(FSCalendarAppearance *)appearance borderDefaultColorForDate:(NSDate *)date;

/**
 * Asks the delegate for a border color in selected state for the specific date.
 */
- (nullable UIColor *)calendar:(FSCalendar *)calendar appearance:(FSCalendarAppearance *)appearance borderSelectionColorForDate:(NSDate *)date;

/**
 * Asks the delegate for an offset for day text for the specific date.
 */
- (CGPoint)calendar:(FSCalendar *)calendar appearance:(FSCalendarAppearance *)appearance titleOffsetForDate:(NSDate *)date;

/**
 * Asks the delegate for an offset for subtitle for the specific date.
 */
- (CGPoint)calendar:(FSCalendar *)calendar appearance:(FSCalendarAppearance *)appearance subtitleOffsetForDate:(NSDate *)date;

/**
 * Asks the delegate for an offset for image for the specific date.
 */
- (CGPoint)calendar:(FSCalendar *)calendar appearance:(FSCalendarAppearance *)appearance imageOffsetForDate:(NSDate *)date;

/**
 * Asks the delegate for an offset for event dots for the specific date.
 */
- (CGPoint)calendar:(FSCalendar *)calendar appearance:(FSCalendarAppearance *)appearance eventOffsetForDate:(NSDate *)date;


/**
 * Asks the delegate for a border radius for the specific date.
 */
- (CGFloat)calendar:(FSCalendar *)calendar appearance:(FSCalendarAppearance *)appearance borderRadiusForDate:(NSDate *)date;

/**
 * These functions are deprecated
 */
- (FSCalendarCellStyle)calendar:(FSCalendar *)calendar appearance:(FSCalendarAppearance *)appearance cellStyleForDate:(NSDate *)date FSCalendarDeprecated(-calendar:appearance:cellShapeForDate:);
- (nullable UIColor *)calendar:(FSCalendar *)calendar appearance:(FSCalendarAppearance *)appearance fillColorForDate:(NSDate *)date FSCalendarDeprecated(-calendar:appearance:fillDefaultColorForDate:);
- (nullable UIColor *)calendar:(FSCalendar *)calendar appearance:(FSCalendarAppearance *)appearance selectionColorForDate:(NSDate *)date FSCalendarDeprecated(-calendar:appearance:fillSelectionColorForDate:);
- (nullable UIColor *)calendar:(FSCalendar *)calendar appearance:(FSCalendarAppearance *)appearance eventColorForDate:(NSDate *)date FSCalendarDeprecated(-calendar:appearance:eventDefaultColorsForDate:);
- (nullable NSArray *)calendar:(FSCalendar *)calendar appearance:(FSCalendarAppearance *)appearance eventColorsForDate:(NSDate *)date FSCalendarDeprecated(-calendar:appearance:eventDefaultColorsForDate:);
- (FSCalendarCellShape)calendar:(FSCalendar *)calendar appearance:(FSCalendarAppearance *)appearance cellShapeForDate:(NSDate *)date FSCalendarDeprecated(-calendar:appearance:borderRadiusForDate:);
@end

#pragma mark - Primary

IB_DESIGNABLE
@interface FSCalendar : UIView

@property (weak, nonatomic) NSExtensionContext *extensionContext;

/**
 * The object that acts as the delegate of the calendar.
 */
@property (weak, nonatomic) IBOutlet id<FSCalendarDelegate> delegate;

/**
 * The object that acts as the data source of the calendar.
 */
@property (weak, nonatomic) IBOutlet id<FSCalendarDataSource> dataSource;

/**
 * A special mark will be put on 'today' of the calendar.
 */
@property (nullable, strong, nonatomic) NSDate *today;

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
@property (copy, nonatomic) NSLocale *locale;


/**
 * Change timeZone to specific time zone.
 *
 * e.g. To make time zone as UTC:
 *
 *    calendar.timeZone = [NSTimeZOne timeZoneWithName:@"UTC"];
 */
@property (strong, nonatomic) NSTimeZone *timeZone;

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
 * A UIPanGestureRecognizer instance which enables the control of scope on the whole day-area. Not available if the scrollDirection is vertical
 *
 * e.g.
 *
 *    calendar.scopeGesture.enabled = YES;
 */
@property (readonly, nonatomic) UIPanGestureRecognizer *scopeGesture;

/**
 * The placeholder type of FSCalendar. Default is FSCalendarPlaceholderTypeFillSixRows;
 *
 * e.g. To hide all placeholder of the calendar
 *
 *    calendar.placeholderType = FSCalendarPlaceholderTypeNone;
 */
#if TARGET_INTERFACE_BUILDER
@property (assign, nonatomic) IBInspectable NSUInteger placeholderType;
#else
@property (assign, nonatomic) FSCalendarPlaceholderType placeholderType;
#endif

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
 * A Boolean value that determines whether the calendar should show a handle for control the scope. Default is NO;
 */
@property (assign, nonatomic) IBInspectable BOOL showsScopeHandle;

/**
 * The multiplier of line height while paging enabled is NO. Default is 1.0;
 */
@property (assign, nonatomic) IBInspectable CGFloat lineHeightMultiplier;

/**
 * The height of the calendar weekday rows (or height of each cell).
 */
@property (assign, nonatomic) IBInspectable CGFloat rowHeight;

/**
 * The height of the calendar scope handle.
 */
@property (assign, nonatomic) IBInspectable CGFloat scopeHandleHeight;

/**
 * Whether or not to hide the scope handle top border.
 */
@property (assign, nonatomic) IBInspectable BOOL hideScopeHandleTopBorder;

/**
 * Whether or not to round the itemSize width for accessibility. If true, the itemSize width will be rounded to ensure
 * that when VoiceOver is enabled, upon swiping to the end of the week, the calendar days do not unexpectedly shift.
 * Additionally, this rounding will only be done if the scroll direction is vertical.
 * This is a fix for: https://github.com/WenchaoD/FSCalendar/issues/501
 * This should only be set if VoiceOver is enabled (logic should be handled in the view controller).
 */
@property (assign, nonatomic) IBInspectable BOOL roundItemSizeWidthForAccessibility;

/**
 * The accessibility trait for the calendar day cell. Default is UIAccessibilityTraitNone.
 */
@property (assign, nonatomic) IBInspectable UIAccessibilityTraits accessibilityTraitForCell;

/**
 * The accessibility trait for the selected calendar day cell. Default is UIAccessibilityTraitNone.
 */
@property (assign, nonatomic) IBInspectable UIAccessibilityTraits accessibilityTraitForSelectedCell;

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

/**
 * Returns the cell's title label corresponding to date.
 *
 * @param date A date in the calendar.
 */
- (UILabel *)cellTitleLabelForDate:(NSDate *)date;

/**
 * Updates the date for today. This should be called if the system / device date is changed while the calendar is in the background.
 *
 * @param date A date in the calendar.
 */
- (void)updateToday:(NSDate *)date;

@end




#pragma mark - Deprecate

@interface FSCalendar (Deprecated)
@property (assign, nonatomic) IBInspectable BOOL showsPlaceholders FSCalendarDeprecated('placeholderType');
@property (strong, nonatomic) NSDate *currentMonth FSCalendarDeprecated('currentPage');
@property (assign, nonatomic) FSCalendarFlow flow FSCalendarDeprecated('scrollDirection');
- (void)setSelectedDate:(NSDate *)selectedDate FSCalendarDeprecated(-selectDate:);
- (void)setSelectedDate:(NSDate *)selectedDate animate:(BOOL)animate FSCalendarDeprecated(-selectDate:scrollToDate:);

@property (strong, nonatomic) NSString *identifier DEPRECATED_MSG_ATTRIBUTE("Changing calendar identifier is NOT RECOMMENDED. You should always use this library as a Gregorian calendar. Try to express other calendar as subtitles just as System calendar app does."); // Deprecated in 2.3.1

// Use NSDateFormatter
- (NSString *)stringFromDate:(NSDate *)date format:(NSString *)format FSCalendarDeprecated([NSDateFormatter stringFromDate:]);
- (NSString *)stringFromDate:(NSDate *)date FSCalendarDeprecated([NSDateFormatter stringFromDate:]);
- (NSDate *)dateFromString:(NSString *)string format:(NSString *)format FSCalendarDeprecated([NSDateFormatter dateFromString:]);
- (NSDate *)dateWithYear:(NSInteger)year month:(NSInteger)month day:(NSInteger)day FSCalendarDeprecated([NSDateFormatter dateFromString:]);

// Use NSCalendar.
- (NSInteger)yearOfDate:(NSDate *)date FSCalendarDeprecated(NSCalendar component:fromDate:]);
- (NSInteger)monthOfDate:(NSDate *)date FSCalendarDeprecated(NSCalendar component:fromDate:]);
- (NSInteger)dayOfDate:(NSDate *)date FSCalendarDeprecated(NSCalendar component:fromDate:]);
- (NSInteger)weekdayOfDate:(NSDate *)date FSCalendarDeprecated(NSCalendar component:fromDate:]);
- (NSInteger)weekOfDate:(NSDate *)date FSCalendarDeprecated(NSCalendar component:fromDate:]);
- (NSInteger)hourOfDate:(NSDate *)date FSCalendarDeprecated(NSCalendar component:fromDate:]);
- (NSInteger)miniuteOfDate:(NSDate *)date FSCalendarDeprecated(NSCalendar component:fromDate:]);
- (NSInteger)secondOfDate:(NSDate *)date FSCalendarDeprecated(NSCalendar component:fromDate:]);
- (NSDate *)dateByIgnoringTimeComponentsOfDate:(NSDate *)date FSCalendarDeprecated([NSCalendar dateBySettingHour:minute:seconds:ofDate:options:]);
- (NSDate *)tomorrowOfDate:(NSDate *)date FSCalendarDeprecated([NSCalendar dateByAddingUnit:value:toDate:options:]);;
- (NSDate *)yesterdayOfDate:(NSDate *)date FSCalendarDeprecated([NSCalendar dateByAddingUnit:value:toDate:options:]);
- (NSDate *)dateByAddingYears:(NSInteger)years toDate:(NSDate *)date FSCalendarDeprecated([NSCalendar dateByAddingUnit:value:toDate:options:]);
- (NSDate *)dateBySubstractingYears:(NSInteger)years fromDate:(NSDate *)date FSCalendarDeprecated([NSCalendar dateByAddingUnit:value:toDate:options:]);
- (NSDate *)dateByAddingMonths:(NSInteger)months toDate:(NSDate *)date FSCalendarDeprecated([NSCalendar dateByAddingUnit:value:toDate:options:]);
- (NSDate *)dateBySubstractingMonths:(NSInteger)months fromDate:(NSDate *)date FSCalendarDeprecated([NSCalendar dateByAddingUnit:value:toDate:options:]);
- (NSDate *)dateByAddingWeeks:(NSInteger)weeks toDate:(NSDate *)date FSCalendarDeprecated([NSCalendar dateByAddingUnit:value:toDate:options:]);
- (NSDate *)dateBySubstractingWeeks:(NSInteger)weeks fromDate:(NSDate *)date FSCalendarDeprecated([NSCalendar dateByAddingUnit:value:toDate:options:]);
- (NSDate *)dateByAddingDays:(NSInteger)days toDate:(NSDate *)date FSCalendarDeprecated([NSCalendar dateByAddingUnit:value:toDate:options:]);
- (NSDate *)dateBySubstractingDays:(NSInteger)days fromDate:(NSDate *)date FSCalendarDeprecated([NSCalendar dateByAddingUnit:value:toDate:options:]);
- (NSInteger)yearsFromDate:(NSDate *)fromDate toDate:(NSDate *)toDate FSCalendarDeprecated([NSCalendar components:fromDate:toDate:options:]);
- (NSInteger)monthsFromDate:(NSDate *)fromDate toDate:(NSDate *)toDate FSCalendarDeprecated([NSCalendar components:fromDate:toDate:options:]);
- (NSInteger)daysFromDate:(NSDate *)fromDate toDate:(NSDate *)toDate FSCalendarDeprecated([NSCalendar components:fromDate:toDate:options:]);
- (NSInteger)weeksFromDate:(NSDate *)fromDate toDate:(NSDate *)toDate FSCalendarDeprecated([NSCalendar components:fromDate:toDate:options:]);
- (BOOL)isDate:(NSDate *)date1 equalToDate:(NSDate *)date2 toCalendarUnit:(FSCalendarUnit)unit FSCalendarDeprecated([NSCalendar -isDate:equalToDate:toUnitGranularity:]);
- (BOOL)isDateInToday:(NSDate *)date FSCalendarDeprecated([NSCalendar -isDateInToday:]);


@end

NS_ASSUME_NONNULL_END

