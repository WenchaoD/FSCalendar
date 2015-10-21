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

UIKIT_EXTERN CGFloat const kFSCalendarDefaultHeaderHeight;
UIKIT_EXTERN CGFloat const kFSCalendarDefaultStickyHeaderHeight;
UIKIT_EXTERN CGFloat const kFSCalendarMinimumRowHeight;
UIKIT_EXTERN CGFloat const kFSCalendarDefaultWeekHeight;
UIKIT_EXTERN CGFloat const kFSCalendarDefaultBounceAnimationDuration;


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
