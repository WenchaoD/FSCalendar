//
//  FSCalendar.m
//  FSCalendar
//
//  Created by Wenchao Ding on 29/1/15.
//  Copyright © 2016 Wenchao Ding. All rights reserved.
//

#import "FSCalendar.h"
#import "FSCalendarHeaderView.h"
#import "FSCalendarWeekdayView.h"
#import "FSCalendarStickyHeader.h"
#import "FSCalendarCollectionViewLayout.h"

#import "FSCalendarExtensions.h"
#import "FSCalendarDynamicHeader.h"
#import "FSCalendarCollectionView.h"
#import "FSCalendarTransitionCoordinator.h"
#import "FSCalendarCalculator.h"
#import "FSCalendarDelegationFactory.h"

NS_ASSUME_NONNULL_BEGIN

static inline void FSCalendarAssertDateInBounds(NSDate *date, NSCalendar *calendar, NSDate *minimumDate, NSDate *maximumDate) {
    BOOL valid = YES;
    NSInteger minOffset = [calendar components:NSCalendarUnitDay fromDate:minimumDate toDate:date options:0].day;
    valid &= minOffset >= 0;
    if (valid) {
        NSInteger maxOffset = [calendar components:NSCalendarUnitDay fromDate:maximumDate toDate:date options:0].day;
        valid &= maxOffset <= 0;
    }
    if (!valid) {
        NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
        formatter.dateFormat = @"yyyy/MM/dd";
        [NSException raise:@"FSCalendar date out of bounds exception" format:@"Target date %@ beyond bounds [%@ - %@]", [formatter stringFromDate:date], [formatter stringFromDate:minimumDate], [formatter stringFromDate:maximumDate]];
    }
}

NS_ASSUME_NONNULL_END

typedef NS_ENUM(NSUInteger, FSCalendarOrientation) {
    FSCalendarOrientationLandscape,
    FSCalendarOrientationPortrait
};

@interface FSCalendar ()<UICollectionViewDataSource,UICollectionViewDelegate,FSCalendarCollectionViewInternalDelegate,UIGestureRecognizerDelegate>
{
    NSMutableArray  *_selectedDates;
}

@property (strong, nonatomic) NSCalendar *gregorian;
@property (strong, nonatomic) NSDateFormatter *formatter;
@property (strong, nonatomic) NSTimeZone *timeZone;

@property (weak  , nonatomic) UIView                     *contentView;
@property (weak  , nonatomic) UIView                     *daysContainer;
@property (weak  , nonatomic) FSCalendarCollectionView   *collectionView;
@property (weak  , nonatomic) FSCalendarCollectionViewLayout *collectionViewLayout;

@property (strong, nonatomic) FSCalendarTransitionCoordinator *transitionCoordinator;
@property (strong, nonatomic) FSCalendarCalculator       *calculator;

@property (weak  , nonatomic) FSCalendarHeaderTouchDeliver *deliver;

@property (assign, nonatomic) BOOL                       needsAdjustingViewFrame;
@property (assign, nonatomic) BOOL                       needsRequestingBoundingDates;
@property (assign, nonatomic) CGFloat                    preferredHeaderHeight;
@property (assign, nonatomic) CGFloat                    preferredWeekdayHeight;
@property (assign, nonatomic) CGFloat                    preferredRowHeight;
@property (assign, nonatomic) FSCalendarOrientation      orientation;

@property (strong, nonatomic) NSMutableArray<NSOperation *> *didLayoutOperations;

@property (readonly, nonatomic) BOOL floatingMode;
@property (readonly, nonatomic) BOOL hasValidateVisibleLayout;
@property (readonly, nonatomic) NSArray *visibleStickyHeaders;
@property (readonly, nonatomic) FSCalendarOrientation currentCalendarOrientation;

@property (strong, nonatomic) FSCalendarDelegationProxy  *dataSourceProxy;
@property (strong, nonatomic) FSCalendarDelegationProxy  *delegateProxy;

@property (strong, nonatomic) NSIndexPath *lastPressedIndexPath;
@property (strong, nonatomic) NSMapTable *visibleSectionHeaders;

- (void)orientationDidChange:(NSNotification *)notification;

- (CGSize)sizeThatFits:(CGSize)size scope:(FSCalendarScope)scope;

- (void)scrollToDate:(NSDate *)date;
- (void)scrollToDate:(NSDate *)date animated:(BOOL)animated;
- (void)scrollToPageForDate:(NSDate *)date animated:(BOOL)animated;

- (BOOL)isPageInRange:(NSDate *)page;
- (BOOL)isDateInRange:(NSDate *)date;
- (BOOL)isDateSelected:(NSDate *)date;
- (BOOL)isDateInDifferentPage:(NSDate *)date;

- (void)selectDate:(NSDate *)date scrollToDate:(BOOL)scrollToDate atMonthPosition:(FSCalendarMonthPosition)monthPosition;
- (void)enqueueSelectedDate:(NSDate *)date;

- (void)invalidateDateTools;
- (void)invalidateLayout;
- (void)invalidateHeaders;
- (void)invalidateAppearanceForCell:(FSCalendarCell *)cell forDate:(NSDate *)date;

- (void)invalidateViewFrames;

- (void)handleSwipeToChoose:(UILongPressGestureRecognizer *)pressGesture;

- (void)selectCounterpartDate:(NSDate *)date;
- (void)deselectCounterpartDate:(NSDate *)date;

- (void)reloadDataForCell:(FSCalendarCell *)cell atIndexPath:(NSIndexPath *)indexPath;

- (void)adjustMonthPosition;
- (BOOL)requestBoundingDatesIfNecessary;
- (void)executePendingOperationsIfNeeded;
- (void)configureAppearance;

@end

@implementation FSCalendar

@dynamic selectedDate;
@synthesize scopeGesture = _scopeGesture, swipeToChooseGesture = _swipeToChooseGesture;

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
    
    _gregorian = [[NSCalendar alloc] initWithCalendarIdentifier:NSCalendarIdentifierGregorian];
    _formatter = [[NSDateFormatter alloc] init];
    _formatter.dateFormat = @"yyyy-MM-dd";
    _locale = [NSLocale currentLocale];
    _timeZone = [NSTimeZone defaultTimeZone];
    _firstWeekday = 1;
    [self invalidateDateTools];
    
    _today = [self.gregorian startOfDayForDate:[NSDate date]];
    _currentPage = [self.gregorian fs_firstDayOfMonth:_today];
    
    
    _minimumDate = [self.formatter dateFromString:@"1970-01-01"];
    _maximumDate = [self.formatter dateFromString:@"2099-12-31"];
    
    _headerHeight     = FSCalendarAutomaticDimension;
    _weekdayHeight    = FSCalendarAutomaticDimension;
    _rowHeight        = FSCalendarStandardRowHeight*MAX(1, FSCalendarDeviceIsIPad*1.5);
    
    _preferredHeaderHeight  = FSCalendarAutomaticDimension;
    _preferredWeekdayHeight = FSCalendarAutomaticDimension;
    _preferredRowHeight     = FSCalendarAutomaticDimension;
    
    _scrollDirection = FSCalendarScrollDirectionHorizontal;
    _scope = FSCalendarScopeMonth;
    _selectedDates = [NSMutableArray arrayWithCapacity:1];
    _visibleSectionHeaders = [NSMapTable weakToWeakObjectsMapTable];
    
    _pagingEnabled = YES;
    _scrollEnabled = YES;
    _needsAdjustingViewFrame = YES;
    _needsRequestingBoundingDates = YES;
    _orientation = self.currentCalendarOrientation;
    _placeholderType = FSCalendarPlaceholderTypeFillSixRows;
    
    _dataSourceProxy = [FSCalendarDelegationFactory dataSourceProxy];
    _delegateProxy = [FSCalendarDelegationFactory delegateProxy];
    
    self.didLayoutOperations = NSMutableArray.array;
    
    UIView *contentView = [[UIView alloc] initWithFrame:CGRectZero];
    contentView.backgroundColor = [UIColor clearColor];
    contentView.clipsToBounds = YES;
    [self addSubview:contentView];
    self.contentView = contentView;
    
    UIView *daysContainer = [[UIView alloc] initWithFrame:CGRectZero];
    daysContainer.backgroundColor = [UIColor clearColor];
    daysContainer.clipsToBounds = YES;
    [contentView addSubview:daysContainer];
    self.daysContainer = daysContainer;
    
    FSCalendarCollectionViewLayout *collectionViewLayout = [[FSCalendarCollectionViewLayout alloc] init];
    collectionViewLayout.calendar = self;
    
    FSCalendarCollectionView *collectionView = [[FSCalendarCollectionView alloc] initWithFrame:CGRectZero
                                                                          collectionViewLayout:collectionViewLayout];
    collectionView.dataSource = self;
    collectionView.delegate = self;
    collectionView.internalDelegate = self;
    collectionView.backgroundColor = [UIColor clearColor];
    collectionView.pagingEnabled = YES;
    collectionView.showsHorizontalScrollIndicator = NO;
    collectionView.showsVerticalScrollIndicator = NO;
    collectionView.allowsMultipleSelection = NO;
    collectionView.clipsToBounds = YES;
    [collectionView registerClass:[FSCalendarCell class] forCellWithReuseIdentifier:FSCalendarDefaultCellReuseIdentifier];
    [collectionView registerClass:[FSCalendarBlankCell class] forCellWithReuseIdentifier:FSCalendarBlankCellReuseIdentifier];
    [collectionView registerClass:[FSCalendarStickyHeader class] forSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:@"header"];
    [collectionView registerClass:[UICollectionReusableView class] forSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:@"placeholderHeader"];
    [daysContainer addSubview:collectionView];
    self.collectionView = collectionView;
    self.collectionViewLayout = collectionViewLayout;
    
    [self invalidateLayout];
    
    // Assistants
    self.transitionCoordinator = [[FSCalendarTransitionCoordinator alloc] initWithCalendar:self];
    self.calculator = [[FSCalendarCalculator alloc] initWithCalendar:self];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(orientationDidChange:) name:UIDeviceOrientationDidChangeNotification object:nil];
    
}

