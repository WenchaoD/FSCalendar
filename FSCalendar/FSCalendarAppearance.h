//
//  FSCalendarAppearance.h
//  Pods
//
//  Created by DingWenchao on 6/29/15.
//  Copyright © 2016 Wenchao Ding. All rights reserved.
//
//  https://github.com/WenchaoD
//

#import "FSCalendarConstants.h"

@class FSCalendar;

typedef NS_ENUM(NSInteger, FSCalendarCellState) {
    FSCalendarCellStateNormal      = 0,
    FSCalendarCellStateSelected    = 1,
    FSCalendarCellStatePlaceholder = 1 << 1,
    FSCalendarCellStateDisabled    = 1 << 2,
    FSCalendarCellStateToday       = 1 << 3,
    FSCalendarCellStateWeekend     = 1 << 4,
    FSCalendarCellStateTodaySelected = FSCalendarCellStateToday|FSCalendarCellStateSelected
};

typedef NS_OPTIONS(NSUInteger, FSCalendarCaseOptions) {
    FSCalendarCaseOptionsHeaderUsesDefaultCase      = 0,
    FSCalendarCaseOptionsHeaderUsesUpperCase        = 1,
    
    FSCalendarCaseOptionsWeekdayUsesDefaultCase     = 0 << 4,
    FSCalendarCaseOptionsWeekdayUsesUpperCase       = 1 << 4,
    FSCalendarCaseOptionsWeekdayUsesSingleUpperCase = 2 << 4,
};

typedef NS_OPTIONS(NSUInteger, FSCalendarSeparators) {
    FSCalendarSeparatorNone          = 0,
    FSCalendarSeparatorInterRows     = 1 << 0,
    FSCalendarSeparatorInterColumns  = 1 << 1,   // Will implemented soon
    FSCalendarSeparatorBelowWeekdays = 1 << 2    // Will implemented soon
};

/**
 * FSCalendarAppearance determines the fonts and colors of components in the calendar.
 *
 * @see FSCalendarDelegateAppearance
 */
@interface FSCalendarAppearance : NSObject

/**
 * The font of the day text.
 *
 * @warning The size of font is adjusted by calendar size. To turn it off, set adjustsFontSizeToFitContentSize to NO;
 */
@property (strong, nonatomic) UIFont   *titleFont;

/**
 * The font of the subtitle text.
 *
 * @warning The size of font is adjusted by calendar size. To turn it off, set adjustsFontSizeToFitContentSize to NO;
 */
@property (strong, nonatomic) UIFont   *subtitleFont;

/**
 * The font of the weekday text.
 *
* @warning The size of font is adjusted by calendar size. To turn it off, set adjustsFontSizeToFitContentSize to NO;
 */
@property (strong, nonatomic) UIFont   *weekdayFont;

/**
 * The font of the month text.
 *
 * @warning The size of font is adjusted by calendar size. To turn it off, set adjustsFontSizeToFitContentSize to NO;
 */
@property (strong, nonatomic) UIFont   *headerTitleFont;

/**
 * The offset of the day text from default position.
 */
@property (assign, nonatomic) CGPoint  titleOffset;

/**
 * The offset of the day text from default position.
 */
@property (assign, nonatomic) CGPoint  subtitleOffset;

/**
 * The offset of the event dots from default position.
 */
@property (assign, nonatomic) CGPoint eventOffset;

/**
 * The offset of the image from default position.
 */
@property (assign, nonatomic) CGPoint imageOffset;

/**
 * The color of event dots.
 */
@property (strong, nonatomic) UIColor  *eventDefaultColor;

/**
 * The color of event dots.
 */
@property (strong, nonatomic) UIColor  *eventSelectionColor;

/**
 * The color of weekday text.
 */
@property (strong, nonatomic) UIColor  *weekdayTextColor;

/**
 * The color of month header text.
 */
@property (strong, nonatomic) UIColor  *headerTitleColor;

/**
 * The date format of the month header.
 */
@property (strong, nonatomic) NSString *headerDateFormat;

/**
 * The alpha value of month label staying on the fringes.
 */
@property (assign, nonatomic) CGFloat  headerMinimumDissolvedAlpha;

/**
 * The day text color for unselected state.
 */
@property (strong, nonatomic) UIColor  *titleDefaultColor;

/**
 * The day text color for selected state.
 */
@property (strong, nonatomic) UIColor  *titleSelectionColor;

/**
 * The day text color for today in the calendar.
 */
@property (strong, nonatomic) UIColor  *titleTodayColor;

/**
 * The day text color for days out of current month.
 */
@property (strong, nonatomic) UIColor  *titlePlaceholderColor;

