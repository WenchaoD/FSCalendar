//
//  FSCalendarConstane.h
//  FSCalendar
//
//  Created by dingwenchao on 8/28/15.
//  Copyright © 2016 Wenchao Ding. All rights reserved.
//
//  https://github.com/WenchaoD
//

#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>

#pragma mark - Constance

UIKIT_EXTERN CGFloat const FSCalendarStandardHeaderHeight;
UIKIT_EXTERN CGFloat const FSCalendarStandardWeekdayHeight;
UIKIT_EXTERN CGFloat const FSCalendarStandardMonthlyPageHeight;
UIKIT_EXTERN CGFloat const FSCalendarStandardWeeklyPageHeight;
UIKIT_EXTERN CGFloat const FSCalendarStandardCellDiameter;
UIKIT_EXTERN CGFloat const FSCalendarAutomaticDimension;
UIKIT_EXTERN CGFloat const FSCalendarDefaultBounceAnimationDuration;
UIKIT_EXTERN CGFloat const FSCalendarStandardRowHeight;
UIKIT_EXTERN CGFloat const FSCalendarStandardTitleTextSize;
UIKIT_EXTERN CGFloat const FSCalendarStandardSubtitleTextSize;
UIKIT_EXTERN CGFloat const FSCalendarStandardWeekdayTextSize;
UIKIT_EXTERN CGFloat const FSCalendarStandardHeaderTextSize;
UIKIT_EXTERN CGFloat const FSCalendarMaximumEventDotDiameter;

UIKIT_EXTERN NSInteger const FSCalendarDefaultHourComponent;

#if TARGET_INTERFACE_BUILDER
#define FSCalendarDeviceIsIPad NO
#else
#define FSCalendarDeviceIsIPad [[UIDevice currentDevice].model hasPrefix:@"iPad"]
#endif

#define FSCalendarStandardSelectionColor  FSColorRGBA(31,119,219,1.0)
#define FSCalendarStandardTodayColor      FSColorRGBA(198,51,42 ,1.0)
#define FSCalendarStandardTitleTextColor  FSColorRGBA(14,69,221 ,1.0)
#define FSCalendarStandardEventDotColor   FSColorRGBA(31,119,219,0.75)

#define FSColorRGBA(r,g,b,a) [UIColor colorWithRed:r/255.0 green:g/255.0 blue:b/255.0 alpha:a]

#if CGFLOAT_IS_DOUBLE
#define FSCalendarFloor(c) floor(c)
#else
#define FSCalendarFloor(c) floorf(c)
#endif

#pragma mark - Deprecated

#define FSCalendarDeprecated(instead) DEPRECATED_MSG_ATTRIBUTE(" Use " # instead " instead")

FSCalendarDeprecated('FSCalendarCellShape')
typedef NS_ENUM(NSInteger, FSCalendarCellStyle) {
    FSCalendarCellStyleCircle      = 0,
    FSCalendarCellStyleRectangle   = 1
};

FSCalendarDeprecated('FSCalendarScrollDirection')
typedef NS_ENUM(NSInteger, FSCalendarFlow) {
    FSCalendarFlowVertical,
    FSCalendarFlowHorizontal
};
