//
//  FScalendar.m
//  Pods
//
//  Created by Wenchao Ding on 29/1/15.
//
//

#import "FSCalendar.h"
#import "FSCalendarHeader.h"
#import "UIView+FSExtension.h"
#import "NSDate+FSExtension.h"
#import "NSCalendar+FSExtension.h"
#import "FSCalendarCell.h"

#define kWeekHeight roundf(self.fs_height/9)
#define kBlueText   [UIColor colorWithRed:14/255.0  green:69/255.0  blue:221/255.0    alpha:1.0]
#define kPink       [UIColor colorWithRed:198/255.0 green:51/255.0  blue:42/255.0     alpha:1.0]
#define kBlue       [UIColor colorWithRed:31/255.0  green:119/255.0 blue:219/255.0    alpha:1.0]

@interface FSCalendar (DataSourceAndDelegate)

- (BOOL)hasEventForDate:(NSDate *)date;
- (NSString *)subtitleForDate:(NSDate *)date;

- (BOOL)shouldSelectDate:(NSDate *)date;
- (void)didSelectDate:(NSDate *)date;
- (void)currentMonthDidChange;

@end

@interface FSCalendar ()<UICollectionViewDataSource, UICollectionViewDelegate>

@property (strong, nonatomic) NSMutableArray             *weekdays;

@property (strong, nonatomic) NSMutableDictionary        *backgroundColors;
@property (strong, nonatomic) NSMutableDictionary        *titleColors;
@property (strong, nonatomic) NSMutableDictionary        *subtitleColors;

@property (weak,   nonatomic) CALayer                    *topBorderLayer;
@property (weak,   nonatomic) CALayer                    *bottomBorderLayer;
@property (weak,   nonatomic) UICollectionView           *collectionView;
@property (weak,   nonatomic) UICollectionViewFlowLayout *collectionViewFlowLayout;


@property (assign, nonatomic) BOOL                       supressEvent;

- (void)adjustTitleIfNecessary;

- (NSDate *)dateForIndexPath:(NSIndexPath *)indexPath;
- (NSIndexPath *)indexPathForDate:(NSDate *)date;

- (void)scrollToDate:(NSDate *)date;
- (void)scrollToDate:(NSDate *)date animate:(BOOL)animate;

- (void)setSelectedDate:(NSDate *)selectedDate animate:(BOOL)animate;

@end

@implementation FSCalendar

@synthesize flow = _flow, firstWeekday = _firstWeekday;

#pragma mark - Life Cycle && Initialize

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
    _titleFont        = [UIFont systemFontOfSize:15];
    _subtitleFont     = [UIFont systemFontOfSize:10];
    _weekdayFont      = [UIFont systemFontOfSize:15];
    _headerTitleFont  = [UIFont systemFontOfSize:15];
    _headerTitleColor = kBlueText;
    
    NSArray *weekSymbols = [[NSCalendar fs_sharedCalendar] shortStandaloneWeekdaySymbols];
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
    
    _flow         = FSCalendarFlowHorizontal;
    _firstWeekday = [[NSCalendar fs_sharedCalendar] firstWeekday];
    
    UICollectionViewFlowLayout *collectionViewFlowLayout = [[UICollectionViewFlowLayout alloc] init];
    collectionViewFlowLayout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
    collectionViewFlowLayout.minimumInteritemSpacing = 0;
    collectionViewFlowLayout.minimumLineSpacing = 0;
    self.collectionViewFlowLayout = collectionViewFlowLayout;
    
    
    UICollectionView *collectionView = [[UICollectionView alloc] initWithFrame:CGRectZero
                                                          collectionViewLayout:collectionViewFlowLayout];
    collectionView.dataSource = self;
    collectionView.delegate = self;
    collectionView.backgroundColor = [UIColor clearColor];
    collectionView.bounces = YES;
    collectionView.pagingEnabled = YES;
    collectionView.showsHorizontalScrollIndicator = NO;
    collectionView.showsVerticalScrollIndicator = NO;
    collectionView.delaysContentTouches = NO;
    collectionView.canCancelContentTouches = YES;
    [collectionView registerClass:[FSCalendarCell class] forCellWithReuseIdentifier:@"cell"];
    [self addSubview:collectionView];
    self.collectionView = collectionView;
    
    _currentDate = [NSDate date];
    _currentMonth = [_currentDate copy];
    
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
    
    _eventColor = [kBlue colorWithAlphaComponent:0.75];
    _cellStyle = FSCalendarCellStyleCircle;
    _autoAdjustTitleSize = YES;
    
    CALayer *topBorderLayer = [CALayer layer];
    topBorderLayer.backgroundColor = [[UIColor lightGrayColor] colorWithAlphaComponent:0.2].CGColor;
    [self.layer addSublayer:topBorderLayer];
    self.topBorderLayer = topBorderLayer;
    
    CALayer *bottomBorderLayer = [CALayer layer];
    bottomBorderLayer.backgroundColor = _topBorderLayer.backgroundColor;
    [self.layer addSublayer:bottomBorderLayer];
    self.bottomBorderLayer = bottomBorderLayer;
    
    _minimumDate = [NSDate fs_dateWithYear:1970 month:1 day:1];
    _maximumDate = [NSDate fs_dateWithYear:2099 month:12 day:31];
}

