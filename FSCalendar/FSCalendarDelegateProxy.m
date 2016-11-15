//
//  FSCalendarDelegateProxy.m
//  FSCalendar
//
//  Created by dingwenchao on 10/27/16.
//  Copyright © 2016 wenchaoios. All rights reserved.
//

#import "FSCalendarDelegateProxy.h"
#import "FSCalendar.h"
#import "FSCalendarDynamicHeader.h"
#import "FSCalendarExtensions.h"

@interface FSCalendarDelegateProxy()

@property (readonly, nonatomic) id<FSCalendarDataSource> dataSource;
@property (readonly, nonatomic) id<FSCalendarDelegate> delegate;
@property (readonly, nonatomic) id<FSCalendarDelegateAppearance> delegateAppearance;

@end

@implementation FSCalendarDelegateProxy

- (instancetype)initWithCalendar:(FSCalendar *)calendar
{
    self = [super init];
    if (self) {
        self.calendar = calendar;
    }
    return self;
}

#pragma mark - DataSource requests

- (NSString *)titleForDate:(NSDate *)date
{
    if (self.dataSource && [self.dataSource respondsToSelector:@selector(calendar:titleForDate:)]) {
        return [self.dataSource calendar:self.calendar titleForDate:date];
    }
    return nil;
}

- (NSString *)subtitleForDate:(NSDate *)date
{
#if !TARGET_INTERFACE_BUILDER
    if (self.dataSource && [self.dataSource respondsToSelector:@selector(calendar:subtitleForDate:)]) {
        return [self.dataSource calendar:self.calendar subtitleForDate:date];
    }
    return nil;
#else
    return _appearance.fakeSubtitles ? @"test" : nil;
#endif
}

- (UIImage *)imageForDate:(NSDate *)date
{
    if (self.dataSource && [self.dataSource respondsToSelector:@selector(calendar:imageForDate:)]) {
        return [self.dataSource calendar:self.calendar imageForDate:date];
    }
    return nil;
}

- (NSInteger)numberOfEventsForDate:(NSDate *)date
{
#if !TARGET_INTERFACE_BUILDER
    
    if (self.dataSource && [self.dataSource respondsToSelector:@selector(calendar:numberOfEventsForDate:)]) {
        return [self.dataSource calendar:self.calendar numberOfEventsForDate:date];
    }
#pragma GCC diagnostic push
#pragma GCC diagnostic ignored "-Wdeprecated-declarations"
    if (self.dataSource && [self.dataSource respondsToSelector:@selector(calendar:hasEventForDate:)]) {
        return [self.dataSource calendar:self.calendar hasEventForDate:date];
    }
#pragma GCC diagnostic pop
    
#else
    if (self.calendar.appearance.fakeEventDots) {
        if ([@[@3,@5] containsObject:@([self dayOfDate:date])]) {
            return 1;
        }
        if ([@[@8,@16] containsObject:@([self dayOfDate:date])]) {
            return 2;
        }
        if ([@[@20,@25] containsObject:@([self dayOfDate:date])]) {
            return 3;
        }
    }
#endif
    
    return 0;
    
}

- (NSDate *)minimumDateForCalendar
{
#if TARGET_INTERFACE_BUILDER
    return _minimumDate;
#else
    NSDate *minimumDate;
    if (self.dataSource && [self.dataSource respondsToSelector:@selector(minimumDateForCalendar:)]) {
        minimumDate = [self.dataSource minimumDateForCalendar:self.calendar];
    }
    if (!minimumDate) {
        self.calendar.formatter.dateFormat = @"yyyy-MM-dd";
        minimumDate = [self.calendar.formatter dateFromString:@"1970-01-01"];
    } else {
        minimumDate = [self.calendar.gregorian dateBySettingHour:0 minute:0 second:0 ofDate:minimumDate options:0];
    }
    return minimumDate;
#endif
}

- (NSDate *)maximumDateForCalendar
{
#if TARGET_INTERFACE_BUILDER
    return _maximumDate;
#else
    NSDate *maximumDate;
    if (self.dataSource && [self.dataSource respondsToSelector:@selector(maximumDateForCalendar:)]) {
        maximumDate = [self.dataSource maximumDateForCalendar:self.calendar];
    }
    if (!maximumDate) {
        self.calendar.formatter.dateFormat = @"yyyy-MM-dd";
        maximumDate = [self.calendar.formatter dateFromString:@"2099-12-31"];
    } else {
        maximumDate = [self.calendar.gregorian dateBySettingHour:0 minute:0 second:0 ofDate:maximumDate options:0];
    }
    return maximumDate;
#endif
}

