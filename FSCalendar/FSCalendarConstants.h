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

#pragma mark - Constants

CG_EXTERN CGFloat const FSCalendarStandardHeaderHeight;
CG_EXTERN CGFloat const FSCalendarStandardWeekdayHeight;
CG_EXTERN CGFloat const FSCalendarStandardMonthlyPageHeight;
CG_EXTERN CGFloat const FSCalendarStandardWeeklyPageHeight;
CG_EXTERN CGFloat const FSCalendarStandardCellDiameter;
CG_EXTERN CGFloat const FSCalendarStandardSeparatorThickness;
CG_EXTERN CGFloat const FSCalendarAutomaticDimension;
CG_EXTERN CGFloat const FSCalendarDefaultBounceAnimationDuration;
CG_EXTERN CGFloat const FSCalendarStandardRowHeight;
CG_EXTERN CGFloat const FSCalendarStandardTitleTextSize;
CG_EXTERN CGFloat const FSCalendarStandardSubtitleTextSize;
CG_EXTERN CGFloat const FSCalendarStandardWeekdayTextSize;
CG_EXTERN CGFloat const FSCalendarStandardHeaderTextSize;
CG_EXTERN CGFloat const FSCalendarMaximumEventDotDiameter;

UIKIT_EXTERN NSInteger const FSCalendarDefaultHourComponent;
UIKIT_EXTERN NSInteger const FSCalendarMaximumNumberOfEvents;

UIKIT_EXTERN NSString * const FSCalendarDefaultCellReuseIdentifier;
UIKIT_EXTERN NSString * const FSCalendarBlankCellReuseIdentifier;
UIKIT_EXTERN NSString * const FSCalendarInvalidArgumentsExceptionName;

CG_EXTERN CGPoint const CGPointInfinity;
CG_EXTERN CGSize const CGSizeAutomatic;

#if TARGET_INTERFACE_BUILDER
#define FSCalendarDeviceIsIPad NO
#else
#define FSCalendarDeviceIsIPad [[UIDevice currentDevice].model hasPrefix:@"iPad"]
#endif

#define FSCalendarStandardSelectionColor   FSColorRGBA(31,119,219,1.0)
#define FSCalendarStandardTodayColor       FSColorRGBA(198,51,42 ,1.0)
#define FSCalendarStandardTitleTextColor   FSColorRGBA(14,69,221 ,1.0)
#define FSCalendarStandardEventDotColor    FSColorRGBA(31,119,219,0.75)

#define FSCalendarStandardLineColor        [[UIColor lightGrayColor] colorWithAlphaComponent:0.30]
#define FSCalendarStandardSeparatorColor   [[UIColor lightGrayColor] colorWithAlphaComponent:0.60]

#define FSColorRGBA(r,g,b,a) [UIColor colorWithRed:r/255.0 green:g/255.0 blue:b/255.0 alpha:a]
#define FSCalendarInAppExtension [[[NSBundle mainBundle] bundlePath] hasSuffix:@".appex"]

#define FSCalendarFloor(c) floorf(c)
#define FSCalendarRound(c) roundf(c)
#define FSCalendarCeil(c) ceilf(c)
#define FSCalendarMod(c1,c2) fmodf(c1,c2)

#define FSCalendarHalfRound(c) (FSCalendarRound(c*2)*0.5)
#define FSCalendarHalfFloor(c) (FSCalendarFloor(c*2)*0.5)
#define FSCalendarHalfCeil(c) (FSCalendarCeil(c*2)*0.5)

#define FSCalendarUseWeakSelf __weak __typeof__(self) FSCalendarWeakSelf = self;
#define FSCalendarUseStrongSelf __strong __typeof__(self) self = FSCalendarWeakSelf;


#pragma mark - Deprecated

#define FSCalendarDeprecated(instead) DEPRECATED_MSG_ATTRIBUTE(" Use " # instead " instead")

static inline void FSCalendarSliceCake(CGFloat cake, NSInteger count, CGFloat *pieces) {
    CGFloat total = cake;
    for (int i = 0; i < count; i++) {
        NSInteger remains = count - i;
        CGFloat piece = FSCalendarRound(total/remains*2)*0.5;
        total -= piece;
        pieces[i] = piece;
    }
}



