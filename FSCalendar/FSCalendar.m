//
//  FScalendar.m
//  Pods
//
//  Created by Wenchao Ding on 29/1/15.
//
//

#import "FSCalendar.h"
#import "FSCalendarHeader.h"
#import "FSCalendarStickyHeader.h"
#import "FSCalendarCell.h"

#import "UIView+FSExtension.h"
#import "NSString+FSExtension.h"
#import "FSCalendarFlowLayout.h"
#import "FSCalendarDynamicHeader.h"
#import "FSCalendarCollectionView.h"

@interface FSCalendar (DataSourceAndDelegate)

- (BOOL)hasEventForDate:(NSDate *)date;
- (NSString *)subtitleForDate:(NSDate *)date;
- (UIImage *)imageForDate:(NSDate *)date;
- (NSDate *)minimumDateForCalendar;
- (NSDate *)maximumDateForCalendar;

- (UIColor *)preferedSelectionColorForDate:(NSDate *)date;
- (UIColor *)preferedTitleDefaultColorForDate:(NSDate *)date;
- (UIColor *)preferedTitleSelectionColorForDate:(NSDate *)date;
- (UIColor *)preferedSubtitleDefaultColorForDate:(NSDate *)date;
- (UIColor *)preferedSubtitleSelectionColorForDate:(NSDate *)date;
- (UIColor *)preferedEventColorForDate:(NSDate *)date;
- (UIColor *)preferedBorderDefaultColorForDate:(NSDate *)date;
- (UIColor *)preferedBorderSelectionColorForDate:(NSDate *)date;
- (FSCalendarCellShape)preferedCellShapeForDate:(NSDate *)date;

- (BOOL)shouldSelectDate:(NSDate *)date;
- (void)didSelectDate:(NSDate *)date;
- (BOOL)shouldDeselectDate:(NSDate *)date;
- (void)didDeselectDate:(NSDate *)date;
- (void)currentPageDidChange;

@end

@interface FSCalendar ()<UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout>
{
    NSMutableArray *_selectedDates;
    NSDate *_minimumDate;
    NSDate *_maximumDate;
}
@property (strong, nonatomic) NSMutableArray             *weekdays;
@property (strong, nonatomic) NSMapTable                 *stickyHeaderMapTable;

@property (strong, nonatomic) NSCalendar *calendar;
@property (strong, nonatomic) NSDateFormatter *formatter;
@property (strong, nonatomic) NSDateComponents *components;
@property (strong, nonatomic) NSTimeZone *timeZone;

@property (weak  , nonatomic) UIView                     *contentView;
@property (weak  , nonatomic) UIView                     *daysContainer;
@property (weak  , nonatomic) CAShapeLayer               *maskLayer;
@property (weak  , nonatomic) UIView                     *topBorder;
@property (weak  , nonatomic) UIView                     *bottomBorder;
@property (weak  , nonatomic) FSCalendarCollectionView   *collectionView;
@property (weak  , nonatomic) FSCalendarFlowLayout       *collectionViewLayout;

@property (weak  , nonatomic) FSCalendarHeader           *header;
@property (weak  , nonatomic) FSCalendarHeaderTouchDeliver *deliver;

@property (assign, nonatomic) BOOL                       ibEditing;
@property (assign, nonatomic) BOOL                       needsAdjustingMonthPosition;
@property (assign, nonatomic) BOOL                       needsAdjustingViewFrame;
@property (assign, nonatomic) BOOL                       needsAdjustingTextSize;
@property (assign, nonatomic) BOOL                       needsLayoutForWeekMode;
@property (assign, nonatomic) BOOL                       supressEvent;
@property (assign, nonatomic) CGFloat                    preferedHeaderHeight;
@property (assign, nonatomic) CGFloat                    preferedWeekdayHeight;
@property (assign, nonatomic) CGFloat                    preferedRowHeight;
@property (assign, nonatomic) UIInterfaceOrientation     interfaceOrientation;

@property (readonly, nonatomic) BOOL floatingMode;
@property (readonly, nonatomic) BOOL hasValidateVisibleLayout;
@property (readonly, nonatomic) NSArray *visibleStickyHeaders;

@property (readonly, nonatomic) id<FSCalendarDelegateAppearance> delegateAppearance;

- (void)orientationDidChange:(NSNotification *)notification;
- (void)significantTimeDidChange:(NSNotification *)notification;

- (NSDate *)dateForIndexPath:(NSIndexPath *)indexPath;
- (NSIndexPath *)indexPathForDate:(NSDate *)date;
- (CGSize)sizeThatFits:(CGSize)size scope:(FSCalendarScope)scope;

- (void)scrollToDate:(NSDate *)date;
- (void)scrollToDate:(NSDate *)date animated:(BOOL)animated;
- (void)scrollToPageForDate:(NSDate *)date animated:(BOOL)animated;

- (BOOL)isDateInRange:(NSDate *)date;
- (BOOL)isDateSelected:(NSDate *)date;
- (BOOL)isDateInDifferentPage:(NSDate *)date;

- (void)selectDate:(NSDate *)date scrollToDate:(BOOL)scrollToDate forPlaceholder:(BOOL)forPlaceholder;
- (void)enqueueSelectedDate:(NSDate *)date;

- (void)invalidateDateTools;
- (void)invalidateLayout;
- (void)invalidateWeekdaySymbols;
- (void)invalidateHeaders;
- (void)invalidateAppearanceForCell:(FSCalendarCell *)cell;

- (void)selectCounterpartDate:(NSDate *)date;
- (void)deselectCounterpartDate:(NSDate *)date;

- (void)performScopeTransitionFromScope:(FSCalendarScope)fromScope toScope:(FSCalendarScope)toScope animated:(BOOL)animated;

- (void)reloadDataForCell:(FSCalendarCell *)cell atIndexPath:(NSIndexPath *)indexPath;
- (void)reloadVisibleCells;

@end

@implementation FSCalendar

@dynamic selectedDate;
@synthesize scrollDirection = _scrollDirection, firstWeekday = _firstWeekday, headerHeight = _headerHeight, appearance = _appearance;

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
    
    _calendar = [NSCalendar currentCalendar];
    _components = [[NSDateComponents alloc] init];
    _formatter = [[NSDateFormatter alloc] init];
    _timeZone = [NSTimeZone timeZoneForSecondsFromGMT:0];
    _locale = [NSLocale currentLocale];
    _firstWeekday = 1;
    [self invalidateDateTools];
    
    _minimumDate = [self dateWithYear:1970 month:1 day:1];
    _maximumDate = [self dateWithYear:2099 month:12 day:31];
    
    _headerHeight     = FSCalendarAutomaticDimension;
    _weekdayHeight    = FSCalendarAutomaticDimension;
    
    _preferedHeaderHeight  = FSCalendarAutomaticDimension;
    _preferedWeekdayHeight = FSCalendarAutomaticDimension;
    _preferedRowHeight     = FSCalendarAutomaticDimension;
    
    _scrollDirection = FSCalendarScrollDirectionHorizontal;
    _scope = FSCalendarScopeMonth;
    _selectedDates = [NSMutableArray arrayWithCapacity:1];
    
    _today = [self dateByIgnoringTimeComponentsOfDate:[NSDate date]];
    _currentPage = [self beginingOfMonthOfDate:_today];
    
    _pagingEnabled = YES;
    _scrollEnabled = YES;
    _needsAdjustingViewFrame = YES;
    _needsAdjustingTextSize = YES;
    _stickyHeaderMapTable = [NSMapTable weakToWeakObjectsMapTable];
    _interfaceOrientation = [UIApplication sharedApplication].statusBarOrientation;
    
    UIView *contentView = [[UIView alloc] initWithFrame:CGRectZero];
    contentView.backgroundColor = [UIColor clearColor];
    [self addSubview:contentView];
    self.contentView = contentView;
    
    CAShapeLayer *maskLayer = [CAShapeLayer layer];
    maskLayer.actions = @{@"path":[NSNull null]};
    contentView.layer.mask = maskLayer;
    self.maskLayer = maskLayer;
    
    UIView *daysContainer = [[UIView alloc] initWithFrame:CGRectZero];
    daysContainer.backgroundColor = [UIColor clearColor];
    [contentView addSubview:daysContainer];
    self.daysContainer = daysContainer;
    
    FSCalendarFlowLayout *collectionViewLayout = [[FSCalendarFlowLayout alloc] init];
    collectionViewLayout.calendar = self;
    
    FSCalendarCollectionView *collectionView = [[FSCalendarCollectionView alloc] initWithFrame:CGRectZero
                                                          collectionViewLayout:collectionViewLayout];
    collectionView.dataSource = self;
    collectionView.delegate = self;
    collectionView.backgroundColor = [UIColor clearColor];
    collectionView.bounces = YES;
    collectionView.pagingEnabled = YES;
    collectionView.showsHorizontalScrollIndicator = NO;
    collectionView.showsVerticalScrollIndicator = NO;
    collectionView.delaysContentTouches = NO;
    collectionView.canCancelContentTouches = YES;
    collectionView.allowsMultipleSelection = NO;
    [collectionView registerClass:[FSCalendarCell class] forCellWithReuseIdentifier:@"cell"];
    [collectionView registerClass:[FSCalendarStickyHeader class] forSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:@"header"];
    [collectionView registerClass:[UICollectionReusableView class] forSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:@"placeholderHeader"];
    [daysContainer addSubview:collectionView];
    self.collectionView = collectionView;
    self.collectionViewLayout = collectionViewLayout;
    
    UIView *view = [[UIView alloc] initWithFrame:CGRectZero];
    view.backgroundColor = [[UIColor lightGrayColor] colorWithAlphaComponent:0.25];
    [self addSubview:view];
    self.topBorder = view;
    
    view = [[UIView alloc] initWithFrame:CGRectZero];
    view.backgroundColor = _topBorder.backgroundColor;
    [self addSubview:view];
    self.bottomBorder = view;
    
    [self invalidateLayout];
    
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(orientationDidChange:) name:UIDeviceOrientationDidChangeNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(significantTimeDidChange:) name:UIApplicationSignificantTimeChangeNotification object:nil];
}

- (void)dealloc
{
    _collectionView.delegate = nil;
    _collectionView.dataSource = nil;
    
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIDeviceOrientationDidChangeNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIApplicationSignificantTimeChangeNotification object:nil];
}

#pragma mark - Overriden methods

