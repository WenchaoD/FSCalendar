//
//  FScalendar.m
//  Pods
//
//  Created by Wenchao Ding on 29/1/15.
//
//

#import <objc/runtime.h>
#import "FSCalendar.h"
#import "FSCalendarPage.h"
#import "FSCalendarUnit.h"
#import "FSCalendarHeader.h"
#import "UIView+FSExtension.h"
#import "NSDate+FSExtension.h"

#define kWeekHeight roundf(self.fs_height/9)
#define kBlueText [UIColor colorWithRed:14/255.0 green:69/255.0 blue:221/255.0 alpha:1.0]
#define kPink [UIColor colorWithRed:198/255.0 green:51/255.0 blue:42/255.0 alpha:1.0]
#define kBlue [UIColor colorWithRed:31/255.0 green:119/255.0 blue:219/255.0 alpha:1.0]

const char * flowKey;

@interface FSCalendar ()<UIScrollViewDelegate, FSCalendarUnitDataSource, FSCalendarUnitDelegate>

@property (strong, nonatomic) UIScrollView *scrollView;
@property (strong, nonatomic) NSMutableArray *weekdays;
@property (strong, nonatomic) FSCalendarPage *page0;
@property (strong, nonatomic) FSCalendarPage *page1;

@property (strong, nonatomic) NSMutableDictionary *unitColors;
@property (strong, nonatomic) NSMutableDictionary *titleColors;
@property (strong, nonatomic) NSMutableDictionary *subtitleColors;

@property (assign, nonatomic) NSInteger currentPage;
@property (assign, nonatomic) CGFloat baseOffset;

@property (readonly, nonatomic) CGSize flowSize;
@property (readonly, nonatomic) CGPoint flowOffset;
@property (readonly, nonatomic) CGFloat flowSide;
@property (readonly, nonatomic) CGFloat flowScrollOffset;

- (BOOL)shouldSelectDate:(NSDate *)date;
- (void)didSelectDate:(NSDate *)date;
- (BOOL)hasEventForDate:(NSDate *)date;
- (NSString *)subtitleForDate:(NSDate *)date;

- (void)adjustTitleIfNecessary;
- (void)reloadUnits;

@end

@implementation FSCalendar

#pragma mark - Life Cycle

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self initialize];
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self) {
        [self initialize];
    }
    return self;
}

