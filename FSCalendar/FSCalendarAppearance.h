//
//  FSCalendarAppearance.h
//  Pods
//
//  Created by DingWenchao on 6/29/15.
//
//

#import "FSCalendarConstance.h"

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

typedef NS_ENUM(NSUInteger, FSCalendarCellShape) {
    FSCalendarCellShapeCircle    = 0,
    FSCalendarCellShapeRectangle = 1
};

typedef NS_OPTIONS(NSUInteger, FSCalendarCaseOptions) {
    FSCalendarCaseOptionsHeaderUsesDefaultCase      = 0,
    FSCalendarCaseOptionsHeaderUsesUpperCase        = 1,
    
    FSCalendarCaseOptionsWeekdayUsesDefaultCase     = 0 << 4,
    FSCalendarCaseOptionsWeekdayUsesUpperCase       = 1 << 4,
    FSCalendarCaseOptionsWeekdayUsesSingleUpperCase = 2 << 4,
};

@interface FSCalendarAppearance : NSObject

@property (strong, nonatomic) UIFont   *titleFont;
@property (strong, nonatomic) UIFont   *subtitleFont;
@property (strong, nonatomic) UIFont   *weekdayFont;
@property (strong, nonatomic) UIFont   *headerTitleFont;

@property (assign, nonatomic) CGFloat  titleVerticalOffset;
@property (assign, nonatomic) CGFloat  subtitleVerticalOffset;

@property (strong, nonatomic) UIColor  *eventColor;
@property (strong, nonatomic) UIColor  *weekdayTextColor;

@property (strong, nonatomic) UIColor  *headerTitleColor;
@property (strong, nonatomic) NSString *headerDateFormat;
@property (assign, nonatomic) CGFloat  headerMinimumDissolvedAlpha;

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
@property (strong, nonatomic) UIColor  *todaySelectionColor;

@property (strong, nonatomic) UIColor  *borderDefaultColor;
@property (strong, nonatomic) UIColor  *borderSelectionColor;

@property (assign, nonatomic) FSCalendarCellShape cellShape;
@property (assign, nonatomic) FSCalendarCaseOptions caseOptions;
@property (assign, nonatomic) BOOL adjustsFontSizeToFitContentSize;

// For preview only
@property (assign, nonatomic) BOOL      fakeSubtitles;
@property (assign, nonatomic) NSInteger fakedSelectedDay;

- (void)invalidateAppearance;

@end

@interface FSCalendarAppearance (Deprecated)

@property (assign, nonatomic) FSCalendarCellStyle cellStyle FSCalendarDeprecated('cellShape');
@property (assign, nonatomic) BOOL useVeryShortWeekdaySymbols FSCalendarDeprecated('caseOptions');
@property (assign, nonatomic) BOOL autoAdjustTitleSize FSCalendarDeprecated('adjustFontSizeToFitContentSize');
@property (assign, nonatomic) BOOL adjustsFontSizeToFitCellSize FSCalendarDeprecated('adjustFontSizeToFitContentSize');

@property (assign, nonatomic) CGFloat titleTextSize FSCalendarDeprecated('titleFont');
@property (assign, nonatomic) CGFloat subtitleTextSize FSCalendarDeprecated('subtitleFont');
@property (assign, nonatomic) CGFloat weekdayTextSize FSCalendarDeprecated('weekdayFont');
@property (assign, nonatomic) CGFloat headerTitleTextSize FSCalendarDeprecated('headerTitleFont');

@end



