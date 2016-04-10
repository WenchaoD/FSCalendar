//
//  FSCalendarAppearance.m
//  Pods
//
//  Created by DingWenchao on 6/29/15.
//  Copyright © 2016 Wenchao Ding. All rights reserved.
//
//  https://github.com/WenchaoD
//

#import "FSCalendarAppearance.h"
#import "FSCalendarDynamicHeader.h"
#import "UIView+FSExtension.h"

@interface FSCalendarAppearance ()

@property (weak  , nonatomic) FSCalendar *calendar;

@property (strong, nonatomic) NSMutableDictionary *backgroundColors;
@property (strong, nonatomic) NSMutableDictionary *titleColors;
@property (strong, nonatomic) NSMutableDictionary *subtitleColors;
@property (strong, nonatomic) NSMutableDictionary *borderColors;

@property (strong, nonatomic) NSString *titleFontName;
@property (strong, nonatomic) NSString *subtitleFontName;
@property (strong, nonatomic) NSString *weekdayFontName;
@property (strong, nonatomic) NSString *headerTitleFontName;

@property (assign, nonatomic) CGFloat titleFontSize;
@property (assign, nonatomic) CGFloat subtitleFontSize;
@property (assign, nonatomic) CGFloat weekdayFontSize;
@property (assign, nonatomic) CGFloat headerTitleFontSize;

@property (assign, nonatomic) CGFloat preferredTitleFontSize;
@property (assign, nonatomic) CGFloat preferredSubtitleFontSize;
@property (assign, nonatomic) CGFloat preferredWeekdayFontSize;
@property (assign, nonatomic) CGFloat preferredHeaderTitleFontSize;

@property (readonly, nonatomic) UIFont *preferredTitleFont;
@property (readonly, nonatomic) UIFont *preferredSubtitleFont;
@property (readonly, nonatomic) UIFont *preferredWeekdayFont;
@property (readonly, nonatomic) UIFont *preferredHeaderTitleFont;

- (void)adjustTitleIfNecessary;

- (void)invalidateFonts;
- (void)invalidateTextColors;
- (void)invalidateTitleFont;
- (void)invalidateSubtitleFont;
- (void)invalidateWeekdayFont;
- (void)invalidateHeaderFont;
- (void)invalidateTitleTextColor;
- (void)invalidateSubtitleTextColor;
- (void)invalidateWeekdayTextColor;
- (void)invalidateHeaderTextColor;

- (void)invalidateBorderColors;
- (void)invalidateFillColors;
- (void)invalidateEventColors;
- (void)invalidateCellShapes;

@end

@implementation FSCalendarAppearance

- (instancetype)init
{
    self = [super init];
    if (self) {
        
        _adjustsFontSizeToFitContentSize = YES;
        
        _titleFontSize = _preferredTitleFontSize  = FSCalendarStandardTitleTextSize;
        _subtitleFontSize = _preferredSubtitleFontSize = FSCalendarStandardSubtitleTextSize;
        _weekdayFontSize = _preferredWeekdayFontSize = FSCalendarStandardWeekdayTextSize;
        _headerTitleFontSize = _preferredHeaderTitleFontSize = FSCalendarStandardHeaderTextSize;
        
        _titleFontName = [UIFont systemFontOfSize:1].fontName;
        _subtitleFontName = [UIFont systemFontOfSize:1].fontName;
        _weekdayFontName = [UIFont systemFontOfSize:1].fontName;
        _headerTitleFontName = [UIFont systemFontOfSize:1].fontName;
        
        _headerTitleColor = FSCalendarStandardTitleTextColor;
        _headerDateFormat = @"MMMM yyyy";
        _headerMinimumDissolvedAlpha = 0.2;
        _weekdayTextColor = FSCalendarStandardTitleTextColor;
        _caseOptions = FSCalendarCaseOptionsHeaderUsesDefaultCase|FSCalendarCaseOptionsWeekdayUsesDefaultCase;
        
        _backgroundColors = [NSMutableDictionary dictionaryWithCapacity:5];
        _backgroundColors[@(FSCalendarCellStateNormal)]      = [UIColor clearColor];
        _backgroundColors[@(FSCalendarCellStateSelected)]    = FSCalendarStandardSelectionColor;
        _backgroundColors[@(FSCalendarCellStateDisabled)]    = [UIColor clearColor];
        _backgroundColors[@(FSCalendarCellStatePlaceholder)] = [UIColor clearColor];
        _backgroundColors[@(FSCalendarCellStateToday)]       = FSCalendarStandardTodayColor;
        
        _titleColors = [NSMutableDictionary dictionaryWithCapacity:5];
        _titleColors[@(FSCalendarCellStateNormal)]      = [UIColor blackColor];
        _titleColors[@(FSCalendarCellStateSelected)]    = [UIColor whiteColor];
        _titleColors[@(FSCalendarCellStateDisabled)]    = [UIColor grayColor];
        _titleColors[@(FSCalendarCellStatePlaceholder)] = [UIColor lightGrayColor];
        _titleColors[@(FSCalendarCellStateToday)]       = [UIColor whiteColor];
        
        _subtitleColors = [NSMutableDictionary dictionaryWithCapacity:5];
        _subtitleColors[@(FSCalendarCellStateNormal)]      = [UIColor darkGrayColor];
        _subtitleColors[@(FSCalendarCellStateSelected)]    = [UIColor whiteColor];
        _subtitleColors[@(FSCalendarCellStateDisabled)]    = [UIColor lightGrayColor];
        _subtitleColors[@(FSCalendarCellStatePlaceholder)] = [UIColor lightGrayColor];
        _subtitleColors[@(FSCalendarCellStateToday)]       = [UIColor whiteColor];
        
        _borderColors[@(FSCalendarCellStateSelected)] = [UIColor clearColor];
        _borderColors[@(FSCalendarCellStateNormal)] = [UIColor clearColor];
        
        _cellShape = FSCalendarCellShapeCircle;
        _eventColor = FSCalendarStandardEventDotColor;
        
        _borderColors = [NSMutableDictionary dictionaryWithCapacity:2];
        
    }
    return self;
}