- (void)dealloc
{
    self.collectionView.delegate = nil;
    self.collectionView.dataSource = nil;
    
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIDeviceOrientationDidChangeNotification object:nil];
}

#pragma mark - Overriden methods

- (void)setBounds:(CGRect)bounds
{
    [super setBounds:bounds];
    if (!CGRectIsEmpty(bounds) && self.transitionCoordinator.state == FSCalendarTransitionStateIdle) {
        [self invalidateViewFrames];
    }
}

- (void)setFrame:(CGRect)frame
{
    [super setFrame:frame];
    if (!CGRectIsEmpty(frame) && self.transitionCoordinator.state == FSCalendarTransitionStateIdle) {
        [self invalidateViewFrames];
    }
}

- (void)setValue:(id)value forUndefinedKey:(NSString *)key
{
#if !TARGET_INTERFACE_BUILDER
    if ([key hasPrefix:@"fake"]) {
        return;
    }
#endif
    if (key.length) {
        NSString *setter = [NSString stringWithFormat:@"set%@%@:",[key substringToIndex:1].uppercaseString,[key substringFromIndex:1]];
        SEL selector = NSSelectorFromString(setter);
        if ([self.appearance respondsToSelector:selector]) {
            return [self.appearance setValue:value forKey:key];
        } else if ([self.collectionViewLayout respondsToSelector:selector]) {
            return [self.collectionViewLayout setValue:value forKey:key];
        }
    }
    
    return [super setValue:value forUndefinedKey:key];
    
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    if (_needsAdjustingViewFrame) {
        _needsAdjustingViewFrame = NO;
        
        if (CGSizeEqualToSize(_transitionCoordinator.cachedMonthSize, CGSizeZero)) {
            _transitionCoordinator.cachedMonthSize = self.frame.size;
        }
        
        _contentView.frame = self.bounds;
        CGFloat headerHeight = self.preferredHeaderHeight;
        CGFloat weekdayHeight = self.preferredWeekdayHeight;
        CGFloat rowHeight = self.preferredRowHeight;
        CGFloat padding = 5;
        if (self.scrollDirection == UICollectionViewScrollDirectionHorizontal) {
            rowHeight = FSCalendarFloor(rowHeight*2)*0.5; // Round to nearest multiple of 0.5. e.g. (16.8->16.5),(16.2->16.0)
        }
        
        self.calendarHeaderView.frame = CGRectMake(0, 0, self.fs_width, headerHeight);
        self.calendarWeekdayView.frame = CGRectMake(0, self.calendarHeaderView.fs_bottom, self.contentView.fs_width, weekdayHeight);

        _deliver.frame = CGRectMake(self.calendarHeaderView.fs_left, self.calendarHeaderView.fs_top, self.calendarHeaderView.fs_width, headerHeight+weekdayHeight);
        _deliver.hidden = self.calendarHeaderView.hidden;
        if (!self.floatingMode) {
            switch (self.transitionCoordinator.representingScope) {
                case FSCalendarScopeMonth: {
                    CGFloat contentHeight = rowHeight*6 + padding*2;
                    _daysContainer.frame = CGRectMake(0, headerHeight+weekdayHeight, self.fs_width, contentHeight);
                    _collectionView.frame = CGRectMake(0, 0, _daysContainer.fs_width, contentHeight);
                    break;
                }
                case FSCalendarScopeWeek: {
                    CGFloat contentHeight = rowHeight + padding*2;
                    _daysContainer.frame = CGRectMake(0, headerHeight+weekdayHeight, self.fs_width, contentHeight);
                    _collectionView.frame = CGRectMake(0, 0, _daysContainer.fs_width, contentHeight);
                    break;
                }
            }
        } else {
            
            CGFloat contentHeight = _contentView.fs_height;
            _daysContainer.frame = CGRectMake(0, 0, self.fs_width, contentHeight);
            _collectionView.frame = _daysContainer.bounds;
            
        }
        _collectionView.fs_height = FSCalendarHalfFloor(_collectionView.fs_height);
    }
    
}

#if TARGET_INTERFACE_BUILDER
- (void)prepareForInterfaceBuilder
{
    NSDate *date = [NSDate date];
    NSDateComponents *components = [self.gregorian components:NSCalendarUnitYear|NSCalendarUnitMonth|NSCalendarUnitDay fromDate:date];
    components.day = _appearance.fakedSelectedDay?:1;
    [_selectedDates addObject:[self.gregorian dateFromComponents:components]];
    [self.collectionView reloadData];
}
#endif

- (CGSize)sizeThatFits:(CGSize)size
{
    return [self sizeThatFits:size scope:self.transitionCoordinator.representingScope];
}

