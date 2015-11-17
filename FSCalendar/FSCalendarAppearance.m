//
//  FSCalendarAppearance.m
//  Pods
//
//  Created by DingWenchao on 6/29/15.
//
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

- (void)adjustTitleIfNecessary;

@end

@implementation FSCalendarAppearance

- (instancetype)init
{
    self = [super init];
    if (self) {
        
        _autoAdjustTitleSize = YES;
        
        _titleTextSize    = FSCalendarStandardTitleTextSize;
        _subtitleTextSize = FSCalendarStandardSubtitleTextSize;
        _weekdayTextSize  = FSCalendarStandardWeekdayTextSize;
        _headerTitleTextSize = FSCalendarStandardHeaderTextSize;
        _headerTitleColor = FSCalendarStandardTitleTextColor;
        _headerDateFormat = @"MMMM yyyy";
        _headerMinimumDissolvedAlpha = 0.2;
        _weekdayTextColor = FSCalendarStandardTitleTextColor;
        _caseOptions = FSCalendarCaseOptionsHeaderUsesDefaultCase|FSCalendarCaseOptionsWeekdayUsesDefaultCase;
        
        _backgroundColors = [NSMutableDictionary dictionaryWithCapacity:4];
        _backgroundColors[@(FSCalendarCellStateNormal)]      = [UIColor clearColor];
        _backgroundColors[@(FSCalendarCellStateSelected)]    = FSCalendarStandardSelectionColor;
        _backgroundColors[@(FSCalendarCellStateDisabled)]    = [UIColor clearColor];
        _backgroundColors[@(FSCalendarCellStatePlaceholder)] = [UIColor clearColor];
        _backgroundColors[@(FSCalendarCellStateToday)]       = FSCalendarStandardTodayColor;
        
        _titleColors = [NSMutableDictionary dictionaryWithCapacity:4];
        _titleColors[@(FSCalendarCellStateNormal)]      = [UIColor darkTextColor];
        _titleColors[@(FSCalendarCellStateSelected)]    = [UIColor whiteColor];
        _titleColors[@(FSCalendarCellStateDisabled)]    = [UIColor grayColor];
        _titleColors[@(FSCalendarCellStatePlaceholder)] = [UIColor lightGrayColor];
        _titleColors[@(FSCalendarCellStateToday)]       = [UIColor whiteColor];
        
        _subtitleColors = [NSMutableDictionary dictionaryWithCapacity:4];
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



- (void)setTitleDefaultColor:(UIColor *)color
{
    if (color) {
        _titleColors[@(FSCalendarCellStateNormal)] = color;
    } else {
        [_titleColors removeObjectForKey:@(FSCalendarCellStateNormal)];
    }
    
    [_calendar.collectionView.visibleCells makeObjectsPerformSelector:@selector(setNeedsLayout)];
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
    [_calendar.collectionView.visibleCells makeObjectsPerformSelector:@selector(setNeedsLayout)];
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
    [_calendar.collectionView.visibleCells makeObjectsPerformSelector:@selector(setNeedsLayout)];
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
    [_calendar.collectionView.visibleCells makeObjectsPerformSelector:@selector(setNeedsLayout)];
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
    [_calendar.collectionView.visibleCells makeObjectsPerformSelector:@selector(setNeedsLayout)];
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
    [_calendar.collectionView.visibleCells makeObjectsPerformSelector:@selector(setNeedsLayout)];
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
    [_calendar.collectionView.visibleCells makeObjectsPerformSelector:@selector(setNeedsLayout)];
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
    [_calendar.collectionView.visibleCells makeObjectsPerformSelector:@selector(setNeedsLayout)];
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
    [_calendar.collectionView.visibleCells makeObjectsPerformSelector:@selector(setNeedsLayout)];
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
    [_calendar.collectionView.visibleCells makeObjectsPerformSelector:@selector(setNeedsLayout)];
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
    [_calendar.collectionView.visibleCells makeObjectsPerformSelector:@selector(setNeedsLayout)];
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
    [_calendar.collectionView.visibleCells makeObjectsPerformSelector:@selector(setNeedsLayout)];
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
    [_calendar.collectionView.visibleCells makeObjectsPerformSelector:@selector(setNeedsLayout)];
}

- (UIColor *)todaySelectionColor
{
    return _backgroundColors[@(FSCalendarCellStateToday|FSCalendarCellStateSelected)];
}

- (void)setEventColor:(UIColor *)eventColor
{
    if (![_eventColor isEqual:eventColor]) {
        _eventColor = eventColor;
        [_calendar.collectionView.visibleCells makeObjectsPerformSelector:@selector(setNeedsLayout)];
    }
}

- (void)setBorderDefaultColor:(UIColor *)color
{
    if (color) {
        _borderColors[@(FSCalendarCellStateNormal)] = color;
    } else {
        [_borderColors removeObjectForKey:@(FSCalendarCellStateNormal)];
    }
    [_calendar.collectionView.visibleCells makeObjectsPerformSelector:@selector(setNeedsLayout)];
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
    [_calendar.collectionView.visibleCells makeObjectsPerformSelector:@selector(setNeedsLayout)];
}

- (UIColor *)borderSelectionColor
{
    return _borderColors[@(FSCalendarCellStateSelected)];
}

- (void)setTitleTextSize:(CGFloat)titleTextSize
{
    if (_titleTextSize != titleTextSize) {
        _titleTextSize = titleTextSize;
        if (_autoAdjustTitleSize) {
            return;
        }
        [_calendar.collectionView.visibleCells makeObjectsPerformSelector:@selector(setNeedsLayout)];
    }
}

- (void)setSubtitleTextSize:(CGFloat)subtitleTextSize
{
    if (_subtitleTextSize != subtitleTextSize) {
        _subtitleTextSize = subtitleTextSize;
        if (_autoAdjustTitleSize) {
            return;
        }
        [_calendar.collectionView.visibleCells makeObjectsPerformSelector:@selector(setNeedsLayout)];
    }
}

- (void)setCellShape:(FSCalendarCellShape)cellShape
{
    if (_cellShape != cellShape) {
        _cellShape = cellShape;
        [_calendar.collectionView.visibleCells makeObjectsPerformSelector:@selector(setNeedsLayout)];
    }
}


- (void)setWeekdayTextSize:(CGFloat)weekdayTextSize
{
    if (_weekdayTextSize != weekdayTextSize) {
        _weekdayTextSize = weekdayTextSize;
        UIFont *font = [UIFont systemFontOfSize:weekdayTextSize];
        [_calendar.weekdays setValue:font forKey:@"font"];
    }
}

- (void)setWeekdayTextColor:(UIColor *)weekdayTextColor
{
    if (![_weekdayTextColor isEqual:weekdayTextColor]) {
        _weekdayTextColor = weekdayTextColor;
        [_calendar.weekdays setValue:weekdayTextColor forKeyPath:@"textColor"];
    }
}

- (void)setHeaderTitleTextSize:(CGFloat)headerTitleTextSize
{
    if (_headerTitleTextSize != headerTitleTextSize) {
        _headerTitleTextSize = headerTitleTextSize;
        [_calendar.header.collectionView.visibleCells makeObjectsPerformSelector:@selector(setNeedsLayout)];
        [_calendar.visibleStickyHeaders makeObjectsPerformSelector:@selector(setNeedsLayout)];
    }
}

- (void)setHeaderTitleColor:(UIColor *)color
{
    if (![_headerTitleColor isEqual:color]) {
        _headerTitleColor = color;
        [_calendar.header.collectionView.visibleCells makeObjectsPerformSelector:@selector(setNeedsLayout)];
        [_calendar.visibleStickyHeaders makeObjectsPerformSelector:@selector(setNeedsLayout)];
    }
}
- (void)setAutoAdjustTitleSize:(BOOL)autoAdjustTitleSize
{
    if (_autoAdjustTitleSize != autoAdjustTitleSize) {
        _autoAdjustTitleSize = autoAdjustTitleSize;
        [self adjustTitleIfNecessary];
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

- (void)adjustTitleIfNecessary
{
    if (!self.calendar.floatingMode) {
        if (_autoAdjustTitleSize) {
            CGFloat factor       = (_calendar.scope==FSCalendarScopeMonth) ? 6 : 1.1;
            _titleTextSize       = _calendar.collectionView.fs_height/3/factor;
            _titleTextSize       -= (_titleTextSize-FSCalendarStandardTitleTextSize)*0.5;
            _subtitleTextSize    = _calendar.collectionView.fs_height/4.5/factor;
            _subtitleTextSize    -= (_subtitleTextSize-FSCalendarStandardSubtitleTextSize)*0.75;
            _headerTitleTextSize = _titleTextSize * 1.25;
            _weekdayTextSize     = _titleTextSize;
            
        }
    } else {
        _headerTitleTextSize = 20;
        if (FSCalendarDeviceIsIPad) {
            _headerTitleTextSize = FSCalendarStandardHeaderTextSize * 1.5;
            _titleTextSize = FSCalendarStandardTitleTextSize * 1.3;
            _subtitleTextSize = FSCalendarStandardSubtitleTextSize * 1.15;
            _weekdayTextSize = _titleTextSize;
        }
    }
    
    // reload appearance
    [_calendar.collectionView.visibleCells makeObjectsPerformSelector:@selector(setNeedsLayout)];
    [_calendar.header.collectionView.visibleCells makeObjectsPerformSelector:@selector(setNeedsLayout)];
    [_calendar.visibleStickyHeaders makeObjectsPerformSelector:@selector(setNeedsLayout)];
    [_calendar.weekdays setValue:[UIFont systemFontOfSize:_weekdayTextSize] forKeyPath:@"font"];
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
    [_calendar.collectionView.visibleCells enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        [_calendar invalidateAppearanceForCell:obj];
    }];
    [_calendar.header.collectionView.visibleCells makeObjectsPerformSelector:@selector(setNeedsLayout)];
    [_calendar.visibleStickyHeaders makeObjectsPerformSelector:@selector(setNeedsLayout)];
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

@end