- (void)setTitleFont:(UIFont *)titleFont
{
    BOOL needsInvalidating = NO;
    if (![_titleFontName isEqualToString:titleFont.fontName]) {
        _titleFontName = titleFont.fontName;
        needsInvalidating = YES;
    }
    if (_titleFontSize != titleFont.pointSize) {
        _titleFontSize = titleFont.pointSize;
        needsInvalidating = YES;
    }
    if (needsInvalidating) {
        [self invalidateTitleFont];
    }
}

- (UIFont *)titleFont
{
    return [UIFont fontWithName:_titleFontName size:_titleFontSize];
}

- (void)setSubtitleFont:(UIFont *)subtitleFont
{
    BOOL needsInvalidating = NO;
    if (![_subtitleFontName isEqualToString:subtitleFont.fontName]) {
        _subtitleFontName = subtitleFont.fontName;
        needsInvalidating = YES;
    }
    if (_subtitleFontSize != subtitleFont.pointSize) {
        _subtitleFontSize = subtitleFont.pointSize;
        needsInvalidating = YES;
    }
    if (needsInvalidating) {
        [self invalidateSubtitleFont];
    }
}

- (UIFont *)subtitleFont
{
    return [UIFont fontWithName:_subtitleFontName size:_subtitleFontSize];
}

- (void)setWeekdayFont:(UIFont *)weekdayFont
{
    BOOL needsInvalidating = NO;
    if (![_weekdayFontName isEqualToString:weekdayFont.fontName]) {
        _weekdayFontName = weekdayFont.fontName;
        needsInvalidating = YES;
    }
    if (_weekdayFontSize != weekdayFont.pointSize) {
        _weekdayFontSize = weekdayFont.pointSize;
        needsInvalidating = YES;
    }
    if (needsInvalidating) {
        [self invalidateWeekdayFont];
    }
}

- (UIFont *)weekdayFont
{
    return [UIFont fontWithName:_weekdayFontName size:_weekdayFontSize];
}

- (void)setHeaderTitleFont:(UIFont *)headerTitleFont
{
    BOOL needsInvalidating = NO;
    if (![_headerTitleFontName isEqualToString:headerTitleFont.fontName]) {
        _headerTitleFontName = headerTitleFont.fontName;
        needsInvalidating = YES;
    }
    if (_headerTitleFontSize != headerTitleFont.pointSize) {
        _headerTitleFontSize = headerTitleFont.pointSize;
        needsInvalidating = YES;
    }
    if (needsInvalidating) {
        [self invalidateHeaderFont];
    }
}

