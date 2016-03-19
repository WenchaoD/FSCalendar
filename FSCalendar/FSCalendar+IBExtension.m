//
//  FSCalendar+IBExtension.m
//  FSCalendar
//
//  Created by Wenchao Ding on 8/14/15.
//  Copyright © 2016 Wenchao Ding. All rights reserved.
//

#import "FSCalendar+IBExtension.h"

@implementation FSCalendar (IBExtension)
#if !TARGET_INTERFACE_BUILDER
@dynamic fakedSelectedDay,fakeSubtitles;
#endif

#pragma mark - adjustsFontSizeToFitContentSize

- (void)setAdjustsFontSizeToFitContentSize:(BOOL)adjustsFontSizeToFitContentSize
{
    self.appearance.adjustsFontSizeToFitContentSize = adjustsFontSizeToFitContentSize;
}

- (BOOL)adjustsFontSizeToFitContentSize
{
    return self.appearance.adjustsFontSizeToFitContentSize;
}

#pragma mark -  eventColor

- (void)setEventColor:(UIColor *)eventColor
{
    self.appearance.eventColor = eventColor;
}

- (UIColor *)eventColor
{
    return self.appearance.eventColor;
}

#pragma mark - weekdayTextColor

- (void)setWeekdayTextColor:(UIColor *)weekdayTextColor
{
    self.appearance.weekdayTextColor = weekdayTextColor;
}

- (UIColor *)weekdayTextColor
{
    return self.appearance.weekdayTextColor;
}

#pragma mark - headerTitleColor

- (void)setHeaderTitleColor:(UIColor *)headerTitleColor
{
    self.appearance.headerTitleColor = headerTitleColor;
}

- (UIColor *)headerTitleColor
{
    return self.appearance.headerTitleColor;
}

#pragma mark -  headerDateFormat

- (void)setHeaderDateFormat:(NSString *)headerDateFormat
{
    self.appearance.headerDateFormat = headerDateFormat;
}

- (NSString *)headerDateFormat
{
    return self.appearance.headerDateFormat;
}

#pragma mark -  headerMinimumDissolvedAlpha

- (void)setHeaderMinimumDissolvedAlpha:(CGFloat)headerMinimumDissolvedAlpha
{
    self.appearance.headerMinimumDissolvedAlpha = headerMinimumDissolvedAlpha;
}

- (CGFloat)headerMinimumDissolvedAlpha
{
    return self.appearance.headerMinimumDissolvedAlpha;
}

#pragma mark -  titleDefaultColor

- (void)setTitleDefaultColor:(UIColor *)titleDefaultColor
{
    self.appearance.titleDefaultColor = titleDefaultColor;
}

- (UIColor *)titleDefaultColor
{
    return self.appearance.titleDefaultColor;
}

#pragma mark -  titleSelectionColor

- (void)setTitleSelectionColor:(UIColor *)titleSelectionColor
{
    self.appearance.titleSelectionColor = titleSelectionColor;
}

- (UIColor *)titleSelectionColor
{
    return self.appearance.titleSelectionColor;
}

#pragma mark -  titleTodayColor

- (void)setTitleTodayColor:(UIColor *)titleTodayColor
{
    self.appearance.titleTodayColor = titleTodayColor;
}

- (UIColor *)titleTodayColor
{
    return self.appearance.titleTodayColor;
}

#pragma mark - titlePlaceholderColor

- (void)setTitlePlaceholderColor:(UIColor *)titlePlaceholderColor
{
    self.appearance.titlePlaceholderColor = titlePlaceholderColor;
}

- (UIColor *)titlePlaceholderColor
{
    return self.appearance.titlePlaceholderColor;
}

#pragma mark - titleWeekendColor

- (void)setTitleWeekendColor:(UIColor *)titleWeekendColor
{
    self.appearance.titleWeekendColor = titleWeekendColor;
}

- (UIColor *)titleWeekendColor
{
    return self.appearance.titleWeekendColor;
}

#pragma mark - subtitleDefaultColor

- (void)setSubtitleDefaultColor:(UIColor *)subtitleDefaultColor
{
    self.appearance.subtitleDefaultColor = subtitleDefaultColor;
}

- (UIColor *)subtitleDefaultColor
{
    return self.appearance.subtitleDefaultColor;
}

#pragma mark - subtitleSelectionColor

- (void)setSubtitleSelectionColor:(UIColor *)subtitleSelectionColor
{
    self.appearance.subtitleSelectionColor = subtitleSelectionColor;
}

- (UIColor *)subtitleSelectionColor
{
    return self.appearance.subtitleSelectionColor;
}

#pragma mark - subtitleTodayColor

- (void)setSubtitleTodayColor:(UIColor *)subtitleTodayColor
{
    self.appearance.subtitleTodayColor = subtitleTodayColor;
}

- (UIColor *)subtitleTodayColor
{
    return self.appearance.subtitleTodayColor;
}

#pragma mark - subtitlePlaceholderColor