- (CGSize)sizeThatFits:(CGSize)size scope:(FSCalendarScope)scope
{
    CGFloat headerHeight = self.preferredHeaderHeight;
    CGFloat weekdayHeight = self.preferredWeekdayHeight;
    CGFloat rowHeight = self.preferredRowHeight;
    CGFloat paddings = self.collectionViewLayout.sectionInsets.top + self.collectionViewLayout.sectionInsets.bottom;
    
    if (!self.floatingMode) {
        switch (scope) {
            case FSCalendarScopeMonth: {
                CGFloat height = weekdayHeight + headerHeight + [self.calculator numberOfRowsInMonth:_currentPage]*rowHeight + paddings;
                return CGSizeMake(size.width, height);
            }
            case FSCalendarScopeWeek: {
                CGFloat height = weekdayHeight + headerHeight + rowHeight + paddings;
                return CGSizeMake(size.width, height);
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
    [self requestBoundingDatesIfNecessary];
    return self.calculator.numberOfSections;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    if (self.floatingMode) {
        NSInteger numberOfRows = [self.calculator numberOfRowsInSection:section];
        return numberOfRows * 7;
    }
    switch (self.transitionCoordinator.representingScope) {
        case FSCalendarScopeMonth: {
            return 42;
        }
        case FSCalendarScopeWeek: {
            return 7;
        }
    }
    return 7;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    FSCalendarMonthPosition monthPosition = [self.calculator monthPositionForIndexPath:indexPath];
    
    switch (self.placeholderType) {
        case FSCalendarPlaceholderTypeNone: {
            if (self.transitionCoordinator.representingScope == FSCalendarScopeMonth && monthPosition != FSCalendarMonthPositionCurrent) {
                return [collectionView dequeueReusableCellWithReuseIdentifier:FSCalendarBlankCellReuseIdentifier forIndexPath:indexPath];
            }
            break;
        }
        case FSCalendarPlaceholderTypeFillHeadTail: {
            if (self.transitionCoordinator.representingScope == FSCalendarScopeMonth) {
                if (indexPath.item >= 7 * [self.calculator numberOfRowsInSection:indexPath.section]) {
                    return [collectionView dequeueReusableCellWithReuseIdentifier:FSCalendarBlankCellReuseIdentifier forIndexPath:indexPath];
                }
            }
            break;
        }
        case FSCalendarPlaceholderTypeFillSixRows: {
            break;
        }
    }
    
    NSDate *date = [self.calculator dateForIndexPath:indexPath];
    FSCalendarCell *cell = [self.dataSourceProxy calendar:self cellForDate:date atMonthPosition:monthPosition];
    if (!cell) {
        cell = [self.collectionView dequeueReusableCellWithReuseIdentifier:FSCalendarDefaultCellReuseIdentifier forIndexPath:indexPath];
    }
    [self reloadDataForCell:cell atIndexPath:indexPath];
    return cell;
}

- (UICollectionReusableView *)collectionView:(UICollectionView *)collectionView viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath
{
    if (self.floatingMode) {
        if ([kind isEqualToString:UICollectionElementKindSectionHeader]) {
            FSCalendarStickyHeader *stickyHeader = [collectionView dequeueReusableSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:@"header" forIndexPath:indexPath];
            stickyHeader.calendar = self;
            stickyHeader.month = [self.gregorian dateByAddingUnit:NSCalendarUnitMonth value:indexPath.section toDate:[self.gregorian fs_firstDayOfMonth:_minimumDate] options:0];
            self.visibleSectionHeaders[indexPath] = stickyHeader;
            [stickyHeader setNeedsLayout];
            return stickyHeader;
        }
    }
    return [collectionView dequeueReusableSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:@"placeholderHeader" forIndexPath:indexPath];
}

- (void)collectionView:(UICollectionView *)collectionView didEndDisplayingSupplementaryView:(UICollectionReusableView *)view forElementOfKind:(NSString *)elementKind atIndexPath:(NSIndexPath *)indexPath
{
    if (self.floatingMode) {
        if ([elementKind isEqualToString:UICollectionElementKindSectionHeader]) {
            self.visibleSectionHeaders[indexPath] = nil;
        }
    }
}

#pragma mark - <UICollectionViewDelegate>

- (BOOL)collectionView:(UICollectionView *)collectionView shouldSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    FSCalendarMonthPosition monthPosition = [self.calculator monthPositionForIndexPath:indexPath];
    if (self.placeholderType == FSCalendarPlaceholderTypeNone && monthPosition != FSCalendarMonthPositionCurrent) {
        return NO;
    }
    NSDate *date = [self.calculator dateForIndexPath:indexPath];
    return [self isDateInRange:date] && (![self.delegateProxy respondsToSelector:@selector(calendar:shouldSelectDate:atMonthPosition:)] || [self.delegateProxy calendar:self shouldSelectDate:date atMonthPosition:monthPosition]);
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    NSDate *selectedDate = [self.calculator dateForIndexPath:indexPath];
    FSCalendarMonthPosition monthPosition = [self.calculator monthPositionForIndexPath:indexPath];
    FSCalendarCell *cell;
    if (monthPosition == FSCalendarMonthPositionCurrent) {
        cell = (FSCalendarCell *)[collectionView cellForItemAtIndexPath:indexPath];
    } else {
        cell = [self cellForDate:selectedDate atMonthPosition:FSCalendarMonthPositionCurrent];
        NSIndexPath *indexPath = [collectionView indexPathForCell:cell];
        if (indexPath) {
            [collectionView selectItemAtIndexPath:indexPath animated:NO scrollPosition:UICollectionViewScrollPositionNone];
        }
    }
    if (![_selectedDates containsObject:selectedDate]) {
        cell.selected = YES;
        [cell performSelecting];
    }
    [self enqueueSelectedDate:selectedDate];
    [self.delegateProxy calendar:self didSelectDate:selectedDate atMonthPosition:monthPosition];
    [self selectCounterpartDate:selectedDate];
}

- (BOOL)collectionView:(UICollectionView *)collectionView shouldDeselectItemAtIndexPath:(NSIndexPath *)indexPath
{
    FSCalendarMonthPosition monthPosition = [self.calculator monthPositionForIndexPath:indexPath];
    if (self.placeholderType == FSCalendarPlaceholderTypeNone && monthPosition != FSCalendarMonthPositionCurrent) {
        return NO;
    }
    NSDate *date = [self.calculator dateForIndexPath:indexPath];
    return [self isDateInRange:date] && (![self.delegateProxy respondsToSelector:@selector(calendar:shouldDeselectDate:atMonthPosition:)]||[self.delegateProxy calendar:self shouldDeselectDate:date atMonthPosition:monthPosition]);
}

- (void)collectionView:(UICollectionView *)collectionView didDeselectItemAtIndexPath:(NSIndexPath *)indexPath
{
    NSDate *selectedDate = [self.calculator dateForIndexPath:indexPath];
    FSCalendarMonthPosition monthPosition = [self.calculator monthPositionForIndexPath:indexPath];
    FSCalendarCell *cell;
    if (monthPosition == FSCalendarMonthPositionCurrent) {
        cell = (FSCalendarCell *)[collectionView cellForItemAtIndexPath:indexPath];
    } else {
        cell = [self cellForDate:selectedDate atMonthPosition:FSCalendarMonthPositionCurrent];
        NSIndexPath *indexPath = [collectionView indexPathForCell:cell];
        if (indexPath) {
            [collectionView deselectItemAtIndexPath:indexPath animated:NO];
        }
    }
    cell.selected = NO;
    [cell configureAppearance];
    
    [_selectedDates removeObject:selectedDate];
    [self.delegateProxy calendar:self didDeselectDate:selectedDate atMonthPosition:monthPosition];
    [self deselectCounterpartDate:selectedDate];
    
}

- (void)collectionView:(UICollectionView *)collectionView willDisplayCell:(UICollectionViewCell *)cell forItemAtIndexPath:(NSIndexPath *)indexPath
{
    if (![cell isKindOfClass:[FSCalendarCell class]]) {
        return;
    }
    NSDate *date = [self.calculator dateForIndexPath:indexPath];
    FSCalendarMonthPosition monthPosition = [self.calculator monthPositionForIndexPath:indexPath];
    [self.delegateProxy calendar:self willDisplayCell:(FSCalendarCell *)cell forDate:date atMonthPosition:monthPosition];
}

- (void)collectionViewDidFinishLayoutSubviews:(FSCalendarCollectionView *)collectionView
{
    [self executePendingOperationsIfNeeded];
}

#pragma mark - <UIScrollViewDelegate>

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    if (!self.window) return;
    if (self.floatingMode && _collectionView.indexPathsForVisibleItems.count) {
        // Do nothing on bouncing
        if (_collectionView.contentOffset.y < 0 || _collectionView.contentOffset.y > _collectionView.contentSize.height-_collectionView.fs_height) {
            return;
        }
        NSDate *currentPage = _currentPage;
        CGPoint significantPoint = CGPointMake(_collectionView.fs_width*0.5,MIN(self.collectionViewLayout.estimatedItemSize.height*2.75, _collectionView.fs_height*0.5)+_collectionView.contentOffset.y);
        NSIndexPath *significantIndexPath = [_collectionView indexPathForItemAtPoint:significantPoint];
        if (significantIndexPath) {
            currentPage = [self.gregorian dateByAddingUnit:NSCalendarUnitMonth value:significantIndexPath.section toDate:[self.gregorian fs_firstDayOfMonth:_minimumDate] options:0];
        } else {
            FSCalendarStickyHeader *significantHeader = [self.visibleStickyHeaders filteredArrayUsingPredicate:[NSPredicate predicateWithBlock:^BOOL(FSCalendarStickyHeader * _Nonnull evaluatedObject, NSDictionary<NSString *,id> * _Nullable bindings) {
                return CGRectContainsPoint(evaluatedObject.frame, significantPoint);
            }]].firstObject;
            if (significantHeader) {
                currentPage = significantHeader.month;
            }
        }
        
        if (![self.gregorian isDate:currentPage equalToDate:_currentPage toUnitGranularity:NSCalendarUnitMonth]) {
            [self willChangeValueForKey:@"currentPage"];
            _currentPage = currentPage;
            [self.delegateProxy calendarCurrentPageDidChange:self];
            [self didChangeValueForKey:@"currentPage"];
        }
        
    } else if (self.hasValidateVisibleLayout) {
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
        }
        _calendarHeaderView.scrollOffset = scrollOffset;
    }
}