-(void)layoutSubviews
{
    [super layoutSubviews];
    _supressEvent = YES;
    CGFloat padding = self.fs_height * 0.01;
    _collectionView.frame = CGRectMake(0, kWeekHeight, self.fs_width, self.fs_height-kWeekHeight);
    _collectionView.contentInset = UIEdgeInsetsZero;
    _collectionViewFlowLayout.itemSize = CGSizeMake(
                                                    _collectionView.fs_width/7-(_flow == FSCalendarFlowVertical)*0.1,
                                                    (_collectionView.fs_height-padding*2)/6
                                                    );
    _collectionViewFlowLayout.sectionInset = UIEdgeInsetsMake(padding, 0, padding, 0);
    
    [_weekdays enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        CGFloat width = self.fs_width/_weekdays.count;
        CGFloat height = kWeekHeight;
        [obj setFrame:CGRectMake(idx*width, 0, width, height)];
    }];
    [self adjustTitleIfNecessary];
    [self scrollToDate:_currentMonth];
}

- (void)layoutSublayersOfLayer:(CALayer *)layer
{
    [super layoutSublayersOfLayer:layer];
    if (layer == self.layer) {
        _topBorderLayer.frame = CGRectMake(0, -1, self.fs_width, 1);
        _bottomBorderLayer.frame = CGRectMake(0, self.fs_height, self.fs_width, 1);
    }
}

#pragma mark - UICollectionView dataSource/delegate

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
    return [_maximumDate fs_monthsFrom:_minimumDate] + 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return 42;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    FSCalendarCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"cell" forIndexPath:indexPath];
    
    cell.titleColors        = self.titleColors;
    cell.subtitleColors     = self.subtitleColors;
    cell.backgroundColors   = self.backgroundColors;
    cell.eventColor         = self.eventColor;
    cell.cellStyle          = self.cellStyle;
    cell.month              = [_minimumDate fs_dateByAddingMonths:indexPath.section];
    cell.currentDate        = self.currentDate;
    cell.titleLabel.font    = _titleFont;
    cell.subtitleLabel.font = _subtitleFont;
    cell.date               = [self dateForIndexPath:indexPath];
    cell.subtitle           = [self subtitleForDate:cell.date];
    cell.hasEvent           = [self hasEventForDate:cell.date];
    cell.enabled            = [self shouldSelectDate:cell.date];
    [cell configureCell];
    return cell;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    FSCalendarCell *cell = (FSCalendarCell *)[collectionView cellForItemAtIndexPath:indexPath];
    if (cell.isPlaceholder) {
        [self setSelectedDate:cell.date animate:YES];
    } else {
        [cell showAnimation];
        _selectedDate = [self dateForIndexPath:indexPath];
        [self didSelectDate:_selectedDate];
    }
}

- (BOOL)collectionView:(UICollectionView *)collectionView shouldSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    FSCalendarCell *cell = (FSCalendarCell *)[collectionView cellForItemAtIndexPath:indexPath];
    return [self shouldSelectDate:cell.date] && ![[collectionView indexPathsForSelectedItems] containsObject:indexPath];
}

- (void)collectionView:(UICollectionView *)collectionView didDeselectItemAtIndexPath:(NSIndexPath *)indexPath
{
    FSCalendarCell *cell = (FSCalendarCell *)[collectionView cellForItemAtIndexPath:indexPath];
    [cell hideAnimation];
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    if (_supressEvent) {
        _supressEvent = NO;
        return;
    }
    CGFloat scrollOffset = MAX(scrollView.contentOffset.x/scrollView.fs_width,
                               scrollView.contentOffset.y/scrollView.fs_height);
    NSDate *currentMonth = [_minimumDate fs_dateByAddingMonths:round(scrollOffset)];
    if (![_currentMonth fs_isEqualToDateForMonth:currentMonth]) {
        _currentMonth = [currentMonth copy];
        [self currentMonthDidChange];
    }
    _header.scrollOffset = scrollOffset;
    [_collectionViewFlowLayout invalidateLayout];
}

