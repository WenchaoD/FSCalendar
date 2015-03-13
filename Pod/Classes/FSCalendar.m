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
#define kBlueText [UIColor colorWithRed:14/255.0 green:69/255.0 blue:221/255.0 alpha:1.0]
#define kPink [UIColor colorWithRed:198/255.0 green:51/255.0 blue:42/255.0 alpha:1.0]
#define kBlue [UIColor colorWithRed:31/255.0 green:119/255.0 blue:219/255.0 alpha:1.0]

#define kNumberOfPages (2100-1970+1)*12 // From 1970 to 2100

@interface FSCalendar (DataSourceAndDelegate)

- (BOOL)hasEventForDate:(NSDate *)date;
- (NSString *)subtitleForDate:(NSDate *)date;

- (BOOL)shouldSelectDate:(NSDate *)date;
- (void)didSelectDate:(NSDate *)date;
- (void)currentMonthDidChange;

@end

@interface FSCalendar ()<UICollectionViewDataSource, UICollectionViewDelegate>

@property (strong, nonatomic) UICollectionView *collectionView;
@property (strong, nonatomic) UICollectionViewFlowLayout *collectionViewFlowLayout;

@property (strong, nonatomic) NSMutableArray *weekdays;
@property (strong, nonatomic) NSMutableDictionary *backgroundColors;
@property (strong, nonatomic) NSMutableDictionary *titleColors;
@property (strong, nonatomic) NSMutableDictionary *subtitleColors;

- (void)adjustTitleIfNecessary;

- (NSDate *)dateForIndexPath:(NSIndexPath *)indexPath;
- (void)scrollToCurrentDate;

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
    _titleFont = [UIFont systemFontOfSize:15];
    _subtitleFont = [UIFont systemFontOfSize:10];
    _weekdayFont = [UIFont systemFontOfSize:15];
    _headerTitleFont = [UIFont systemFontOfSize:15];
    
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
    
    _collectionViewFlowLayout = [[UICollectionViewFlowLayout alloc] init];
    _collectionViewFlowLayout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
    _collectionViewFlowLayout.minimumInteritemSpacing = 0;
    _collectionViewFlowLayout.minimumLineSpacing = 0;
    
    _collectionView = [[UICollectionView alloc] initWithFrame:CGRectZero
                                         collectionViewLayout:_collectionViewFlowLayout];
    _collectionView.dataSource = self;
    _collectionView.delegate = self;
    _collectionView.backgroundColor = [UIColor clearColor];
    _collectionView.bounces = YES;
    _collectionView.pagingEnabled = YES;
    _collectionView.showsHorizontalScrollIndicator = NO;
    _collectionView.showsVerticalScrollIndicator = NO;
    _collectionView.delaysContentTouches = NO;
    _collectionView.canCancelContentTouches = YES;
    [_collectionView registerClass:[FSCalendarCell class] forCellWithReuseIdentifier:@"cell"];
    [self addSubview:_collectionView];
    
    _collectionView.collectionViewLayout = _collectionViewFlowLayout;
    
    _currentDate = [NSDate date];
    _currentMonth = [_currentDate copy];
    
    _backgroundColors = [NSMutableDictionary dictionaryWithCapacity:4];
    _backgroundColors[@(FSCalendarCellStateNormal)] = [UIColor clearColor];
    _backgroundColors[@(FSCalendarCellStateSelected)] = kBlue;
    _backgroundColors[@(FSCalendarCellStateDisabled)] = [UIColor clearColor];
    _backgroundColors[@(FSCalendarCellStatePlaceholder)] = [UIColor clearColor];
    _backgroundColors[@(FSCalendarCellStateToday)] = kPink;
    
    _titleColors = [NSMutableDictionary dictionaryWithCapacity:4];
    _titleColors[@(FSCalendarCellStateNormal)] = [UIColor darkTextColor];
    _titleColors[@(FSCalendarCellStateWeekend)] = [UIColor darkTextColor];
    _titleColors[@(FSCalendarCellStateSelected)] = [UIColor whiteColor];
    _titleColors[@(FSCalendarCellStateDisabled)] = [UIColor grayColor];
    _titleColors[@(FSCalendarCellStatePlaceholder)] = [UIColor lightGrayColor];
    _titleColors[@(FSCalendarCellStateToday)] = [UIColor whiteColor];
    
    _subtitleColors = [NSMutableDictionary dictionaryWithCapacity:4];
    _subtitleColors[@(FSCalendarCellStateNormal)] = [UIColor darkGrayColor];
    _subtitleColors[@(FSCalendarCellStateWeekend)] = [UIColor darkGrayColor];
    _subtitleColors[@(FSCalendarCellStateSelected)] = [UIColor whiteColor];
    _subtitleColors[@(FSCalendarCellStateDisabled)] = [UIColor lightGrayColor];
    _subtitleColors[@(FSCalendarCellStatePlaceholder)] = [UIColor lightGrayColor];
    _subtitleColors[@(FSCalendarCellStateToday)] = [UIColor whiteColor];
    
    _cellStyle = FSCalendarCellStyleCircle;
    _autoAdjustTitleSize = YES;
}