- (void)setSubtitlePlaceholderColor:(UIColor *)subtitlePlaceholderColor
{
    self.appearance.subtitlePlaceholderColor = subtitlePlaceholderColor;
}

- (UIColor *)subtitlePlaceholderColor
{
    return self.appearance.subtitlePlaceholderColor;
}

#pragma mark -  subtitleWeekendColor

- (void)setSubtitleWeekendColor:(UIColor *)subtitleWeekendColor
{
    self.appearance.subtitleWeekendColor = subtitleWeekendColor;
}

- (UIColor *)subtitleWeekendColor
{
    return self.appearance.subtitleWeekendColor;
}

#pragma mark -  selectionColor

- (void)setSelectionColor:(UIColor *)selectionColor
{
    self.appearance.selectionColor = selectionColor;
}

- (UIColor *)selectionColor
{
    return self.appearance.selectionColor;
}

#pragma mark -  todayColor

- (void)setTodayColor:(UIColor *)todayColor
{
    self.appearance.todayColor = todayColor;
}

- (UIColor *)todayColor
{
    return self.appearance.todayColor;
}

#pragma mark - todaySelectionColor

- (void)setTodaySelectionColor:(UIColor *)todaySelectionColor
{
    self.appearance.todaySelectionColor = todaySelectionColor;
}

- (UIColor *)todaySelectionColor
{
    return self.appearance.todaySelectionColor;
}

#pragma mark - borderDefaultColor

- (void)setBorderDefaultColor:(UIColor *)borderDefaultColor
{
    self.appearance.borderDefaultColor = borderDefaultColor;
}

- (UIColor *)borderDefaultColor
{
    return self.appearance.borderDefaultColor;
}

#pragma mark - borderSelectionColor

- (void)setBorderSelectionColor:(UIColor *)borderSelectionColor
{
    self.appearance.borderSelectionColor = borderSelectionColor;
}

- (UIColor *)borderSelectionColor
{
    return self.appearance.borderSelectionColor;
}

#pragma mark - cellStyle

- (void)setCellShape:(FSCalendarCellShape)cellShape
{
    self.appearance.cellShape = cellShape;
}

- (FSCalendarCellShape)cellShape
{
    return self.appearance.cellShape;
}

#pragma mark - useVeryShortWeekdaySymbols

- (void)setUseVeryShortWeekdaySymbols:(BOOL)useVeryShortWeekdaySymbols
{
#pragma GCC diagnostic push
#pragma GCC diagnostic ignored "-Wdeprecated-declarations"
    self.appearance.useVeryShortWeekdaySymbols = useVeryShortWeekdaySymbols;
#pragma GCC diagnostic pop
}

- (BOOL)useVeryShortWeekdaySymbols
{
#pragma GCC diagnostic push
#pragma GCC diagnostic ignored "-Wdeprecated-declarations"
    return self.appearance.useVeryShortWeekdaySymbols;
#pragma GCC diagnostic pop
}


#pragma mark - fakeSubtitles

- (void)setFakeSubtitles:(BOOL)fakeSubtitles
{
#if TARGET_INTERFACE_BUILDER
    self.appearance.fakeSubtitles = fakeSubtitles;
#endif
}

#if TARGET_INTERFACE_BUILDER
- (BOOL)fakeSubtitles
{
    return self.appearance.fakeSubtitles;
}
#endif

#pragma mark - fakedSelectedDay

- (void)setFakedSelectedDay:(NSInteger)fakedSelectedDay
{
#if TARGET_INTERFACE_BUILDER
    self.appearance.fakedSelectedDay = fakedSelectedDay;
#endif
}


#if TARGET_INTERFACE_BUILDER
- (NSInteger)fakedSelectedDay
{
    return self.appearance.fakedSelectedDay;
}
#endif

#pragma GCC diagnostic push
#pragma GCC diagnostic ignored "-Wdeprecated-declarations"

- (void)setTitleTextSize:(CGFloat)titleTextSize
{
    self.appearance.titleTextSize = titleTextSize;
}

- (CGFloat)titleTextSize
{
    return self.appearance.titleTextSize;
}


- (void)setSubtitleTextSize:(CGFloat)subtitleTextSize
{
    self.appearance.subtitleTextSize = subtitleTextSize;
}

- (CGFloat)subtitleTextSize
{
    return self.appearance.subtitleTextSize;
}

- (void)setWeekdayTextSize:(CGFloat)weekdayTextSize
{
    self.appearance.weekdayTextSize = weekdayTextSize;
}

- (CGFloat)weekdayTextSize
{
    return self.appearance.weekdayTextSize;
}

- (void)setHeaderTitleTextSize:(CGFloat)headerTitleTextSize
{
    self.appearance.headerTitleTextSize = headerTitleTextSize;
}

- (CGFloat)headerTitleTextSize
{
    return self.appearance.headerTitleTextSize;
}

#pragma GCC diagnostic pop

@end