- (void)layoutSubviews
{
    [super layoutSubviews];
    _supressEvent = YES;
    
    if (_needsAdjustingViewFrame) {
    
        _contentView.frame = self.bounds;

        if (_needsLayoutForWeekMode) _scope = FSCalendarScopeMonth;
        
        CGFloat headerHeight = self.preferedHeaderHeight;
        CGFloat weekdayHeight = self.preferedWeekdayHeight;
        CGFloat rowHeight = self.preferedRowHeight;
        CGFloat weekdayWidth = _contentView.fs_width/_weekdays.count;
        CGFloat padding = weekdayHeight*0.1;
        
        if (_needsLayoutForWeekMode) _scope = FSCalendarScopeWeek;
        
        _header.frame = CGRectMake(0, 0, self.fs_width, headerHeight);
        [_weekdays enumerateObjectsUsingBlock:^(UILabel *weekdayLabel, NSUInteger index, BOOL *stop) {
            weekdayLabel.frame = CGRectMake(index*weekdayWidth,
                                            _header.fs_height,
                                            weekdayWidth,
                                            weekdayHeight);
        }];
        
        _deliver.frame = CGRectMake(_header.fs_left, _header.fs_top, _header.fs_width, headerHeight+weekdayHeight);
        _deliver.hidden = _header.hidden;
        
        if (!self.floatingMode) {
            
            switch (_scope) {
                case FSCalendarScopeMonth: {
                    CGFloat contentHeight = rowHeight*6 + padding*2;
                    _daysContainer.frame = CGRectMake(0, headerHeight+weekdayHeight, self.fs_width, contentHeight);
                    _collectionView.frame = _daysContainer.bounds;
                    break;
                }
                case FSCalendarScopeWeek: {
                    CGFloat contentHeight = rowHeight + padding*2;
                    _daysContainer.frame = CGRectMake(0, headerHeight+weekdayHeight, self.fs_width, contentHeight);
                    _collectionView.frame = _daysContainer.bounds;
                    break;
                }
                default: {
                    break;
                }
            }
        } else {
            CGFloat contentHeight = _contentView.fs_height;
            _daysContainer.frame = CGRectMake(0, 0, self.fs_width, contentHeight);
            _collectionView.frame = _daysContainer.bounds;
            
        }
        _topBorder.frame = CGRectMake(0, -1, self.fs_width, 1);
        _bottomBorder.frame = CGRectMake(0, self.fs_height, self.fs_width, 1);
        
    }
    if (_needsAdjustingTextSize) {
        _needsAdjustingTextSize = NO;
        [_appearance adjustTitleIfNecessary];
    }
    
    if (_needsLayoutForWeekMode) {
        _needsLayoutForWeekMode = NO;
        _scope = FSCalendarScopeWeek;
        [self performScopeTransitionFromScope:FSCalendarScopeMonth toScope:FSCalendarScopeWeek animated:NO];
    } else {
        if (_needsAdjustingMonthPosition) {
            _needsAdjustingMonthPosition = NO;
            [self scrollToDate:_pagingEnabled?_currentPage:(_currentPage?:self.selectedDate)];
        }
    }
    
    _supressEvent = NO;
    
}

- (void)layoutSublayersOfLayer:(CALayer *)layer
{
    [super layoutSublayersOfLayer:layer];
    if (layer == self.layer) {
        if (_needsAdjustingViewFrame) {
            
            _needsAdjustingViewFrame = NO;
            
            CGSize size = [self sizeThatFits:self.frame.size];
            _maskLayer.frame = self.bounds;
            _maskLayer.path = [UIBezierPath bezierPathWithRect:(CGRect){CGPointZero,size}].CGPath;
            
        }
    }
}

- (void)didMoveToWindow
{
    [super didMoveToWindow];
    if (self.window) {
        _needsAdjustingViewFrame = YES;
        _needsAdjustingMonthPosition = YES;
        [self setNeedsLayout];
    }
}

- (void)prepareForInterfaceBuilder
{
    self.ibEditing = YES;
    NSDate *date = [NSDate date];
    [self selectDate:[self dateWithYear:[self yearOfDate:date] month:[self monthOfDate:date] day:_appearance.fakedSelectedDay?:1]];
}

- (CGSize)sizeThatFits:(CGSize)size
{
    return [self sizeThatFits:size scope:_scope];
}

- (CGSize)sizeThatFits:(CGSize)size scope:(FSCalendarScope)scope
{
    CGFloat headerHeight = self.preferedHeaderHeight;
    CGFloat weekdayHeight = self.preferedWeekdayHeight;
    CGFloat rowHeight = self.preferedRowHeight;
    CGFloat paddings = weekdayHeight * 0.2;
    
    if (!self.floatingMode) {
        switch (scope) {
            case FSCalendarScopeMonth: {
                CGFloat height = weekdayHeight + headerHeight + 6*rowHeight + paddings;
                return CGSizeMake(size.width, height);
            }
            case FSCalendarScopeWeek: {
                CGFloat height = weekdayHeight + headerHeight + rowHeight + paddings;
                return CGSizeMake(size.width, height);
            }
            default: {
                break;
            }
        }
    } else {
        return CGSizeMake(size.width, self.fs_height);
    }
    return size;
}

#pragma mark - <UICollectionViewDataSource>

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
    NSInteger sections;
    switch (_scope) {
        case FSCalendarScopeMonth:
            sections = [self monthsFromDate:[self beginingOfMonthOfDate:_minimumDate] toDate:_maximumDate] + 1;
            break;
        case FSCalendarScopeWeek:
            sections = [self weeksFromDate:[self beginingOfWeekOfDate:_minimumDate] toDate:_maximumDate] + 1;
            break;
        default: {
            break;
        }
    }
    return sections;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    if (!self.floatingMode) {
        switch (_scope) {
            case FSCalendarScopeMonth: {
                return 42;
            }
            case FSCalendarScopeWeek: {
                return 7;
            }
            default:
                break;
        }
    } else {
        NSDate *currentPage = [self dateByAddingMonths:section toDate:[self beginingOfMonthOfDate:_minimumDate]];
        NSInteger currentWeekday = [self weekdayOfDate:currentPage];
        NSInteger numberOfDaysInMonth = [self numberOfDatesInMonthOfDate:currentPage];
        NSInteger numberOfPlaceholdersForPrev = (currentWeekday-_firstWeekday + 7) % 7;
        NSInteger numberOfRows = (numberOfPlaceholdersForPrev+numberOfDaysInMonth)/7 + ((numberOfPlaceholdersForPrev+numberOfDaysInMonth)%7!=0);
        return numberOfRows * 7;
    }
    return 7;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    FSCalendarCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"cell" forIndexPath:indexPath];
    [self reloadDataForCell:cell atIndexPath:indexPath];
    return cell;
}

- (UICollectionReusableView *)collectionView:(UICollectionView *)collectionView viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath
{
    if (self.floatingMode) {
        if ([kind isEqualToString:UICollectionElementKindSectionHeader]) {
            FSCalendarStickyHeader *stickyHeader = [collectionView dequeueReusableSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:@"header" forIndexPath:indexPath];
            stickyHeader.calendar = self;
            stickyHeader.month =  [self dateByAddingMonths:indexPath.section toDate:[self beginingOfMonthOfDate:_minimumDate]];
            [stickyHeader setNeedsLayout];
            NSArray *allKeys = [_stickyHeaderMapTable.dictionaryRepresentation allKeysForObject:stickyHeader];
            if (allKeys.count) {
                [allKeys enumerateObjectsUsingBlock:^(NSIndexPath *indexPath, NSUInteger idx, BOOL *stop) {
                    [_stickyHeaderMapTable removeObjectForKey:indexPath];
                }];
            }
            [_stickyHeaderMapTable setObject:stickyHeader forKey:indexPath];
            return stickyHeader;
        }
    }
    return [collectionView dequeueReusableSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:@"placeholderHeader" forIndexPath:indexPath];
}

#pragma mark - <UICollectionViewDelegate>

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    FSCalendarCell *cell = (FSCalendarCell *)[collectionView cellForItemAtIndexPath:indexPath];
    cell.dateIsSelected = YES;
    [cell performSelecting];
    NSDate *selectedDate = [self dateForIndexPath:indexPath];
    if (!_supressEvent) {
        [self didSelectDate:selectedDate];
    }
    [self selectCounterpartDate:selectedDate];
}

- (BOOL)collectionView:(UICollectionView *)collectionView shouldSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    FSCalendarCell *cell = (FSCalendarCell *)[collectionView cellForItemAtIndexPath:indexPath];
    if (cell.dateIsPlaceholder) {
        if ([self isDateInRange:cell.date]) {
            [self selectDate:cell.date scrollToDate:YES forPlaceholder:YES];
        } else if (![self date:cell.date sharesSameMonthWithDate:_currentPage]){
            [self scrollToPageForDate:cell.date animated:YES];
        }
        return NO;
    }
    NSDate *targetDate = [self dateForIndexPath:indexPath];
    if ([self isDateSelected:targetDate]) {
        // 这个if几乎不会调用到
        if (self.allowsMultipleSelection) {
            if ([self collectionView:collectionView shouldDeselectItemAtIndexPath:indexPath]) {
                [collectionView deselectItemAtIndexPath:indexPath animated:YES];
                [self collectionView:collectionView didDeselectItemAtIndexPath:indexPath];
            }
        } else {
            // 点击了已经选择的日期，直接触发事件
            [self didSelectDate:self.selectedDate];
        }
        return NO;
    }
    BOOL shouldSelect = YES;
    if (cell.date && [self isDateInRange:cell.date] && !_supressEvent) {
        shouldSelect &= [self shouldSelectDate:cell.date];
    }
    if (shouldSelect) {
        if (!self.allowsMultipleSelection && self.selectedDate) {
            [self deselectDate:self.selectedDate];
        }
    }
    return shouldSelect && [self isDateInRange:cell.date];
}

- (void)collectionView:(UICollectionView *)collectionView didDeselectItemAtIndexPath:(NSIndexPath *)indexPath
{
    if (!self.allowsMultipleSelection) {
        NSIndexPath *selectedIndexPath = [self indexPathForDate:self.selectedDate];
        if (![indexPath isEqual:selectedIndexPath]) {
            [self collectionView:collectionView didDeselectItemAtIndexPath:selectedIndexPath];
            return;
        }
    }
    FSCalendarCell *cell = (FSCalendarCell *)[collectionView cellForItemAtIndexPath:indexPath];
    if (cell) {
        cell.dateIsSelected = NO;
        [cell setNeedsLayout];
    }
    NSDate *selectedDate = cell.date ?: [self dateForIndexPath:indexPath];
    [_selectedDates removeObject:selectedDate];
    [self deselectCounterpartDate:selectedDate];
    [self didDeselectDate:selectedDate];
}

