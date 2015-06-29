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
#import "FSCalendarCell.h"

#import "FSCalendarDynamicHeader.h"

#define kDefaultHeaderHeight 40
#define kWeekHeight roundf(self.fs_height/12)

@interface FSCalendar (DataSourceAndDelegate)

- (BOOL)hasEventForDate:(NSDate *)date;
- (NSString *)subtitleForDate:(NSDate *)date;

- (BOOL)shouldSelectDate:(NSDate *)date;
- (void)didSelectDate:(NSDate *)date;
- (void)currentMonthDidChange;

@end

@interface FSCalendar ()<UICollectionViewDataSource, UICollectionViewDelegate>
{
    FSCalendarAppearance *_appearance;
    NSDate *_minimumDate;
    NSDate *_maximumDate;
}
@property (strong, nonatomic) NSMutableArray             *weekdays;

@property (weak  , nonatomic) CALayer                    *topBorderLayer;
@property (weak  , nonatomic) CALayer                    *bottomBorderLayer;
@property (weak  , nonatomic) UICollectionView           *collectionView;
@property (weak  , nonatomic) UICollectionViewFlowLayout *collectionViewFlowLayout;
@property (weak  , nonatomic) FSCalendarHeader           *header;

@property (strong, nonatomic) NSCalendar                 *calendar;
@property (assign, nonatomic) BOOL                       supressEvent;

- (void)orientationDidChange:(NSNotification *)notification;

- (NSDate *)dateForIndexPath:(NSIndexPath *)indexPath;
- (NSIndexPath *)indexPathForDate:(NSDate *)date;

- (void)scrollToDate:(NSDate *)date;
- (void)scrollToDate:(NSDate *)date animate:(BOOL)animate;

- (void)setSelectedDate:(NSDate *)selectedDate animate:(BOOL)animate;

- (BOOL)isDateInRange:(NSDate *)date;

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
    _appearance = [[FSCalendarAppearance alloc] init];
    _appearance.calendar = self;
    
    _headerHeight     = -1;
    _calendar         = [NSCalendar currentCalendar];
    
    NSArray *weekSymbols = [_calendar shortStandaloneWeekdaySymbols];
    _weekdays = [NSMutableArray arrayWithCapacity:weekSymbols.count];
    for (int i = 0; i < weekSymbols.count; i++) {
        UILabel *weekdayLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        weekdayLabel.text = weekSymbols[i];
        weekdayLabel.textAlignment = NSTextAlignmentCenter;
        weekdayLabel.font = _appearance.weekdayFont;
        weekdayLabel.textColor = _appearance.weekdayTextColor;
        [_weekdays addObject:weekdayLabel];
        [self addSubview:weekdayLabel];
    }
    
    _flow         = FSCalendarFlowHorizontal;
    _firstWeekday = [_calendar firstWeekday];
    
    FSCalendarHeader *header = [[FSCalendarHeader alloc] initWithFrame:CGRectZero];
    header.appearance = _appearance;
    [self addSubview:header];
    self.header = header;
    
    UICollectionViewFlowLayout *collectionViewFlowLayout = [[UICollectionViewFlowLayout alloc] init];
    collectionViewFlowLayout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
    collectionViewFlowLayout.minimumInteritemSpacing = 0;
    collectionViewFlowLayout.minimumLineSpacing = 0;
    collectionViewFlowLayout.itemSize = CGSizeMake(1, 1);
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
    
    CALayer *topBorderLayer = [CALayer layer];
    topBorderLayer.backgroundColor = [[UIColor lightGrayColor] colorWithAlphaComponent:0.2].CGColor;
    [self.layer addSublayer:topBorderLayer];
    self.topBorderLayer = topBorderLayer;
    
    CALayer *bottomBorderLayer = [CALayer layer];
    bottomBorderLayer.backgroundColor = _topBorderLayer.backgroundColor;
    [self.layer addSublayer:bottomBorderLayer];
    self.bottomBorderLayer = bottomBorderLayer;
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(orientationDidChange:) name:UIDeviceOrientationDidChangeNotification object:nil];
    
    dispatch_async(dispatch_get_main_queue(), ^{
        
        if (!_selectedDate) {
            _supressEvent = YES;
            self.selectedDate = [NSDate date];
            _supressEvent = NO;
        } else {
            [self scrollToDate:_selectedDate];
        }
        
    });
    
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIDeviceOrientationDidChangeNotification object:nil];
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    _supressEvent = YES;
    CGFloat padding = self.fs_height * 0.01;
    if (_headerHeight == -1) {
        _header.frame = CGRectMake(0, 0, self.fs_width, kDefaultHeaderHeight);
    }
    
    _collectionView.frame = CGRectMake(0, kWeekHeight+_header.fs_height, self.fs_width, self.fs_height-kWeekHeight-_header.fs_height);
    _collectionView.contentInset = UIEdgeInsetsZero;
    _collectionViewFlowLayout.itemSize = CGSizeMake(
                                                    _collectionView.fs_width/7-(_flow == FSCalendarFlowVertical)*0.1,
                                                    (_collectionView.fs_height-padding*2)/6
                                                    );
    _collectionViewFlowLayout.sectionInset = UIEdgeInsetsMake(padding, 0, padding, 0);
    
    CGFloat width = self.fs_width/_weekdays.count;
    CGFloat height = kWeekHeight;
    [_weekdays enumerateObjectsUsingBlock:^(UILabel *weekdayLabel, NSUInteger idx, BOOL *stop) {
        NSUInteger absoluteIndex = ((idx-(_firstWeekday-1))+7)%7;
        weekdayLabel.frame = CGRectMake(absoluteIndex*weekdayLabel.fs_width,
                                        _header.fs_height,
                                        width,
                                        height);
    }];
    [_appearance adjustTitleIfNecessary];
    NSDate *maximumDate = self.maximumDate;
    NSDate *minimumDate = self.minimumDate;
    if ([maximumDate fs_daysFrom:minimumDate] <= 0) {
        [NSException raise:@"maximumDate must be later than minimumDate" format:nil];
    }
    
    _header.minimumDate = minimumDate;
    _header.maximumDate = maximumDate;
    
    _supressEvent = NO;
    
}