- (FSCalendarCell *)cellForDate:(NSDate *)date atMonthPosition:(FSCalendarMonthPosition)position
{
    if (self.dataSource && [self.dataSource respondsToSelector:@selector(calendar:cellForDate:atMonthPosition:)]) {
        FSCalendarCell *cell = [self.dataSource calendar:self.calendar cellForDate:date atMonthPosition:position];
        if (cell && ![cell isKindOfClass:[FSCalendarCell class]]) {
            [NSException raise:@"You must return a valid cell in calendar:cellForDate:atMonthPosition:" format:@""];
        }
        return cell;
    }
    return nil;
}

#pragma mark - Delegate requests

- (BOOL)shouldSelectDate:(NSDate *)date atMonthPosition:(FSCalendarMonthPosition)position
{
    if (self.delegate && [self.delegate respondsToSelector:@selector(calendar:shouldSelectDate:atMonthPosition:)]) {
        return [self.delegate calendar:self.calendar shouldSelectDate:date atMonthPosition:position];
    }
#pragma GCC diagnostic push
#pragma GCC diagnostic ignored "-Wdeprecated-declarations"
    else if (self.delegate && [self.delegate respondsToSelector:@selector(calendar:shouldSelectDate:)]) {
        return [self.delegate calendar:self.calendar shouldSelectDate:date];
    }
#pragma GCC diagnostic pop
    return YES;
}


- (void)didSelectDate:(NSDate *)date atMonthPosition:(FSCalendarMonthPosition)position
{
    NSMutableArray<NSDate *> *selectedDates = [self.calendar fs_variableForKey:@"_selectedDates"];
    if (!self.calendar.allowsMultipleSelection) {
        [selectedDates removeAllObjects];
    }
    if (![selectedDates containsObject:date]) {
        [selectedDates addObject:date];
    }
    if (self.delegate && [self.delegate respondsToSelector:@selector(calendar:didSelectDate:atMonthPosition:)]) {
        [self.delegate calendar:self.calendar didSelectDate:date atMonthPosition:position];
    }
#pragma GCC diagnostic push
#pragma GCC diagnostic ignored "-Wdeprecated-declarations"
    else if (self.delegate && [self.delegate respondsToSelector:@selector(calendar:didSelectDate:)]) {
        [self.delegate calendar:self.calendar didSelectDate:date];
    }
#pragma GCC diagnostic pop
}

- (BOOL)shouldDeselectDate:(NSDate *)date atMonthPosition:(FSCalendarMonthPosition)position
{
    if (self.delegate && [self.delegate respondsToSelector:@selector(calendar:shouldDeselectDate:atMonthPosition:)]) {
        return [self.delegate calendar:self.calendar shouldDeselectDate:date atMonthPosition:position];
    }
#pragma GCC diagnostic push
#pragma GCC diagnostic ignored "-Wdeprecated-declarations"
    else if (self.delegate && [self.delegate respondsToSelector:@selector(calendar:shouldDeselectDate:)]) {
        return [self.delegate calendar:self.calendar shouldDeselectDate:date];
    }
#pragma GCC diagnostic pop
    return YES;
}

- (void)didDeselectDate:(NSDate *)date atMonthPosition:(FSCalendarMonthPosition)position
{
    if (self.delegate && [self.delegate respondsToSelector:@selector(calendar:didDeselectDate:atMonthPosition:)]) {
        [self.delegate calendar:self.calendar didDeselectDate:date atMonthPosition:position];
    }
#pragma GCC diagnostic push
#pragma GCC diagnostic ignored "-Wdeprecated-declarations"
    else if (self.delegate && [self.delegate respondsToSelector:@selector(calendar:didDeselectDate:)]) {
        [self.delegate calendar:self.calendar didDeselectDate:date];
    }
#pragma GCC diagnostic pop
}

- (void)currentPageDidChange
{
    if (self.delegate && [self.delegate respondsToSelector:@selector(calendarCurrentPageDidChange:)]) {
        [self.delegate calendarCurrentPageDidChange:self.calendar];
    }
#pragma GCC diagnostic push
#pragma GCC diagnostic ignored "-Wdeprecated-declarations"
    else if (self.delegate && [self.delegate respondsToSelector:@selector(calendarCurrentMonthDidChange:)]) {
        [self.delegate calendarCurrentMonthDidChange:self.calendar];
    }
#pragma GCC diagnostic pop
}

- (BOOL)boundingRectWillChange:(BOOL)animated
{
    if (self.delegate && [self.delegate respondsToSelector:@selector(calendar:boundingRectWillChange:animated:)]) {
        CGRect boundingRect = (CGRect){CGPointZero,[self.calendar sizeThatFits:self.calendar.frame.size]};
        if (!CGRectEqualToRect((CGRect){CGPointZero,self.calendar.frame.size}, boundingRect)) {
            [self.delegate calendar:self.calendar boundingRectWillChange:boundingRect animated:animated];
            return YES;
        }
    }
    return NO;
}