- (void)setTitleVerticalOffset:(CGFloat)titleVerticalOffset
{
    if (_titleVerticalOffset != titleVerticalOffset) {
        _titleVerticalOffset = titleVerticalOffset;
        [_calendar.collectionView.visibleCells makeObjectsPerformSelector:@selector(setNeedsLayout)];
    }
}

- (void)setSubtitleVerticalOffset:(CGFloat)subtitleVerticalOffset
{
    if (_subtitleVerticalOffset != subtitleVerticalOffset) {
        _subtitleVerticalOffset = subtitleVerticalOffset;
        [_calendar.collectionView.visibleCells makeObjectsPerformSelector:@selector(setNeedsLayout)];
    }
}

- (UIFont *)headerTitleFont
{
    return [UIFont fontWithName:_headerTitleFontName size:_headerTitleFontSize];
}

- (void)setTitleDefaultColor:(UIColor *)color
{
    if (color) {
        _titleColors[@(FSCalendarCellStateNormal)] = color;
    } else {
        [_titleColors removeObjectForKey:@(FSCalendarCellStateNormal)];
    }
    [self invalidateTitleTextColor];
}

- (UIColor *)titleDefaultColor
{
    return _titleColors[@(FSCalendarCellStateNormal)];
}

- (void)setTitleSelectionColor:(UIColor *)color
{
    if (color) {
        _titleColors[@(FSCalendarCellStateSelected)] = color;
    } else {
        [_titleColors removeObjectForKey:@(FSCalendarCellStateSelected)];
    }
    [self invalidateTitleTextColor];
}

- (UIColor *)titleSelectionColor
{
    return _titleColors[@(FSCalendarCellStateSelected)];
}

- (void)setTitleTodayColor:(UIColor *)color
{
    if (color) {
        _titleColors[@(FSCalendarCellStateToday)] = color;
    } else {
        [_titleColors removeObjectForKey:@(FSCalendarCellStateToday)];
    }
    [self invalidateTitleTextColor];
}

- (UIColor *)titleTodayColor
{
    return _titleColors[@(FSCalendarCellStateToday)];
}

- (void)setTitlePlaceholderColor:(UIColor *)color
{
    if (color) {
        _titleColors[@(FSCalendarCellStatePlaceholder)] = color;
    } else {
        [_titleColors removeObjectForKey:@(FSCalendarCellStatePlaceholder)];
    }
    [self invalidateTitleTextColor];
}

- (UIColor *)titlePlaceholderColor
{
    return _titleColors[@(FSCalendarCellStatePlaceholder)];
}

- (void)setTitleWeekendColor:(UIColor *)color
{
    if (color) {
        _titleColors[@(FSCalendarCellStateWeekend)] = color;
    } else {
        [_titleColors removeObjectForKey:@(FSCalendarCellStateWeekend)];
    }
    [self invalidateTitleTextColor];
}

- (UIColor *)titleWeekendColor
{
    return _titleColors[@(FSCalendarCellStateWeekend)];
}

- (void)setSubtitleDefaultColor:(UIColor *)color
{
    if (color) {
        _subtitleColors[@(FSCalendarCellStateNormal)] = color;
    } else {
        [_subtitleColors removeObjectForKey:@(FSCalendarCellStateNormal)];
    }
    [self invalidateSubtitleTextColor];
}

-(UIColor *)subtitleDefaultColor
{
    return _subtitleColors[@(FSCalendarCellStateNormal)];
}

- (void)setSubtitleSelectionColor:(UIColor *)color
{
    if (color) {
        _subtitleColors[@(FSCalendarCellStateSelected)] = color;
    } else {
        [_subtitleColors removeObjectForKey:@(FSCalendarCellStateSelected)];
    }
    [self invalidateSubtitleTextColor];
}

- (UIColor *)subtitleSelectionColor
{
    return _subtitleColors[@(FSCalendarCellStateSelected)];
}

- (void)setSubtitleTodayColor:(UIColor *)color
{
    if (color) {
        _subtitleColors[@(FSCalendarCellStateToday)] = color;
    } else {
        [_subtitleColors removeObjectForKey:@(FSCalendarCellStateToday)];
    }
    [self invalidateSubtitleTextColor];
}

- (UIColor *)subtitleTodayColor
{
    return _subtitleColors[@(FSCalendarCellStateToday)];
}

- (void)setSubtitlePlaceholderColor:(UIColor *)color
{
    if (color) {
        _subtitleColors[@(FSCalendarCellStatePlaceholder)] = color;
    } else {
        [_subtitleColors removeObjectForKey:@(FSCalendarCellStatePlaceholder)];
    }
    [self invalidateSubtitleTextColor];
}

