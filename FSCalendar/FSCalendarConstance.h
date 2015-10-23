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

UIKIT_EXTERN CGFloat const kFSCalendarStandardHeaderHeight;
UIKIT_EXTERN CGFloat const kFSCalendarStandardWeekdayHeight;
UIKIT_EXTERN CGFloat const kFSCalendarStandardMonthlyPageHeight;
UIKIT_EXTERN CGFloat const kFSCalendarStandardWeeklyPageHeight;
UIKIT_EXTERN CGFloat const kFSCalendarStandardCellDiameter;
UIKIT_EXTERN CGFloat const kFSCalendarAutomaticDimension;
UIKIT_EXTERN CGFloat const kFSCalendarDefaultBounceAnimationDuration;
UIKIT_EXTERN CGFloat const kFSCalendarStandardRowHeight;
UIKIT_EXTERN CGFloat const kFSCalendarStandardTitleTextSize;
UIKIT_EXTERN CGFloat const kFSCalendarStandardSubtitleTextSize;
UIKIT_EXTERN CGFloat const kFSCalendarStandardWeekdayTextSize;
UIKIT_EXTERN CGFloat const kFSCalendarStandardHeaderTextSize;


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