- (void)willDisplayCell:(FSCalendarCell *)cell forDate:(NSDate *)date atMonthPosition:(FSCalendarMonthPosition)position
{
    if (self.delegate && [self.delegate respondsToSelector:@selector(calendar:willDisplayCell:forDate:atMonthPosition:)]) {
        [self.delegate calendar:self.calendar willDisplayCell:cell forDate:date atMonthPosition:position];
    }
}

#pragma mark - Delegate appearance requests

- (UIColor *)preferredFillDefaultColorForDate:(NSDate *)date
{
    if (self.delegateAppearance && [self.delegateAppearance respondsToSelector:@selector(calendar:appearance:fillDefaultColorForDate:)]) {
        UIColor *color = [self.delegateAppearance calendar:self.calendar appearance:self.calendar.appearance fillDefaultColorForDate:date];
        return color;
    }
#pragma GCC diagnostic push
#pragma GCC diagnostic ignored "-Wdeprecated-declarations"
    else if (self.delegateAppearance && [self.delegateAppearance respondsToSelector:@selector(calendar:appearance:fillColorForDate:)]) {
        UIColor *color = [self.delegateAppearance calendar:self.calendar appearance:self.calendar.appearance fillColorForDate:date];
        return color;
    }
#pragma GCC diagnostic pop
    return nil;
}

- (UIColor *)preferredFillSelectionColorForDate:(NSDate *)date
{
    if (self.delegateAppearance && [self.delegateAppearance respondsToSelector:@selector(calendar:appearance:fillSelectionColorForDate:)]) {
        UIColor *color = [self.delegateAppearance calendar:self.calendar appearance:self.calendar.appearance fillSelectionColorForDate:date];
        return color;
    }
#pragma GCC diagnostic push
#pragma GCC diagnostic ignored "-Wdeprecated-declarations"
    else if (self.delegateAppearance && [self.delegateAppearance respondsToSelector:@selector(calendar:appearance:selectionColorForDate:)]) {
        UIColor *color = [self.delegateAppearance calendar:self.calendar appearance:self.calendar.appearance selectionColorForDate:date];
        return color;
    }
#pragma GCC diagnostic pop
    return nil;
}

- (UIColor *)preferredTitleDefaultColorForDate:(NSDate *)date
{
    if (self.delegateAppearance && [self.delegateAppearance respondsToSelector:@selector(calendar:appearance:titleDefaultColorForDate:)]) {
        UIColor *color = [self.delegateAppearance calendar:self.calendar appearance:self.calendar.appearance titleDefaultColorForDate:date];
        return color;
    }
    return nil;
}

- (UIColor *)preferredTitleSelectionColorForDate:(NSDate *)date
{
    if (self.delegateAppearance && [self.delegateAppearance respondsToSelector:@selector(calendar:appearance:titleSelectionColorForDate:)]) {
        UIColor *color = [self.delegateAppearance calendar:self.calendar appearance:self.calendar.appearance titleSelectionColorForDate:date];
        return color;
    }
    return nil;
}

- (UIColor *)preferredSubtitleDefaultColorForDate:(NSDate *)date
{
    if (self.delegateAppearance && [self.delegateAppearance respondsToSelector:@selector(calendar:appearance:subtitleDefaultColorForDate:)]) {
        UIColor *color = [self.delegateAppearance calendar:self.calendar appearance:self.calendar.appearance subtitleDefaultColorForDate:date];
        return color;
    }
    return nil;
}

- (UIColor *)preferredSubtitleSelectionColorForDate:(NSDate *)date
{
    if (self.delegateAppearance && [self.delegateAppearance respondsToSelector:@selector(calendar:appearance:subtitleSelectionColorForDate:)]) {
        UIColor *color = [self.delegateAppearance calendar:self.calendar appearance:self.calendar.appearance subtitleSelectionColorForDate:date];
        return color;
    }
    return nil;
}

- (NSArray<UIColor *> *)preferredEventDefaultColorsForDate:(NSDate *)date
{
    if (self.delegateAppearance && [self.delegateAppearance respondsToSelector:@selector(calendar:appearance:eventDefaultColorsForDate:)]) {
        NSArray *colors = [self.delegateAppearance calendar:self.calendar appearance:self.calendar.appearance eventDefaultColorsForDate:date];
        if (colors) {
            return colors;
        }
    }
#pragma GCC diagnostic push
#pragma GCC diagnostic ignored "-Wdeprecated-declarations"
    if (self.delegateAppearance && [self.delegateAppearance respondsToSelector:@selector(calendar:appearance:eventColorsForDate:)]) {
        NSArray *colors = [self.delegateAppearance calendar:self.calendar appearance:self.calendar.appearance eventColorsForDate:date];
        if (colors) {
            return colors;
        }
    }
    if (self.delegateAppearance && [self.delegateAppearance respondsToSelector:@selector(calendar:appearance:eventColorForDate:)]) {
        UIColor *color = [self.delegateAppearance calendar:self.calendar appearance:self.calendar.appearance eventColorForDate:date];
        if (color) {
            return @[color];
        }
    }
#pragma GCC diagnostic pop
    return nil;
}

