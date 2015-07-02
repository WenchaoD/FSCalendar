//
//  FSCalendarAppearance.h
//  Pods
//
//  Created by DingWenchao on 6/29/15.
//
//

#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>

typedef NS_OPTIONS(NSInteger, FSCalendarCellStyle) {
    FSCalendarCellStyleCircle      = 0,
    FSCalendarCellStyleRectangle   = 1
};

@class FSCalendar;

@interface FSCalendarAppearance : NSObject

@property (weak  , nonatomic) FSCalendar *calendar;

@property (strong, nonatomic) UIFont   *titleFont;
@property (strong, nonatomic) UIFont   *subtitleFont;
@property (strong, nonatomic) UIFont   *weekdayFont;
@property (strong, nonatomic) UIColor  *eventColor;
@property (strong, nonatomic) UIColor  *weekdayTextColor;

@property (strong, nonatomic) UIColor  *headerTitleColor;
@property (strong, nonatomic) NSString *headerDateFormat;
@property (strong, nonatomic) UIFont   *headerTitleFont;
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

@property (assign, nonatomic) FSCalendarCellStyle cellStyle;
@property (assign, nonatomic) BOOL autoAdjustTitleSize;

@end