#pragma mark - Setter & Getter

- (void)setFlow:(FSCalendarFlow)flow
{
    if (self.flow != flow) {
        _flow = flow;
        NSIndexPath *newIndexPath;
        
        if (_collectionView.indexPathsForSelectedItems && _collectionView.indexPathsForSelectedItems.count) {
            NSIndexPath *indexPath = _collectionView.indexPathsForSelectedItems.lastObject;
            if (flow == FSCalendarFlowVertical) {
                NSInteger index  = indexPath.item;
                NSInteger row    = index % 6;
                NSInteger column = index / 6;
                newIndexPath = [NSIndexPath indexPathForRow:column+row*7
                                                  inSection:indexPath.section];
            } else if (flow == FSCalendarFlowHorizontal) {
                NSInteger index  = indexPath.item;
                NSInteger row    = index / 7;
                NSInteger column = index % 7;
                newIndexPath = [NSIndexPath indexPathForRow:row+column*6
                                                  inSection:indexPath.section];
            }
        }
        _collectionViewFlowLayout.scrollDirection = (UICollectionViewScrollDirection)flow;
        [self setNeedsLayout];
        [self reloadData:newIndexPath];
    }
}

- (FSCalendarFlow)flow
{
    return (FSCalendarFlow)_collectionViewFlowLayout.scrollDirection;
}

- (void)setFirstWeekday:(NSUInteger)firstWeekday
{
    if (_firstWeekday != firstWeekday) {
        _firstWeekday = firstWeekday;
        [[NSCalendar fs_sharedCalendar] setFirstWeekday:firstWeekday];
        [self reloadData];
    }
}

- (void)setSelectedDate:(NSDate *)selectedDate
{
    [self setSelectedDate:selectedDate animate:NO];
}

- (void)setSelectedDate:(NSDate *)selectedDate animate:(BOOL)animate
{
    NSIndexPath *selectedIndexPath = [self indexPathForDate:selectedDate];
    if (![_selectedDate fs_isEqualToDateForDay:selectedDate] && [self collectionView:_collectionView shouldSelectItemAtIndexPath:selectedIndexPath]) {
        NSIndexPath *currentIndex = [_collectionView indexPathsForSelectedItems].lastObject;
        [_collectionView deselectItemAtIndexPath:currentIndex animated:NO];
        [self collectionView:_collectionView didDeselectItemAtIndexPath:currentIndex];
        [_collectionView selectItemAtIndexPath:selectedIndexPath animated:NO scrollPosition:UICollectionViewScrollPositionNone];
        [self collectionView:_collectionView didSelectItemAtIndexPath:selectedIndexPath];
    }
    if (!_collectionView.tracking && !_collectionView.decelerating && ![_currentMonth fs_isEqualToDateForMonth:_selectedDate]) {
        [self scrollToDate:selectedDate animate:animate];
    }
}


- (void)setCurrentDate:(NSDate *)currentDate
{
    if (![_currentDate fs_isEqualToDateForDay:currentDate]) {
        _currentDate = [currentDate copy];
        _currentMonth = [currentDate copy];
        dispatch_async(dispatch_get_main_queue(), ^{
            [self scrollToDate:_currentDate];
        });
    }
}

- (void)setCurrentMonth:(NSDate *)currentMonth
{
    if (![_currentMonth fs_isEqualToDateForMonth:currentMonth]) {
        _currentMonth = [currentMonth copy];
        dispatch_async(dispatch_get_main_queue(), ^{
            [self scrollToDate:_currentMonth];
            [self currentMonthDidChange];
        });
    }
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
    if (![_weekdayTextColor isEqual:weekdayTextColor]) {
        _weekdayTextColor = weekdayTextColor;
        [_weekdays setValue:weekdayTextColor forKeyPath:@"textColor"];
    }
}

- (void)setHeader:(FSCalendarHeader *)header
{
    if (_header != header) {
        _header = header;
        _topBorderLayer.hidden = header != nil;
    }
}

- (void)setHeaderTitleFont:(UIFont *)font
{
    if (_headerTitleFont != font) {
        _headerTitleFont = font;
        [_header reloadData];
    }
}