- (NSArray<UIColor *> *)preferredEventSelectionColorsForDate:(NSDate *)date
{
    if (self.delegateAppearance && [self.delegateAppearance respondsToSelector:@selector(calendar:appearance:eventSelectionColorsForDate:)]) {
        NSArray *colors = [self.delegateAppearance calendar:self.calendar appearance:self.calendar.appearance eventSelectionColorsForDate:date];
        if (colors) {
            return colors;
        }
    }
    return nil;
}

- (UIColor *)preferredBorderDefaultColorForDate:(NSDate *)date
{
    if (self.delegateAppearance && [self.delegateAppearance respondsToSelector:@selector(calendar:appearance:borderDefaultColorForDate:)]) {
        UIColor *color = [self.delegateAppearance calendar:self.calendar appearance:self.calendar.appearance borderDefaultColorForDate:date];
        return color;
    }
    return nil;
}

- (UIColor *)preferredBorderSelectionColorForDate:(NSDate *)date
{
    if (self.delegateAppearance && [self.delegateAppearance respondsToSelector:@selector(calendar:appearance:borderSelectionColorForDate:)]) {
        UIColor *color = [self.delegateAppearance calendar:self.calendar appearance:self.calendar.appearance borderSelectionColorForDate:date];
        return color;
    }
    return nil;
}

- (CGFloat)preferredBorderRadiusForDate:(NSDate *)date
{
    if (self.delegateAppearance && [self.delegateAppearance respondsToSelector:@selector(calendar:appearance:borderRadiusForDate:)]) {
        CGFloat borderRadius = [self.delegateAppearance calendar:self.calendar appearance:self.calendar.appearance borderRadiusForDate:date];
        borderRadius = MAX(0, borderRadius);
        borderRadius = MIN(1, borderRadius);
        return borderRadius;
    }
#pragma GCC diagnostic push
#pragma GCC diagnostic ignored "-Wdeprecated-declarations"
    else if (self.delegateAppearance && [self.delegateAppearance respondsToSelector:@selector(calendar:appearance:cellShapeForDate:)]) {
        FSCalendarCellShape cellShape = [self.delegateAppearance calendar:self.calendar appearance:self.calendar.appearance cellShapeForDate:date];
        return cellShape;
    }
#pragma GCC diagnostic pop
    return -1;
}

- (CGPoint)preferredTitleOffsetForDate:(NSDate *)date
{
    if (self.delegateAppearance && [self.delegateAppearance respondsToSelector:@selector(calendar:appearance:titleOffsetForDate:)]) {
        CGPoint point = [self.delegateAppearance calendar:self.calendar appearance:self.self.calendar.appearance titleOffsetForDate:date];
        return point;
    }
    return CGPointZero;
}

- (CGPoint)preferredSubtitleOffsetForDate:(NSDate *)date
{
    if (self.delegateAppearance && [self.delegateAppearance respondsToSelector:@selector(calendar:appearance:subtitleOffsetForDate:)]) {
        CGPoint point = [self.delegateAppearance calendar:self.calendar appearance:self.self.calendar.appearance subtitleOffsetForDate:date];
        return point;
    }
    return CGPointZero;
}

- (CGPoint)preferredImageOffsetForDate:(NSDate *)date
{
    if (self.delegateAppearance && [self.delegateAppearance respondsToSelector:@selector(calendar:appearance:imageOffsetForDate:)]) {
        CGPoint point = [self.delegateAppearance calendar:self.calendar appearance:self.self.calendar.appearance imageOffsetForDate:date];
        return point;
    }
    return CGPointZero;
}

- (CGPoint)preferredEventOffsetForDate:(NSDate *)date
{
    if (self.delegateAppearance && [self.delegateAppearance respondsToSelector:@selector(calendar:appearance:eventOffsetForDate:)]) {
        CGPoint point = [self.delegateAppearance calendar:self.calendar appearance:self.self.calendar.appearance eventOffsetForDate:date];
        return point;
    }
    return CGPointZero;
}

#pragma mark - Private methods

- (id<FSCalendarDelegate>)delegate { return self.calendar.delegate; }
- (id<FSCalendarDataSource>)dataSource { return self.calendar.dataSource; }
- (id<FSCalendarDelegateAppearance>)delegateAppearance
{
    if (self.delegate && [self.delegate conformsToProtocol:@protocol(FSCalendarDelegateAppearance)]) {
        return (id<FSCalendarDelegateAppearance>)self.delegate;
    }
    return nil;
}

@end