- (void)initialize
{
    _titleFont = [UIFont systemFontOfSize:16];
    _subtitleFont = [UIFont systemFontOfSize:11];
    _weekdayFont = [UIFont systemFontOfSize:16];
    _headerTitleFont = [UIFont systemFontOfSize:16];
    
    NSArray *weekSymbols = [[NSCalendar currentCalendar] shortStandaloneWeekdaySymbols];
    _weekdays = [NSMutableArray arrayWithCapacity:weekSymbols.count];
    for (int i = 0; i < weekSymbols.count; i++) {
        UILabel *weekdayLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        weekdayLabel.text = weekSymbols[i];
        weekdayLabel.textAlignment = NSTextAlignmentCenter;
        weekdayLabel.font = _weekdayFont;
        weekdayLabel.textColor = kBlueText;
        [_weekdays addObject:weekdayLabel];
        [self addSubview:weekdayLabel];
    }
    
    _scrollView = [[UIScrollView alloc] initWithFrame:CGRectZero];
    _scrollView.delegate = self;
    _scrollView.backgroundColor = [UIColor clearColor];
    _scrollView.bounces = YES;
    _scrollView.opaque = NO;
    _scrollView.pagingEnabled = YES;
    _scrollView.showsHorizontalScrollIndicator = NO;
    _scrollView.showsVerticalScrollIndicator = NO;
    _scrollView.tag = -1;
    _scrollView.delaysContentTouches = NO;
    _scrollView.canCancelContentTouches = YES;
    [self addSubview:_scrollView];
    
    _page0 = [[FSCalendarPage alloc] initWithFrame:CGRectZero];
    _page0.tag = 0;
    [_scrollView addSubview:_page0];
    
    _page1 = [[FSCalendarPage alloc] initWithFrame:CGRectZero];
    _page1.tag = 1;
    [_scrollView addSubview:_page1];
    
    _currentDate = [NSDate date];
    _currentMonth = [_currentDate copy];
    
    [_page0.subviews setValue:self forKeyPath:@"dataSource"];
    [_page0.subviews setValue:self forKeyPath:@"delegate"];
    [_page1.subviews setValue:self forKeyPath:@"dataSource"];
    [_page1.subviews setValue:self forKeyPath:@"delegate"];
    
    
    _unitColors = [NSMutableDictionary dictionaryWithCapacity:4];
    _unitColors[@(FSCalendarUnitStateNormal)] = [UIColor clearColor];
    _unitColors[@(FSCalendarUnitStateSelected)] = kBlue;
    _unitColors[@(FSCalendarUnitStateDisabled)] = [UIColor clearColor];
    _unitColors[@(FSCalendarUnitStatePlaceholder)] = [UIColor clearColor];
    _unitColors[@(FSCalendarUnitStateToday)] = kPink;
    
    _titleColors = [NSMutableDictionary dictionaryWithCapacity:4];
    _titleColors[@(FSCalendarUnitStateNormal)] = [UIColor darkTextColor];
    _titleColors[@(FSCalendarUnitStateWeekend)] = [UIColor darkTextColor];
    _titleColors[@(FSCalendarUnitStateSelected)] = [UIColor whiteColor];
    _titleColors[@(FSCalendarUnitStateDisabled)] = [UIColor grayColor];
    _titleColors[@(FSCalendarUnitStatePlaceholder)] = [UIColor lightGrayColor];
    _titleColors[@(FSCalendarUnitStateToday)] = [UIColor whiteColor];
    
    _subtitleColors = [NSMutableDictionary dictionaryWithCapacity:4];
    _subtitleColors[@(FSCalendarUnitStateNormal)] = [UIColor darkGrayColor];
    _subtitleColors[@(FSCalendarUnitStateWeekend)] = [UIColor darkGrayColor];
    _subtitleColors[@(FSCalendarUnitStateSelected)] = [UIColor whiteColor];
    _subtitleColors[@(FSCalendarUnitStateDisabled)] = [UIColor lightGrayColor];
    _subtitleColors[@(FSCalendarUnitStatePlaceholder)] = [UIColor lightGrayColor];
    _subtitleColors[@(FSCalendarUnitStateToday)] = [UIColor whiteColor];
    
    _unitStyle = FSCalendarUnitStyleCircle;
    _autoAdjustTitleSize = YES;
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    if (_scrollView.tag == -1) {
        if (CGRectEqualToRect(_scrollView.frame, CGRectZero)) {
            // make sure this is called only at initialing
            _scrollView.frame = CGRectMake(0, kWeekHeight, self.fs_width, self.fs_height-kWeekHeight);
            _scrollView.contentInset = UIEdgeInsetsZero;
            _scrollView.scrollIndicatorInsets = UIEdgeInsetsZero;
            
            [_weekdays enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
                CGFloat width = self.fs_width/_weekdays.count;
                CGFloat height = kWeekHeight;
                [obj setFrame:CGRectMake(idx*width, 0, width, height)];
            }];
        }
        _page0.frame = CGRectMake(0, 0, _scrollView.fs_width, _scrollView.fs_height);
        _page1.frame = CGRectOffset(_page0.frame, self.flowOffset.x, self.flowOffset.y);
        [self reloadData];
        _scrollView.contentSize = self.flowSize;
        _scrollView.tag = 0;
    }
    [self adjustTitleIfNecessary];   
}

- (void)dealloc
{
    _scrollView.delegate = nil;
}