- (BOOL)collectionView:(UICollectionView *)collectionView shouldDeselectItemAtIndexPath:(NSIndexPath *)indexPath
{
    if (!self.allowsMultipleSelection) {
        NSIndexPath *selectedIndexPath = [self indexPathForDate:self.selectedDate];
        if (![indexPath isEqual:selectedIndexPath]) {
            return [self collectionView:collectionView shouldDeselectItemAtIndexPath:selectedIndexPath];
        }
    }
    FSCalendarCell *cell = (FSCalendarCell *)[collectionView cellForItemAtIndexPath:indexPath];
    return [self shouldDeselectDate:(cell.date?:[self dateForIndexPath:indexPath])];
}

- (void)collectionView:(UICollectionView *)collectionView willDisplaySupplementaryView:(UICollectionReusableView *)view forElementKind:(NSString *)elementKind atIndexPath:(NSIndexPath *)indexPath
{
    if ([elementKind isEqualToString:UICollectionElementKindSectionHeader] && [view isKindOfClass:[FSCalendarStickyHeader class]]) {
        [view setNeedsLayout];
    }
}

#pragma mark - <UIScrollViewDelegate>

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    if (_supressEvent || !self.window) {
        return;
    }
    if (self.floatingMode && _collectionView.indexPathsForVisibleItems.count) {
        
        // Do nothing on bouncing
        if (_collectionView.contentOffset.y < 0 || _collectionView.contentOffset.y > _collectionView.contentSize.height-_collectionView.fs_height) {
            return;
        }
        NSDate *currentPage = _currentPage;
        CGPoint significantPoint = CGPointMake(_collectionView.fs_width*0.5,MIN(self.preferedRowHeight*2.75, _collectionView.fs_height*0.5)+_collectionView.contentOffset.y);
        NSIndexPath *significantIndexPath = [_collectionView indexPathForItemAtPoint:significantPoint];
        if (significantIndexPath) {
            currentPage = [self dateByAddingMonths:significantIndexPath.section toDate:[self beginingOfMonthOfDate:_minimumDate]];
        } else {
            __block FSCalendarStickyHeader *significantHeader = nil;
            [_stickyHeaderMapTable.dictionaryRepresentation.allValues enumerateObjectsUsingBlock:^(FSCalendarStickyHeader *header, NSUInteger idx, BOOL *stop) {
                if (CGRectContainsPoint(header.frame, significantPoint)) {
                    significantHeader = header;
                    *stop = YES;
                }
            }];
            if (significantHeader) {
                currentPage = significantHeader.month;
            }
        }
        
        if (![self date:_currentPage sharesSameMonthWithDate:currentPage]) {
            [self willChangeValueForKey:@"currentPage"];
            _currentPage = currentPage;
            [self currentPageDidChange];
            [self didChangeValueForKey:@"currentPage"];
        }
        
    } else if (_collectionView.indexPathsForVisibleItems.count) {
        CGFloat scrollOffset = 0;
        switch (_collectionViewLayout.scrollDirection) {
            case UICollectionViewScrollDirectionHorizontal: {
                scrollOffset = scrollView.contentOffset.x/scrollView.fs_width;
                break;
            }
            case UICollectionViewScrollDirectionVertical: {
                scrollOffset = scrollView.contentOffset.y/scrollView.fs_height;
                break;
            }
            default: {
                break;
            }
        }
        _header.scrollOffset = scrollOffset;
    }
}

- (void)scrollViewWillEndDragging:(UIScrollView *)scrollView withVelocity:(CGPoint)velocity targetContentOffset:(inout CGPoint *)targetContentOffset
{
    if (!_pagingEnabled || !_scrollEnabled) {
        return;
    }
    CGFloat pannedOffset = 0, targetOffset = 0, currentOffset = 0, contentSize = 0;
    switch (_collectionViewLayout.scrollDirection) {
        case UICollectionViewScrollDirectionHorizontal: {
            pannedOffset = [scrollView.panGestureRecognizer translationInView:scrollView].x;
            targetOffset = targetContentOffset->x;
            currentOffset = scrollView.contentOffset.x;
            contentSize = scrollView.fs_width;
            break;
        }
        case UICollectionViewScrollDirectionVertical: {
            pannedOffset = [scrollView.panGestureRecognizer translationInView:scrollView].y;
            targetOffset = targetContentOffset->y;
            currentOffset = scrollView.contentOffset.y;
            contentSize = scrollView.fs_height;
            break;
        }
        default: {
            break;
        }
    }
    BOOL shouldTriggerPageChange = ((pannedOffset < 0 && targetOffset > currentOffset) ||
                                     (pannedOffset > 0 && targetOffset < currentOffset)) && _minimumDate;
    if (shouldTriggerPageChange) {
        [self willChangeValueForKey:@"currentPage"];
        switch (_scope) {
            case FSCalendarScopeMonth: {
                NSDate *minimumPage = [self beginingOfMonthOfDate:_minimumDate];
                _currentPage = [self dateByAddingMonths:targetOffset/contentSize toDate:minimumPage];
                break;
            }
            case FSCalendarScopeWeek: {
                NSDate *minimumPage = [self beginingOfWeekOfDate:_minimumDate];
                _currentPage = [self dateByAddingWeeks:targetOffset/contentSize toDate:minimumPage];
                break;
            }
            default: {
                break;
            }
        }
        [self currentPageDidChange];
        [self didChangeValueForKey:@"currentPage"];
    }
}

#pragma mark - Notification

- (void)orientationDidChange:(NSNotification *)notification
{
    self.interfaceOrientation = [UIApplication sharedApplication].statusBarOrientation;
}

- (void)significantTimeDidChange:(NSNotification *)notification
{
    self.today = [NSDate date];
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

- (void)setScrollDirection:(FSCalendarScrollDirection)scrollDirection
{
    if (_scrollDirection != scrollDirection) {
        _scrollDirection = scrollDirection;
        
        if (self.floatingMode) return;
        
        switch (_scope) {
            case FSCalendarScopeMonth: {
                _supressEvent = YES;

                _collectionViewLayout.scrollDirection = (UICollectionViewScrollDirection)scrollDirection;
                [_collectionViewLayout invalidateLayout];
                _header.scrollDirection = _collectionViewLayout.scrollDirection;
                if (self.hasValidateVisibleLayout) {
                    [_collectionView reloadData];
                    [_header reloadData];
                }
                _needsAdjustingMonthPosition = YES;
                [self setNeedsLayout];
                
                _supressEvent = NO;
                break;
            }
            case FSCalendarScopeWeek: {
                break;
            }
            default: {
                break;
            }
        }
    }
}

- (void)setScope:(FSCalendarScope)scope
{
    [self setScope:scope animated:NO];
}

- (void)setFirstWeekday:(NSUInteger)firstWeekday
{
    if (_firstWeekday != firstWeekday) {
        _firstWeekday = firstWeekday;
        [self invalidateDateTools];
        [self invalidateWeekdaySymbols];
        if (self.hasValidateVisibleLayout) {
            [_collectionView reloadData];
        }
    }
}

- (void)setToday:(NSDate *)today
{
    if (![self isDateInRange:today]) {
        [NSException raise:@"currentDate out of range" format:@""];
    }
    if (![self date:_today sharesSameDayWithDate:today]) {
        _today = [self dateByIgnoringTimeComponentsOfDate:today];
        switch (_scope) {
            case FSCalendarScopeMonth: {
                _currentPage = [self beginingOfMonthOfDate:today];
                break;
            }
            case FSCalendarScopeWeek: {
                _currentPage = [self beginingOfWeekOfDate:today];
                break;
            }
            default: {
                break;
            }
        }
        _needsAdjustingMonthPosition = YES;
        [self setNeedsLayout];
        
        [_collectionView.visibleCells makeObjectsPerformSelector:@selector(setDateIsToday:) withObject:@NO];
        [[_collectionView cellForItemAtIndexPath:[self indexPathForDate:today]] setValue:@YES forKey:@"dateIsToday"];
        [_collectionView.visibleCells makeObjectsPerformSelector:@selector(setNeedsLayout)];
        
    }
}

- (void)setCurrentPage:(NSDate *)currentPage
{
    [self setCurrentPage:currentPage animated:NO];
}

- (void)setCurrentPage:(NSDate *)currentPage animated:(BOOL)animated
{
    if (![self isDateInRange:currentPage]) {
        [NSException raise:@"currentMonth out of range" format:@""];
    }
    if (self.floatingMode || [self isDateInDifferentPage:currentPage]) {
        currentPage = [self dateByIgnoringTimeComponentsOfDate:currentPage];
        [self scrollToPageForDate:currentPage animated:animated];
    }
}

- (void)setHeaderHeight:(CGFloat)headerHeight
{
    if (_headerHeight != headerHeight) {
        _headerHeight = headerHeight;
        _needsAdjustingViewFrame = YES;
        [self setNeedsLayout];
    }
}

- (void)setWeekdayHeight:(CGFloat)weekdayHeight
{
    if (_weekdayHeight != weekdayHeight) {
        _weekdayHeight = weekdayHeight;
        _needsAdjustingViewFrame = YES;
        [self setNeedsLayout];
    }
}

- (void)setDataSource:(id<FSCalendarDataSource>)dataSource
{
    if (![_dataSource isEqual:dataSource]) {
        _dataSource = dataSource;
        _minimumDate = self.minimumDateForCalendar;
        _maximumDate = self.maximumDateForCalendar;
    }
}

- (void)setLocale:(NSLocale *)locale
{
    if (![_locale isEqual:locale]) {
        _locale = locale;
        [self invalidateDateTools];
        [self invalidateWeekdaySymbols];
        if (self.hasValidateVisibleLayout) {
            [self invalidateHeaders];
        }
    }
}

- (void)setIdentifier:(NSString *)identifier
{
    if (![identifier isEqualToString:_calendar.calendarIdentifier]) {
        _calendar = [NSCalendar calendarWithIdentifier:identifier];
        [self invalidateDateTools];
        [self invalidateWeekdaySymbols];
        if (self.hasValidateVisibleLayout) {
            [self reloadData];
        }
        [self scrollToPageForDate:_today animated:YES];
    }
}

- (NSString *)identifier
{
    return _calendar.calendarIdentifier;
}

- (void)setAllowsMultipleSelection:(BOOL)allowsMultipleSelection
{
    _collectionView.allowsMultipleSelection = allowsMultipleSelection;
}

- (BOOL)allowsMultipleSelection
{
    return _collectionView.allowsMultipleSelection;
}

- (void)setAllowsSelection:(BOOL)allowsSelection
{
    _collectionView.allowsSelection = allowsSelection;
}

- (BOOL)allowsSelection
{
    return _collectionView.allowsSelection;
}

- (void)setPagingEnabled:(BOOL)pagingEnabled
{
    if (_pagingEnabled != pagingEnabled) {
        _pagingEnabled = pagingEnabled;
        
        [self invalidateLayout];
    }
}

- (void)setScrollEnabled:(BOOL)scrollEnabled
{
    if (_scrollEnabled != scrollEnabled) {
        _scrollEnabled = scrollEnabled;
        
        _collectionView.scrollEnabled = scrollEnabled;
        _header.scrollEnabled = scrollEnabled;
        
        [self invalidateLayout];
    }
}

- (void)setInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    if (_interfaceOrientation != interfaceOrientation) {
        _interfaceOrientation = interfaceOrientation;
        
        if (interfaceOrientation != UIInterfaceOrientationUnknown) {
            _needsAdjustingViewFrame = YES;
            _needsAdjustingMonthPosition = YES;
            _needsAdjustingTextSize = YES;
            [_collectionViewLayout invalidateLayout]; // Necessary in Swift. Anyone can tell why?
            [_stickyHeaderMapTable.dictionaryRepresentation.allValues setValue:@YES forKey:@"needsAdjustingFrames"];
            _preferedWeekdayHeight = FSCalendarAutomaticDimension;
            _preferedRowHeight = FSCalendarAutomaticDimension;
            _preferedHeaderHeight = FSCalendarAutomaticDimension;
            [self setNeedsLayout];
        }

    }
}