- (void)layoutSublayersOfLayer:(CALayer *)layer
{
    [super layoutSublayersOfLayer:layer];
    if (layer == self.layer) {
        _topBorderLayer.frame = CGRectMake(0, -1, self.fs_width, 1);
        _bottomBorderLayer.frame = CGRectMake(0, self.fs_height, self.fs_width, 1);
    }
}

- (void)didMoveToWindow
{
    [super didMoveToWindow];
    if (self.window) {
        // In case : Pushing to another view controller then change orientation then pop back
        [self setNeedsLayout];
        dispatch_async(dispatch_get_main_queue(), ^{
            if (_currentMonth) {
                [self scrollToDate:_currentMonth];
            }
        });
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
    cell.appearance         = self.appearance;
    cell.month              = [_minimumDate fs_dateByAddingMonths:indexPath.section];
    cell.currentDate        = self.currentDate;
    cell.date               = [self dateForIndexPath:indexPath];
    cell.subtitle           = [self subtitleForDate:cell.date];
    cell.hasEvent           = [self hasEventForDate:cell.date];
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
        if (!_supressEvent) {
            [self didSelectDate:_selectedDate];
        }
    }
}

- (BOOL)collectionView:(UICollectionView *)collectionView shouldSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    FSCalendarCell *cell = (FSCalendarCell *)[collectionView cellForItemAtIndexPath:indexPath];
    BOOL shouldSelect = ![[collectionView indexPathsForSelectedItems] containsObject:indexPath];
    if (shouldSelect && cell.date) {
        shouldSelect &= [self shouldSelectDate:cell.date];
    }
    return shouldSelect;
}

- (void)collectionView:(UICollectionView *)collectionView didDeselectItemAtIndexPath:(NSIndexPath *)indexPath
{
    FSCalendarCell *cell = (FSCalendarCell *)[collectionView cellForItemAtIndexPath:indexPath];
    [cell hideAnimation];
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    if (!_minimumDate || _supressEvent) {
        return;
    }
    CGFloat scrollOffset = MAX(scrollView.contentOffset.x/scrollView.fs_width,
                               scrollView.contentOffset.y/scrollView.fs_height);
    _header.scrollOffset = scrollOffset;
}