#pragma mark - UIScrollView Delegate

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    CGFloat offset = self.flowScrollOffset;
    if (offset > self.flowSide) {
        _scrollView.bounds = CGRectOffset(_scrollView.bounds, -self.flowOffset.x, -self.flowOffset.y);
        _page1.frame = CGRectOffset(_page1.frame, -self.flowOffset.x, -self.flowOffset.y);
        _page0.frame = CGRectOffset(_page1.frame, self.flowOffset.x, self.flowOffset.y);
        _baseOffset += self.flowOffset.x + self.flowOffset.y;
        offset -= (self.flowOffset.x + self.flowOffset.y);
        [self updatePointer];
        [self updatePage:_page1 forIndex:self.currentPage + 1];
    } else if (offset < 0) {
        _scrollView.bounds = CGRectOffset(_scrollView.bounds, self.flowOffset.x, self.flowOffset.y);
        _page0.frame = CGRectOffset(_page0.frame, self.flowOffset.x, self.flowOffset.y);
        _page1.frame = CGRectOffset(_page0.frame, -self.flowOffset.x, -self.flowOffset.y);
        _baseOffset -= (self.flowOffset.x + self.flowOffset.y);
        offset += (self.flowOffset.x + self.flowOffset.y);
        [self updatePointer];
        [self updatePage:_page0 forIndex:self.currentPage - 1];
    }
    self.currentPage = (roundf(offset/self.flowSide)*self.flowSide+self.baseOffset)/self.flowSide;
    if (_header) {
        _header.scrollOffset = (self.baseOffset+offset)/self.flowSide;
    }
    
}

#pragma mark - Setter & Getter

- (void)setCurrentPage:(NSInteger)currentPage
{
    if (_currentPage != currentPage) {
        _currentPage = currentPage;
        self.currentMonth = [_currentDate fs_dateByAddingMonths:currentPage];
        if (_delegate && [_delegate respondsToSelector:@selector(calendarCurrentMonthDidChange:)]) {
            [_delegate calendarCurrentMonthDidChange:self];
        }
    }
}

- (void)setFlow:(FSCalendarFlow)flow
{
    if (self.flow != flow) {
        objc_setAssociatedObject(self, &flowKey, @(flow), OBJC_ASSOCIATION_COPY_NONATOMIC);
        _scrollView.tag = -1;
        _baseOffset = _currentPage * self.flowSide;
        [self setNeedsLayout];
    }
}

- (FSCalendarFlow)flow
{
    return [objc_getAssociatedObject(self, &flowKey) integerValue];
}

- (void)setWeekdayFont:(UIFont *)weekdayFont
{
    if (_weekdayFont != weekdayFont) {
        _weekdayFont = weekdayFont;
        [_weekdays setValue:weekdayFont forKeyPath:@"font"];
    }
}

- (void)setWeekdayTextColor:(UIColor *)weekdayTextColor
{
   [_weekdays setValue:weekdayTextColor forKeyPath:@"textColor"];
}

- (void)setHeader:(FSCalendarHeader *)header
{
    if (_header != header) {
        _header = header;
        if (header) {
            header.calendar = self;
        }
    }
}

- (void)setCurrentDate:(NSDate *)currentDate
{
    if (![_currentDate isEqualToDate:currentDate]) {
        _currentDate = [currentDate copy];
        _currentMonth = [_currentDate copy];
        [self updatePage:_page0 forIndex:0];
        [self updatePage:_page1 forIndex:1];
        if (_header) {
            _header.calendar = nil;
            _header.calendar = self;
        }
    }
}

- (void)setHeaderTitleFont:(UIFont *)font
{
    if (_headerTitleFont != font) {
        _headerTitleFont = font;
        _header.titleFont = font;
    }
}

- (void)setHeaderTitleColor:(UIColor *)color
{
    _header.titleColor = color;
}

- (void)setHeaderDateFormat:(NSString *)dateFormat
{
    _header.dateFormat = dateFormat;
}

- (void)setTitleDefaultColor:(UIColor *)color
{
    if (color) {
        _titleColors[@(FSCalendarUnitStateNormal)] = color;
    } else {
        [_titleColors removeObjectForKey:@(FSCalendarUnitStateNormal)];
    }
    [self reloadUnits];
}

- (void)setTitleSelectionColor:(UIColor *)color
{
    if (color) {
        _titleColors[@(FSCalendarUnitStateSelected)] = color;
    } else {
        [_titleColors removeObjectForKey:@(FSCalendarUnitStateSelected)];
    }
    [self reloadUnits];
}