- (void)setBounds:(CGRect)bounds
{
    [super setBounds:bounds];
    CGFloat padding = bounds.size.height * 0.01;
    _collectionView.frame = CGRectMake(0, kWeekHeight, self.fs_width, self.fs_height-kWeekHeight);
    _collectionViewFlowLayout.itemSize = CGSizeMake(_collectionView.fs_width/7,
                                                    (_collectionView.fs_height-padding*2)/6);
    _collectionViewFlowLayout.sectionInset = UIEdgeInsetsMake(padding, 0, padding, 0);
    _collectionView.collectionViewLayout = _collectionViewFlowLayout;
    [_weekdays enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        CGFloat width = self.fs_width/_weekdays.count;
        CGFloat height = kWeekHeight;
        [obj setFrame:CGRectMake(idx*width, 0, width, height)];
    }];
    [self adjustTitleIfNecessary];
}

#pragma mark - UICollectionView dataSource/delegate

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
    return kNumberOfPages;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return 42;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    FSCalendarCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"cell" forIndexPath:indexPath];
    cell.titleColors = self.titleColors;
    cell.subtitleColors = self.subtitleColors;
    cell.backgroundColors = self.backgroundColors;
    cell.month = [[NSCalendar fs_sharedCalendar] dateByAddingUnit:NSMonthCalendarUnit
                                                            value:indexPath.section
                                                           toDate:[NSDate dateWithTimeIntervalSince1970:1]
                                                          options:0];
    cell.cellStyle = self.cellStyle;
    cell.date = [self dateForIndexPath:indexPath];
    if (!_autoAdjustTitleSize) {
        cell.titleLabel.font = _titleFont;
        cell.subtitleLabel.font = _subtitleFont;
    }
    cell.hasEvent = [self hasEventForDate:cell.date];
    return cell;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    FSCalendarCell *cell = (FSCalendarCell *)[collectionView cellForItemAtIndexPath:indexPath];
    if (cell.isPlaceholder) {

    } else {
        [cell showAnimation];
        self.selectedDate = cell.date;
        [self didSelectDate:cell.date];
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

- (void)collectionView:(UICollectionView *)collectionView willDisplayCell:(UICollectionViewCell *)cell forItemAtIndexPath:(NSIndexPath *)indexPath
{
    static BOOL executed = NO;
    if (indexPath.item == [(NSIndexPath *)collectionView.indexPathsForVisibleItems.lastObject item]) {
        if (!executed) {
            executed = YES;
            [self scrollToCurrentDate];
        }
    }
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    if (!_header) {
        return;
    }
    CGFloat scrollOffset = MAX(scrollView.contentOffset.x/scrollView.fs_width,
                               scrollView.contentOffset.y/scrollView.fs_height);
    _header.scrollOffset = scrollOffset;
    NSDate *currentMonth = [[NSDate dateWithTimeIntervalSince1970:0] fs_dateByAddingMonths:round(scrollOffset)];
    self.currentMonth = currentMonth;
}

#pragma mark - Setter & Getter

- (void)setFlow:(FSCalendarFlow)flow
{
    if (self.flow != flow) {
        NSIndexPath *newIndexPath;
        CGFloat scrollOffset = MAX(_collectionView.contentOffset.x/_collectionView.fs_width,
                                   _collectionView.contentOffset.y/_collectionView.fs_height);
        if (_collectionView.indexPathsForSelectedItems && _collectionView.indexPathsForSelectedItems.count) {
            NSIndexPath *indexPath = _collectionView.indexPathsForSelectedItems.lastObject;
            if (flow == FSCalendarFlowVertical) {
                NSInteger index = indexPath.item;
                NSInteger row = index%6;
                NSInteger column = index/6;
                newIndexPath = [NSIndexPath indexPathForRow:column+row*7
                                                               inSection:indexPath.section];
            } else if (flow == FSCalendarFlowHorizontal) {
                NSInteger index = indexPath.item;
                NSInteger row = index/7;
                NSInteger column = index%7;
                newIndexPath = [NSIndexPath indexPathForRow:row+column*6
                                                               inSection:indexPath.section];
            }
        }
        _collectionViewFlowLayout.scrollDirection = (UICollectionViewScrollDirection)flow;
        [self reloadData:newIndexPath];
        CGPoint newOffset = CGPointMake(
                                        flow == FSCalendarFlowHorizontal ? scrollOffset * _collectionView.fs_width : 0,
                                        flow == FSCalendarFlowVertical ? scrollOffset * _collectionView.fs_height : 0
                                        );
        _collectionView.contentOffset = newOffset;
    }
}

- (FSCalendarFlow)flow
{
    return (FSCalendarFlow)_collectionViewFlowLayout.scrollDirection;
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
        _currentMonth = [currentDate copy];
        [self scrollToCurrentDate];
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
        _titleColors[@(FSCalendarCellStateNormal)] = color;
    } else {
        [_titleColors removeObjectForKey:@(FSCalendarCellStateNormal)];
    }
    [self reloadData];
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

- (void)setTitleTodayColor:(UIColor *)color
{
    if (color) {
        _titleColors[@(FSCalendarCellStateToday)] = color;
    } else {
        [_titleColors removeObjectForKey:@(FSCalendarCellStateToday)];
    }
    [self reloadData];
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

- (void)setTitleWeekendColor:(UIColor *)color
{
    if (color) {
        _titleColors[@(FSCalendarCellStateWeekend)] = color;
    } else {
        [_titleColors removeObjectForKey:@(FSCalendarCellStateWeekend)];
    }
    [self reloadData];
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

- (void)setSubtitleSelectionColor:(UIColor *)color
{
    if (color) {
        _subtitleColors[@(FSCalendarCellStateSelected)] = color;
    } else {
        [_subtitleColors removeObjectForKey:@(FSCalendarCellStateSelected)];
    }
    [self reloadData];
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

- (void)setSubtitlePlaceholderColor:(UIColor *)color
{
    if (color) {
        _subtitleColors[@(FSCalendarCellStatePlaceholder)] = color;
    } else {
        [_subtitleColors removeObjectForKey:@(FSCalendarCellStatePlaceholder)];
    }
    [self reloadData];
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

- (void)setSelectionColor:(UIColor *)color
{
    if (color) {
        _backgroundColors[@(FSCalendarCellStateSelected)] = color;
    } else {
        [_backgroundColors removeObjectForKey:@(FSCalendarCellStateSelected)];
    }
    [self reloadData];
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
    }
}

- (void)setSubtitleFont:(UIFont *)font
{
    if (_subtitleFont != font) {
        _subtitleFont = font;
        if (_autoAdjustTitleSize) {
            return;
        }
    }
}

- (void)setMinDissolvedAlpha:(CGFloat)minDissolvedAlpha
{
    if (_minDissolvedAlpha != minDissolvedAlpha) {
        _minDissolvedAlpha = minDissolvedAlpha;
        _header.minDissolveAlpha = minDissolvedAlpha;
    }
}

- (void)setCurrentMonth:(NSDate *)currentMonth
{
    if (!(_currentMonth.fs_year==currentMonth.fs_year
          && _currentMonth.fs_month == currentMonth.fs_month)) {
        _currentMonth = [currentMonth copy];
        [self currentMonthDidChange];
    }
}

#pragma mark - Public

- (void)reloadData
{
    NSIndexPath *selectedPath = [_collectionView indexPathsForSelectedItems].lastObject;
    [_collectionView reloadData];
    [_collectionView selectItemAtIndexPath:selectedPath animated:NO scrollPosition:UICollectionViewScrollPositionNone];
}

#pragma mark - Private

- (void)scrollToCurrentDate
{
    NSInteger scrollOffset = [_currentDate fs_monthsFrom:[NSDate dateWithTimeIntervalSince1970:0]];
    if (self.flow == FSCalendarFlowHorizontal) {
        _collectionView.bounds = CGRectOffset(_collectionView.bounds,
                                              scrollOffset * _collectionView.fs_width,
                                              0);
    } else if (self.flow == FSCalendarFlowVertical) {
        _collectionView.bounds = CGRectOffset(_collectionView.bounds,
                                              0,
                                              scrollOffset * _collectionView.fs_height);
    }
}

- (NSDate *)dateForIndexPath:(NSIndexPath *)indexPath
{
    NSCalendar *calendar = [NSCalendar fs_sharedCalendar];
    NSDate *currentMonth = [calendar dateByAddingUnit:NSMonthCalendarUnit
                                                value:indexPath.section
                                               toDate:[NSDate dateWithTimeIntervalSince1970:1]
                                              options:0];
    NSDate *firstDayOfMonth = [NSDate fs_dateWithYear:currentMonth.fs_year month:currentMonth.fs_month day:1];
    NSInteger numberOfPlaceholdersForPrev = (firstDayOfMonth.fs_weekday - 1) ? : 7;
    NSDate *firstDateOfPage = [firstDayOfMonth fs_dateBySubtractingDays:numberOfPlaceholdersForPrev];
    NSDate *dateForRow;
    if (self.flow == FSCalendarFlowHorizontal) {
        dateForRow = [firstDateOfPage fs_dateByAddingDays:7*(indexPath.item%6)+indexPath.item/6];
    } else {
        dateForRow = [firstDateOfPage fs_dateByAddingDays:indexPath.item];
    }
    return dateForRow;
}

- (void)adjustTitleIfNecessary
{
    UIFont *titleFont = _titleFont;
    UIFont *subtitleFont = _subtitleFont;
    UIFont *headerFont = _headerTitleFont;
    UIFont *weekdayFont = _weekdayFont;
    if (_autoAdjustTitleSize) {
        titleFont = [titleFont fontWithSize:_collectionView.fs_height/3/6];
        subtitleFont = [subtitleFont fontWithSize:_collectionView.fs_height/4.3/6];
        headerFont = titleFont;
        weekdayFont = titleFont;
    }
    [_collectionView reloadData];
    [_weekdays setValue:weekdayFont forKey:@"font"];
    if (_header) {
        [_header setTitleFont:headerFont];
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
    if (selection) {
        [_collectionView reloadData];
        [_collectionView selectItemAtIndexPath:selection animated:NO scrollPosition:UICollectionViewScrollPositionNone];
    } else {
        [self reloadData];
    }
}

@end

