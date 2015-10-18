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

#define kBlueText   [UIColor colorWithRed:14/255.0  green:69/255.0  blue:221/255.0    alpha:1.0]
#define kPink       [UIColor colorWithRed:198/255.0 green:51/255.0  blue:42/255.0     alpha:1.0]
#define kBlue       [UIColor colorWithRed:31/255.0  green:119/255.0 blue:219/255.0    alpha:1.0]

@interface FSCalendarAppearance ()

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
        
        _titleTextSize    = 13.5;
        _subtitleTextSize = 10;
        _weekdayTextSize  = 14;
        _headerTitleTextSize = 16;
        _headerTitleColor = kBlueText;
        _headerDateFormat = @"MMMM yyyy";
        _headerMinimumDissolvedAlpha = 0.2;
        _weekdayTextColor = kBlueText;
        
        _backgroundColors = [NSMutableDictionary dictionaryWithCapacity:4];
        _backgroundColors[@(FSCalendarCellStateNormal)]      = [UIColor clearColor];
        _backgroundColors[@(FSCalendarCellStateSelected)]    = kBlue;
        _backgroundColors[@(FSCalendarCellStateDisabled)]    = [UIColor clearColor];
        _backgroundColors[@(FSCalendarCellStatePlaceholder)] = [UIColor clearColor];
        _backgroundColors[@(FSCalendarCellStateToday)]       = kPink;
        
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
        _eventColor = [kBlue colorWithAlphaComponent:0.75];
        
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
        [_calendar.header.collectionView reloadData];
    }
}

- (void)setHeaderTitleColor:(UIColor *)color
{
    if (![_headerTitleColor isEqual:color]) {
        _headerTitleColor = color;
        [_calendar.header reloadData];
    }
}
- (void)setAutoAdjustTitleSize:(BOOL)autoAdjustTitleSize
{
    if (_autoAdjustTitleSize != autoAdjustTitleSize) {
        _autoAdjustTitleSize = autoAdjustTitleSize;
        [self adjustTitleIfNecessary];
    }
}

- (void)setUseVeryShortWeekdaySymbols:(BOOL)useVeryShortWeekdaySymbols
{
    if (_useVeryShortWeekdaySymbols != useVeryShortWeekdaySymbols) {
        _useVeryShortWeekdaySymbols = useVeryShortWeekdaySymbols;
        [self.calendar invalidateWeekdaySymbols];
    }
}

- (void)setHeaderMinimumDissolvedAlpha:(CGFloat)headerMinimumDissolvedAlpha
{
    if (_headerMinimumDissolvedAlpha != headerMinimumDissolvedAlpha) {
        _headerMinimumDissolvedAlpha = headerMinimumDissolvedAlpha;
        [_calendar.header.collectionView reloadData];
    }
}

- (void)setHeaderDateFormat:(NSString *)headerDateFormat
{
    if (![_headerDateFormat isEqual:headerDateFormat]) {
        _headerDateFormat = headerDateFormat;
        [_calendar.header reloadData];
    }
}

- (void)adjustTitleIfNecessary
{
    if (!self.calendar.floatingMode) {
        if (_autoAdjustTitleSize) {
            CGFloat factor       = (_calendar.scope==FSCalendarScopeMonth) ? 6 : 1.1;
            _titleTextSize       = _calendar.collectionView.fs_height/3/factor;
            _subtitleTextSize    = _calendar.collectionView.fs_height/4.5/factor;
            _headerTitleTextSize = _titleTextSize + 3;
            _weekdayTextSize     = _titleTextSize;
            
        }
    } else {
        _headerTitleTextSize = 20;
    }
    
    // reload appearance
    [_calendar.collectionView.visibleCells makeObjectsPerformSelector:@selector(setNeedsLayout)];
    [_calendar.header.collectionView reloadData];
    [_calendar.weekdays setValue:[UIFont systemFontOfSize:_weekdayTextSize] forKeyPath:@"font"];
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

@end