- (void)setTitleTodayColor:(UIColor *)color
{
    if (color) {
        _titleColors[@(FSCalendarUnitStateToday)] = color;
    } else {
        [_titleColors removeObjectForKey:@(FSCalendarUnitStateToday)];
    }
    [self reloadUnits];
}

- (void)setTitlePlaceholderColor:(UIColor *)color
{
    if (color) {
        _titleColors[@(FSCalendarUnitStatePlaceholder)] = color;
    } else {
        [_titleColors removeObjectForKey:@(FSCalendarUnitStatePlaceholder)];
    }
    [self reloadUnits];
}

- (void)setTitleWeekendColor:(UIColor *)color
{
    if (color) {
        _titleColors[@(FSCalendarUnitStateWeekend)] = color;
    } else {
        [_titleColors removeObjectForKey:@(FSCalendarUnitStateWeekend)];
    }
    [self reloadUnits];
}

- (void)setSubtitleDefaultColor:(UIColor *)color
{
    if (color) {
        _subtitleColors[@(FSCalendarUnitStateNormal)] = color;
    } else {
        [_subtitleColors removeObjectForKey:@(FSCalendarUnitStateNormal)];
    }
    [self reloadUnits];
}

- (void)setSubtitleSelectionColor:(UIColor *)color
{
    if (color) {
        _subtitleColors[@(FSCalendarUnitStateSelected)] = color;
    } else {
        [_subtitleColors removeObjectForKey:@(FSCalendarUnitStateSelected)];
    }
    [self reloadUnits];
}

- (void)setSubtitleTodayColor:(UIColor *)color
{
    if (color) {
        _subtitleColors[@(FSCalendarUnitStateToday)] = color;
    } else {
        [_subtitleColors removeObjectForKey:@(FSCalendarUnitStateToday)];
    }
    [self reloadUnits];
}

- (void)setSubtitlePlaceholderColor:(UIColor *)color
{
    if (color) {
        _subtitleColors[@(FSCalendarUnitStatePlaceholder)] = color;
    } else {
        [_subtitleColors removeObjectForKey:@(FSCalendarUnitStatePlaceholder)];
    }
    [self reloadUnits];
}

- (void)setSubtitleWeekendColor:(UIColor *)color
{
    if (color) {
        _subtitleColors[@(FSCalendarUnitStateWeekend)] = color;
    } else {
        [_subtitleColors removeObjectForKey:@(FSCalendarUnitStateWeekend)];
    }
    [self reloadUnits];
}

- (void)setSelectionColor:(UIColor *)color
{
    if (color) {
        _unitColors[@(FSCalendarUnitStateSelected)] = color;
    } else {
        [_unitColors removeObjectForKey:@(FSCalendarUnitStateSelected)];
    }
    [self reloadUnits];
}

- (void)setTodayColor:(UIColor *)color
{
    if (color) {
        _unitColors[@(FSCalendarUnitStateToday)] = color;
    } else {
        [_unitColors removeObjectForKey:@(FSCalendarUnitStateToday)];
    }
    [self reloadUnits];
}

- (void)setEventColor:(UIColor *)color
{
    [_page0.subviews enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        [(FSCalendarUnit *)obj setEventColor:color];
    }];
    [_page1.subviews enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        [(FSCalendarUnit *)obj setEventColor:color];
    }];
}

- (void)setTitleFont:(UIFont *)font
{
    if (_titleFont != font) {
        _titleFont = font;
        if (_autoAdjustTitleSize) {
            return;
        }
        [_page0.subviews setValue:_titleFont forKeyPath:@"titleFont"];
        [_page1.subviews setValue:_titleFont forKeyPath:@"titleFont"];
    }
}

- (void)setSubtitleFont:(UIFont *)font
{
    if (_subtitleFont != font) {
        _subtitleFont = font;
        if (_autoAdjustTitleSize) {
            return;
        }
        [_page0.subviews setValue:_subtitleFont forKeyPath:@"subtitleFont"];
        [_page1.subviews setValue:_subtitleFont forKeyPath:@"subtitleFont"];
    }
}

- (void)setMinDissolvedAlpha:(CGFloat)minDissolvedAlpha
{
    if (_minDissolvedAlpha != minDissolvedAlpha) {
        _minDissolvedAlpha = minDissolvedAlpha;
        _header.minDissolveAlpha = minDissolvedAlpha;
    }
}