- (NSDate *)selectedDate
{
    return _selectedDates.lastObject;
}

- (NSArray *)selectedDates
{
    return [NSArray arrayWithArray:_selectedDates];
}

- (CGFloat)preferedHeaderHeight
{
    if (_headerHeight == FSCalendarAutomaticDimension) {
        if (_preferedWeekdayHeight == FSCalendarAutomaticDimension) {
            if (!self.floatingMode) {
                CGFloat divider = _scope == FSCalendarScopeMonth ? FSCalendarStandardMonthlyPageHeight : FSCalendarStandardWeeklyPageHeight;
                _preferedHeaderHeight = (FSCalendarStandardHeaderHeight/divider)*self.fs_height;
            } else {
                _preferedHeaderHeight = FSCalendarStandardHeaderHeight*MAX(1, FSCalendarDeviceIsIPad*1.5);
            }
        }
        return _preferedHeaderHeight;
    }
    return _headerHeight;
}

- (CGFloat)preferedWeekdayHeight
{
    if (_weekdayHeight == FSCalendarAutomaticDimension) {
        if (_preferedWeekdayHeight == FSCalendarAutomaticDimension) {
            if (!self.floatingMode) {
                CGFloat divider = _scope == FSCalendarScopeMonth ? FSCalendarStandardMonthlyPageHeight : FSCalendarStandardWeeklyPageHeight;
                _preferedWeekdayHeight = (FSCalendarStandardWeekdayHeight/divider)*self.fs_height;
            } else {
                _preferedWeekdayHeight = FSCalendarStandardWeekdayHeight*MAX(1, FSCalendarDeviceIsIPad*1.5);
            }
        }
        return _preferedWeekdayHeight;
    }
    return _weekdayHeight;
}

- (CGFloat)preferedRowHeight
{
    if (_preferedRowHeight == FSCalendarAutomaticDimension) {
        CGFloat headerHeight = self.preferedHeaderHeight;
        CGFloat weekdayHeight = self.preferedWeekdayHeight;
        CGFloat contentHeight = self.fs_height-headerHeight-weekdayHeight;
        CGFloat padding = weekdayHeight*0.1;
        if (!self.floatingMode) {
            switch (_scope) {
                case FSCalendarScopeMonth: {
                    _preferedRowHeight = (contentHeight-padding*2)/6.0;
                    break;
                }
                case FSCalendarScopeWeek: {
                    _preferedRowHeight = contentHeight-padding*2;
                    break;
                }
                default: {
                    break;
                }
            }
        } else {
            _preferedRowHeight = FSCalendarStandardRowHeight*MAX(1, FSCalendarDeviceIsIPad*1.5);
        }
    }
    return _preferedRowHeight;
}

- (id<FSCalendarDelegateAppearance>)delegateAppearance
{
    if (_delegate && [_delegate conformsToProtocol:@protocol(FSCalendarDelegateAppearance)]) {
        return (id<FSCalendarDelegateAppearance>)_delegate;
    }
    return nil;
}

- (BOOL)floatingMode
{
    return _scrollEnabled && !_pagingEnabled;
}

#pragma mark - Public

- (void)reloadData
{
    NSDate *minimumDate = self.minimumDateForCalendar;
    NSDate *maximumDate = self.maximumDateForCalendar;
    if (![self date:minimumDate sharesSameMonthWithDate:_minimumDate] || ![self date:maximumDate sharesSameMonthWithDate:_maximumDate]) {
        
        _minimumDate = minimumDate;
        _maximumDate = maximumDate;
        [_collectionView reloadData];
        [_header.collectionView reloadData];
        [self setNeedsLayout];
        
    } else {
        [self reloadVisibleCells];
    }
    
    [_weekdays setValue:[UIFont systemFontOfSize:_appearance.weekdayTextSize] forKey:@"font"];
    [self invalidateHeaders];
    [self invalidateWeekdaySymbols];
}

- (void)setScope:(FSCalendarScope)scope animated:(BOOL)animated
{
    if (_scope != scope) {
        
#define m_set_scope \
        [self willChangeValueForKey:@"scope"]; \
        _scope = scope; \
        [self didChangeValueForKey:@"scope"]; \

        if (self.floatingMode) {
            m_set_scope
            return;
        }
        
        FSCalendarScope prevScope = _scope;
        
        if (!self.hasValidateVisibleLayout && prevScope == FSCalendarScopeMonth && scope == FSCalendarScopeWeek) {
            m_set_scope
            _needsLayoutForWeekMode = YES;
            [self setNeedsLayout];
            return;
        }
        
        [self performScopeTransitionFromScope:prevScope toScope:scope animated:animated];
        
        m_set_scope
        
    }
}

- (void)performScopeTransitionFromScope:(FSCalendarScope)fromScope toScope:(FSCalendarScope)toScope animated:(BOOL)animated
{
    BOOL weekToMonth = fromScope == FSCalendarScopeWeek && toScope == FSCalendarScopeMonth;
    BOOL monthToWeek = !weekToMonth;
    void(^completion)(void) = ^{
        switch (toScope) {
            case FSCalendarScopeMonth: {
                _collectionViewLayout.scrollDirection = (UICollectionViewScrollDirection)_scrollDirection;
                _header.scrollDirection = _collectionViewLayout.scrollDirection;
                break;
            }
            case FSCalendarScopeWeek: {
                _collectionViewLayout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
                _header.scrollDirection = _collectionViewLayout.scrollDirection;
                break;
            }
            default: {
                break;
            }
        }
        
        [_collectionView reloadData];
        [_header reloadData];
        _needsAdjustingMonthPosition = YES;
        _needsAdjustingViewFrame = YES;
        [self setNeedsLayout];
        
    };
    
    NSInteger rowNumber = -1;
    
    if (weekToMonth) {
        NSDate *currentPage = _currentPage;
        if (rowNumber == -1) {
            NSDate *firstDayOfMonth = [self beginingOfMonthOfDate:[self dateByAddingMonths:1 toDate:currentPage]];
            NSInteger weekdayOfFirstDay = [self weekdayOfDate:firstDayOfMonth];
            NSInteger numberOfPlaceholdersForPrev = ((weekdayOfFirstDay - _firstWeekday) + 7) % 7 ?: 7;
            NSDate *firstDateOfPage = [self dateBySubstractingDays:numberOfPlaceholdersForPrev fromDate:firstDayOfMonth];
            for (int i = 0; i < 6; i++) {
                NSDate *currentRow = [self dateByAddingWeeks:i toDate:firstDateOfPage];
                if ([self date:currentRow sharesSameDayWithDate:currentPage]) {
                    rowNumber = i;
                    _currentPage = firstDayOfMonth;
                    break;
                }
            }
        }
        if (rowNumber == -1) {
            NSDate *firstDayOfMonth = [self beginingOfMonthOfDate:currentPage];
            NSInteger weekdayOfFirstDay = [self weekdayOfDate:firstDayOfMonth];
            NSInteger numberOfPlaceholdersForPrev = ((weekdayOfFirstDay - _firstWeekday) + 7) % 7 ?: 7;
            NSDate *firstDateOfPage = [self dateBySubstractingDays:numberOfPlaceholdersForPrev fromDate:firstDayOfMonth];
            for (int i = 0; i < 6; i++) {
                NSDate *currentRow = [self dateByAddingWeeks:i toDate:firstDateOfPage];
                if ([self date:currentRow sharesSameDayWithDate:currentPage]) {
                    rowNumber = i;
                    _currentPage = firstDayOfMonth;
                    break;
                }
            }
        }
        _currentPage = _currentPage ?: _today;
        completion();
        
    } else {
        
        NSDate *minimumPage = [self beginingOfMonthOfDate:_minimumDate];
        NSInteger visibleSection = [self monthsFromDate:minimumPage toDate:_currentPage];
        NSIndexPath *firstIndexPath = [NSIndexPath indexPathForItem:0 inSection:visibleSection];
        NSDate *firstDateForWeekMode = [self dateForIndexPath:firstIndexPath scope:fromScope];
        _currentPage = firstDateForWeekMode;
        
    }
    
    void(^resizeBlock)() = ^{
        
        CGSize size = [self sizeThatFits:self.frame.size scope:toScope];
        void(^transitionCompletion)() = ^{
            _maskLayer.path = [UIBezierPath bezierPathWithRect:(CGRect){CGPointZero,size}].CGPath;
            if (monthToWeek) {
                if (animated) {
                    dispatch_async(dispatch_get_main_queue(), ^{
                        completion();
                    });
                } else {
                    completion();
                }
            }
            _contentView.clipsToBounds = NO;
            _daysContainer.clipsToBounds = NO;
        };
        
        if (animated) {
            CABasicAnimation *path = [CABasicAnimation animationWithKeyPath:@"path"];
            path.fromValue = (id)_maskLayer.path;
            path.toValue = (id)[UIBezierPath bezierPathWithRect:(CGRect){CGPointZero,size}].CGPath;
            path.duration = 0.3;
            path.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
            
            if (weekToMonth) {
                _collectionView.transform = CGAffineTransformMakeTranslation(0, -rowNumber*self.preferedRowHeight);
            }
            [CATransaction begin];
            [CATransaction setCompletionBlock:transitionCompletion];
            [CATransaction setAnimationDuration:0.3];

            _needsAdjustingViewFrame = weekToMonth;
            
            [_maskLayer addAnimation:path forKey:@"path"];
            
            [CATransaction commit];
            
            if (_delegate && [_delegate respondsToSelector:@selector(calendarCurrentScopeWillChange:animated:)]) {
                [UIView beginAnimations:@"delegateTranslation" context:"translation"];
                [UIView setAnimationCurve:UIViewAnimationCurveEaseInOut];
                [UIView setAnimationDuration:0.3];
                _collectionView.transform = CGAffineTransformIdentity;
                _bottomBorder.frame = CGRectMake(0, size.height, self.fs_width, 1);
                [_delegate calendarCurrentScopeWillChange:self animated:animated];
                [UIView commitAnimations];
            }
            
        } else {
            
            _needsAdjustingViewFrame = YES;
            _bottomBorder.frame = CGRectMake(0, size.height, self.fs_width, 1);

            transitionCompletion();
            
            if (_delegate && [_delegate respondsToSelector:@selector(calendarCurrentScopeWillChange:animated:)]) {
                [_delegate calendarCurrentScopeWillChange:self animated:animated];
            }
        }
    };
    
    _contentView.clipsToBounds = YES;
    _daysContainer.clipsToBounds = YES;
    
    dispatch_async(dispatch_get_main_queue(), ^{
        resizeBlock();
    });
    
}