- (void)scrollViewWillEndDragging:(UIScrollView *)scrollView withVelocity:(CGPoint)velocity targetContentOffset:(inout CGPoint *)targetContentOffset
{
    CGFloat pannedOffset = 0, targetOffset = 0, currentOffset = 0, contentSize = 0;
    if (_flow == FSCalendarFlowHorizontal) {
        pannedOffset = [scrollView.panGestureRecognizer translationInView:scrollView].x;
        targetOffset = (*targetContentOffset).x;
        currentOffset = scrollView.contentOffset.x;
        contentSize = scrollView.fs_width;
    } else if (_flow == FSCalendarFlowVertical) {
        pannedOffset = [scrollView.panGestureRecognizer translationInView:scrollView].y;
        targetOffset = (*targetContentOffset).y;
        currentOffset = scrollView.contentOffset.y;
        contentSize = scrollView.fs_height;
    }
    BOOL shouldTriggerMonthChange = ((pannedOffset < 0 && targetOffset > currentOffset) ||
                                     (pannedOffset > 0 && targetOffset < currentOffset)) && _minimumDate;
    if (shouldTriggerMonthChange) {
        [self willChangeValueForKey:@"currentMonth"];
        _currentMonth = [_minimumDate fs_dateByAddingMonths:targetOffset/contentSize];
        [self currentMonthDidChange];
        [self didChangeValueForKey:@"currentMonth"];
    }
}

#pragma mark - Notification

- (void)orientationDidChange:(NSNotification *)notification
{
    [self scrollToDate:_currentMonth];
}

#pragma mark - Properties

- (void)setAppearance:(FSCalendarAppearance *)appearance
{
    if (_appearance != appearance) {
        _appearance = appearance;
    }
}

- (FSCalendarAppearance *)appearance
{
    return _appearance;
}

- (void)setFlow:(FSCalendarFlow)flow
{
    if (self.flow != flow) {
        _flow = flow;
        _supressEvent = YES;
        NSDate *currentMonth = self.currentMonth;
        _collectionViewFlowLayout.scrollDirection = (UICollectionViewScrollDirection)flow;
        [self layoutSubviews];
        [self reloadData];
        [self scrollToDate:currentMonth];
        _supressEvent = NO;
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
        [_calendar setFirstWeekday:firstWeekday];
        [self reloadData];
    }
}

- (void)setSelectedDate:(NSDate *)selectedDate
{
    if (![self isDateInRange:selectedDate]) {
        [NSException raise:@"selectedDate out of range" format:nil];
    }
    [self setSelectedDate:selectedDate animate:NO];
}

- (void)setSelectedDate:(NSDate *)selectedDate animate:(BOOL)animate
{
    selectedDate = [selectedDate fs_daysFrom:_minimumDate] < 0 ? [NSDate fs_dateWithYear:_minimumDate.fs_year month:_minimumDate.fs_month day:selectedDate.fs_day] : selectedDate;
    selectedDate = [selectedDate fs_daysFrom:_maximumDate] > 0 ? [NSDate fs_dateWithYear:_maximumDate.fs_year month:_maximumDate.fs_month day:selectedDate.fs_day] : selectedDate;
    NSIndexPath *selectedIndexPath = [self indexPathForDate:selectedDate];
    if ([self collectionView:_collectionView shouldSelectItemAtIndexPath:selectedIndexPath]) {
        if (_collectionView.indexPathsForSelectedItems.count && _selectedDate) {
            NSIndexPath *currentIndexPath = [self indexPathForDate:_selectedDate];
            [_collectionView deselectItemAtIndexPath:currentIndexPath animated:YES];
            [self collectionView:_collectionView didDeselectItemAtIndexPath:currentIndexPath];
        }
        [_collectionView selectItemAtIndexPath:selectedIndexPath animated:NO scrollPosition:UICollectionViewScrollPositionNone];
        [self collectionView:_collectionView didSelectItemAtIndexPath:selectedIndexPath];
    }
    if (!_collectionView.tracking && !_collectionView.decelerating) {
        [self willChangeValueForKey:@"currentMonth"];
        _currentMonth = [selectedDate copy];
        [self currentMonthDidChange];
        [self didChangeValueForKey:@"currentMonth"];
        [self scrollToDate:selectedDate animate:animate];
    }
}