- (void)scrollViewWillEndDragging:(UIScrollView *)scrollView withVelocity:(CGPoint)velocity targetContentOffset:(inout CGPoint *)targetContentOffset
{
    if (!_pagingEnabled || !_scrollEnabled) {
        return;
    }
    CGFloat targetOffset = 0, contentSize = 0;
    switch (_collectionViewLayout.scrollDirection) {
        case UICollectionViewScrollDirectionHorizontal: {
            targetOffset = targetContentOffset->x;
            contentSize = scrollView.fs_width;
            break;
        }
        case UICollectionViewScrollDirectionVertical: {
            targetOffset = targetContentOffset->y;
            contentSize = scrollView.fs_height;
            break;
        }
    }
    
    NSInteger sections = lrint(targetOffset/contentSize);
    NSDate *targetPage = nil;
    switch (_scope) {
        case FSCalendarScopeMonth: {
            NSDate *minimumPage = [self.gregorian fs_firstDayOfMonth:_minimumDate];
            targetPage = [self.gregorian dateByAddingUnit:NSCalendarUnitMonth value:sections toDate:minimumPage options:0];
            break;
        }
        case FSCalendarScopeWeek: {
            NSDate *minimumPage = [self.gregorian fs_firstDayOfWeek:_minimumDate];
            targetPage = [self.gregorian dateByAddingUnit:NSCalendarUnitWeekOfYear value:sections toDate:minimumPage options:0];
            break;
        }
    }
    BOOL shouldTriggerPageChange = [self isDateInDifferentPage:targetPage];
    if (shouldTriggerPageChange) {
        NSDate *lastPage = _currentPage;
        [self willChangeValueForKey:@"currentPage"];
        _currentPage = targetPage;
        [self.delegateProxy calendarCurrentPageDidChange:self];
        if (_placeholderType != FSCalendarPlaceholderTypeFillSixRows) {
            [self.transitionCoordinator performBoundingRectTransitionFromMonth:lastPage toMonth:_currentPage duration:0.25];
        }
        [self didChangeValueForKey:@"currentPage"];
    }
    
}

#pragma mark - <UIGestureRecognizerDelegate>

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer
{
    return YES;
}

#pragma mark - Notification

- (void)orientationDidChange:(NSNotification *)notification
{
    self.orientation = self.currentCalendarOrientation;
}

#pragma mark - Properties

- (void)setScrollDirection:(FSCalendarScrollDirection)scrollDirection
{
    if (_scrollDirection != scrollDirection) {
        _scrollDirection = scrollDirection;
        
        if (self.floatingMode) return;
        
        switch (_scope) {
            case FSCalendarScopeMonth: {
                _collectionViewLayout.scrollDirection = (UICollectionViewScrollDirection)scrollDirection;
                _calendarHeaderView.scrollDirection = _collectionViewLayout.scrollDirection;
                if (self.hasValidateVisibleLayout) {
                    [_collectionView reloadData];
                    [_calendarHeaderView reloadData];
                }
                _needsAdjustingViewFrame = YES;
                [self setNeedsLayout];
                break;
            }
            case FSCalendarScopeWeek: {
                break;
            }
        }
    }
}

+ (BOOL)automaticallyNotifiesObserversOfScope
{
    return NO;
}

- (void)setScope:(FSCalendarScope)scope
{
    [self setScope:scope animated:NO];
}

- (void)setFirstWeekday:(NSUInteger)firstWeekday
{
    if (_firstWeekday != firstWeekday) {
        _firstWeekday = firstWeekday;
        _needsRequestingBoundingDates = YES;
        [self invalidateDateTools];
        [self invalidateHeaders];
        [self.collectionView reloadData];
        [self configureAppearance];
    }
}

- (void)setToday:(NSDate *)today
{
    if (!today) {
        _today = nil;
    } else {
        FSCalendarAssertDateInBounds(today,self.gregorian,self.minimumDate,self.maximumDate);
        _today = [self.gregorian startOfDayForDate:today];
    }
    if (self.hasValidateVisibleLayout) {
        [self.visibleCells makeObjectsPerformSelector:@selector(setDateIsToday:) withObject:nil];
        if (today) [[_collectionView cellForItemAtIndexPath:[self.calculator indexPathForDate:today]] setValue:@YES forKey:@"dateIsToday"];
        [self.visibleCells makeObjectsPerformSelector:@selector(configureAppearance)];
    }
}

- (void)setCurrentPage:(NSDate *)currentPage
{
    [self setCurrentPage:currentPage animated:NO];
}

- (void)setCurrentPage:(NSDate *)currentPage animated:(BOOL)animated
{
    [self requestBoundingDatesIfNecessary];
    if (self.floatingMode || [self isDateInDifferentPage:currentPage]) {
        currentPage = [self.gregorian startOfDayForDate:currentPage];
        if ([self isPageInRange:currentPage]) {
            [self scrollToPageForDate:currentPage animated:animated];
        }
    }
}

- (void)registerClass:(Class)cellClass forCellReuseIdentifier:(NSString *)identifier
{
    if (!identifier.length) {
        [NSException raise:FSCalendarInvalidArgumentsExceptionName format:@"This identifier must not be nil and must not be an empty string."];
    }
    if (![cellClass isSubclassOfClass:[FSCalendarCell class]]) {
        [NSException raise:@"The cell class must be a subclass of FSCalendarCell." format:@""];
    }
    if ([identifier isEqualToString:FSCalendarBlankCellReuseIdentifier]) {
        [NSException raise:FSCalendarInvalidArgumentsExceptionName format:@"Do not use %@ as the cell reuse identifier.", identifier];
    }
    [self.collectionView registerClass:cellClass forCellWithReuseIdentifier:identifier];

}

- (FSCalendarCell *)dequeueReusableCellWithIdentifier:(NSString *)identifier forDate:(NSDate *)date atMonthPosition:(FSCalendarMonthPosition)position;
{
    if (!identifier.length) {
        [NSException raise:FSCalendarInvalidArgumentsExceptionName format:@"This identifier must not be nil and must not be an empty string."];
    }
    NSIndexPath *indexPath = [self.calculator indexPathForDate:date atMonthPosition:position];
    if (!indexPath) {
        [NSException raise:FSCalendarInvalidArgumentsExceptionName format:@"Attempting to dequeue a cell with invalid date."];
    }
    FSCalendarCell *cell = [self.collectionView dequeueReusableCellWithReuseIdentifier:identifier forIndexPath:indexPath];
    return cell;
}