- (void)selectDate:(NSDate *)date
{
    [self selectDate:date scrollToDate:YES];
}

- (void)selectDate:(NSDate *)date scrollToDate:(BOOL)scrollToDate
{
    [self selectDate:date scrollToDate:scrollToDate forPlaceholder:NO];
}

- (void)deselectDate:(NSDate *)date
{
    date = [self dateByIgnoringTimeComponentsOfDate:date];
    if (![_selectedDates containsObject:date]) {
        return;
    }
    [_selectedDates removeObject:date];
    NSIndexPath *indexPath = [self indexPathForDate:date];
    if ([_collectionView.indexPathsForSelectedItems containsObject:indexPath]) {
        [_collectionView deselectItemAtIndexPath:indexPath animated:YES];
        FSCalendarCell *cell = (FSCalendarCell *)[_collectionView cellForItemAtIndexPath:indexPath];
        cell.dateIsSelected = NO;
        [cell setNeedsLayout];
        [self deselectCounterpartDate:date];
    }
}

- (void)selectDate:(NSDate *)date scrollToDate:(BOOL)scrollToDate forPlaceholder:(BOOL)forPlaceholder
{
    if (!self.allowsSelection) {
        return;
    }
    if (![self isDateInRange:date]) {
        [NSException raise:@"selectedDate out of range" format:@""];
    }
    NSDate *targetDate = [self dateByIgnoringTimeComponentsOfDate:date];
    NSIndexPath *targetIndexPath = [self indexPathForDate:targetDate];
    
    BOOL shouldSelect = !_supressEvent;
    // 跨月份点击
    if (forPlaceholder) {
        if (self.allowsMultipleSelection) {
            // 处理多选模式
            if ([self isDateSelected:targetDate]) {
                // 已经选中的日期，是否应该反选，如果不应该，则不切换月份，不选中
                BOOL shouldDeselect = [self shouldDeselectDate:targetDate];
                if (!shouldDeselect) {
                    return;
                }
            } else {
                // 未选中的日期，判断是否应该选中，不应该选中则不切换月份，不选中
                shouldSelect &= [self shouldSelectDate:targetDate];
                if (!shouldSelect) {
                    return;
                }
                [_collectionView selectItemAtIndexPath:targetIndexPath animated:YES scrollPosition:UICollectionViewScrollPositionNone];
                [self collectionView:_collectionView didSelectItemAtIndexPath:targetIndexPath];
            }
        } else {
            // 处理单选模式
            shouldSelect &= [self shouldSelectDate:targetDate];
            if (shouldSelect) {
                if ([self isDateSelected:targetDate]) {
                    [self didSelectDate:targetDate];
                } else {
                    NSDate *selectedDate = self.selectedDate;
                    if (selectedDate) {
                        [self deselectDate:selectedDate];
                    }
                    [_collectionView selectItemAtIndexPath:targetIndexPath animated:YES scrollPosition:UICollectionViewScrollPositionNone];
                    [self collectionView:_collectionView didSelectItemAtIndexPath:targetIndexPath];
                }
            } else {
                return;
            }
        }
        
    } else if (![self isDateSelected:targetDate]){
        // 调用代码选中未选中日期
        if (self.selectedDate && !self.allowsMultipleSelection) {
            [self deselectDate:self.selectedDate];
        }
        [_collectionView selectItemAtIndexPath:targetIndexPath animated:YES scrollPosition:UICollectionViewScrollPositionNone];
        FSCalendarCell *cell = (FSCalendarCell *)[_collectionView cellForItemAtIndexPath:targetIndexPath];
        [cell performSelecting];
        [self enqueueSelectedDate:targetDate];
        [self selectCounterpartDate:targetDate];
        
    } else if (![_collectionView.indexPathsForSelectedItems containsObject:targetIndexPath]) {
        // 调用代码选中已选中日期
        [_collectionView selectItemAtIndexPath:targetIndexPath animated:NO scrollPosition:UICollectionViewScrollPositionNone];
    }
    
    if (scrollToDate) {
        // 如果跨月份点击日期，并且该日期不应该选中，则不跳转页面，其他情况均跳转
        if (forPlaceholder && !shouldSelect) {
            return;
        }
        [self scrollToPageForDate:targetDate animated:YES];
    }
}

#pragma mark - Private methods

- (void)scrollToDate:(NSDate *)date
{
    [self scrollToDate:date animated:NO];
}

- (void)scrollToDate:(NSDate *)date animated:(BOOL)animated
{
    if (!_minimumDate || !_maximumDate) {
        return;
    }
    animated &= _scrollEnabled; // No animation if _scrollEnabled == NO;
    
    _supressEvent = !animated;
    NSDate * targetDate = [self daysFromDate:_minimumDate toDate:date] < 0 ? _minimumDate : date;
    targetDate = [self daysFromDate:_maximumDate toDate:targetDate] > 0 ? _maximumDate : targetDate;
    NSInteger scrollOffset = 0;
    switch (_scope) {
        case FSCalendarScopeMonth: {
            scrollOffset = [self monthsFromDate:[self beginingOfMonthOfDate:_minimumDate] toDate:targetDate];
            break;
        }
        case FSCalendarScopeWeek: {
            scrollOffset = [self weeksFromDate:[self beginingOfWeekOfDate:_minimumDate] toDate:targetDate];
            break;
        }
        default: {
            break;
        }
    }
    
    if (!self.floatingMode) {
        
        switch (_collectionViewLayout.scrollDirection) {
            case UICollectionViewScrollDirectionVertical: {
                [_collectionView setContentOffset:CGPointMake(0, scrollOffset * _collectionView.fs_height) animated:animated];
                break;
            }
            case UICollectionViewScrollDirectionHorizontal: {
                [_collectionView setContentOffset:CGPointMake(scrollOffset * _collectionView.fs_width, 0) animated:animated];
                break;
            }
            default: {
                break;
            }
        }
        
    } else {
        // 全屏模式中，切换页面时需要将该月份提升到视图最上方
        CGRect headerFrame = [_collectionViewLayout layoutAttributesForSupplementaryViewOfKind:UICollectionElementKindSectionHeader atIndexPath:[NSIndexPath indexPathForItem:0 inSection:scrollOffset]].frame;
        if (self.hasValidateVisibleLayout) {
            CGPoint targetOffset = CGPointMake(0, MIN(headerFrame.origin.y,_collectionView.contentSize.height-_collectionView.fs_bottom));
            [_collectionView setContentOffset:targetOffset animated:animated];
        } else {
            // 如果在loadView或者viewDidLoad中调用需要切换月份的方法, 这时UICollectionView并没有准备好自己的单元格和空间大小，这时不能直接调用setContentOffset,而是等到在layoutSubviews之后再去调用
            _currentPage = targetDate;
            _needsAdjustingMonthPosition = YES;
            [self setNeedsLayout];
        }
        
    }
    
    if (_header && !animated) {
        _header.scrollOffset = scrollOffset;
    }
    _supressEvent = NO;
}

- (void)scrollToPageForDate:(NSDate *)date animated:(BOOL)animated
{
    if (!_collectionView.tracking) {
        if (!self.floatingMode) {
            if ([self isDateInDifferentPage:date]) {
                [self willChangeValueForKey:@"currentPage"];
                switch (_scope) {
                    case FSCalendarScopeMonth: {
                        _currentPage = [self beginingOfMonthOfDate:date];
                        break;
                    }
                    case FSCalendarScopeWeek: {
                        _currentPage = [self beginingOfWeekOfDate:date];
                        break;
                    }
                    default: {
                        break;
                    }
                }
                if (!_supressEvent && self.hasValidateVisibleLayout) {
                    _supressEvent = YES;
                    [self currentPageDidChange];
                    _supressEvent = NO;
                }
                [self didChangeValueForKey:@"currentPage"];
            }
            [self scrollToDate:_currentPage animated:animated];
        } else {
            [self scrollToDate:[self beginingOfMonthOfDate:date] animated:animated];
        }
    }
}