/**
 * The day text color for weekend.
 */
@property (strong, nonatomic) UIColor  *titleWeekendColor;

/**
 * The subtitle text color for unselected state.
 */
@property (strong, nonatomic) UIColor  *subtitleDefaultColor;

/**
 * The subtitle text color for selected state.
 */
@property (strong, nonatomic) UIColor  *subtitleSelectionColor;

/**
 * The subtitle text color for today in the calendar.
 */
@property (strong, nonatomic) UIColor  *subtitleTodayColor;

/**
 * The subtitle text color for days out of current month.
 */
@property (strong, nonatomic) UIColor  *subtitlePlaceholderColor;

/**
 * The subtitle text color for weekend.
 */
@property (strong, nonatomic) UIColor  *subtitleWeekendColor;

/**
 * The fill color of the shape for selected state.
 */
@property (strong, nonatomic) UIColor  *selectionColor;

/**
 * The fill color of the shape for today.
 */
@property (strong, nonatomic) UIColor  *todayColor;

/**
 * The fill color of the shape for today and selected state.
 */
@property (strong, nonatomic) UIColor  *todaySelectionColor;

/**
 * The border color of the shape for unselected state.
 */
@property (strong, nonatomic) UIColor  *borderDefaultColor;

/**
 * The border color of the shape for selected state.
 */
@property (strong, nonatomic) UIColor  *borderSelectionColor;

/**
 * The border radius, while 1 means a circle, 0 means a rectangle, and the middle value will give it a corner radius.
 */
@property (assign, nonatomic) CGFloat borderRadius;

/**
 * The case options manage the case of month label and weekday symbols.
 *
 * @see FSCalendarCaseOptions
 */
@property (assign, nonatomic) FSCalendarCaseOptions caseOptions;

/**
 * The line integrations for calendar.
 *
 */
@property (assign, nonatomic) FSCalendarSeparators separators;

/**
 * A Boolean value indicates whether the calendar should adjust font size by its content size.
 *
 * @see titleFont
 * @see subtitleFont
 * @see weekdayFont
 * @see headerTitleFont
 */
@property (assign, nonatomic) BOOL adjustsFontSizeToFitContentSize;

/**
 * A Boolean value indicates whether the calendar header should adjust font size 
 * if adjustsFontSizeToFitContentSize is set.
 */
@property (assign, nonatomic) BOOL adjustsHeaderTitleFontSizeToFitContentSize;

/**
 * The size of the header title items according to the CollectionView size.
 * If horizontal scrolling is enabled, the default is 0.5.
 * For vertical scrolling the value is 1.0.
 *
 */
@property (assign, nonatomic) CGFloat headerTitleItemSizeMultiplier;

/**
 * The offset of the header title within it's item size.
 *
 */
@property (assign, nonatomic) CGFloat headerTitleItemSizeOffset;

/**
 * The text alignment of the header title.
 * Default is NSTextAlignmentCenter.
 */
@property (assign, nonatomic) NSTextAlignment headerTitleTextAlignment;


#if TARGET_INTERFACE_BUILDER

// For preview only
@property (assign, nonatomic) BOOL      fakeSubtitles;
@property (assign, nonatomic) BOOL      fakeEventDots;
@property (assign, nonatomic) NSInteger fakedSelectedDay;

#endif

/**
 * Triggers an appearance update.
 */
- (void)invalidateAppearance;

@end

/**
 * These functions and attributes are deprecated.
 */
@interface FSCalendarAppearance (Deprecated)

@property (assign, nonatomic) BOOL useVeryShortWeekdaySymbols FSCalendarDeprecated('caseOptions');
@property (assign, nonatomic) BOOL adjustsFontSizeToFitCellSize FSCalendarDeprecated('adjustFontSizeToFitContentSize');
@property (assign, nonatomic) CGFloat titleTextSize FSCalendarDeprecated('titleFont');
@property (assign, nonatomic) CGFloat subtitleTextSize FSCalendarDeprecated('subtitleFont');
@property (assign, nonatomic) CGFloat weekdayTextSize FSCalendarDeprecated('weekdayFont');
@property (assign, nonatomic) CGFloat headerTitleTextSize FSCalendarDeprecated('headerTitleFont');
@property (assign, nonatomic) CGFloat titleVerticalOffset FSCalendarDeprecated('titleOffset');
@property (assign, nonatomic) CGFloat subtitleVerticalOffset FSCalendarDeprecated('subtitleOffset');
@property (strong, nonatomic) UIColor *eventColor FSCalendarDeprecated('eventDefaultColor');
@property (assign, nonatomic) FSCalendarCellShape cellShape FSCalendarDeprecated('borderRadius');

@end