- (nullable FSCalendarCell *)cellForDate:(NSDate *)date atMonthPosition:(FSCalendarMonthPosition)position
{
    NSIndexPath *indexPath = [self.calculator indexPathForDate:date atMonthPosition:position];
    return (FSCalendarCell *)[self.collectionView cellForItemAtIndexPath:indexPath];
}

- (NSDate *)dateForCell:(FSCalendarCell *)cell
{
    NSIndexPath *indexPath = [self.collectionView indexPathForCell:cell];
    return [self.calculator dateForIndexPath:indexPath];
}

- (FSCalendarMonthPosition)monthPositionForCell:(FSCalendarCell *)cell
{
    NSIndexPath *indexPath = [self.collectionView indexPathForCell:cell];
    return [self.calculator monthPositionForIndexPath:indexPath];
}

- (NSArray<FSCalendarCell *> *)visibleCells
{
    return [self.collectionView.visibleCells filteredArrayUsingPredicate:[NSPredicate predicateWithBlock:^BOOL(id  _Nullable evaluatedObject, NSDictionary<NSString *,id> * _Nullable bindings) {
        return [evaluatedObject isKindOfClass:[FSCalendarCell class]];
    }]];
}

- (CGRect)frameForDate:(NSDate *)date
{
    if (!self.superview) {
        return CGRectZero;
    }
    CGRect frame = [_collectionViewLayout layoutAttributesForItemAtIndexPath:[self.calculator indexPathForDate:date]].frame;
    frame = [self.superview convertRect:frame fromView:_collectionView];
    return frame;
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

- (void)setLocale:(NSLocale *)locale
{
    if (![_locale isEqual:locale]) {
        _locale = locale.copy;
        [self invalidateDateTools];
        [self configureAppearance];
        if (self.hasValidateVisibleLayout) {
            [self invalidateHeaders];
        }
    }
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
        _calendarHeaderView.scrollEnabled = scrollEnabled;
        
        [self invalidateLayout];
    }
}