- (NSDate *)dateForIndexPath:(NSIndexPath *)indexPath scope:(FSCalendarScope)scope
{
    switch (scope) {
        case FSCalendarScopeMonth: {
            NSDate *currentPage = [self dateByAddingMonths:indexPath.section toDate:[self beginingOfMonthOfDate:_minimumDate]];
            NSInteger currentWeekday = [self weekdayOfDate:currentPage];
            NSInteger numberOfPlaceholdersForPrev = ((currentWeekday- _firstWeekday) + 7) % 7 ?: (7 * !self.floatingMode);
            NSDate *firstDateOfPage = [self dateBySubstractingDays:numberOfPlaceholdersForPrev fromDate:currentPage];
            switch (_collectionViewLayout.scrollDirection) {
                case UICollectionViewScrollDirectionHorizontal: {
                    NSUInteger rows = indexPath.item % 6;
                    NSUInteger columns = indexPath.item / 6;
                    NSUInteger daysOffset = 7*rows + columns;
                    return [self dateByAddingDays:daysOffset toDate:firstDateOfPage];
                }
                case UICollectionViewScrollDirectionVertical: {
                    NSUInteger daysOffset = indexPath.item;
                    return [self dateByAddingDays:daysOffset toDate:firstDateOfPage];
                }
                default:
                    break;
            }
            break;
        }
        case FSCalendarScopeWeek: {
            NSDate *currentPage = [self dateByAddingWeeks:indexPath.section toDate:[self beginingOfWeekOfDate:_minimumDate]];
            return [self dateByAddingDays:indexPath.item toDate:currentPage];
        }
        default: {
            break;
        }
    }
    return nil;
}

- (NSDate *)dateForIndexPath:(NSIndexPath *)indexPath
{
    return [self dateForIndexPath:indexPath scope:_scope];
}

- (NSIndexPath *)indexPathForDate:(NSDate *)date scope:(FSCalendarScope)scope
{
    NSInteger item = 0;
    NSInteger section = 0;
    switch (scope) {
        case FSCalendarScopeMonth: {
            section = [self monthsFromDate:[self beginingOfMonthOfDate:_minimumDate] toDate:date];
            NSDate *firstDayOfMonth = [self beginingOfMonthOfDate:date];
            NSInteger weekdayOfFirstDay = [self weekdayOfDate:firstDayOfMonth];
            NSInteger numberOfPlaceholdersForPrev = ((weekdayOfFirstDay- _firstWeekday) + 7) % 7 ?: (7 * !self.floatingMode);
            NSDate *firstDateOfPage = [self dateBySubstractingDays:numberOfPlaceholdersForPrev fromDate:firstDayOfMonth];
            switch (_collectionViewLayout.scrollDirection) {
                case UICollectionViewScrollDirectionHorizontal: {
                    NSInteger vItem = [self daysFromDate:firstDateOfPage toDate:date];
                    NSInteger rows = vItem/7;
                    NSInteger columns = vItem%7;
                    item = columns*6 + rows;
                    break;
                }
                case UICollectionViewScrollDirectionVertical: {
                    item = [self daysFromDate:firstDateOfPage toDate:date];
                    break;
                }
                default:
                    break;
            }
            break;
        }
        case FSCalendarScopeWeek: {
            section = [self weeksFromDate:[self beginingOfWeekOfDate:_minimumDate] toDate:date];
            item = (([self weekdayOfDate:date] - _firstWeekday) + 7) % 7;
            break;
        }
        default: {
            break;
        }
    }
    return [NSIndexPath indexPathForItem:item inSection:section];
}

- (NSIndexPath *)indexPathForDate:(NSDate *)date
{
    return [self indexPathForDate:date scope:_scope];
}

- (BOOL)isDateInRange:(NSDate *)date
{
    BOOL flag = [self daysFromDate:_minimumDate toDate:date] >= 0;
    flag &= [self daysFromDate:_maximumDate toDate:date] <= 0;
    return flag;
}

- (BOOL)isDateSelected:(NSDate *)date
{
    return [_selectedDates containsObject:date] || [_collectionView.indexPathsForSelectedItems containsObject:[self indexPathForDate:date]];
}

- (BOOL)isDateInDifferentPage:(NSDate *)date
{
    if (self.floatingMode) {
        return ![self date:date sharesSameMonthWithDate:_currentPage];
    }
    switch (_scope) {
        case FSCalendarScopeMonth:
            return ![self date:date sharesSameMonthWithDate:_currentPage];
        case FSCalendarScopeWeek:
            return ![self date:date sharesSameWeekWithDate:_currentPage];
    }
}

- (BOOL)hasValidateVisibleLayout
{
    return self.superview  && !CGSizeEqualToSize(_collectionView.frame.size, CGSizeZero) && !CGSizeEqualToSize(_collectionView.contentSize, CGSizeZero);
}

- (void)invalidateDateTools
{
    _calendar.locale = _locale;
    _calendar.timeZone = _timeZone;
    _calendar.firstWeekday = _firstWeekday;
    _components.calendar = _calendar;
    _components.timeZone = _timeZone;
    _formatter.calendar = _calendar;
    _formatter.timeZone = _timeZone;
    _formatter.locale = _locale;
}

- (void)invalidateLayout
{
    if (!self.floatingMode) {
        
        if (!_header) {
            
            FSCalendarHeader *header = [[FSCalendarHeader alloc] initWithFrame:CGRectZero];
            header.calendar = self;
            header.scrollEnabled = _scrollEnabled;
            [_contentView addSubview:header];
            self.header = header;
            
        }
        
        if (_scrollEnabled) {
            if (!_deliver) {
                FSCalendarHeaderTouchDeliver *deliver = [[FSCalendarHeaderTouchDeliver alloc] initWithFrame:CGRectZero];
                deliver.header = _header;
                deliver.calendar = self;
                [_contentView addSubview:deliver];
                self.deliver = deliver;
            }
        } else if (_deliver) {
            [_deliver removeFromSuperview];
        }
        
        if (!_weekdays.count) {
            NSArray *weekSymbols = self.calendar.shortStandaloneWeekdaySymbols;
            _weekdays = [NSMutableArray arrayWithCapacity:weekSymbols.count];
            UIFont *weekdayFont = [UIFont systemFontOfSize:_appearance.weekdayTextSize];
            for (int i = 0; i < weekSymbols.count; i++) {
                UILabel *weekdayLabel = [[UILabel alloc] initWithFrame:CGRectZero];
                weekdayLabel.text = weekSymbols[i];
                weekdayLabel.textAlignment = NSTextAlignmentCenter;
                weekdayLabel.font = weekdayFont;
                weekdayLabel.textColor = _appearance.weekdayTextColor;
                [_weekdays addObject:weekdayLabel];
                [_contentView addSubview:weekdayLabel];
            }
        }
        
        _collectionView.pagingEnabled = YES;
        _collectionViewLayout.scrollDirection = (UICollectionViewScrollDirection)self.scrollDirection;
        
    } else {
        
        if (_header) {
            [_header removeFromSuperview];
        }
        if (_weekdays.count) {
            [_weekdays makeObjectsPerformSelector:@selector(removeFromSuperview)];
            [_weekdays removeAllObjects];
        }
        
        _collectionView.pagingEnabled = NO;
        _collectionViewLayout.scrollDirection = UICollectionViewScrollDirectionVertical;
        
        [self deselectCounterpartDate:nil];
    }
    
    _preferedHeaderHeight = FSCalendarAutomaticDimension;
    _preferedWeekdayHeight = FSCalendarAutomaticDimension;
    _preferedRowHeight = FSCalendarAutomaticDimension;
    _needsAdjustingViewFrame = YES;
    [self setNeedsLayout];
}

- (void)invalidateWeekdaySymbols
{
    BOOL useVeryShortWeekdaySymbols = (_appearance.caseOptions & (15<<4) ) == FSCalendarCaseOptionsWeekdayUsesSingleUpperCase;
    NSArray *weekdaySymbols = useVeryShortWeekdaySymbols ? _calendar.veryShortStandaloneWeekdaySymbols : _calendar.shortStandaloneWeekdaySymbols;
    BOOL useDefaultWeekdayCase = (_appearance.caseOptions & (15<<4) ) == FSCalendarCaseOptionsWeekdayUsesDefaultCase;
    [_weekdays enumerateObjectsUsingBlock:^(UILabel *label, NSUInteger index, BOOL *stop) {
        index += _firstWeekday-1;
        index %= 7;
        label.text = useDefaultWeekdayCase ? weekdaySymbols[index] : [weekdaySymbols[index] uppercaseString];
    }];
    if (_stickyHeaderMapTable.count) {
        [_stickyHeaderMapTable.objectEnumerator.allObjects makeObjectsPerformSelector:@selector(reloadData)];
    }
}

- (void)invalidateHeaders
{
    [_header.collectionView reloadData];
    if (_stickyHeaderMapTable.count) {
        [_stickyHeaderMapTable.objectEnumerator.allObjects makeObjectsPerformSelector:@selector(reloadData)];
    }
}

- (void)invalidateAppearanceForCell:(FSCalendarCell *)cell
{
    cell.preferedSelectionColor = [self preferedSelectionColorForDate:cell.date];
    cell.preferedTitleDefaultColor = [self preferedTitleDefaultColorForDate:cell.date];
    cell.preferedTitleSelectionColor = [self preferedTitleSelectionColorForDate:cell.date];
    if (cell.subtitle) {
        cell.preferedSubtitleDefaultColor = [self preferedSubtitleDefaultColorForDate:cell.date];
        cell.preferedSubtitleSelectionColor = [self preferedSubtitleSelectionColorForDate:cell.date];
    }
    if (cell.hasEvent) cell.preferedEventColor = [self preferedEventColorForDate:cell.date];
    cell.preferedBorderDefaultColor = [self preferedBorderDefaultColorForDate:cell.date];
    cell.preferedBorderSelectionColor = [self preferedBorderSelectionColorForDate:cell.date];
    cell.preferedCellShape = [self preferedCellShapeForDate:cell.date];
    
    [cell setNeedsLayout];
}

- (void)reloadDataForCell:(FSCalendarCell *)cell atIndexPath:(NSIndexPath *)indexPath
{
    cell.calendar = self;
    cell.date = [self dateForIndexPath:indexPath];
    
    cell.image = [self imageForDate:cell.date];
    cell.hasEvent = [self hasEventForDate:cell.date];
    cell.subtitle  = [self subtitleForDate:cell.date];
    cell.dateIsSelected = [_selectedDates containsObject:cell.date];
    cell.dateIsToday = [cell.date isEqual:_today];
    switch (_scope) {
        case FSCalendarScopeMonth: {
            NSDate *firstPage = [self beginingOfMonthOfDate:_minimumDate];
            NSDate *month = [self dateByAddingMonths:indexPath.section toDate:firstPage];
            cell.dateIsPlaceholder = ![self date:cell.date sharesSameMonthWithDate:month] || ![self isDateInRange:cell.date];
            if (cell.dateIsPlaceholder) {
                cell.dateIsSelected &= _pagingEnabled;
                cell.dateIsToday &= _pagingEnabled;
            }
            break;
        }
        case FSCalendarScopeWeek: {
            if (_pagingEnabled) {
                cell.dateIsPlaceholder = ![self isDateInRange:cell.date];
            }
            break;
        }
    }
    
    [self invalidateAppearanceForCell:cell];
    if (cell.dateIsSelected && !cell.dateIsPlaceholder) {
        [_collectionView selectItemAtIndexPath:indexPath animated:NO scrollPosition:UICollectionViewScrollPositionNone];
    } else if ([_collectionView.indexPathsForSelectedItems containsObject:indexPath]) {
        [_collectionView deselectItemAtIndexPath:indexPath animated:NO];
    }
    [cell setNeedsLayout];
}