- (void)setHeaderTitleColor:(UIColor *)color
{
    if (![_headerTitleColor isEqual:color]) {
        _headerTitleColor = color;
        [_header reloadData];
    }
}

- (void)setHeaderDateFormat:(NSString *)dateFormat
{
    _header.dateFormat = dateFormat;
}

- (NSString *)headerDateFormat
{
    return _header.dateFormat;
}

- (void)setTitleDefaultColor:(UIColor *)color
{
    if (color) {
        _titleColors[@(FSCalendarCellStateNormal)] = color;
    } else {
        [_titleColors removeObjectForKey:@(FSCalendarCellStateNormal)];
    }
    [self reloadData];
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
    [self reloadData];
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
    [self reloadData];
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
    [self reloadData];
}

- (UIColor *)titlePlaceholderColor
{
    return _titleColors[@(FSCalendarCellStatePlaceholder)];
}

- (void)setTitleDisabledColor:(UIColor *)color
{
    if (color) {
        _titleColors[@(FSCalendarCellStateDisabled)] = color;
    } else {
        [_titleColors removeObjectForKey:@(FSCalendarCellStateDisabled)];
    }
    [self reloadData];
}

- (UIColor *)titleDisabledColor{
    return _titleColors[@(FSCalendarCellStateDisabled)];
}


- (void)setTitleWeekendColor:(UIColor *)color
{
    if (color) {
        _titleColors[@(FSCalendarCellStateWeekend)] = color;
    } else {
        [_titleColors removeObjectForKey:@(FSCalendarCellStateWeekend)];
    }
    [self reloadData];
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
    [self reloadData];
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
    [self reloadData];
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
    [self reloadData];
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
    [self reloadData];
}

- (UIColor *)subtitlePlaceholderColor
{
    return _subtitleColors[@(FSCalendarCellStatePlaceholder)];
}

- (void)setSubtitleDisabledColor:(UIColor *)color
{
    if (color) {
        _subtitleColors[@(FSCalendarCellStateDisabled)] = color;
    } else {
        [_subtitleColors removeObjectForKey:@(FSCalendarCellStateDisabled)];
    }
    [self reloadData];
}

- (UIColor *)subtitleDisabledColor{
    return _subtitleColors[@(FSCalendarCellStateDisabled)];
}


- (void)setSubtitleWeekendColor:(UIColor *)color
{
    if (color) {
        _subtitleColors[@(FSCalendarCellStateWeekend)] = color;
    } else {
        [_subtitleColors removeObjectForKey:@(FSCalendarCellStateWeekend)];
    }
    [self reloadData];
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
    [self reloadData];
}

- (UIColor *)selectionColor
{
    return _backgroundColors[@(FSCalendarCellStateSelected)];
}

- (void)setTodayColor:(UIColor *)color
{
    if (color) {
        _backgroundColors[@(FSCalendarCellStateToday)] = color;
    } else {
        [_backgroundColors removeObjectForKey:@(FSCalendarCellStateToday)];
    }
    [self reloadData];
}

- (UIColor *)todayColor
{
    return _backgroundColors[@(FSCalendarCellStateToday)];
}

- (void)setEventColor:(UIColor *)eventColor
{
    if (![_eventColor isEqual:eventColor]) {
        _eventColor = eventColor;
        [self reloadData];
    }
}

- (void)setTitleFont:(UIFont *)font
{
    if (_titleFont != font) {
        _titleFont = font;
        if (_autoAdjustTitleSize) {
            return;
        }
        [self reloadData];
    }
}

