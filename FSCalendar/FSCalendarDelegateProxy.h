//
//  FSCalendarDelegateProxy.h
//  FSCalendar
//
//  Created by dingwenchao on 10/27/16.
//  Copyright © 2016 wenchaoios. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>

@class FSCalendar, FSCalendarCell;

typedef NS_ENUM(NSUInteger, FSCalendarMonthPosition);

@interface FSCalendarDelegateProxy : NSObject

@property (weak, nonatomic) FSCalendar *calendar;

- (instancetype)initWithCalendar:(FSCalendar *)calendar;

// DataSource requests
- (NSString *)titleForDate:(NSDate *)date;
- (NSString *)subtitleForDate:(NSDate *)date;
- (UIImage *)imageForDate:(NSDate *)date;
- (NSInteger)numberOfEventsForDate:(NSDate *)date;
- (NSDate *)minimumDateForCalendar;
- (NSDate *)maximumDateForCalendar;
- (FSCalendarCell *)cellForDate:(NSDate *)date atMonthPosition:(FSCalendarMonthPosition)position;

// Delegate requests
- (BOOL)shouldSelectDate:(NSDate *)date atMonthPosition:(FSCalendarMonthPosition)position;
- (void)didSelectDate:(NSDate *)date atMonthPosition:(FSCalendarMonthPosition)position;
- (BOOL)shouldDeselectDate:(NSDate *)date atMonthPosition:(FSCalendarMonthPosition)position;
- (void)didDeselectDate:(NSDate *)date atMonthPosition:(FSCalendarMonthPosition)position;
- (void)currentPageDidChange;
- (BOOL)boundingRectWillChange:(BOOL)animated;
- (void)willDisplayCell:(FSCalendarCell *)cell forDate:(NSDate *)date atMonthPosition:(FSCalendarMonthPosition)position;

// Delegate appearance requests
- (UIColor *)preferredFillDefaultColorForDate:(NSDate *)date;
- (UIColor *)preferredFillSelectionColorForDate:(NSDate *)date;
- (UIColor *)preferredTitleDefaultColorForDate:(NSDate *)date;
- (UIColor *)preferredTitleSelectionColorForDate:(NSDate *)date;
- (UIColor *)preferredSubtitleDefaultColorForDate:(NSDate *)date;
- (UIColor *)preferredSubtitleSelectionColorForDate:(NSDate *)date;
- (UIColor *)preferredBorderDefaultColorForDate:(NSDate *)date;
- (UIColor *)preferredBorderSelectionColorForDate:(NSDate *)date;
- (CGPoint)preferredTitleOffsetForDate:(NSDate *)date;
- (CGPoint)preferredSubtitleOffsetForDate:(NSDate *)date;
- (CGPoint)preferredImageOffsetForDate:(NSDate *)date;
- (CGPoint)preferredEventOffsetForDate:(NSDate *)date;
- (NSArray<UIColor *> *)preferredEventDefaultColorsForDate:(NSDate *)date;
- (NSArray<UIColor *> *)preferredEventSelectionColorsForDate:(NSDate *)date;
- (CGFloat)preferredBorderRadiusForDate:(NSDate *)date;

@end