- (void)reloadVisibleCells
{
    [_collectionView.indexPathsForVisibleItems enumerateObjectsUsingBlock:^(NSIndexPath *indexPath, NSUInteger idx, BOOL *stop) {
        FSCalendarCell *cell = (FSCalendarCell *)[_collectionView cellForItemAtIndexPath:indexPath];
        [self reloadDataForCell:cell atIndexPath:indexPath];
    }];
}

- (void)selectCounterpartDate:(NSDate *)date
{
    if (!self.floatingMode) {
        [_collectionView.visibleCells enumerateObjectsUsingBlock:^(FSCalendarCell *cell, NSUInteger idx, BOOL *stop) {
            if (cell.dateIsPlaceholder && [self date:cell.date sharesSameDayWithDate:date] && !cell.dateIsSelected) {
                cell.dateIsSelected = YES;
                [cell setNeedsLayout];
                *stop = YES;
            }
        }];
    }
}

- (void)deselectCounterpartDate:(NSDate *)date
{
    if (self.floatingMode) {
        [_collectionView.visibleCells enumerateObjectsUsingBlock:^(FSCalendarCell *cell, NSUInteger index, BOOL *stop) {
            if (cell.dateIsPlaceholder && cell.dateIsSelected) {
                cell.dateIsSelected = NO;
                [_collectionView deselectItemAtIndexPath:[_collectionView indexPathForCell:cell] animated:NO];
                [cell setNeedsLayout];
            }
        }];
    } else {
        [_collectionView.visibleCells enumerateObjectsUsingBlock:^(FSCalendarCell *cell, NSUInteger idx, BOOL *stop) {
            if (cell.dateIsPlaceholder && [self date:cell.date sharesSameDayWithDate:date] && cell.dateIsSelected) {
                cell.dateIsSelected = NO;
                [_collectionView deselectItemAtIndexPath:[_collectionView indexPathForCell:cell] animated:NO];
                [cell setNeedsLayout];
                *stop = YES;
            }
        }];
    }
}

- (void)enqueueSelectedDate:(NSDate *)date
{
    if (!self.allowsMultipleSelection) {
        [_selectedDates removeAllObjects];
    }
    if (![_selectedDates containsObject:date]) {
        [_selectedDates addObject:date];
    }
}

- (NSArray *)visibleStickyHeaders
{
    return _stickyHeaderMapTable.objectEnumerator.allObjects;
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
    [self enqueueSelectedDate:date];
    if (_delegate && [_delegate respondsToSelector:@selector(calendar:didSelectDate:)]) {
        [_delegate calendar:self didSelectDate:date];
    }
}

- (BOOL)shouldDeselectDate:(NSDate *)date
{
    if (_delegate && [_delegate respondsToSelector:@selector(calendar:shouldDeselectDate:)]) {
       return [_delegate calendar:self shouldDeselectDate:date];
    }
    return YES;
}

- (void)didDeselectDate:(NSDate *)date
{
    if (_delegate && [_delegate respondsToSelector:@selector(calendar:didDeselectDate:)]) {
        [_delegate calendar:self didDeselectDate:date];
    }
}

- (void)currentPageDidChange
{
    if (_delegate && [_delegate respondsToSelector:@selector(calendarCurrentPageDidChange:)]) {
        [_delegate calendarCurrentPageDidChange:self];
    }
#pragma GCC diagnostic push
#pragma GCC diagnostic ignored "-Wdeprecated-declarations"
    else if (_delegate && [_delegate respondsToSelector:@selector(calendarCurrentMonthDidChange:)]) {
        [_delegate calendarCurrentMonthDidChange:self];
    }
#pragma GCC diagnostic pop
}

- (UIColor *)preferedSelectionColorForDate:(NSDate *)date
{
    if (self.delegateAppearance && [self.delegateAppearance respondsToSelector:@selector(calendar:appearance:selectionColorForDate:)]) {
        UIColor *color = [self.delegateAppearance calendar:self appearance:self.appearance selectionColorForDate:date];
        return color;
    }
    return nil;
}

- (UIColor *)preferedTitleDefaultColorForDate:(NSDate *)date
{
    if (self.delegateAppearance && [self.delegateAppearance respondsToSelector:@selector(calendar:appearance:titleDefaultColorForDate:)]) {
        UIColor *color = [self.delegateAppearance calendar:self appearance:self.appearance titleDefaultColorForDate:date];
        return color;
    }
    return nil;
}

- (UIColor *)preferedTitleSelectionColorForDate:(NSDate *)date
{
    if (self.delegateAppearance && [self.delegateAppearance respondsToSelector:@selector(calendar:appearance:titleSelectionColorForDate:)]) {
        UIColor *color = [self.delegateAppearance calendar:self appearance:self.appearance titleSelectionColorForDate:date];
        return color;
    }
    return nil;
}

- (UIColor *)preferedSubtitleDefaultColorForDate:(NSDate *)date
{
    if (self.delegateAppearance && [self.delegateAppearance respondsToSelector:@selector(calendar:appearance:subtitleDefaultColorForDate:)]) {
        UIColor *color = [self.delegateAppearance calendar:self appearance:self.appearance subtitleDefaultColorForDate:date];
        return color;
    }
    return nil;
}

- (UIColor *)preferedSubtitleSelectionColorForDate:(NSDate *)date
{
    if (self.delegateAppearance && [self.delegateAppearance respondsToSelector:@selector(calendar:appearance:subtitleSelectionColorForDate:)]) {
        UIColor *color = [self.delegateAppearance calendar:self appearance:self.appearance subtitleSelectionColorForDate:date];
        return color;
    }
    return nil;
}

- (UIColor *)preferedEventColorForDate:(NSDate *)date
{
    if (self.delegateAppearance && [self.delegateAppearance respondsToSelector:@selector(calendar:appearance:eventColorForDate:)]) {
        UIColor *color = [self.delegateAppearance calendar:self appearance:self.appearance eventColorForDate:date];
        return color;
    }
    return nil;
}

- (UIColor *)preferedBorderDefaultColorForDate:(NSDate *)date
{
    if (self.delegateAppearance && [self.delegateAppearance respondsToSelector:@selector(calendar:appearance:borderDefaultColorForDate:)]) {
        UIColor *color = [self.delegateAppearance calendar:self appearance:self.appearance borderDefaultColorForDate:date];
        return color;
    }
    return nil;
}

- (UIColor *)preferedBorderSelectionColorForDate:(NSDate *)date
{
    if (self.delegateAppearance && [self.delegateAppearance respondsToSelector:@selector(calendar:appearance:borderSelectionColorForDate:)]) {
        UIColor *color = [self.delegateAppearance calendar:self appearance:self.appearance borderSelectionColorForDate:date];
        return color;
    }
    return nil;
}

- (FSCalendarCellShape)preferedCellShapeForDate:(NSDate *)date
{
    if (self.delegateAppearance && [self.delegateAppearance respondsToSelector:@selector(calendar:appearance:cellShapeForDate:)]) {
        FSCalendarCellShape cellShape = [self.delegateAppearance calendar:self appearance:self.appearance cellShapeForDate:date];
        return cellShape;
    }
#pragma GCC diagnostic push
#pragma GCC diagnostic ignored "-Wdeprecated-declarations"
    else if (self.delegateAppearance && [self.delegateAppearance respondsToSelector:@selector(calendar:appearance:cellStyleForDate:)]) {
        FSCalendarCellShape cellShape = (FSCalendarCellShape)[self.delegateAppearance calendar:self appearance:self.appearance cellStyleForDate:date];
        return cellShape;
    }
#pragma GCC diagnostic pop
    
    return FSCalendarCellShapeCircle;
}

#pragma mark - DataSource

- (NSString *)subtitleForDate:(NSDate *)date
{
    if (_dataSource && [_dataSource respondsToSelector:@selector(calendar:subtitleForDate:)]) {
        return [_dataSource calendar:self subtitleForDate:date];
    }
    return _ibEditing && _appearance.fakeSubtitles ? @"test" : nil;
}

- (UIImage *)imageForDate:(NSDate *)date
{
    if (_dataSource && [_dataSource respondsToSelector:@selector(calendar:imageForDate:)]) {
        return [_dataSource calendar:self imageForDate:date];
    }
    return nil;
}

- (BOOL)hasEventForDate:(NSDate *)date
{
    if (_dataSource && [_dataSource respondsToSelector:@selector(calendar:hasEventForDate:)]) {
        return [_dataSource calendar:self hasEventForDate:date];
    }
    return _ibEditing && ([@[@3,@5,@8,@16,@20,@25] containsObject:@([self dayOfDate:date])]);
}

- (NSDate *)minimumDateForCalendar
{
    if (_dataSource && [_dataSource respondsToSelector:@selector(minimumDateForCalendar:)]) {
        _minimumDate = [self dateByIgnoringTimeComponentsOfDate:[_dataSource minimumDateForCalendar:self]];
    }
    if (!_minimumDate) {
        _minimumDate = [self dateWithYear:1970 month:1 day:1];
    }
    return _minimumDate;
}

- (NSDate *)maximumDateForCalendar
{
    if (_dataSource && [_dataSource respondsToSelector:@selector(maximumDateForCalendar:)]) {
        _maximumDate = [self dateByIgnoringTimeComponentsOfDate:[_dataSource maximumDateForCalendar:self]];
    }
    if (!_maximumDate) {
        _maximumDate = [self dateWithYear:2099 month:12 day:31];
    }
    return _maximumDate;
}

@end

#pragma mark - DateTools


@implementation FSCalendar (DateTools)

#pragma mark - Public methods

- (NSInteger)yearOfDate:(NSDate *)date
{
    NSDateComponents *component = [self.calendar components:NSCalendarUnitYear fromDate:date];
    return component.year;
}