- (void)setSubtitleFont:(UIFont *)font
{
    if (_subtitleFont != font) {
        _subtitleFont = font;
        if (_autoAdjustTitleSize) {
            return;
        }
        [self reloadData];
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
    NSIndexPath *selectedPath = [_collectionView indexPathsForSelectedItems].lastObject;
    [self reloadData:selectedPath];
}

#pragma mark - Private

- (void)scrollToDate:(NSDate *)date
{
    [self scrollToDate:date animate:NO];
}

- (void)scrollToDate:(NSDate *)date animate:(BOOL)animate
{
    NSInteger scrollOffset = [date fs_monthsFrom:_minimumDate];
    _supressEvent = !animate;
    if (self.flow == FSCalendarFlowHorizontal) {
        [_collectionView setContentOffset:CGPointMake(scrollOffset * _collectionView.fs_width, 0) animated:animate];
    } else if (self.flow == FSCalendarFlowVertical) {
        [_collectionView setContentOffset:CGPointMake(0, scrollOffset * _collectionView.fs_height) animated:animate];
    }
    if (_header && !animate) {
        _header.scrollOffset = scrollOffset;
    }
}

- (NSDate *)dateForIndexPath:(NSIndexPath *)indexPath
{
    NSDate *currentMonth = [_minimumDate fs_dateByAddingMonths:indexPath.section];
    NSDate *firstDayOfMonth = [NSDate fs_dateWithYear:currentMonth.fs_year
                                                month:currentMonth.fs_month
                                                  day:1];
    NSInteger numberOfPlaceholdersForPrev = ((firstDayOfMonth.fs_weekday - _firstWeekday) + 7) % 7 ? : 7;
    NSDate *firstDateOfPage = [firstDayOfMonth fs_dateBySubtractingDays:numberOfPlaceholdersForPrev];
    NSDate *date;
    if (self.flow == FSCalendarFlowHorizontal) {
        NSUInteger    rows = indexPath.item % 6;
        NSUInteger columns = indexPath.item / 6;
        date = [firstDateOfPage fs_dateByAddingDays:7 * rows + columns];
    } else {
        date = [firstDateOfPage fs_dateByAddingDays:indexPath.item];
    }
    return date;
}

- (NSIndexPath *)indexPathForDate:(NSDate *)date
{
    NSInteger section = [date fs_monthsFrom:_minimumDate];
    NSDate *firstDayOfMonth = [NSDate fs_dateWithYear:date.fs_year month:date.fs_month day:1];
    NSInteger numberOfPlaceholdersForPrev = ((firstDayOfMonth.fs_weekday - _firstWeekday) + 7) % 7 ? : 7;
    NSDate *firstDateOfPage = [firstDayOfMonth fs_dateBySubtractingDays:numberOfPlaceholdersForPrev];
    NSInteger item = 0;
    if (self.flow == FSCalendarFlowHorizontal) {
        NSInteger vItem = [date fs_daysFrom:firstDateOfPage];
        NSInteger rows = vItem/7;
        NSInteger columns = vItem%7;
        item = columns*6 + rows;
    } else if (self.flow == FSCalendarFlowVertical) {
        item = [date fs_daysFrom:firstDateOfPage];
    }
    return [NSIndexPath indexPathForItem:item inSection:section];
}

- (void)adjustTitleIfNecessary
{
    if (_autoAdjustTitleSize) {
        _titleFont       = [_titleFont fontWithSize:_collectionView.fs_height/3/6];
        _subtitleFont    = [_subtitleFont fontWithSize:_collectionView.fs_height/4.5/6];
        _headerTitleFont = [_headerTitleFont fontWithSize:_titleFont.pointSize+3];
        _weekdayFont     = _titleFont;
        [self reloadData];
    }
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

- (void)currentMonthDidChange
{
    if (_delegate && [_delegate respondsToSelector:@selector(calendarCurrentMonthDidChange:)]) {
        [_delegate calendarCurrentMonthDidChange:self];
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
        [self reloadData];
    }
}

- (void)setCellStyle:(FSCalendarCellStyle)cellStyle
{
    if (_cellStyle != cellStyle) {
        _cellStyle = cellStyle;
        [self reloadData];
    }
}

- (void)reloadData:(NSIndexPath *)selection
{
    [_collectionView reloadData];
    [_collectionView selectItemAtIndexPath:selection animated:NO scrollPosition:UICollectionViewScrollPositionNone];
    
    [_weekdays setValue:_weekdayFont forKey:@"font"];
    
    _header.titleFont       = self.headerTitleFont;
    _header.titleColor      = self.headerTitleColor;
    _header.scrollDirection = self.collectionViewFlowLayout.scrollDirection;
    [_header reloadData];
    
    [_weekdays enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        UILabel *weekdayLabel = obj;
        NSUInteger absoluteIndex = ((idx-(_firstWeekday-1))+7)%7;
        weekdayLabel.frame = CGRectMake(absoluteIndex*weekdayLabel.fs_width,
                                        0,
                                        weekdayLabel.fs_width,
                                        weekdayLabel.fs_height);
    }];
}


- (void) setMaximumDate:(NSDate *)maximumDate{
    _maximumDate = maximumDate;
    self.header.maximumDate = maximumDate;
}

- (void) setMinimumDate:(NSDate *)minimumDate{
    _minimumDate = minimumDate;
    self.header.minimumDate = minimumDate;
}


@end