- (UIColor *)subtitlePlaceholderColor
{
    return _subtitleColors[@(FSCalendarCellStatePlaceholder)];
}

- (void)setSubtitleWeekendColor:(UIColor *)color
{
    if (color) {
        _subtitleColors[@(FSCalendarCellStateWeekend)] = color;
    } else {
        [_subtitleColors removeObjectForKey:@(FSCalendarCellStateWeekend)];
    }
    [self invalidateSubtitleTextColor];
}

- (UIColor *)subtitleWeekendColor
{
    return _subtitleColors[@(FSCalendarCellStateWeekend)];
}

- (void)setSelectionColor:(UIColor *)color
{
    if (color) {
        _backgroundColors[@(FSCalendarCellStateSelected)] = color;
    } else {
        [_backgroundColors removeObjectForKey:@(FSCalendarCellStateSelected)];
    }
    [self invalidateFillColors];
}

- (UIColor *)selectionColor
{
    return _backgroundColors[@(FSCalendarCellStateSelected)];
}

- (void)setTodayColor:(UIColor *)todayColor
{
    if (todayColor) {
        _backgroundColors[@(FSCalendarCellStateToday)] = todayColor;
    } else {
        [_backgroundColors removeObjectForKey:@(FSCalendarCellStateToday)];
    }
    [self invalidateFillColors];
}

- (UIColor *)todayColor
{
    return _backgroundColors[@(FSCalendarCellStateToday)];
}

- (void)setTodaySelectionColor:(UIColor *)todaySelectionColor
{
    if (todaySelectionColor) {
        _backgroundColors[@(FSCalendarCellStateToday|FSCalendarCellStateSelected)] = todaySelectionColor;
    } else {
        [_backgroundColors removeObjectForKey:@(FSCalendarCellStateToday|FSCalendarCellStateSelected)];
    }
    [self invalidateFillColors];
}

- (UIColor *)todaySelectionColor
{
    return _backgroundColors[@(FSCalendarCellStateToday|FSCalendarCellStateSelected)];
}

- (void)setEventColor:(UIColor *)eventColor
{
    if (![_eventColor isEqual:eventColor]) {
        _eventColor = eventColor;
        [self invalidateEventColors];
    }
}

- (void)setBorderDefaultColor:(UIColor *)color
{
    if (color) {
        _borderColors[@(FSCalendarCellStateNormal)] = color;
    } else {
        [_borderColors removeObjectForKey:@(FSCalendarCellStateNormal)];
    }
    [self invalidateBorderColors];
}

- (UIColor *)borderDefaultColor
{
    return _borderColors[@(FSCalendarCellStateNormal)];
}

- (void)setBorderSelectionColor:(UIColor *)color
{
    if (color) {
        _borderColors[@(FSCalendarCellStateSelected)] = color;
    } else {
        [_borderColors removeObjectForKey:@(FSCalendarCellStateSelected)];
    }
    [self invalidateBorderColors];
}

- (UIColor *)borderSelectionColor
{
    return _borderColors[@(FSCalendarCellStateSelected)];
}

- (void)setCellShape:(FSCalendarCellShape)cellShape
{
    if (_cellShape != cellShape) {
        _cellShape = cellShape;
        [self invalidateCellShapes];
    }
}

- (void)setWeekdayTextColor:(UIColor *)weekdayTextColor
{
    if (![_weekdayTextColor isEqual:weekdayTextColor]) {
        _weekdayTextColor = weekdayTextColor;
        [self invalidateWeekdayTextColor];
    }
}

- (void)setHeaderTitleColor:(UIColor *)color
{
    if (![_headerTitleColor isEqual:color]) {
        _headerTitleColor = color;
        [self invalidateHeaderTextColor];
    }
}

- (void)setHeaderMinimumDissolvedAlpha:(CGFloat)headerMinimumDissolvedAlpha
{
    if (_headerMinimumDissolvedAlpha != headerMinimumDissolvedAlpha) {
        _headerMinimumDissolvedAlpha = headerMinimumDissolvedAlpha;
        [_calendar.header.collectionView.visibleCells makeObjectsPerformSelector:@selector(setNeedsLayout)];
        [_calendar.visibleStickyHeaders makeObjectsPerformSelector:@selector(setNeedsLayout)];
    }
}