- (NSInteger)monthOfDate:(NSDate *)date
{
    NSDateComponents *component = [self.calendar components:NSCalendarUnitMonth
                                                   fromDate:date];
    return component.month;
}

- (NSInteger)dayOfDate:(NSDate *)date
{
    NSDateComponents *component = [self.calendar components:NSCalendarUnitDay
                                                   fromDate:date];
    return component.day;
}

- (NSInteger)weekdayOfDate:(NSDate *)date
{
    NSDateComponents *component = [self.calendar components:NSCalendarUnitWeekday fromDate:date];
    return component.weekday;
}

- (NSInteger)weekOfDate:(NSDate *)date
{
    NSDateComponents *component = [self.calendar components:NSCalendarUnitWeekOfYear fromDate:date];
    return component.weekOfYear;
}

- (NSInteger)hourOfDate:(NSDate *)date
{
    NSDateComponents *component = [self.calendar components:NSCalendarUnitHour
                                                   fromDate:date];
    return component.hour;
}

- (NSInteger)miniuteOfDate:(NSDate *)date
{
    NSDateComponents *component = [self.calendar components:NSCalendarUnitMinute
                                                   fromDate:date];
    return component.minute;
}

- (NSInteger)secondOfDate:(NSDate *)date
{
    NSDateComponents *component = [self.calendar components:NSCalendarUnitSecond
                                                   fromDate:date];
    return component.second;
}

- (NSDate *)dateByIgnoringTimeComponentsOfDate:(NSDate *)date
{
    NSDateComponents *components = [self.calendar components:NSCalendarUnitYear|NSCalendarUnitMonth|NSCalendarUnitDay fromDate:date];
    return [self.calendar dateFromComponents:components];
}

- (NSDate *)beginingOfMonthOfDate:(NSDate *)date
{
    NSDateComponents *components = [self.calendar components:NSCalendarUnitYear|NSCalendarUnitMonth| NSCalendarUnitDay fromDate:date];
    components.day = 1;
    return [self.calendar dateFromComponents:components];
}

- (NSDate *)endOfMonthOfDate:(NSDate *)date
{
    NSDateComponents *components = [self.calendar components:NSCalendarUnitYear|NSCalendarUnitMonth|NSCalendarUnitDay fromDate:date];
    components.month++;
    components.day = 0;
    return [self.calendar dateFromComponents:components];
}

- (NSDate *)beginingOfWeekOfDate:(NSDate *)date
{
    NSDateComponents *weekdayComponents = [self.calendar components:NSCalendarUnitWeekday fromDate:date];
    NSDateComponents *componentsToSubtract = self.components;
    componentsToSubtract.day = - (weekdayComponents.weekday - self.calendar.firstWeekday);
    NSDate *beginningOfWeek = [self.calendar dateByAddingComponents:componentsToSubtract toDate:date options:0];
    NSDateComponents *components = [self.calendar components:NSCalendarUnitYear|NSCalendarUnitMonth|NSCalendarUnitDay fromDate:beginningOfWeek];
    beginningOfWeek = [self.calendar dateFromComponents:components];
    componentsToSubtract.day = NSIntegerMax;
    return beginningOfWeek;
}

- (NSDate *)middleOfWeekFromDate:(NSDate *)date
{
    NSDateComponents *weekdayComponents = [self.calendar components:NSCalendarUnitWeekday fromDate:date];
    NSDateComponents *componentsToSubtract = self.components;
    componentsToSubtract.day = - (weekdayComponents.weekday - self.calendar.firstWeekday) + 3;
    NSDate *middleOfWeek = [self.calendar dateByAddingComponents:componentsToSubtract toDate:date options:0];
    NSDateComponents *components = [self.calendar components:NSCalendarUnitYear|NSCalendarUnitMonth|NSCalendarUnitDay fromDate:middleOfWeek];
    middleOfWeek = [self.calendar dateFromComponents:components];
    componentsToSubtract.day = NSIntegerMax;
    return middleOfWeek;
}

- (NSDate *)tomorrowOfDate:(NSDate *)date
{
    NSDateComponents *components = [self.calendar components:NSCalendarUnitYear|NSCalendarUnitMonth|NSCalendarUnitDay fromDate:date];
    components.day++;
    return [self.calendar dateFromComponents:components];
}

- (NSDate *)yesterdayOfDate:(NSDate *)date
{
    NSDateComponents *components = [self.calendar components:NSCalendarUnitYear|NSCalendarUnitMonth|NSCalendarUnitDay fromDate:date];
    components.day--;
    return [self.calendar dateFromComponents:components];
}

- (NSInteger)numberOfDatesInMonthOfDate:(NSDate *)date
{
    NSRange days = [self.calendar rangeOfUnit:NSCalendarUnitDay
                                       inUnit:NSCalendarUnitMonth
                                      forDate:date];
    return days.length;
}

- (NSDate *)dateFromString:(NSString *)string format:(NSString *)format
{
    self.formatter.dateFormat = format;
    return [self.formatter dateFromString:string];
}

- (NSDate *)dateWithYear:(NSInteger)year month:(NSInteger)month day:(NSInteger)day
{
    NSDateComponents *components = self.components;
    components.year = year;
    components.month = month;
    components.day = day;
    NSDate *date = [self.calendar dateFromComponents:components];
    components.year = NSIntegerMax;
    components.month = NSIntegerMax;
    components.day = NSIntegerMax;
    return date;
}

- (NSDate *)dateByAddingYears:(NSInteger)years toDate:(NSDate *)date
{
    NSDateComponents *components = self.components;
    components.year = years;
    NSDate *d = [self.calendar dateByAddingComponents:components toDate:date options:0];
    components.year = NSIntegerMax;
    return d;
}

- (NSDate *)dateBySubstractingYears:(NSInteger)years fromDate:(NSDate *)date
{
    return [self dateByAddingYears:-years toDate:date];
}

- (NSDate *)dateByAddingMonths:(NSInteger)months toDate:(NSDate *)date
{
    NSDateComponents *components = self.components;
    components.month = months;
    NSDate *d = [self.calendar dateByAddingComponents:components toDate:date options:0];
    components.month = NSIntegerMax;
    return d;
}

- (NSDate *)dateBySubstractingMonths:(NSInteger)months fromDate:(NSDate *)date
{
    return [self dateByAddingMonths:-months toDate:date];
}

- (NSDate *)dateByAddingWeeks:(NSInteger)weeks toDate:(NSDate *)date
{
    NSDateComponents *components = self.components;
    components.weekOfYear = weeks;
    NSDate *d = [self.calendar dateByAddingComponents:components toDate:date options:0];
    components.weekOfYear = NSIntegerMax;
    return d;
}

- (NSDate *)dateBySubstractingWeeks:(NSInteger)weeks fromDate:(NSDate *)date
{
    return [self dateByAddingWeeks:-weeks toDate:date];
}

- (NSDate *)dateByAddingDays:(NSInteger)days toDate:(NSDate *)date
{
    NSDateComponents *components = self.components;
    components.day = days;
    NSDate *d = [self.calendar dateByAddingComponents:components toDate:date options:0];
    components.day = NSIntegerMax;
    return d;
}

- (NSDate *)dateBySubstractingDays:(NSInteger)days fromDate:(NSDate *)date
{
    return [self dateByAddingDays:-days toDate:date];
}

- (NSInteger)yearsFromDate:(NSDate *)fromDate toDate:(NSDate *)toDate
{
    NSDateComponents *components = [self.calendar components:NSCalendarUnitYear
                                                    fromDate:fromDate
                                                      toDate:toDate
                                                     options:0];
    return components.year;
}

- (NSInteger)monthsFromDate:(NSDate *)fromDate toDate:(NSDate *)toDate
{
    NSDateComponents *components = [self.calendar components:NSCalendarUnitMonth
                                                    fromDate:fromDate
                                                      toDate:toDate
                                                     options:0];
    return components.month;
}

- (NSInteger)weeksFromDate:(NSDate *)fromDate toDate:(NSDate *)toDate
{
    NSDateComponents *components = [self.calendar components:NSCalendarUnitWeekOfYear
                                                    fromDate:fromDate
                                                      toDate:toDate
                                                     options:0];
    return components.weekOfYear;
}

- (NSInteger)daysFromDate:(NSDate *)fromDate toDate:(NSDate *)toDate
{
    NSDateComponents *components = [self.calendar components:NSCalendarUnitDay
                                                    fromDate:fromDate
                                                      toDate:toDate
                                                     options:0];
    return components.day;
}

- (BOOL)date:(NSDate *)date sharesSameMonthWithDate:(NSDate *)anotherDate
{
    return [self yearOfDate:date] == [self yearOfDate:anotherDate] && [self monthOfDate:date] == [self monthOfDate:anotherDate];
}

- (BOOL)date:(NSDate *)date sharesSameWeekWithDate:(NSDate *)anotherDate
{
    return [self yearOfDate:date] == [self yearOfDate:anotherDate] && [self weekOfDate:date] == [self weekOfDate:anotherDate];
}

- (BOOL)date:(NSDate *)date sharesSameDayWithDate:(NSDate *)anotherDate
{
    return [self yearOfDate:date] == [self yearOfDate:anotherDate] && [self monthOfDate:date] == [self monthOfDate:anotherDate] && [self dayOfDate:date] == [self dayOfDate:anotherDate];
}

- (NSString *)stringFromDate:(NSDate *)date format:(NSString *)format
{
    self.formatter.dateFormat = format;
    return [self.formatter stringFromDate:date];
}

- (NSString *)stringFromDate:(NSDate *)date
{
    return [self stringFromDate:date format:@"yyyy-MM-dd"];
}

@end

#pragma mark - Deprecate

@implementation FSCalendar (Deprecated)

- (void)setCurrentMonth:(NSDate *)currentMonth
{
    self.currentPage = currentMonth;
}

- (NSDate *)currentMonth
{
    return self.currentPage;
}

- (void)setFlow:(FSCalendarFlow)flow
{
    self.scrollDirection = (FSCalendarScrollDirection)flow;
}

- (FSCalendarFlow)flow
{
    return (FSCalendarFlow)self.scrollDirection;
}

- (void)setSelectedDate:(NSDate *)selectedDate
{
    [self selectDate:selectedDate];
}

- (void)setSelectedDate:(NSDate *)selectedDate animate:(BOOL)animate
{
    [self selectDate:selectedDate scrollToDate:animate];
}

@end