- (void)setOrientation:(FSCalendarOrientation)orientation
{
    if (_orientation != orientation) {
        _orientation = orientation;
        
        _needsAdjustingViewFrame = YES;
        _preferredWeekdayHeight = FSCalendarAutomaticDimension;
        _preferredRowHeight = FSCalendarAutomaticDimension;
        _preferredHeaderHeight = FSCalendarAutomaticDimension;
        [self setNeedsLayout];
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

- (CGFloat)preferredHeaderHeight
{
    if (_headerHeight == FSCalendarAutomaticDimension) {
        if (_preferredWeekdayHeight == FSCalendarAutomaticDimension) {
            if (!self.floatingMode) {
                CGFloat DIYider = FSCalendarStandardMonthlyPageHeight;
                CGFloat contentHeight = self.transitionCoordinator.cachedMonthSize.height;
                _preferredHeaderHeight = (FSCalendarStandardHeaderHeight/DIYider)*contentHeight;
                _preferredHeaderHeight -= (_preferredHeaderHeight-FSCalendarStandardHeaderHeight)*0.5;
            } else {
                _preferredHeaderHeight = FSCalendarStandardHeaderHeight*MAX(1, FSCalendarDeviceIsIPad*1.5);
            }
        }
        return _preferredHeaderHeight;
    }
    return _headerHeight;
}

- (CGFloat)preferredWeekdayHeight
{
    if (_weekdayHeight == FSCalendarAutomaticDimension) {
        if (_preferredWeekdayHeight == FSCalendarAutomaticDimension) {
            if (!self.floatingMode) {
                CGFloat DIYider = FSCalendarStandardMonthlyPageHeight;
                CGFloat contentHeight = self.transitionCoordinator.cachedMonthSize.height;
                _preferredWeekdayHeight = (FSCalendarStandardWeekdayHeight/DIYider)*contentHeight;
            } else {
                _preferredWeekdayHeight = FSCalendarStandardWeekdayHeight*MAX(1, FSCalendarDeviceIsIPad*1.5);
            }
        }
        return _preferredWeekdayHeight;
    }
    return _weekdayHeight;
}

- (CGFloat)preferredRowHeight
{
    if (_preferredRowHeight == FSCalendarAutomaticDimension) {
        CGFloat headerHeight = self.preferredHeaderHeight;
        CGFloat weekdayHeight = self.preferredWeekdayHeight;
        CGFloat contentHeight = self.transitionCoordinator.cachedMonthSize.height-headerHeight-weekdayHeight;
        CGFloat padding = 5;
        if (!self.floatingMode) {
            _preferredRowHeight = (contentHeight-padding*2)/6.0;
        } else {
            _preferredRowHeight = _rowHeight;
        }
    }
    return _preferredRowHeight;
}

- (BOOL)floatingMode
{
    return _scope == FSCalendarScopeMonth && _scrollEnabled && !_pagingEnabled;
}

- (UIPanGestureRecognizer *)scopeGesture
{
    if (!_scopeGesture) {
        UIPanGestureRecognizer *panGesture = [[UIPanGestureRecognizer alloc] initWithTarget:self.transitionCoordinator action:@selector(handleScopeGesture:)];
        panGesture.delegate = self.transitionCoordinator;
        panGesture.minimumNumberOfTouches = 1;
        panGesture.maximumNumberOfTouches = 2;
        panGesture.enabled = NO;
        [self.daysContainer addGestureRecognizer:panGesture];
        _scopeGesture = panGesture;
    }
    return _scopeGesture;
}

- (UILongPressGestureRecognizer *)swipeToChooseGesture
{
    if (!_swipeToChooseGesture) {
        UILongPressGestureRecognizer *pressGesture = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(handleSwipeToChoose:)];
        pressGesture.enabled = NO;
        pressGesture.numberOfTapsRequired = 0;
        pressGesture.numberOfTouchesRequired = 1;
        pressGesture.minimumPressDuration = 0.7;
        [self.daysContainer addGestureRecognizer:pressGesture];
        [self.collectionView.panGestureRecognizer requireGestureRecognizerToFail:pressGesture];
        _swipeToChooseGesture = pressGesture;
    }
    return _swipeToChooseGesture;
}

- (void)setDataSource:(id<FSCalendarDataSource>)dataSource
{
    self.dataSourceProxy.delegation = dataSource;
}

- (id<FSCalendarDataSource>)dataSource
{
    return self.dataSourceProxy.delegation;
}

- (void)setDelegate:(id<FSCalendarDelegate>)delegate
{
    self.delegateProxy.delegation = delegate;
}

- (id<FSCalendarDelegate>)delegate
{
    return self.delegateProxy.delegation;
}

#pragma mark - Public methods

- (void)reloadData
{
    _needsRequestingBoundingDates = YES;
    if ([self requestBoundingDatesIfNecessary] || !self.collectionView.indexPathsForVisibleItems.count) {
        [self invalidateHeaders];
    }
    [self.collectionView reloadData];
}

- (void)setScope:(FSCalendarScope)scope animated:(BOOL)animated
{
    if (self.floatingMode) return;
    if (self.transitionCoordinator.state != FSCalendarTransitionStateIdle) return;
    
    [self performEnsuringValidLayout:^{
        [self.transitionCoordinator performScopeTransitionFromScope:self.scope toScope:scope animated:animated];
    }];
}

- (void)setPlaceholderType:(FSCalendarPlaceholderType)placeholderType
{
    _placeholderType = placeholderType;
    if (self.hasValidateVisibleLayout) {
        _preferredRowHeight = FSCalendarAutomaticDimension;
        [_collectionView reloadData];
    }
    [self adjustBoundingRectIfNecessary];
}

- (void)setAdjustsBoundingRectWhenChangingMonths:(BOOL)adjustsBoundingRectWhenChangingMonths
{
    _adjustsBoundingRectWhenChangingMonths = adjustsBoundingRectWhenChangingMonths;
    [self adjustBoundingRectIfNecessary];
}

- (void)selectDate:(NSDate *)date
{
    [self selectDate:date scrollToDate:YES];
}

- (void)selectDate:(NSDate *)date scrollToDate:(BOOL)scrollToDate
{
    [self selectDate:date scrollToDate:scrollToDate atMonthPosition:FSCalendarMonthPositionCurrent];
}

- (void)deselectDate:(NSDate *)date
{
    date = [self.gregorian startOfDayForDate:date];
    if (![_selectedDates containsObject:date]) {
        return;
    }
    [_selectedDates removeObject:date];
    [self deselectCounterpartDate:date];
    NSIndexPath *indexPath = [self.calculator indexPathForDate:date];
    if ([_collectionView.indexPathsForSelectedItems containsObject:indexPath]) {
        [_collectionView deselectItemAtIndexPath:indexPath animated:YES];
        FSCalendarCell *cell = (FSCalendarCell *)[_collectionView cellForItemAtIndexPath:indexPath];
        cell.selected = NO;
        [cell configureAppearance];
    }
}

- (void)selectDate:(NSDate *)date scrollToDate:(BOOL)scrollToDate atMonthPosition:(FSCalendarMonthPosition)monthPosition
{
    if (!self.allowsSelection || !date) return;
        
    [self requestBoundingDatesIfNecessary];
    
    FSCalendarAssertDateInBounds(date,self.gregorian,self.minimumDate,self.maximumDate);
    
    NSDate *targetDate = [self.gregorian startOfDayForDate:date];
    NSIndexPath *targetIndexPath = [self.calculator indexPathForDate:targetDate];
    
    BOOL shouldSelect = YES;
    // 跨月份点击
    if (monthPosition==FSCalendarMonthPositionPrevious||monthPosition==FSCalendarMonthPositionNext) {
        if (self.allowsMultipleSelection) {
            if ([self isDateSelected:targetDate]) {
                BOOL shouldDeselect = ![self.delegateProxy respondsToSelector:@selector(calendar:shouldDeselectDate:atMonthPosition:)] || [self.delegateProxy calendar:self shouldDeselectDate:targetDate atMonthPosition:monthPosition];
                if (!shouldDeselect) {
                    return;
                }
            } else {
                shouldSelect &= (![self.delegateProxy respondsToSelector:@selector(calendar:shouldSelectDate:atMonthPosition:)] || [self.delegateProxy calendar:self shouldSelectDate:targetDate atMonthPosition:monthPosition]);
                if (!shouldSelect) {
                    return;
                }
                [_collectionView selectItemAtIndexPath:targetIndexPath animated:YES scrollPosition:UICollectionViewScrollPositionNone];
                [self collectionView:_collectionView didSelectItemAtIndexPath:targetIndexPath];
            }
        } else {
            shouldSelect &= (![self.delegateProxy respondsToSelector:@selector(calendar:shouldSelectDate:atMonthPosition:)] || [self.delegateProxy calendar:self shouldSelectDate:targetDate atMonthPosition:monthPosition]);
            if (shouldSelect) {
                if ([self isDateSelected:targetDate]) {
                    [self.delegateProxy calendar:self didSelectDate:targetDate atMonthPosition:monthPosition];
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
        if (self.selectedDate && !self.allowsMultipleSelection) {
            [self deselectDate:self.selectedDate];
        }
        [_collectionView selectItemAtIndexPath:targetIndexPath animated:NO scrollPosition:UICollectionViewScrollPositionNone];
        FSCalendarCell *cell = (FSCalendarCell *)[_collectionView cellForItemAtIndexPath:targetIndexPath];
        [cell performSelecting];
        [self enqueueSelectedDate:targetDate];
        [self selectCounterpartDate:targetDate];
        
    } else if (![_collectionView.indexPathsForSelectedItems containsObject:targetIndexPath]) {
        [_collectionView selectItemAtIndexPath:targetIndexPath animated:NO scrollPosition:UICollectionViewScrollPositionNone];
    }
    
    if (scrollToDate) {
        if (!shouldSelect) {
            return;
        }
        [self scrollToPageForDate:targetDate animated:YES];
    }
}

- (void)handleScopeGesture:(UIPanGestureRecognizer *)sender
{
    if (self.floatingMode) return;
    [self.transitionCoordinator handleScopeGesture:sender];
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
    
    date = [self.calculator safeDateForDate:date];
    NSInteger scrollOffset = [self.calculator indexPathForDate:date atMonthPosition:FSCalendarMonthPositionCurrent].section;
    
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
        }
        
    } else if (self.hasValidateVisibleLayout) {
        [_collectionViewLayout layoutAttributesForElementsInRect:_collectionView.bounds];
        CGRect headerFrame = [_collectionViewLayout layoutAttributesForSupplementaryViewOfKind:UICollectionElementKindSectionHeader atIndexPath:[NSIndexPath indexPathForItem:0 inSection:scrollOffset]].frame;
        CGPoint targetOffset = CGPointMake(0, MIN(headerFrame.origin.y,MAX(0,_collectionViewLayout.collectionViewContentSize.height-_collectionView.fs_bottom)));
        [_collectionView setContentOffset:targetOffset animated:animated];
    }
    if (!animated) {
        self.calendarHeaderView.scrollOffset = scrollOffset;
    }
}

- (void)scrollToPageForDate:(NSDate *)date animated:(BOOL)animated
{
    if (!date) return;
    if (![self isDateInRange:date]) {
        date = [self.calculator safeDateForDate:date];
        if (!date) return;
    }
    
    if (!self.floatingMode) {
        if ([self isDateInDifferentPage:date]) {
            [self willChangeValueForKey:@"currentPage"];
            NSDate *lastPage = _currentPage;
            switch (self.transitionCoordinator.representingScope) {
                case FSCalendarScopeMonth: {
                    _currentPage = [self.gregorian fs_firstDayOfMonth:date];
                    break;
                }
                case FSCalendarScopeWeek: {
                    _currentPage = [self.gregorian fs_firstDayOfWeek:date];
                    break;
                }
            }
            if (self.hasValidateVisibleLayout) {
                [self.delegateProxy calendarCurrentPageDidChange:self];
                if (_placeholderType != FSCalendarPlaceholderTypeFillSixRows && self.transitionCoordinator.state == FSCalendarTransitionStateIdle) {
                    [self.transitionCoordinator performBoundingRectTransitionFromMonth:lastPage toMonth:_currentPage duration:0.33];
                }
            }
            [self didChangeValueForKey:@"currentPage"];
        }
        [self scrollToDate:_currentPage animated:animated];
    } else {
        [self scrollToDate:[self.gregorian fs_firstDayOfMonth:date] animated:animated];
    }
}


- (BOOL)isDateInRange:(NSDate *)date
{
    BOOL flag = YES;
    flag &= [self.gregorian components:NSCalendarUnitDay fromDate:date toDate:self.minimumDate options:0].day <= 0;
    flag &= [self.gregorian components:NSCalendarUnitDay fromDate:date toDate:self.maximumDate options:0].day >= 0;;
    return flag;
}

- (BOOL)isPageInRange:(NSDate *)page
{
    BOOL flag = YES;
    switch (self.transitionCoordinator.representingScope) {
        case FSCalendarScopeMonth: {
            NSDateComponents *c1 = [self.gregorian components:NSCalendarUnitDay fromDate:[self.gregorian fs_firstDayOfMonth:self.minimumDate] toDate:page options:0];
            flag &= (c1.day>=0);
            if (!flag) break;
            NSDateComponents *c2 = [self.gregorian components:NSCalendarUnitDay fromDate:page toDate:[self.gregorian fs_lastDayOfMonth:self.maximumDate] options:0];
            flag &= (c2.day>=0);
            break;
        }
        case FSCalendarScopeWeek: {
            NSDateComponents *c1 = [self.gregorian components:NSCalendarUnitDay fromDate:[self.gregorian fs_firstDayOfWeek:self.minimumDate] toDate:page options:0];
            flag &= (c1.day>=0);
            if (!flag) break;
            NSDateComponents *c2 = [self.gregorian components:NSCalendarUnitDay fromDate:page toDate:[self.gregorian fs_lastDayOfWeek:self.maximumDate] options:0];
            flag &= (c2.day>=0);
            break;
        }
        default:
            break;
    }
    return flag;
}

- (BOOL)isDateSelected:(NSDate *)date
{
    return [_selectedDates containsObject:date] || [_collectionView.indexPathsForSelectedItems containsObject:[self.calculator indexPathForDate:date]];
}

- (BOOL)isDateInDifferentPage:(NSDate *)date
{
    if (self.floatingMode) {
        return ![self.gregorian isDate:date equalToDate:_currentPage toUnitGranularity:NSCalendarUnitMonth];
    }
    switch (_scope) {
        case FSCalendarScopeMonth:
            return ![self.gregorian isDate:date equalToDate:_currentPage toUnitGranularity:NSCalendarUnitMonth];
        case FSCalendarScopeWeek:
            return ![self.gregorian isDate:date equalToDate:_currentPage toUnitGranularity:NSCalendarUnitWeekOfYear];
    }
}

- (BOOL)hasValidateVisibleLayout
{
#if TARGET_INTERFACE_BUILDER
    return YES;
#else
    return self.superview  && !CGRectIsEmpty(_collectionView.frame) && !CGSizeEqualToSize(_collectionViewLayout.collectionViewContentSize, CGSizeZero);
#endif
}

- (void)invalidateDateTools
{
    _gregorian.locale = _locale;
    _gregorian.timeZone = _timeZone;
    _gregorian.firstWeekday = _firstWeekday;
    _formatter.calendar = _gregorian;
    _formatter.timeZone = _timeZone;
    _formatter.locale = _locale;
}

- (void)invalidateLayout
{
    if (!self.floatingMode) {
        
        if (!_calendarHeaderView) {
            
            FSCalendarHeaderView *headerView = [[FSCalendarHeaderView alloc] initWithFrame:CGRectZero];
            headerView.calendar = self;
            headerView.scrollEnabled = _scrollEnabled;
            [_contentView addSubview:headerView];
            self.calendarHeaderView = headerView;
            
        }
        
        if (!_calendarWeekdayView) {
            FSCalendarWeekdayView *calendarWeekdayView = [[FSCalendarWeekdayView alloc] initWithFrame:CGRectZero];
            calendarWeekdayView.calendar = self;
            [_contentView addSubview:calendarWeekdayView];
            _calendarWeekdayView = calendarWeekdayView;
        }
        
        if (_scrollEnabled) {
            if (!_deliver) {
                FSCalendarHeaderTouchDeliver *deliver = [[FSCalendarHeaderTouchDeliver alloc] initWithFrame:CGRectZero];
                deliver.header = _calendarHeaderView;
                deliver.calendar = self;
                [_contentView addSubview:deliver];
                self.deliver = deliver;
            }
        } else if (_deliver) {
            [_deliver removeFromSuperview];
        }
        
        _collectionView.pagingEnabled = YES;
        _collectionViewLayout.scrollDirection = (UICollectionViewScrollDirection)self.scrollDirection;
        
    } else {
        
        [self.calendarHeaderView removeFromSuperview];
        [self.deliver removeFromSuperview];
        [self.calendarWeekdayView removeFromSuperview];
        
        _collectionView.pagingEnabled = NO;
        _collectionViewLayout.scrollDirection = UICollectionViewScrollDirectionVertical;
        
    }
    
    _preferredHeaderHeight = FSCalendarAutomaticDimension;
    _preferredWeekdayHeight = FSCalendarAutomaticDimension;
    _preferredRowHeight = FSCalendarAutomaticDimension;
    _needsAdjustingViewFrame = YES;
    [self setNeedsLayout];
}

- (void)invalidateHeaders
{
    [self.calendarHeaderView.collectionView reloadData];
    [self.visibleStickyHeaders makeObjectsPerformSelector:@selector(configureAppearance)];
}

- (void)invalidateAppearanceForCell:(FSCalendarCell *)cell forDate:(NSDate *)date
{
#define FSCalendarInvalidateCellAppearance(SEL1,SEL2) \
    cell.SEL1 = [self.delegateProxy calendar:self appearance:self.appearance SEL2:date];
    
#define FSCalendarInvalidateCellAppearanceWithDefault(SEL1,SEL2,DEFAULT) \
    if ([self.delegateProxy respondsToSelector:@selector(calendar:appearance:SEL2:)]) { \
        cell.SEL1 = [self.delegateProxy calendar:self appearance:self.appearance SEL2:date]; \
    } else { \
        cell.SEL1 = DEFAULT; \
    }
    
    FSCalendarInvalidateCellAppearance(preferredFillDefaultColor,fillDefaultColorForDate);
    FSCalendarInvalidateCellAppearance(preferredFillSelectionColor,fillSelectionColorForDate);
    FSCalendarInvalidateCellAppearance(preferredTitleDefaultColor,titleDefaultColorForDate);
    FSCalendarInvalidateCellAppearance(preferredTitleSelectionColor,titleSelectionColorForDate);

    FSCalendarInvalidateCellAppearanceWithDefault(preferredTitleOffset,titleOffsetForDate,CGPointInfinity);
    if (cell.subtitle) {
        FSCalendarInvalidateCellAppearance(preferredSubtitleDefaultColor,subtitleDefaultColorForDate);
        FSCalendarInvalidateCellAppearance(preferredSubtitleSelectionColor,subtitleSelectionColorForDate);
        FSCalendarInvalidateCellAppearanceWithDefault(preferredSubtitleOffset,subtitleOffsetForDate,CGPointInfinity);
    }
    if (cell.numberOfEvents) {
        FSCalendarInvalidateCellAppearance(preferredEventDefaultColors,eventDefaultColorsForDate);
        FSCalendarInvalidateCellAppearance(preferredEventSelectionColors,eventSelectionColorsForDate);
        FSCalendarInvalidateCellAppearanceWithDefault(preferredEventOffset,eventOffsetForDate,CGPointInfinity);
    }
    FSCalendarInvalidateCellAppearance(preferredBorderDefaultColor,borderDefaultColorForDate);
    FSCalendarInvalidateCellAppearance(preferredBorderSelectionColor,borderSelectionColorForDate);
    FSCalendarInvalidateCellAppearanceWithDefault(preferredBorderRadius,borderRadiusForDate,-1);

    if (cell.image) {
        FSCalendarInvalidateCellAppearanceWithDefault(preferredImageOffset,imageOffsetForDate,CGPointInfinity);
    }
    
#undef FSCalendarInvalidateCellAppearance
#undef FSCalendarInvalidateCellAppearanceWithDefault
    
}

- (void)reloadDataForCell:(FSCalendarCell *)cell atIndexPath:(NSIndexPath *)indexPath
{
    cell.calendar = self;
    NSDate *date = [self.calculator dateForIndexPath:indexPath];
    cell.image = [self.dataSourceProxy calendar:self imageForDate:date];
    cell.numberOfEvents = [self.dataSourceProxy calendar:self numberOfEventsForDate:date];
    cell.titleLabel.text = [self.dataSourceProxy calendar:self titleForDate:date] ?: @([self.gregorian component:NSCalendarUnitDay fromDate:date]).stringValue;
    cell.subtitle  = [self.dataSourceProxy calendar:self subtitleForDate:date];
    cell.selected = [_selectedDates containsObject:date];
    cell.dateIsToday = self.today?[self.gregorian isDate:date inSameDayAsDate:self.today]:NO;
    cell.weekend = [self.gregorian isDateInWeekend:date];
    cell.monthPosition = [self.calculator monthPositionForIndexPath:indexPath];
    switch (self.transitionCoordinator.representingScope) {
        case FSCalendarScopeMonth: {
            cell.placeholder = (cell.monthPosition == FSCalendarMonthPositionPrevious || cell.monthPosition == FSCalendarMonthPositionNext) || ![self isDateInRange:date];
            if (cell.placeholder) {
                cell.selected &= _pagingEnabled;
                cell.dateIsToday &= _pagingEnabled;
            }
            break;
        }
        case FSCalendarScopeWeek: {
            cell.placeholder = ![self isDateInRange:date];
            break;
        }
    }
    // Synchronize selecion state to the collection view, otherwise delegate methods would not be triggered.
    if (cell.selected) {
        [self.collectionView selectItemAtIndexPath:indexPath animated:NO scrollPosition:UICollectionViewScrollPositionNone];
    } else {
        [self.collectionView deselectItemAtIndexPath:indexPath animated:NO];
    }
    [self invalidateAppearanceForCell:cell forDate:date];
    [cell configureAppearance];
}


- (void)handleSwipeToChoose:(UILongPressGestureRecognizer *)pressGesture
{
    switch (pressGesture.state) {
        case UIGestureRecognizerStateBegan:
        case UIGestureRecognizerStateChanged: {
            NSIndexPath *indexPath = [self.collectionView indexPathForItemAtPoint:[pressGesture locationInView:self.collectionView]];
            if (indexPath && ![indexPath isEqual:self.lastPressedIndexPath]) {
                NSDate *date = [self.calculator dateForIndexPath:indexPath];
                FSCalendarMonthPosition monthPosition = [self.calculator monthPositionForIndexPath:indexPath];
                if (![self.selectedDates containsObject:date] && [self collectionView:self.collectionView shouldSelectItemAtIndexPath:indexPath]) {
                    [self selectDate:date scrollToDate:NO atMonthPosition:monthPosition];
                    [self collectionView:self.collectionView didSelectItemAtIndexPath:indexPath];
                } else if (self.collectionView.allowsMultipleSelection && [self collectionView:self.collectionView shouldDeselectItemAtIndexPath:indexPath]) {
                    [self deselectDate:date];
                    [self collectionView:self.collectionView didDeselectItemAtIndexPath:indexPath];
                }
            }
            self.lastPressedIndexPath = indexPath;
            break;
        }
        case UIGestureRecognizerStateEnded:
        case UIGestureRecognizerStateCancelled: {
            self.lastPressedIndexPath = nil;
            break;
        }
        default:
            break;
    }
   
}

- (void)selectCounterpartDate:(NSDate *)date
{
    if (_placeholderType == FSCalendarPlaceholderTypeNone) return;
    if (self.scope == FSCalendarScopeWeek) return;
    NSInteger numberOfDays = [self.gregorian fs_numberOfDaysInMonth:date];
    NSInteger day = [self.gregorian component:NSCalendarUnitDay fromDate:date];
    FSCalendarCell *cell;
    if (day < numberOfDays/2+1) {
        cell = [self cellForDate:date atMonthPosition:FSCalendarMonthPositionNext];
    } else {
        cell = [self cellForDate:date atMonthPosition:FSCalendarMonthPositionPrevious];
    }
    if (cell) {
        cell.selected = YES;
        if (self.collectionView.allowsMultipleSelection) {   
            [self.collectionView selectItemAtIndexPath:[self.collectionView indexPathForCell:cell] animated:NO scrollPosition:UICollectionViewScrollPositionNone];
        }
    }
    [cell configureAppearance];
}

- (void)deselectCounterpartDate:(NSDate *)date
{
    if (_placeholderType == FSCalendarPlaceholderTypeNone) return;
    if (self.scope == FSCalendarScopeWeek) return;
    NSInteger numberOfDays = [self.gregorian fs_numberOfDaysInMonth:date];
    NSInteger day = [self.gregorian component:NSCalendarUnitDay fromDate:date];
    FSCalendarCell *cell;
    if (day < numberOfDays/2+1) {
        cell = [self cellForDate:date atMonthPosition:FSCalendarMonthPositionNext];
    } else {
        cell = [self cellForDate:date atMonthPosition:FSCalendarMonthPositionPrevious];
    }
    if (cell) {
        cell.selected = NO;
        [self.collectionView deselectItemAtIndexPath:[self.collectionView indexPathForCell:cell] animated:NO];
    }
    [cell configureAppearance];
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
    return [self.visibleSectionHeaders.dictionaryRepresentation allValues];
}

- (void)invalidateViewFrames
{
    _needsAdjustingViewFrame = YES;
    
    _preferredHeaderHeight  = FSCalendarAutomaticDimension;
    _preferredWeekdayHeight = FSCalendarAutomaticDimension;
    _preferredRowHeight     = FSCalendarAutomaticDimension;
    
    [self setNeedsLayout];
    
}

// The best way to detect orientation
// http://stackoverflow.com/questions/25830448/what-is-the-best-way-to-detect-orientation-in-an-app-extension/26023538#26023538
- (FSCalendarOrientation)currentCalendarOrientation
{
    CGFloat scale = [UIScreen mainScreen].scale;
    CGSize nativeSize = [UIScreen mainScreen].currentMode.size;
    CGSize sizeInPoints = [UIScreen mainScreen].bounds.size;
    FSCalendarOrientation orientation = scale * sizeInPoints.width == nativeSize.width ? FSCalendarOrientationPortrait : FSCalendarOrientationLandscape;
    return orientation;
}

- (void)adjustMonthPosition
{
    [self requestBoundingDatesIfNecessary];
    NSDate *targetPage = self.pagingEnabled?self.currentPage:(self.currentPage?:self.selectedDate);
    [self scrollToPageForDate:targetPage animated:NO];
}

- (BOOL)requestBoundingDatesIfNecessary
{
    if (_needsRequestingBoundingDates) {
        _needsRequestingBoundingDates = NO;
        self.formatter.dateFormat = @"yyyy-MM-dd";
        NSDate *newMin = [self.dataSourceProxy minimumDateForCalendar:self]?:[self.formatter dateFromString:@"1970-01-01"];
        newMin = [self.gregorian startOfDayForDate:newMin];
        NSDate *newMax = [self.dataSourceProxy maximumDateForCalendar:self]?:[self.formatter dateFromString:@"2099-12-31"];
        newMax = [self.gregorian startOfDayForDate:newMax];
        
        NSAssert([self.gregorian compareDate:newMin toDate:newMax toUnitGranularity:NSCalendarUnitDay] != NSOrderedDescending, @"The minimum date of calendar should be earlier than the maximum.");
        
        BOOL res = ![self.gregorian isDate:newMin inSameDayAsDate:_minimumDate] || ![self.gregorian isDate:newMax inSameDayAsDate:_maximumDate];
        _minimumDate = newMin;
        _maximumDate = newMax;
        [self.calculator reloadSections];
        
        return res;
    }
    return NO;
}

- (void)configureAppearance
{
    [self.visibleCells makeObjectsPerformSelector:@selector(configureAppearance)];
    [self.visibleStickyHeaders makeObjectsPerformSelector:@selector(configureAppearance)];
    [self.calendarHeaderView configureAppearance];
    [self.calendarWeekdayView configureAppearance];
}

- (void)adjustBoundingRectIfNecessary
{
    if (self.placeholderType == FSCalendarPlaceholderTypeFillSixRows) {
        return;
    }
    if (!self.adjustsBoundingRectWhenChangingMonths) {
        return;
    }
    [self performEnsuringValidLayout:^{
        [self.transitionCoordinator performBoundingRectTransitionFromMonth:nil toMonth:self.currentPage duration:0];
    }];
}

- (void)performEnsuringValidLayout:(void (^)(void))block
{
    if (self.collectionView.visibleCells.count) {
        block();
    } else {
        [self setNeedsLayout];
        [self.didLayoutOperations addObject:[NSBlockOperation blockOperationWithBlock:block]];
    }
}

- (void)executePendingOperationsIfNeeded
{
    NSArray<NSOperation *> *operations = nil;
    if (self.didLayoutOperations.count) {
        operations = self.didLayoutOperations.copy;
        [self.didLayoutOperations removeAllObjects];
    }
    [operations makeObjectsPerformSelector:@selector(start)];
}


@end