#pragma mark - Public

- (void)reloadData
{
    [self updatePage:_page0 forIndex:_currentPage];
    [self updatePage:_page1 forIndex:_currentPage + 1];
}

#pragma mark - Private

- (void)adjustTitleIfNecessary
{
    UIFont *titleFont = _titleFont;
    UIFont *subtitleFont = _subtitleFont;
    UIFont *headerFont = _headerTitleFont;
    UIFont *weekdayFont = _weekdayFont;
    if (_autoAdjustTitleSize) {
        titleFont = [titleFont fontWithSize:_scrollView.fs_height/3/6];
        subtitleFont = [subtitleFont fontWithSize:_scrollView.fs_height/4.3/6];
        headerFont = titleFont;
        weekdayFont = titleFont;
    }
    [_page0.subviews setValue:titleFont forKeyPath:@"titleFont"];
    [_page1.subviews setValue:titleFont forKeyPath:@"titleFont"];
    [_page0.subviews setValue:subtitleFont forKeyPath:@"subtitleFont"];
    [_page1.subviews setValue:subtitleFont forKeyPath:@"subtitleFont"];
    [_weekdays setValue:weekdayFont forKey:@"font"];
    if (_header) {
        [_header setTitleFont:headerFont];
    }
}

- (void)reloadUnits
{
    [_page0.subviews makeObjectsPerformSelector:@selector(setNeedsLayout)];
    [_page1.subviews makeObjectsPerformSelector:@selector(setNeedsLayout)];
}

- (void)updatePointer
{
    switch (self.flow) {
        case FSCalendarFlowHorizontal:
            if (_page0.fs_left > _page1.fs_left) {
                id temp0 = _page0;
                self.page0 = _page1;
                self.page1 = temp0;
            }
            break;
        case FSCalendarFlowVertical:
            if (_page0.fs_top > _page1.fs_top) {
                id temp0 = _page0;
                self.page0 = _page1;
                self.page1 = temp0;
            }
            break;
        default:
            break;
    }
}

- (CGSize)flowSize
{
    switch (self.flow) {
        case FSCalendarFlowHorizontal:
            return CGSizeMake(_scrollView.fs_width * 2, _scrollView.fs_height);
            break;
        case FSCalendarFlowVertical:
            return CGSizeMake(_scrollView.fs_width, _scrollView.fs_height * 2);
            break;
        default:
            break;
    }
}

- (CGPoint)flowOffset
{
    switch (self.flow) {
        case FSCalendarFlowHorizontal:
            return CGPointMake(_scrollView.fs_width, 0);
            break;
        case FSCalendarFlowVertical:
            return CGPointMake(0, _scrollView.fs_height);
            break;
        default:
            break;
    }
}

- (CGFloat)flowSide
{
    switch (self.flow) {
        case FSCalendarFlowHorizontal:
            return _scrollView.fs_width;
            break;
        case FSCalendarFlowVertical:
            return _scrollView.fs_height;
            break;
        default:
            break;
    }
}

- (CGFloat)flowScrollOffset
{
    switch (self.flow) {
        case FSCalendarFlowHorizontal:
            return _scrollView.contentOffset.x;
            break;
        case FSCalendarFlowVertical:
            return _scrollView.contentOffset.y;
            break;
        default:
            break;
    }
}

- (void)updatePage:(FSCalendarPage *)page forIndex:(NSInteger)index
{
    NSDate *destDate = [_currentDate fs_dateByAddingMonths:index];
    page.date = destDate;
}

- (BOOL)shouldSelectDate:(NSDate *)date
{
    if (_delegate && [_delegate respondsToSelector:@selector(calendar:shouldSelectDate:)]) {
        return [_delegate calendar:self shouldSelectDate:date];
    }
    return YES;
}

- (void)didSelectDate:(NSDate *)date
{
    if (_delegate && [_delegate respondsToSelector:@selector(calendar:didSelectDate:)]) {
        [_delegate calendar:self didSelectDate:date];
    }
}

