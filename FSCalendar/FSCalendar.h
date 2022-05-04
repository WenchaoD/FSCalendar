//
//  FSCalendar.h
//  FSCalendar
//
//  Created by Wenchao Ding on 29/1/15.
//  Copyright © 2016 Wenchao Ding. All rights reserved.
// 
//  https://github.com/WenchaoD
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
#import "FSCalendarConstants.h"
#import "FSCalendarCell.h"
#import "FSCalendarWeekdayView.h"
#import "FSCalendarHeaderView.h"

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

typedef NS_ENUM(NSUInteger, FSCalendarMonthPosition) {
    FSCalendarMonthPositionPrevious,
    FSCalendarMonthPositionCurrent,
    FSCalendarMonthPositionNext,
    
    FSCalendarMonthPositionNotFound = NSNotFound
};

NS_ASSUME_NONNULL_BEGIN

@class FSCalendar;

/**
 * FSCalendarDataSource is a source set of FSCalendar. The basic role is to provide event、subtitle and min/max day to display, or customized day cell for the calendar.
 */
@protocol FSCalendarDataSource <NSObject>

@optional


- (nullable NSDictionary *)calendar:(FSCalendar *)calendar subToptitleForDate:(NSDate *)date;
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
 * Asks the data source for a cell to insert in a particular data of the calendar.
 */
- (__kindof FSCalendarCell *)calendar:(FSCalendar *)calendar cellForDate:(NSDate *)date atMonthPosition:(FSCalendarMonthPosition)position;

/**
 * Asks the dataSource the number of event dots for a specific date.
 *
 * @see
 *   - (UIColor *)calendar:(FSCalendar *)calendar appearance:(FSCalendarAppearance *)appearance eventColorForDate:(NSDate *)date;
 *   - (NSArray *)calendar:(FSCalendar *)calendar appearance:(FSCalendarAppearance *)appearance eventColorsForDate:(NSDate *)date;
 */
- (NSInteger)calendar:(FSCalendar *)calendar numberOfEventsForDate:(NSDate *)date;

@end


/**
 * The delegate of a FSCalendar object must adopt the FSCalendarDelegate protocol. The optional methods of FSCalendarDelegate manage selections、 user events and help to manager the frame of the calendar.
 */
@protocol FSCalendarDelegate <NSObject>

@optional

/**
 Asks the delegate whether the specific date is allowed to be selected by tapping.
 */
- (BOOL)calendar:(FSCalendar *)calendar shouldSelectDate:(NSDate *)date atMonthPosition:(FSCalendarMonthPosition)monthPosition;

/**
 Tells the delegate a date in the calendar is selected by tapping.
 */
- (void)calendar:(FSCalendar *)calendar didSelectDate:(NSDate *)date atMonthPosition:(FSCalendarMonthPosition)monthPosition;

/**
 Asks the delegate whether the specific date is allowed to be deselected by tapping.
 */
- (BOOL)calendar:(FSCalendar *)calendar shouldDeselectDate:(NSDate *)date atMonthPosition:(FSCalendarMonthPosition)monthPosition;

/**
 Tells the delegate a date in the calendar is deselected by tapping.
 */
- (void)calendar:(FSCalendar *)calendar didDeselectDate:(NSDate *)date atMonthPosition:(FSCalendarMonthPosition)monthPosition;


/**
 Tells the delegate the calendar is about to change the bounding rect.
 */
- (void)calendar:(FSCalendar *)calendar boundingRectWillChange:(CGRect)bounds animated:(BOOL)animated;

/**
 Tells the delegate that the specified cell is about to be displayed in the calendar.
 */
- (void)calendar:(FSCalendar *)calendar willDisplayCell:(FSCalendarCell *)cell forDate:(NSDate *)date atMonthPosition:(FSCalendarMonthPosition)monthPosition;

/**
 Tells the delegate the calendar is about to change the current page.
 */
- (void)calendarCurrentPageDidChange:(FSCalendar *)calendar;

@end

/**
 * FSCalendarDelegateAppearance determines the fonts and colors of components in the calendar, but more specificly. Basically, if you need to make a global customization of appearance of the calendar, use FSCalendarAppearance. But if you need different appearance for different days, use FSCalendarDelegateAppearance.
 *
 * @see FSCalendarAppearance
 */
@protocol FSCalendarDelegateAppearance <FSCalendarDelegate>

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
 A UIPanGestureRecognizer instance which enables the control of scope on the whole day-area. Not available if the scrollDirection is vertical.
 
 @deprecated Use -handleScopeGesture: instead
 
 e.g.
 
    UIPanGestureRecognizer *scopeGesture = [[UIPanGestureRecognizer alloc] initWithTarget:calendar action:@selector(handleScopeGesture:)];
    [calendar addGestureRecognizer:scopeGesture];
 
 @see DIYExample
 @see FSCalendarScopeExample
 */
