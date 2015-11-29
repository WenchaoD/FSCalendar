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

@end

@implementation FSCalendarAppearance

- (instancetype)init
{
    self = [super init];
    if (self) {
        
        _adjustsFontSizeToFitCellSize = YES;
        
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

- (void)setTitleFont:(UIFont *)titleFont
{
    BOOL needsLayout = NO;
    if (![_titleFontName isEqualToString:titleFont.fontName]) {
        _titleFontName = titleFont.fontName;
        needsLayout = YES;
    }
    if (_titleFontSize != titleFont.pointSize) {
        _titleFontSize = titleFont.pointSize;
        needsLayout = YES;
    }
    if (needsLayout) {
        [_calendar.collectionView.visibleCells makeObjectsPerformSelector:@selector(setNeedsLayout)];
    }
}

- (UIFont *)titleFont
{
    return [UIFont fontWithName:_titleFontName size:_titleFontSize];
}

- (void)setSubtitleFont:(UIFont *)subtitleFont
{
    BOOL needsLayout = NO;
    if (![_subtitleFontName isEqualToString:subtitleFont.fontName]) {
        _subtitleFontName = subtitleFont.fontName;
        needsLayout = YES;
    }
    if (_subtitleFontSize != subtitleFont.pointSize) {
        _subtitleFontSize = subtitleFont.pointSize;
        needsLayout = YES;
    }
    if (needsLayout) {
        [_calendar.collectionView.visibleCells makeObjectsPerformSelector:@selector(setNeedsLayout)];
    }
}

- (UIFont *)subtitleFont
{
    return [UIFont fontWithName:_subtitleFontName size:_subtitleFontSize];
}

- (void)setWeekdayFont:(UIFont *)weekdayFont
{
    BOOL needsLayout = NO;
    if (![_weekdayFontName isEqualToString:weekdayFont.fontName]) {
        _weekdayFontName = weekdayFont.fontName;
        needsLayout = YES;
    }
    if (_weekdayFontSize != weekdayFont.pointSize) {
        _weekdayFontSize = weekdayFont.pointSize;
        needsLayout = YES;
    }
    if (needsLayout) {
        [_calendar.collectionView.visibleCells makeObjectsPerformSelector:@selector(setNeedsLayout)];
    }
}

- (UIFont *)weekdayFont
{
    return [UIFont fontWithName:_weekdayFontName size:_weekdayFontSize];
}

- (void)setHeaderTitleFont:(UIFont *)headerTitleFont
{
    BOOL needsLayout = NO;
    if (![_headerTitleFontName isEqualToString:headerTitleFont.fontName]) {
        _headerTitleFontName = headerTitleFont.fontName;
        needsLayout = YES;
    }
    if (_headerTitleFontSize != headerTitleFont.pointSize) {
        _headerTitleFontSize = headerTitleFont.pointSize;
        needsLayout = YES;
    }
    if (needsLayout) {
        [_calendar.collectionView.visibleCells makeObjectsPerformSelector:@selector(setNeedsLayout)];
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

- (void)setCellShape:(FSCalendarCellShape)cellShape
{
    if (_cellShape != cellShape) {
        _cellShape = cellShape;
        [_calendar.collectionView.visibleCells makeObjectsPerformSelector:@selector(setNeedsLayout)];
    }
}

- (void)setWeekdayTextColor:(UIColor *)weekdayTextColor
{
    if (![_weekdayTextColor isEqual:weekdayTextColor]) {
        _weekdayTextColor = weekdayTextColor;
        [_calendar.weekdays setValue:weekdayTextColor forKeyPath:@"textColor"];
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

- (UIFont *)preferredTitleFont
{
    return [UIFont fontWithName:_titleFontName size:_adjustsFontSizeToFitCellSize?_preferredTitleFontSize:_titleFontSize];
}

- (UIFont *)preferredSubtitleFont
{
    return [UIFont fontWithName:_subtitleFontName size:_adjustsFontSizeToFitCellSize?_preferredSubtitleFontSize:_subtitleFontSize];
}

- (UIFont *)preferredWeekdayFont
{
    return [UIFont fontWithName:_weekdayFontName size:_adjustsFontSizeToFitCellSize?_preferredWeekdayFontSize:_weekdayFontSize];
}

- (UIFont *)preferredHeaderTitleFont
{
    return [UIFont fontWithName:_headerTitleFontName size:_adjustsFontSizeToFitCellSize?_preferredHeaderTitleFontSize:_headerTitleFontSize];
}

- (void)adjustTitleIfNecessary
{
    if (!self.calendar.floatingMode) {
        if (_adjustsFontSizeToFitCellSize) {
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
    [_calendar.collectionView.visibleCells makeObjectsPerformSelector:@selector(setNeedsLayout)];
    [_calendar.header.collectionView.visibleCells makeObjectsPerformSelector:@selector(setNeedsLayout)];
    [_calendar.visibleStickyHeaders makeObjectsPerformSelector:@selector(setNeedsLayout)];
    [_calendar.weekdays setValue:self.preferredWeekdayFont forKeyPath:@"font"];
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

- (void)setAutoAdjustTitleSize:(BOOL)autoAdjustTitleSize
{
    self.adjustsFontSizeToFitCellSize = autoAdjustTitleSize;
}

- (BOOL)autoAdjustTitleSize
{
    return self.adjustsFontSizeToFitCellSize;
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

@end