- (NSString *)subtitleForDate:(NSDate *)date
{
    if (_dataSource && [_dataSource respondsToSelector:@selector(calendar:subtitleForDate:)]) {
        return [_dataSource calendar:self subtitleForDate:date];
    }
    return nil;
}

- (BOOL)hasEventForDate:(NSDate *)date
{
    if (_dataSource && [_dataSource respondsToSelector:@selector(calendar:hasEventForDate:)]) {
        return [_dataSource calendar:self hasEventForDate:date];
    }
    return NO;
}

- (void)setAutoAdjustTitleSize:(BOOL)autoAdjustTitleSize
{
    if (_autoAdjustTitleSize != autoAdjustTitleSize) {
        _autoAdjustTitleSize = autoAdjustTitleSize;
        [self setNeedsLayout];
    }
}

- (void)setUnitStyle:(FSCalendarUnitStyle)unitStyle
{
    if (_unitStyle != unitStyle) {
        _unitStyle = unitStyle;
        [_page0.subviews setValue:@(unitStyle) forKeyPath:@"style"];
        [_page1.subviews setValue:@(unitStyle) forKeyPath:@"style"];
    }
}

#pragma mark - Unit DataSource

- (NSString *)subtitleForUnit:(FSCalendarUnit *)unit
{
    return [self subtitleForDate:unit.date];
}

- (BOOL)hasEventForUnit:(FSCalendarUnit *)unit
{
    return [self hasEventForDate:unit.date];
}

- (BOOL)unitIsToday:(FSCalendarUnit *)unit
{
    BOOL today = unit.date.fs_year == self.currentDate.fs_year;
    today &= unit.date.fs_month == self.currentDate.fs_month;
    today &= unit.date.fs_day == self.currentDate.fs_day;
    return today;
}

- (BOOL)unitIsPlaceholder:(FSCalendarUnit *)unit
{
    FSCalendarPage *page = (FSCalendarPage *)unit.superview;
    BOOL isPlaceholder = page.date.fs_year != unit.date.fs_year;
    isPlaceholder |= page.date.fs_month != unit.date.fs_month;
    return isPlaceholder;
}

- (BOOL)unitIsSelected:(FSCalendarUnit *)unit
{
    if ([self unitIsPlaceholder:unit]) {
        return NO;
    }
    BOOL selected = unit.date.fs_year == self.selectedDate.fs_year;
    selected &= unit.date.fs_month == self.selectedDate.fs_month;
    selected &= unit.date.fs_day == self.selectedDate.fs_day;
    return selected;
}

- (UIColor *)unitColorForUnit:(FSCalendarUnit *)unit
{
    return _unitColors[@(unit.absoluteState)];
}

- (UIColor *)titleColorForUnit:(FSCalendarUnit *)unit
{
    return _titleColors[@(unit.absoluteState)];
}

- (UIColor *)subtitleColorForUnit:(FSCalendarUnit *)unit
{
    return _subtitleColors[@(unit.absoluteState)];
}

#pragma mark - Unit Delegate

- (void)handleUnitTap:(FSCalendarUnit *)unit
{
    if ([self shouldSelectDate:unit.date] && !unit.isSelected) {
        if (unit.isPlaceholder) {
            NSArray *subviews;
            if ([_page0.subviews containsObject:unit]) {
                subviews = _page0.subviews;
            } else {
                subviews = _page1.subviews;
            }
            NSInteger index = [subviews indexOfObject:unit];
            CGPoint destOffset;
            if (index <= 7) {
                destOffset = CGPointMake(_scrollView.contentOffset.x-[self flowOffset].x, _scrollView.contentOffset.y-self.flowOffset.y);
            } else {
                destOffset = CGPointMake(_scrollView.contentOffset.x+[self flowOffset].x, _scrollView.contentOffset.y+self.flowOffset.y);
            }
            [_scrollView setContentOffset:destOffset animated:YES];
        }
        self.selectedDate = unit.date;
        [self didSelectDate:unit.date];
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.01 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [_page0.subviews makeObjectsPerformSelector:@selector(setNeedsLayout)];
            [_page1.subviews makeObjectsPerformSelector:@selector(setNeedsLayout)];
        });
    }
}

@end