- (void)setCurrentDate:(NSDate *)currentDate
{
    if (![self isDateInRange:currentDate]) {
        [NSException raise:@"currentDate out of range" format:nil];
    }
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
    if (![self isDateInRange:currentMonth]) {
        [NSException raise:@"currentMonth out of range" format:nil];
    }
    if (![_currentMonth fs_isEqualToDateForMonth:currentMonth]) {
        _currentMonth = currentMonth;
        dispatch_async(dispatch_get_main_queue(), ^{
            [self scrollToDate:currentMonth];
            [self currentMonthDidChange];
        });
    }
}

- (void)setHeaderHeight:(CGFloat)headerHeight
{
    if (_headerHeight != headerHeight) {
        _headerHeight = headerHeight;
        [self setNeedsLayout];
    }
}

#pragma mark - Public

- (void)reloadData
{
    _header.scrollDirection = self.collectionViewFlowLayout.scrollDirection;
    [_header reloadData];
    
    [_weekdays setValue:_appearance.weekdayFont forKey:@"font"];
    CGFloat width = self.fs_width/_weekdays.count;
    CGFloat height = kWeekHeight;
    [_weekdays enumerateObjectsUsingBlock:^(UILabel *weekdayLabel, NSUInteger idx, BOOL *stop) {
        NSUInteger absoluteIndex = ((idx-(_firstWeekday-1))+7)%7;
        weekdayLabel.frame = CGRectMake(absoluteIndex*weekdayLabel.fs_width,
                                        _header.fs_height,
                                        width,
                                        height);
    }];
    
    [_collectionView reloadData];
    if (_selectedDate) {
        _supressEvent = YES;
        NSIndexPath *selectedIndexPath = [self indexPathForDate:_selectedDate];
        [_collectionView selectItemAtIndexPath:selectedIndexPath animated:NO scrollPosition:UICollectionViewScrollPositionNone];
        [self collectionView:_collectionView didSelectItemAtIndexPath:selectedIndexPath];
        _supressEvent = NO;
    }
}

#pragma mark - Private

- (void)scrollToDate:(NSDate *)date
{
    [self scrollToDate:date animate:NO];
}

- (void)scrollToDate:(NSDate *)date animate:(BOOL)animate
{
    if (!_minimumDate || !_maximumDate) {
        return;
    }
    _supressEvent = !animate;
    date = [date fs_daysFrom:_minimumDate] < 0 ? [NSDate fs_dateWithYear:_minimumDate.fs_year month:_minimumDate.fs_month day:date.fs_day] : date;
    date = [date fs_daysFrom:_maximumDate] > 0 ? [NSDate fs_dateWithYear:_maximumDate.fs_year month:_maximumDate.fs_month day:date.fs_day] : date;
    NSInteger scrollOffset = [date fs_monthsFrom:_minimumDate];
    if (self.flow == FSCalendarFlowHorizontal) {
        [_collectionView setContentOffset:CGPointMake(scrollOffset * _collectionView.fs_width, 0) animated:animate];
    } else if (self.flow == FSCalendarFlowVertical) {
        [_collectionView setContentOffset:CGPointMake(0, scrollOffset * _collectionView.fs_height) animated:animate];
    }
    if (_header && !animate) {
        _header.scrollOffset = scrollOffset;
    }
    _supressEvent = NO;
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

- (BOOL)isDateInRange:(NSDate *)date
{
    return [date fs_daysFrom:self.minimumDate] >= 0 && [date fs_daysFrom:self.maximumDate] <= 0;
}

#pragma mark - Delegate

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

#pragma mark - DataSource

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

- (NSDate *)minimumDate
{
    if (_dataSource && [_dataSource respondsToSelector:@selector(minimumDateForCalendar:)]) {
        _minimumDate = [_dataSource minimumDateForCalendar:self];
    }
    if (!_minimumDate) {
        _minimumDate = [NSDate fs_dateWithYear:1970 month:1 day:1];
    }
    return _minimumDate;
}

- (NSDate *)maximumDate
{
    if (_dataSource && [_dataSource respondsToSelector:@selector(maximumDateForCalendar:)]) {
        _maximumDate = [_dataSource maximumDateForCalendar:self];
    }
    if (!_maximumDate) {
        _maximumDate = [NSDate fs_dateWithYear:2099 month:12 day:31];
    }
    return _maximumDate;
}

@end