- (void)setHeaderDateFormat:(NSString *)headerDateFormat
{
    if (![_headerDateFormat isEqual:headerDateFormat]) {
        _headerDateFormat = headerDateFormat;
        [_calendar invalidateHeaders];
    }
}

- (void)setAdjustsFontSizeToFitContentSize:(BOOL)adjustsFontSizeToFitContentSize
{
    if (_adjustsFontSizeToFitContentSize != adjustsFontSizeToFitContentSize) {
        _adjustsFontSizeToFitContentSize = adjustsFontSizeToFitContentSize;
        if (adjustsFontSizeToFitContentSize) {
            [self invalidateFonts];
        }
    }
}

- (UIFont *)preferredTitleFont
{
    return [UIFont fontWithName:_titleFontName size:_adjustsFontSizeToFitContentSize?_preferredTitleFontSize:_titleFontSize];
}

- (UIFont *)preferredSubtitleFont
{
    return [UIFont fontWithName:_subtitleFontName size:_adjustsFontSizeToFitContentSize?_preferredSubtitleFontSize:_subtitleFontSize];
}

- (UIFont *)preferredWeekdayFont
{
    return [UIFont fontWithName:_weekdayFontName size:_adjustsFontSizeToFitContentSize?_preferredWeekdayFontSize:_weekdayFontSize];
}

- (UIFont *)preferredHeaderTitleFont
{
    return [UIFont fontWithName:_headerTitleFontName size:_adjustsFontSizeToFitContentSize?_preferredHeaderTitleFontSize:_headerTitleFontSize];
}

- (void)adjustTitleIfNecessary
{
    if (!self.calendar.floatingMode) {
        if (_adjustsFontSizeToFitContentSize) {
            CGFloat factor       = (_calendar.scope==FSCalendarScopeMonth) ? 6 : 1.1;
            _preferredTitleFontSize       = _calendar.collectionView.fs_height/3/factor;
            _preferredTitleFontSize       -= (_preferredTitleFontSize-FSCalendarStandardTitleTextSize)*0.5;
            _preferredSubtitleFontSize    = _calendar.collectionView.fs_height/4.5/factor;
            _preferredSubtitleFontSize    -= (_preferredSubtitleFontSize-FSCalendarStandardSubtitleTextSize)*0.75;
            _preferredHeaderTitleFontSize = _preferredTitleFontSize * 1.25;
            _preferredWeekdayFontSize     = _preferredTitleFontSize;
            
        }
    } else {
        _preferredHeaderTitleFontSize = 20;
        if (FSCalendarDeviceIsIPad) {
            _preferredHeaderTitleFontSize = FSCalendarStandardHeaderTextSize * 1.5;
            _preferredTitleFontSize = FSCalendarStandardTitleTextSize * 1.3;
            _preferredSubtitleFontSize = FSCalendarStandardSubtitleTextSize * 1.15;
            _preferredWeekdayFontSize = _preferredTitleFontSize;
        }
    }
    
    // reload appearance
    [self invalidateFonts];
}

- (void)setCaseOptions:(FSCalendarCaseOptions)caseOptions
{
    if (_caseOptions != caseOptions) {
        _caseOptions = caseOptions;
        [_calendar invalidateWeekdaySymbols];
        [_calendar invalidateHeaders];
    }
}

- (void)invalidateAppearance
{
    [self invalidateFonts];
    [self invalidateTextColors];
    [self invalidateBorderColors];
    [self invalidateFillColors];
    /*
    [_calendar.collectionView.visibleCells enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        [_calendar invalidateAppearanceForCell:obj];
    }];
    [_calendar.header.collectionView.visibleCells makeObjectsPerformSelector:@selector(setNeedsLayout)];
    [_calendar.visibleStickyHeaders makeObjectsPerformSelector:@selector(setNeedsLayout)];
     */
}

- (void)invalidateFonts
{
    [self invalidateTitleFont];
    [self invalidateSubtitleFont];
    [self invalidateWeekdayFont];
    [self invalidateHeaderFont];
}

- (void)invalidateTextColors
{
    [self invalidateTitleTextColor];
    [self invalidateSubtitleTextColor];
    [self invalidateWeekdayTextColor];
    [self invalidateHeaderTextColor];
}

- (void)invalidateBorderColors
{
    [_calendar.collectionView.visibleCells makeObjectsPerformSelector:_cmd];
}