@property (readonly, nonatomic) UIPanGestureRecognizer *scopeGesture FSCalendarDeprecated(handleScopeGesture:);

/**
 * A UILongPressGestureRecognizer instance which enables the swipe-to-choose feature of the calendar.
 *
 * e.g.
 *
 *    calendar.swipeToChooseGesture.enabled = YES;
 */
@property (readonly, nonatomic) UILongPressGestureRecognizer *swipeToChooseGesture;

/**
 * The placeholder type of FSCalendar. Default is FSCalendarPlaceholderTypeFillSixRows.
 *
 * e.g. To hide all placeholder of the calendar
 *
 *    calendar.placeholderType = FSCalendarPlaceholderTypeNone;
 */
@property (assign, nonatomic) FSCalendarPlaceholderType placeholderType;

/**
 The index of the first weekday of the calendar. Give a '2' to make Monday in the first column.
 */
@property (assign, nonatomic) IBInspectable NSUInteger firstWeekday;

/**
 The height of month header of the calendar. Give a '0' to remove the header.
 */
@property (assign, nonatomic) IBInspectable CGFloat headerHeight;

/**
 The height of weekday header of the calendar.
 */
@property (assign, nonatomic) IBInspectable CGFloat weekdayHeight;

/**
 The weekday view of the calendar
 */
@property (strong, nonatomic) FSCalendarWeekdayView *calendarWeekdayView;

/**
 The header view of the calendar
 */
@property (strong, nonatomic) FSCalendarHeaderView *calendarHeaderView;

/**
 A Boolean value that determines whether users can select a date.
 */
@property (assign, nonatomic) IBInspectable BOOL allowsSelection;

/**
 A Boolean value that determines whether users can select more than one date.
 */
@property (assign, nonatomic) IBInspectable BOOL allowsMultipleSelection;

/**
 A Boolean value that determines whether the bounding rect changes when the displayed month of the calendar is changed.
 */
@property (assign, nonatomic) IBInspectable BOOL adjustsBoundingRectWhenChangingMonths;

/**
 A Boolean value that determines whether paging is enabled for the calendar.
 */
@property (assign, nonatomic) IBInspectable BOOL pagingEnabled;

/**
 A Boolean value that determines whether scrolling is enabled for the calendar.
 */
@property (assign, nonatomic) IBInspectable BOOL scrollEnabled;

/**
 The row height of the calendar if paging enabled is NO.;
 */
@property (assign, nonatomic) IBInspectable CGFloat rowHeight;

/**
 The calendar appearance used to control the global fonts、colors .etc
 */
@property (readonly, nonatomic) FSCalendarAppearance *appearance;

/**
 A date object representing the minimum day enable、visible and selectable. (read-only)
 */
@property (readonly, nonatomic) NSDate *minimumDate;

/**
 A date object representing the maximum day enable、visible and selectable. (read-only)
 */
@property (readonly, nonatomic) NSDate *maximumDate;

/**
 A date object identifying the section of the selected date. (read-only)
 */
@property (nullable, readonly, nonatomic) NSDate *selectedDate;

/**
 The dates representing the selected dates. (read-only)
 */
@property (readonly, nonatomic) NSArray<NSDate *> *selectedDates;

/**
 Reload the dates and appearance of the calendar.
 */
- (void)reloadData;

/**
 Change the scope of the calendar. Make sure `-calendar:boundingRectWillChange:animated` is correctly adopted.
 
 @param scope The target scope to change.
 @param animated YES if you want to animate the scoping; NO if the change should be immediate.
 */
- (void)setScope:(FSCalendarScope)scope animated:(BOOL)animated;

/**
 Selects a given date in the calendar.
 
 @param date A date in the calendar.
 */
- (void)selectDate:(nullable NSDate *)date;

/**
 Selects a given date in the calendar, optionally scrolling the date to visible area.
 
 @param date A date in the calendar.
 @param scrollToDate A Boolean value that determines whether the calendar should scroll to the selected date to visible area.
 */
- (void)selectDate:(nullable NSDate *)date scrollToDate:(BOOL)scrollToDate;

/**
 Deselects a given date of the calendar.
 
 @param date A date in the calendar.
 */
- (void)deselectDate:(NSDate *)date;

/**
 Changes the current page of the calendar.
 
 @param currentPage Representing weekOfYear in week mode, or month in month mode.
 @param animated YES if you want to animate the change in position; NO if it should be immediate.
 */
- (void)setCurrentPage:(NSDate *)currentPage animated:(BOOL)animated;

/**
 Register a class for use in creating new calendar cells.

 @param cellClass The class of a cell that you want to use in the calendar.
 @param identifier The reuse identifier to associate with the specified class. This parameter must not be nil and must not be an empty string.
 */
