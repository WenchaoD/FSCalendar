//
//  FSCalendarConstane.h
//  FSCalendar
//
//  Created by dingwenchao on 8/28/15.
//  Copyright (c) 2015 wenchaoios. All rights reserved.
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


#pragma mark - Deprecated

#define FSCalendarDeprecated(message) __attribute((deprecated(message)))

FSCalendarDeprecated("use \'FSCalendarCellShape\' instead")
typedef NS_OPTIONS(NSInteger, FSCalendarCellStyle) {
    FSCalendarCellStyleCircle      = 0,
    FSCalendarCellStyleRectangle   = 1
};

FSCalendarDeprecated("use \'FSCalendarScrollDirection\' instead")
typedef NS_ENUM(NSInteger, FSCalendarFlow) {
    FSCalendarFlowVertical,
    FSCalendarFlowHorizontal
};