- (void)invalidateFillColors
{
    [_calendar.collectionView.visibleCells makeObjectsPerformSelector:_cmd];
}

- (void)invalidateEventColors
{
    [_calendar.collectionView.visibleCells makeObjectsPerformSelector:_cmd];
}

- (void)invalidateCellShapes
{
    [_calendar.collectionView.visibleCells makeObjectsPerformSelector:_cmd];
}

- (void)invalidateTitleFont
{
    [_calendar.collectionView.visibleCells makeObjectsPerformSelector:_cmd];
}

- (void)invalidateSubtitleFont
{
    [_calendar.collectionView.visibleCells makeObjectsPerformSelector:_cmd];
}

- (void)invalidateTitleTextColor
{
    [_calendar.collectionView.visibleCells makeObjectsPerformSelector:_cmd];
}

- (void)invalidateSubtitleTextColor
{
    [_calendar.collectionView.visibleCells makeObjectsPerformSelector:_cmd];
}

- (void)invalidateWeekdayFont
{
    [_calendar invalidateWeekdayFont];
    [_calendar.visibleStickyHeaders makeObjectsPerformSelector:_cmd];
}

- (void)invalidateWeekdayTextColor
{
    [_calendar invalidateWeekdayTextColor];
    [_calendar.visibleStickyHeaders makeObjectsPerformSelector:_cmd];
}

- (void)invalidateHeaderFont
{
    [_calendar.header.collectionView.visibleCells makeObjectsPerformSelector:_cmd];
    [_calendar.visibleStickyHeaders makeObjectsPerformSelector:_cmd];
}

- (void)invalidateHeaderTextColor
{
    [_calendar.header.collectionView.visibleCells makeObjectsPerformSelector:_cmd];
    [_calendar.visibleStickyHeaders makeObjectsPerformSelector:_cmd];
}

@end


@implementation FSCalendarAppearance (Deprecated)

- (void)setCellStyle:(FSCalendarCellStyle)cellStyle
{
    self.cellShape = (FSCalendarCellShape)cellStyle;
}

- (FSCalendarCellStyle)cellStyle
{
    return (FSCalendarCellStyle)self.cellShape;
}

- (void)setUseVeryShortWeekdaySymbols:(BOOL)useVeryShortWeekdaySymbols
{
    _caseOptions &= 15;
    self.caseOptions |= (useVeryShortWeekdaySymbols*FSCalendarCaseOptionsWeekdayUsesSingleUpperCase);
}

- (BOOL)useVeryShortWeekdaySymbols
{
    return (_caseOptions & (15<<4) ) == FSCalendarCaseOptionsWeekdayUsesSingleUpperCase;
}

- (void)setAutoAdjustTitleSize:(BOOL)autoAdjustTitleSize
{
    self.adjustsFontSizeToFitContentSize = autoAdjustTitleSize;
}

- (BOOL)autoAdjustTitleSize
{
    return self.adjustsFontSizeToFitContentSize;
}

- (void)setTitleTextSize:(CGFloat)titleTextSize
{
    self.titleFont = [UIFont fontWithName:_titleFontName size:titleTextSize];
}

- (CGFloat)titleTextSize
{
    return _titleFontSize;
}

- (void)setSubtitleTextSize:(CGFloat)subtitleTextSize
{
    self.subtitleFont = [UIFont fontWithName:_subtitleFontName size:subtitleTextSize];
}

- (CGFloat)subtitleTextSize
{
    return _subtitleFontSize;
}

- (void)setWeekdayTextSize:(CGFloat)weekdayTextSize
{
    self.weekdayFont = [UIFont fontWithName:_weekdayFontName size:weekdayTextSize];
}

- (CGFloat)weekdayTextSize
{
    return _weekdayFontSize;
}

- (void)setHeaderTitleTextSize:(CGFloat)headerTitleTextSize
{
    self.headerTitleFont = [UIFont fontWithName:_headerTitleFontName size:headerTitleTextSize];
}

- (CGFloat)headerTitleTextSize
{
    return _headerTitleFontSize;
}

- (void)setAdjustsFontSizeToFitCellSize:(BOOL)adjustsFontSizeToFitCellSize
{
    self.adjustsFontSizeToFitContentSize = adjustsFontSizeToFitCellSize;
}

- (BOOL)adjustsFontSizeToFitCellSize
{
    return self.adjustsFontSizeToFitContentSize;
}

@end