- (void)registerClass:(Class)cellClass forCellReuseIdentifier:(NSString *)identifier;

/**
 Returns a reusable calendar cell object located by its identifier.

 @param identifier The reuse identifier for the specified cell. This parameter must not be nil.
 @param date The specific date of the cell.
 @return A valid FSCalendarCell object.
 */
- (__kindof FSCalendarCell *)dequeueReusableCellWithIdentifier:(NSString *)identifier forDate:(NSDate *)date atMonthPosition:(FSCalendarMonthPosition)position;

/**
 Returns the calendar cell for the specified date.

 @param date The date of the cell
 @param position The month position for the cell
 @return An object representing a cell of the calendar, or nil if the cell is not visible or date is out of range.
 */
- (nullable FSCalendarCell *)cellForDate:(NSDate *)date atMonthPosition:(FSCalendarMonthPosition)position;


/**
 Returns the date of the specified cell.
 
 @param cell The cell object whose date you want.
 @return The date of the cell or nil if the specified cell is not in the calendar.
 */
- (nullable NSDate *)dateForCell:(FSCalendarCell *)cell;

/**
 Returns the month position of the specified cell.
 
 @param cell The cell object whose month position you want.
 @return The month position of the cell or FSCalendarMonthPositionNotFound if the specified cell is not in the calendar.
 */
- (FSCalendarMonthPosition)monthPositionForCell:(FSCalendarCell *)cell;


/**
 Returns an array of visible cells currently displayed by the calendar.
 
 @return An array of FSCalendarCell objects. If no cells are visible, this method returns an empty array.
 */
- (NSArray<__kindof FSCalendarCell *> *)visibleCells;

/**
 Returns the frame for a non-placeholder cell relative to the super view of the calendar.
 
 @param date A date is the calendar.
 */
- (CGRect)frameForDate:(NSDate *)date;

/**
 An action selector for UIPanGestureRecognizer instance to control the scope transition
 
 @param sender A UIPanGestureRecognizer instance which controls the scope of the calendar
 */
- (void)handleScopeGesture:(UIPanGestureRecognizer *)sender;

@end


IB_DESIGNABLE
@interface FSCalendar (IBExtension)

#if TARGET_INTERFACE_BUILDER

@property (assign, nonatomic) IBInspectable CGFloat  titleTextSize;
@property (assign, nonatomic) IBInspectable CGFloat  subtitleTextSize;
@property (assign, nonatomic) IBInspectable CGFloat  weekdayTextSize;
@property (assign, nonatomic) IBInspectable CGFloat  headerTitleTextSize;

@property (strong, nonatomic) IBInspectable UIColor  *eventDefaultColor;
@property (strong, nonatomic) IBInspectable UIColor  *eventSelectionColor;
@property (strong, nonatomic) IBInspectable UIColor  *weekdayTextColor;

@property (strong, nonatomic) IBInspectable UIColor  *headerTitleColor;
@property (strong, nonatomic) IBInspectable NSString *headerDateFormat;
@property (assign, nonatomic) IBInspectable CGFloat  headerMinimumDissolvedAlpha;

@property (strong, nonatomic) IBInspectable UIColor  *titleDefaultColor;
@property (strong, nonatomic) IBInspectable UIColor  *titleSelectionColor;
@property (strong, nonatomic) IBInspectable UIColor  *titleTodayColor;
@property (strong, nonatomic) IBInspectable UIColor  *titlePlaceholderColor;
@property (strong, nonatomic) IBInspectable UIColor  *titleWeekendColor;

@property (strong, nonatomic) IBInspectable UIColor  *subtitleDefaultColor;
@property (strong, nonatomic) IBInspectable UIColor  *subtitleSelectionColor;
@property (strong, nonatomic) IBInspectable UIColor  *subtitleTodayColor;
@property (strong, nonatomic) IBInspectable UIColor  *subtitlePlaceholderColor;
@property (strong, nonatomic) IBInspectable UIColor  *subtitleWeekendColor;

@property (strong, nonatomic) IBInspectable UIColor  *selectionColor;
@property (strong, nonatomic) IBInspectable UIColor  *todayColor;
@property (strong, nonatomic) IBInspectable UIColor  *todaySelectionColor;

@property (strong, nonatomic) IBInspectable UIColor *borderDefaultColor;
@property (strong, nonatomic) IBInspectable UIColor *borderSelectionColor;

@property (assign, nonatomic) IBInspectable CGFloat borderRadius;
@property (assign, nonatomic) IBInspectable BOOL    useVeryShortWeekdaySymbols;

@property (assign, nonatomic) IBInspectable BOOL      fakeSubtitles;
@property (assign, nonatomic) IBInspectable BOOL      fakeEventDots;
@property (assign, nonatomic) IBInspectable NSInteger fakedSelectedDay;

#endif

@end

NS_ASSUME_NONNULL_END
