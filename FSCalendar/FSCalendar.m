//
//  FSCalendar.m
//  FSCalendar
//
//  Created by Wenchao Ding on 29/1/15.
//  Copyright © 2016 Wenchao Ding. All rights reserved.
//

#import "FSCalendar.h"
#import "FSCalendarHeader.h"
#import "FSCalendarStickyHeader.h"
#import "FSCalendarCell.h"
#import "FSCalendarFlowLayout.h"
#import "FSCalendarAnimator.h"
#import "FSCalendarScopeHandle.h"

#import "FSCalendarExtensions.h"
#import "FSCalendarDynamicHeader.h"
#import "FSCalendarCollectionView.h"

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
        [NSException raise:@"FSCalendar date out of bounds exception" format:@"Target date %@ beyond bounds [%@ - %@]", [formatter stringFromDate:date], [formatter stringFromDate:minimumDate], [formatter stringFromDate:date]];
    }
}

NS_ASSUME_NONNULL_END

typedef NS_ENUM(NSUInteger, FSCalendarOrientation) {
    FSCalendarOrientationLandscape,
    FSCalendarOrientationPortrait
};

@interface FSCalendar (DataSourceAndDelegate)

- (NSInteger)numberOfEventsForDate:(NSDate *)date;
- (NSString *)titleForDate:(NSDate *)date;
- (NSString *)subtitleForDate:(NSDate *)date;
- (UIImage *)imageForDate:(NSDate *)date;
- (NSDate *)minimumDateForCalendar;
- (NSDate *)maximumDateForCalendar;

- (UIColor *)preferredFillSelectionColorForDate:(NSDate *)date;
- (UIColor *)preferredTitleDefaultColorForDate:(NSDate *)date;
- (UIColor *)preferredTitleSelectionColorForDate:(NSDate *)date;
- (UIColor *)preferredSubtitleDefaultColorForDate:(NSDate *)date;
- (UIColor *)preferredSubtitleSelectionColorForDate:(NSDate *)date;
- (UIColor *)preferredBorderDefaultColorForDate:(NSDate *)date;
- (UIColor *)preferredBorderSelectionColorForDate:(NSDate *)date;
- (CGPoint)preferredTitleOffsetForDate:(NSDate *)date;
- (CGPoint)preferredSubtitleOffsetForDate:(NSDate *)date;
- (CGPoint)preferredImageOffsetForDate:(NSDate *)date;
- (CGPoint)preferredEventOffsetForDate:(NSDate *)date;
- (NSArray<UIColor *> *)preferredEventDefaultColorsForDate:(NSDate *)date;
- (NSArray<UIColor *> *)preferredEventSelectionColorsForDate:(NSDate *)date;
- (CGFloat)preferredBorderRadiusForDate:(NSDate *)date;


- (BOOL)shouldSelectDate:(NSDate *)date;
- (void)didSelectDate:(NSDate *)date;
- (BOOL)shouldDeselectDate:(NSDate *)date;
- (void)didDeselectDate:(NSDate *)date;
- (void)currentPageDidChange;
- (BOOL)boundingRectWillChange:(BOOL)animated;

@end

@interface FSCalendar (Private)

- (NSDate *)beginingOfMonth:(NSDate *)month;
- (NSDate *)endOfMonth:(NSDate *)month;
- (NSDate *)beginingOfWeek:(NSDate *)week;
- (NSDate *)endOfWeek:(NSDate *)week;
- (NSDate *)middleOfWeek:(NSDate *)week;
- (NSInteger)numberOfDatesInMonth:(NSDate *)month;

@end

@interface FSCalendar ()<UICollectionViewDataSource, UICollectionViewDelegate>
{
    NSMutableArray  *_selectedDates;
}
@property (strong, nonatomic) NSMutableArray             *weekdays;
@property (strong, nonatomic) NSMapTable                 *stickyHeaderMapTable;

@property (strong, nonatomic) NSCalendar *gregorian;
@property (strong, nonatomic) NSDateFormatter *formatter;
@property (strong, nonatomic) NSDateComponents *components;
@property (strong, nonatomic) NSTimeZone *timeZone;

@property (weak  , nonatomic) UIView                     *contentView;
@property (weak  , nonatomic) UIView                     *daysContainer;
@property (weak  , nonatomic) UIView                     *topBorder;
@property (weak  , nonatomic) UIView                     *bottomBorder;
@property (weak  , nonatomic) FSCalendarScopeHandle      *scopeHandle;
@property (weak  , nonatomic) FSCalendarCollectionView   *collectionView;
@property (weak  , nonatomic) FSCalendarFlowLayout       *collectionViewLayout;
@property (strong, nonatomic) FSCalendarAnimator         *animator;

@property (weak  , nonatomic) FSCalendarHeader           *header;
@property (weak  , nonatomic) FSCalendarHeaderTouchDeliver *deliver;

@property (assign, nonatomic) BOOL                       needsAdjustingMonthPosition;
@property (assign, nonatomic) BOOL                       needsAdjustingViewFrame;
@property (assign, nonatomic) BOOL                       needsAdjustingTextSize;
@property (assign, nonatomic) BOOL                       needsLayoutForWeekMode;
@property (assign, nonatomic) BOOL                       hasRequestedBoundingDates;
@property (assign, nonatomic) BOOL                       supressEvent;
@property (assign, nonatomic) CGFloat                    preferredHeaderHeight;
@property (assign, nonatomic) CGFloat                    preferredWeekdayHeight;
@property (assign, nonatomic) CGFloat                    preferredRowHeight;
@property (assign, nonatomic) CGFloat                    preferredPadding;
@property (assign, nonatomic) FSCalendarOrientation      orientation;

@property (readonly, nonatomic) BOOL floatingMode;
@property (readonly, nonatomic) BOOL hasValidateVisibleLayout;
@property (readonly, nonatomic) NSArray *visibleStickyHeaders;
@property (readonly, nonatomic) FSCalendarOrientation currentCalendarOrientation;

@property (readonly, nonatomic) id<FSCalendarDelegateAppearance> delegateAppearance;

- (void)orientationDidChange:(NSNotification *)notification;

- (NSDate *)dateForIndexPath:(NSIndexPath *)indexPath;
- (NSDate *)dateForIndexPath:(NSIndexPath *)indexPath scope:(FSCalendarScope)scope;
- (NSIndexPath *)indexPathForDate:(NSDate *)date;
- (NSIndexPath *)indexPathForDate:(NSDate *)date scope:(FSCalendarScope)scope;
- (CGSize)sizeThatFits:(CGSize)size scope:(FSCalendarScope)scope;

- (NSInteger)numberOfHeadPlaceholdersForMonth:(NSDate *)month;
- (NSInteger)numberOfRowsInMonth:(NSDate *)month;

- (void)scrollToDate:(NSDate *)date;
- (void)scrollToDate:(NSDate *)date animated:(BOOL)animated;
- (void)scrollToPageForDate:(NSDate *)date animated:(BOOL)animated;

- (BOOL)isPageInRange:(NSDate *)page;
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

- (void)invalidateWeekdayFont;
- (void)invalidateWeekdayTextColor;

- (void)invalidateViewFrames;

- (void)selectCounterpartDate:(NSDate *)date;
- (void)deselectCounterpartDate:(NSDate *)date;

- (void)reloadDataForCell:(FSCalendarCell *)cell atIndexPath:(NSIndexPath *)indexPath;
- (void)reloadVisibleCells;

- (void)requestBoundingDatesIfNecessary;

@end

@implementation FSCalendar

@dynamic selectedDate;
@synthesize scrollDirection = _scrollDirection, firstWeekday = _firstWeekday, appearance = _appearance;

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
    _components = [[NSDateComponents alloc] init];
    _formatter = [[NSDateFormatter alloc] init];
    _formatter.dateFormat = @"yyyy-MM-dd";
    _locale = [NSLocale currentLocale];
    _timeZone = [NSTimeZone localTimeZone];
    _firstWeekday = 1;
    [self invalidateDateTools];
    
    
    _today = [self.gregorian dateBySettingHour:0 minute:0 second:0 ofDate:[NSDate date] options:0];
    _currentPage = [self beginingOfMonth:_today];
    
#if TARGET_INTERFACE_BUILDER
    _minimumDate = [self.gregorian dateByAddingUnit:NSCalendarUnitMonth value:-1 toDate:_today options:0];
    _maximumDate = [self.gregorian dateByAddingUnit:NSCalendarUnitMonth value:4 toDate:_today options:0];
#else
    _minimumDate = [self.formatter dateFromString:@"1970-01-01"];
    _maximumDate = [self.formatter dateFromString:@"2099-12-31"];
#endif
    
    
    _headerHeight     = FSCalendarAutomaticDimension;
    _weekdayHeight    = FSCalendarAutomaticDimension;
    
    _preferredHeaderHeight  = FSCalendarAutomaticDimension;
    _preferredWeekdayHeight = FSCalendarAutomaticDimension;
    _preferredRowHeight     = FSCalendarAutomaticDimension;
    _preferredPadding       = FSCalendarAutomaticDimension;
    _lineHeightMultiplier    = 1.0;
    
    _scrollDirection = FSCalendarScrollDirectionHorizontal;
    _scope = FSCalendarScopeMonth;
    _selectedDates = [NSMutableArray arrayWithCapacity:1];
    
    _pagingEnabled = YES;
    _scrollEnabled = YES;
    _needsAdjustingViewFrame = YES;
    _needsAdjustingTextSize = YES;
    _needsAdjustingMonthPosition = YES;
    _stickyHeaderMapTable = [NSMapTable weakToWeakObjectsMapTable];
    _orientation = self.currentCalendarOrientation;
    _focusOnSingleSelectedDate = YES;
    _placeholderType = FSCalendarPlaceholderTypeFillSixRows;
    
    UIView *contentView = [[UIView alloc] initWithFrame:CGRectZero];
    contentView.backgroundColor = [UIColor clearColor];
    [self addSubview:contentView];
    self.contentView = contentView;
    
    UIView *daysContainer = [[UIView alloc] initWithFrame:CGRectZero];
    daysContainer.backgroundColor = [UIColor clearColor];
    daysContainer.clipsToBounds = YES;
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
    
#if __IPHONE_OS_VERSION_MAX_ALLOWED >= __IPHONE_10_0
    if ([collectionView respondsToSelector:@selector(setPrefetchingEnabled:)]) {
        collectionView.prefetchingEnabled = NO;
    }
#endif
    
    if (!FSCalendarInAppExtension) {
        
        UIView *view = [[UIView alloc] initWithFrame:CGRectZero];
        view.backgroundColor = FSCalendarStandardSeparatorColor;
        [self addSubview:view];
        self.topBorder = view;
        
        view = [[UIView alloc] initWithFrame:CGRectZero];
        view.backgroundColor = FSCalendarStandardSeparatorColor;
        [self addSubview:view];
        self.bottomBorder = view;
        
    }
    
    [self invalidateLayout];
    
    self.animator = [[FSCalendarAnimator alloc] init];
    self.animator.calendar = self;
    self.animator.collectionView = self.collectionView;
    self.animator.collectionViewLayout = self.collectionViewLayout;
    
    UIPanGestureRecognizer *panGesture = [[UIPanGestureRecognizer alloc] initWithTarget:self.animator action:@selector(handlePan:)];
    panGesture.delegate = self.animator;
    panGesture.minimumNumberOfTouches = 1;
    panGesture.maximumNumberOfTouches = 2;
    panGesture.enabled = NO;
    [self.daysContainer addGestureRecognizer:panGesture];
    _scopeGesture = panGesture;
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(orientationDidChange:) name:UIDeviceOrientationDidChangeNotification object:nil];
    
}

- (void)dealloc
{
    _collectionView.delegate = nil;
    _collectionView.dataSource = nil;
    
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIDeviceOrientationDidChangeNotification object:nil];
}

#pragma mark - Overriden methods

- (void)setBounds:(CGRect)bounds
{
    [super setBounds:bounds];
    if (!CGRectIsEmpty(bounds) && self.animator.state == FSCalendarTransitionStateIdle) {
        [self invalidateViewFrames];
    }
}

- (void)setFrame:(CGRect)frame
{
    [super setFrame:frame];
    if (!CGRectIsEmpty(frame) && self.animator.state == FSCalendarTransitionStateIdle) {
        [self invalidateViewFrames];
    }
}

- (void)layoutSubviews
{
    [super layoutSubviews];

    _supressEvent = YES;
    
    if (_needsAdjustingViewFrame) {
        _needsAdjustingViewFrame = NO;
        
        if (CGSizeEqualToSize(_animator.cachedMonthSize, CGSizeZero)) {
            _animator.cachedMonthSize = self.frame.size;
        }
        
        BOOL needsAdjustingBoundingRect = (self.scope == FSCalendarScopeMonth) &&
                                          (self.placeholderType != FSCalendarPlaceholderTypeFillSixRows) &&
                                          !self.hasValidateVisibleLayout;
        
        if (_scopeHandle) {
            CGFloat scopeHandleHeight = self.animator.cachedMonthSize.height*0.08;
            _contentView.frame = CGRectMake(0, 0, self.fs_width, self.fs_height-scopeHandleHeight);
            _scopeHandle.frame = CGRectMake(0, _contentView.fs_bottom, self.fs_width, scopeHandleHeight);
        } else {
            _contentView.frame = self.bounds;
        }

        if (_needsLayoutForWeekMode) _scope = FSCalendarScopeMonth;
        
        CGFloat headerHeight = self.preferredHeaderHeight;
        CGFloat weekdayHeight = self.preferredWeekdayHeight;
        CGFloat rowHeight = self.preferredRowHeight;
        CGFloat weekdayWidth = self.fs_width/_weekdays.count;
        CGFloat padding = self.preferredPadding;
        if (self.scrollDirection == UICollectionViewScrollDirectionHorizontal) {
            padding = FSCalendarFloor(padding);
            rowHeight = FSCalendarFloor(rowHeight*2)*0.5; // Round to nearest multiple of 0.5. e.g. (16.8->16.5),(16.2->16.0)
        }
        
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
                    CGFloat currentHeight = rowHeight*[self numberOfRowsInMonth:self.currentPage] + padding*2;
                    _daysContainer.frame = CGRectMake(0, headerHeight+weekdayHeight, self.fs_width, currentHeight);
                    _collectionView.frame = CGRectMake(0, 0, _daysContainer.fs_width, contentHeight);
                    if (needsAdjustingBoundingRect) {
                        self.animator.state = FSCalendarTransitionStateInProgress;
                        [self boundingRectWillChange:NO];
                        self.animator.state = FSCalendarTransitionStateIdle;
                    }
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
        _topBorder.frame = CGRectMake(0, -1, self.fs_width, 1);
        _bottomBorder.frame = CGRectMake(0, self.fs_height, self.fs_width, 1);
        _scopeHandle.fs_bottom = _bottomBorder.fs_top;
        
    }
    if (_needsAdjustingTextSize) {
        _needsAdjustingTextSize = NO;
        [_appearance adjustTitleIfNecessary];
    }
    
    if (_needsLayoutForWeekMode) {
        _needsLayoutForWeekMode = NO;
        _scope = FSCalendarScopeWeek;
        [self.animator performScopeTransitionFromScope:FSCalendarScopeMonth toScope:FSCalendarScopeWeek animated:NO];
    } else {
        if (_needsAdjustingMonthPosition) {
            _needsAdjustingMonthPosition = NO;
            [self requestBoundingDatesIfNecessary];
            _supressEvent = NO;
            [self scrollToPageForDate:_pagingEnabled?_currentPage:(_currentPage?:self.selectedDate) animated:NO];
        }
    }
    
    _supressEvent = NO;
    
}

#if TARGET_INTERFACE_BUILDER
- (void)prepareForInterfaceBuilder
{
    NSDate *date = [NSDate date];
    [self selectDate:[self dateWithYear:[self yearOfDate:date] month:[self monthOfDate:date] day:_appearance.fakedSelectedDay?:1]];
}
#endif

- (CGSize)sizeThatFits:(CGSize)size
{
    switch (self.animator.transition) {
        case FSCalendarTransitionNone:
            return [self sizeThatFits:size scope:_scope];
        case FSCalendarTransitionWeekToMonth:
            if (self.animator.state == FSCalendarTransitionStateInProgress) {
                return [self sizeThatFits:size scope:FSCalendarScopeMonth];
            }
        case FSCalendarTransitionMonthToWeek:
            break;
    }
    return [self sizeThatFits:size scope:FSCalendarScopeWeek];
}

- (CGSize)sizeThatFits:(CGSize)size scope:(FSCalendarScope)scope
{
    CGFloat headerHeight = self.preferredHeaderHeight;
    CGFloat weekdayHeight = self.preferredWeekdayHeight;
    CGFloat rowHeight = self.preferredRowHeight;
    CGFloat paddings = self.preferredPadding*2;
    
    if (!self.floatingMode) {
        switch (scope) {
            case FSCalendarScopeMonth: {
                CGFloat height = weekdayHeight + headerHeight + [self numberOfRowsInMonth:_currentPage]*rowHeight + paddings;
                height += _scopeHandle.fs_height;
                return CGSizeMake(size.width, height);
            }
            case FSCalendarScopeWeek: {
                CGFloat height = weekdayHeight + headerHeight + rowHeight + paddings;
                height += _scopeHandle.fs_height;
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
    if (self.animator.transition == FSCalendarTransitionWeekToMonth) {
        NSInteger sections = [self.gregorian components:NSCalendarUnitMonth fromDate:[self beginingOfMonth:self.minimumDate] toDate:self.maximumDate options:0].month + 1;
        return sections;
    }
    switch (_scope) {
        case FSCalendarScopeMonth: {
            NSInteger sections = [self.gregorian components:NSCalendarUnitMonth fromDate:[self beginingOfMonth:self.minimumDate] toDate:self.maximumDate options:0].month + 1;
            return sections;
        }
        case FSCalendarScopeWeek: {
            NSInteger sections = [self.gregorian components:NSCalendarUnitWeekOfYear fromDate:[self beginingOfWeek:self.minimumDate] toDate:self.maximumDate options:0].weekOfYear + 1;
            return sections;
        }
    }
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    if (self.animator.transition == FSCalendarTransitionWeekToMonth && self.animator.state == FSCalendarTransitionStateInProgress) {
        return 42;
    }
    if (!self.floatingMode) {
        switch (_scope) {
            case FSCalendarScopeMonth: {
                return 42;
            }
            case FSCalendarScopeWeek: {
                return 7;
            }
        }
    } else {
        NSDate *currentPage = [self.gregorian dateByAddingUnit:NSCalendarUnitMonth value:section toDate:[self beginingOfMonth:_minimumDate] options:0];
        NSInteger numberOfRows = [self numberOfRowsInMonth:currentPage];
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
            stickyHeader.month = [self.gregorian dateByAddingUnit:NSCalendarUnitMonth value:indexPath.section toDate:[self beginingOfMonth:_minimumDate] options:0];
            [stickyHeader setNeedsLayout];
            NSArray *allKeys = [_stickyHeaderMapTable.dictionaryRepresentation allKeysForObject:stickyHeader];
            if (allKeys.count) {
                [allKeys enumerateObjectsUsingBlock:^(NSIndexPath *itemIndexPath, NSUInteger idx, BOOL *stop) {
                    [_stickyHeaderMapTable removeObjectForKey:itemIndexPath];
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
        if (_placeholderType == FSCalendarPlaceholderTypeNone) return NO;
        if ([self isDateInRange:cell.date]) {
            [self selectDate:cell.date scrollToDate:YES forPlaceholder:YES];
        }
        return NO;
    }
    NSDate *targetDate = [self dateForIndexPath:indexPath];
    if ([self isDateSelected:targetDate]) {
        // Click on a selected date in multiple-selection mode
        if (self.allowsMultipleSelection) {
            if ([self collectionView:collectionView shouldDeselectItemAtIndexPath:indexPath]) {
                [collectionView deselectItemAtIndexPath:indexPath animated:YES];
                [self collectionView:collectionView didDeselectItemAtIndexPath:indexPath];
            }
        } else {
            // Click on a selected date in single-selection mode
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
    if (!self.allowsMultipleSelection && self.selectedDate) {
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
    if (_supressEvent) {
        return;
    }
    if (self.floatingMode && _collectionView.indexPathsForVisibleItems.count) {
        if (!self.window) return;
        // Do nothing on bouncing
        if (_collectionView.contentOffset.y < 0 || _collectionView.contentOffset.y > _collectionView.contentSize.height-_collectionView.fs_height) {
            return;
        }
        NSDate *currentPage = _currentPage;
        CGPoint significantPoint = CGPointMake(_collectionView.fs_width*0.5,MIN(self.preferredRowHeight*2.75, _collectionView.fs_height*0.5)+_collectionView.contentOffset.y);
        NSIndexPath *significantIndexPath = [_collectionView indexPathForItemAtPoint:significantPoint];
        if (significantIndexPath) {
            currentPage = [self.gregorian dateByAddingUnit:NSCalendarUnitMonth value:significantIndexPath.section toDate:[self beginingOfMonth:_minimumDate] options:0];
        } else {
            FSCalendarStickyHeader *significantHeader = [_stickyHeaderMapTable.dictionaryRepresentation.allValues filteredArrayUsingPredicate:[NSPredicate predicateWithBlock:^BOOL(FSCalendarStickyHeader * _Nonnull evaluatedObject, NSDictionary<NSString *,id> * _Nullable bindings) {
                return CGRectContainsPoint(evaluatedObject.frame, significantPoint);
            }]].firstObject;
            if (significantHeader) {
                currentPage = significantHeader.month;
            }
        }
        
        if (![self.gregorian isDate:currentPage equalToDate:_currentPage toUnitGranularity:NSCalendarUnitMonth]) {
            [self willChangeValueForKey:@"currentPage"];
            _currentPage = currentPage;
            [self currentPageDidChange];
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
        _header.scrollOffset = scrollOffset;
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
            NSDate *minimumPage = [self beginingOfMonth:_minimumDate];
            targetPage = [self.gregorian dateByAddingUnit:NSCalendarUnitMonth value:sections toDate:minimumPage options:0];
            break;
        }
        case FSCalendarScopeWeek: {
            NSDate *minimumPage = [self beginingOfWeek:_minimumDate];
            targetPage = [self.gregorian dateByAddingUnit:NSCalendarUnitWeekOfYear value:sections toDate:minimumPage options:0];
            break;
        }
    }
    BOOL shouldTriggerPageChange = [self isDateInDifferentPage:targetPage];
    if (shouldTriggerPageChange) {
        NSDate *lastPage = _currentPage;
        [self willChangeValueForKey:@"currentPage"];
        _currentPage = targetPage;
        [self currentPageDidChange];
        if (_placeholderType != FSCalendarPlaceholderTypeFillSixRows) {
            [self.animator performBoundingRectTransitionFromMonth:lastPage toMonth:_currentPage duration:0.25];
        }
        [self didChangeValueForKey:@"currentPage"];
    }
    
    // Disable all inner gestures to avoid missing event
    [scrollView.gestureRecognizers enumerateObjectsUsingBlock:^(__kindof UIGestureRecognizer * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if (obj != scrollView.panGestureRecognizer) {
            obj.enabled = NO;
        }
    }];
    
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    // Recover all disabled gestures
    [scrollView.gestureRecognizers enumerateObjectsUsingBlock:^(__kindof UIGestureRecognizer * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if (obj != scrollView.panGestureRecognizer) {
            obj.enabled = YES;
        }
    }];
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
                _supressEvent = YES;

                _collectionViewLayout.scrollDirection = (UICollectionViewScrollDirection)scrollDirection;
                _header.scrollDirection = _collectionViewLayout.scrollDirection;
                if (self.hasValidateVisibleLayout) {
                    [_collectionView reloadData];
                    [_header reloadData];
                }
                _needsAdjustingMonthPosition = YES;
                _needsAdjustingViewFrame = YES;
                [self setNeedsLayout];
                _supressEvent = NO;
                break;
            }
            case FSCalendarScopeWeek: {
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
    if (!today) {
        _today = nil;
    } else {
        FSCalendarAssertDateInBounds(today,self.gregorian,self.minimumDate,self.maximumDate);
        if (![self.gregorian isDateInToday:today]) {
            _today = [self.gregorian dateBySettingHour:0 minute:0 second:0 ofDate:today options:0];
            [self setNeedsLayout];
        }
    }
    
    [_collectionView.visibleCells makeObjectsPerformSelector:@selector(setDateIsToday:) withObject:@NO];
    [[_collectionView cellForItemAtIndexPath:[self indexPathForDate:today]] setValue:@YES forKey:@"dateIsToday"];
    [_collectionView.visibleCells makeObjectsPerformSelector:@selector(setNeedsLayout)];
}

- (void)setCurrentPage:(NSDate *)currentPage
{
    [self setCurrentPage:currentPage animated:NO];
}

- (void)setCurrentPage:(NSDate *)currentPage animated:(BOOL)animated
{
    [self requestBoundingDatesIfNecessary];
    if (self.floatingMode || [self isDateInDifferentPage:currentPage]) {
        currentPage = [self.gregorian dateBySettingHour:0 minute:0 second:0 ofDate:currentPage options:0];
        if ([self isPageInRange:currentPage]) {
            [self scrollToPageForDate:currentPage animated:animated];
        }
    }
}

- (CGRect)frameForDate:(NSDate *)date
{
    if (!self.superview) {
        return CGRectZero;
    }
    CGRect frame = [_collectionViewLayout layoutAttributesForItemAtIndexPath:[self indexPathForDate:date]].frame;
    frame = [self.superview convertRect:frame fromView:_collectionView];
    return frame;
}

- (CGPoint)centerForDate:(NSDate *)date
{
    CGRect frame = [self frameForDate:date];
    if (CGRectIsEmpty(frame)) {
        return CGPointZero;
    }
    return CGPointMake(CGRectGetMidX(frame), CGRectGetMidY(frame));
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
        [self invalidateWeekdaySymbols];
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
        _header.scrollEnabled = scrollEnabled;
        
        [self invalidateLayout];
    }
}

- (void)setOrientation:(FSCalendarOrientation)orientation
{
    if (_orientation != orientation) {
        _orientation = orientation;
        
        _needsAdjustingViewFrame = YES;
        _needsAdjustingMonthPosition = YES;
        _needsAdjustingTextSize = YES;
        _preferredWeekdayHeight = FSCalendarAutomaticDimension;
        _preferredRowHeight = FSCalendarAutomaticDimension;
        _preferredHeaderHeight = FSCalendarAutomaticDimension;
        _preferredPadding = FSCalendarAutomaticDimension;
        [self.visibleStickyHeaders setValue:@YES forKey:@"needsAdjustingViewFrame"];
        [self.visibleStickyHeaders makeObjectsPerformSelector:@selector(setNeedsLayout)];
        [_collectionView.visibleCells setValue:@YES forKey:@"needsAdjustingViewFrame"];
        [_collectionView.visibleCells makeObjectsPerformSelector:@selector(setNeedsLayout)];
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
                CGFloat divider = FSCalendarStandardMonthlyPageHeight;
                CGFloat contentHeight = self.animator.cachedMonthSize.height*(1-_showsScopeHandle*0.08);
                _preferredHeaderHeight = (FSCalendarStandardHeaderHeight/divider)*contentHeight;
                _preferredHeaderHeight -= (_preferredHeaderHeight-FSCalendarStandardHeaderHeight)*0.5;
            } else {
                _preferredHeaderHeight = FSCalendarStandardHeaderHeight*MAX(1, FSCalendarDeviceIsIPad*1.5)*_lineHeightMultiplier;
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
                CGFloat divider = FSCalendarStandardMonthlyPageHeight;
                CGFloat contentHeight = self.animator.cachedMonthSize.height*(1-_showsScopeHandle*0.08);
                _preferredWeekdayHeight = (FSCalendarStandardWeekdayHeight/divider)*contentHeight;
            } else {
                _preferredWeekdayHeight = FSCalendarStandardWeekdayHeight*MAX(1, FSCalendarDeviceIsIPad*1.5)*_lineHeightMultiplier;
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
        CGFloat contentHeight = self.animator.cachedMonthSize.height-headerHeight-weekdayHeight-_scopeHandle.fs_height;
        CGFloat padding = self.preferredPadding;
        if (self.collectionViewLayout.scrollDirection == UICollectionViewScrollDirectionHorizontal) {
            padding = FSCalendarFloor(padding);
        }
        if (!self.floatingMode) {
            _preferredRowHeight = (contentHeight-padding*2)/6.0;
        } else {
            _preferredRowHeight = FSCalendarStandardRowHeight*MAX(1, FSCalendarDeviceIsIPad*1.5)*_lineHeightMultiplier;
        }
    }
    return _preferredRowHeight;
}

- (CGFloat)preferredPadding
{
    if (_preferredPadding == FSCalendarAutomaticDimension) {
        if (!self.floatingMode) {
            CGFloat divider = FSCalendarStandardMonthlyPageHeight;
            CGFloat contentHeight = self.animator.cachedMonthSize.height*(1-_showsScopeHandle*0.08);
            _preferredPadding = (FSCalendarStandardWeekdayHeight/divider)*contentHeight*0.1;
        } else {
            _preferredPadding = FSCalendarStandardWeekdayHeight*MAX(1, FSCalendarDeviceIsIPad*1.5)*_lineHeightMultiplier*0.1;
        }
    }
    return _preferredPadding;
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
    return _scope == FSCalendarScopeMonth && _scrollEnabled && !_pagingEnabled;
}

- (void)setShowsScopeHandle:(BOOL)showsScopeHandle
{
    if (_showsScopeHandle != showsScopeHandle) {
        _showsScopeHandle = showsScopeHandle;
        [self invalidateLayout];
    }
}

#pragma mark - Public methods

- (void)reloadData
{
    if (!self.hasValidateVisibleLayout) return;
    NSDate *minimumDate = self.minimumDateForCalendar;
    NSDate *maximumDate = self.maximumDateForCalendar;
    if (![self.gregorian isDate:minimumDate equalToDate:_minimumDate toUnitGranularity:NSCalendarUnitMonth] || ![self.gregorian isDate:maximumDate equalToDate:_maximumDate toUnitGranularity:NSCalendarUnitMonth]) {
        _minimumDate = minimumDate;
        _maximumDate = maximumDate;
        [_collectionView reloadData];
        [_header.collectionView reloadData];
        [self setNeedsLayout];
    } else {
        [self reloadVisibleCells];
    }
    [self invalidateWeekdayFont];
    [self invalidateWeekdayTextColor];
    [self invalidateWeekdaySymbols];
    [self invalidateHeaders];
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
        
        if (self.animator.state == FSCalendarTransitionStateIdle) {
            m_set_scope
            [self.animator performScopeTransitionFromScope:prevScope toScope:scope animated:animated];
        }
        
    }
}

- (void)setPlaceholderType:(FSCalendarPlaceholderType)placeholderType
{
    if (_placeholderType != placeholderType) {
        _placeholderType = placeholderType;
        if (self.hasValidateVisibleLayout) {
            _preferredRowHeight = FSCalendarAutomaticDimension;
            [_collectionView reloadData];
        }
    }
}

- (void)setLineHeightMultiplier:(CGFloat)lineHeightMultiplier
{
    _lineHeightMultiplier = MAX(0, lineHeightMultiplier);
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
    date = [self.gregorian dateBySettingHour:0 minute:0 second:0 ofDate:date options:0];
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
    [self requestBoundingDatesIfNecessary];
    
    FSCalendarAssertDateInBounds(date,self.gregorian,self.minimumDate,self.maximumDate);
    
    NSDate *targetDate = [self.gregorian dateBySettingHour:0 minute:0 second:0 ofDate:date options:0];
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
        [_collectionView selectItemAtIndexPath:targetIndexPath animated:NO scrollPosition:UICollectionViewScrollPositionNone];
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
    
    NSInteger scrollOffset = 0;
    switch (_scope) {
        case FSCalendarScopeMonth: {
            FSCalendarAssertDateInBounds(date,self.gregorian,[self beginingOfMonth:self.minimumDate],[self endOfMonth:self.maximumDate]);
            scrollOffset = [self.gregorian components:NSCalendarUnitMonth fromDate:[self beginingOfMonth:self.minimumDate] toDate:date options:0].month;
            break;
        }
        case FSCalendarScopeWeek: {
            FSCalendarAssertDateInBounds(date,self.gregorian,[self beginingOfWeek:self.minimumDate],[self endOfWeek:self.maximumDate]);
            scrollOffset = [self.gregorian components:NSCalendarUnitWeekOfYear fromDate:[self beginingOfWeek:self.minimumDate] toDate:date options:0].weekOfYear;
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
        }
        
    } else {
        if (self.hasValidateVisibleLayout) {
            // Force layout to avoid crash on orientation changing
            [_collectionViewLayout layoutAttributesForElementsInRect:_collectionView.bounds];
            CGRect headerFrame = [_collectionViewLayout layoutAttributesForSupplementaryViewOfKind:UICollectionElementKindSectionHeader atIndexPath:[NSIndexPath indexPathForItem:0 inSection:scrollOffset]].frame;
            CGPoint targetOffset = CGPointMake(0, MIN(headerFrame.origin.y,MAX(0,_collectionView.contentSize.height-_collectionView.fs_bottom)));
            [_collectionView setContentOffset:targetOffset animated:animated];
        } else {
            _currentPage = date;
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
    if (!date) return;
    
    if (!self.floatingMode) {
        if ([self isDateInDifferentPage:date]) {
            [self willChangeValueForKey:@"currentPage"];
            NSDate *lastPage = _currentPage;
            switch (_scope) {
                case FSCalendarScopeMonth: {
                    FSCalendarAssertDateInBounds(date, self.gregorian, [self beginingOfMonth:self.minimumDate], [self endOfMonth:self.maximumDate]);
                    _currentPage = [self beginingOfMonth:date];
                    break;
                }
                case FSCalendarScopeWeek: {
                    FSCalendarAssertDateInBounds(date, self.gregorian, [self beginingOfWeek:self.minimumDate], [self endOfWeek:self.maximumDate]);
                    _currentPage = [self beginingOfWeek:date];
                    break;
                }
            }
            if (!_supressEvent && self.hasValidateVisibleLayout) {
                _supressEvent = YES;
                [self currentPageDidChange];
                if (_placeholderType != FSCalendarPlaceholderTypeFillSixRows && self.animator.state == FSCalendarTransitionStateIdle) {
                    [self.animator performBoundingRectTransitionFromMonth:lastPage toMonth:_currentPage duration:0.33];
                }
                _supressEvent = NO;
            }
            [self didChangeValueForKey:@"currentPage"];
        }
        [self scrollToDate:_currentPage animated:animated];
    } else {
        [self scrollToDate:[self beginingOfMonth:date] animated:animated];
    }
}

- (NSDate *)dateForIndexPath:(NSIndexPath *)indexPath scope:(FSCalendarScope)scope
{
    if (!indexPath) return nil;
    switch (scope) {
        case FSCalendarScopeMonth: {
            NSDate *currentPage = [self.gregorian dateByAddingUnit:NSCalendarUnitMonth value:indexPath.section toDate:[self beginingOfMonth:_minimumDate] options:0];
            NSInteger numberOfHeadPlaceholders = [self numberOfHeadPlaceholdersForMonth:currentPage];
            NSDate *firstDateOfPage = [self.gregorian dateByAddingUnit:NSCalendarUnitDay value:-numberOfHeadPlaceholders toDate:currentPage options:0];
            switch (_collectionViewLayout.scrollDirection) {
                case UICollectionViewScrollDirectionHorizontal: {
                    NSUInteger rows = indexPath.item % 6;
                    NSUInteger columns = indexPath.item / 6;
                    NSUInteger daysOffset = 7*rows + columns;
                    NSDate *date = [self.gregorian dateByAddingUnit:NSCalendarUnitDay value:daysOffset toDate:firstDateOfPage options:0];
                    return date;
                }
                case UICollectionViewScrollDirectionVertical: {
                    NSUInteger daysOffset = indexPath.item;
                    NSDate *date = [self.gregorian dateByAddingUnit:NSCalendarUnitDay value:daysOffset toDate:firstDateOfPage options:0];
                    return date;
                }
            }
            break;
        }
        case FSCalendarScopeWeek: {
            NSDate *currentPage = [self.gregorian dateByAddingUnit:NSCalendarUnitWeekOfYear value:indexPath.section toDate:[self beginingOfWeek:_minimumDate] options:0];
            NSDate *date = [self.gregorian dateByAddingUnit:NSCalendarUnitDay value:indexPath.item toDate:currentPage options:0];
            return date;
            
        }
    }
    return nil;
}

- (NSDate *)dateForIndexPath:(NSIndexPath *)indexPath
{
    if (self.animator.transition == FSCalendarTransitionWeekToMonth && self.animator.state == FSCalendarTransitionStateInProgress) {
        return [self dateForIndexPath:indexPath scope:FSCalendarScopeMonth];
    }
    return [self dateForIndexPath:indexPath scope:_scope];
}

- (NSIndexPath *)indexPathForDate:(NSDate *)date scope:(FSCalendarScope)scope
{
    if (!date) return nil;
    NSInteger item = 0;
    NSInteger section = 0;
    switch (scope) {
        case FSCalendarScopeMonth: {
            section = [self.gregorian components:NSCalendarUnitMonth fromDate:[self beginingOfMonth:self.minimumDate] toDate:date options:0].month;
            NSDate *firstDayOfMonth = [self beginingOfMonth:date];
            NSInteger numberOfHeadPlaceholders = [self numberOfHeadPlaceholdersForMonth:firstDayOfMonth];
            NSDate *firstDateOfPage = [self.gregorian dateByAddingUnit:NSCalendarUnitDay value:-numberOfHeadPlaceholders toDate:firstDayOfMonth options:0];
            switch (_collectionViewLayout.scrollDirection) {
                case UICollectionViewScrollDirectionHorizontal: {
                    NSInteger vItem = [self.gregorian components:NSCalendarUnitDay fromDate:firstDateOfPage toDate:date options:0].day;
                    NSInteger rows = vItem/7;
                    NSInteger columns = vItem%7;
                    item = columns*6 + rows;
                    break;
                }
                case UICollectionViewScrollDirectionVertical: {
                    item = [self.gregorian components:NSCalendarUnitDay fromDate:firstDateOfPage toDate:date options:0].day;
                    break;
                }
            }
            break;
        }
        case FSCalendarScopeWeek: {
            section = [self.gregorian components:NSCalendarUnitWeekOfYear fromDate:[self beginingOfWeek:self.minimumDate] toDate:date options:0].weekOfYear;
            item = (([self.gregorian component:NSCalendarUnitWeekday fromDate:date] - _firstWeekday) + 7) % 7;
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
    BOOL flag = YES;
    flag &= [self.gregorian components:NSCalendarUnitDay fromDate:date toDate:self.minimumDate options:0].day <= 0;
    flag &= [self.gregorian components:NSCalendarUnitDay fromDate:date toDate:self.maximumDate options:0].day >= 0;;
    return flag;
}

- (BOOL)isPageInRange:(NSDate *)page
{
    BOOL flag = YES;
    switch (self.scope) {
        case FSCalendarScopeMonth: {
            NSDateComponents *c1 = [self.gregorian components:NSCalendarUnitDay fromDate:[self beginingOfMonth:self.minimumDate] toDate:page options:0];
            flag &= (c1.day>=0);
            if (!flag) break;
            NSDateComponents *c2 = [self.gregorian components:NSCalendarUnitDay fromDate:page toDate:[self endOfMonth:self.maximumDate] options:0];
            flag &= (c2.day>=0);
            break;
        }
        case FSCalendarScopeWeek: {
            NSDateComponents *c1 = [self.gregorian components:NSCalendarUnitDay fromDate:[self beginingOfWeek:self.minimumDate] toDate:page options:0];
            flag &= (c1.day>=0);
            if (!flag) break;
            NSDateComponents *c2 = [self.gregorian components:NSCalendarUnitDay fromDate:page toDate:[self endOfWeek:self.maximumDate] options:0];
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
    return [_selectedDates containsObject:date] || [_collectionView.indexPathsForSelectedItems containsObject:[self indexPathForDate:date]];
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
    return self.superview  && !CGRectIsEmpty(_collectionView.frame) && !CGSizeEqualToSize(_collectionView.contentSize, CGSizeZero);
#endif
}

- (void)invalidateDateTools
{
    _gregorian.locale = _locale;
    _gregorian.timeZone = _timeZone;
    _gregorian.firstWeekday = _firstWeekday;
    _components.calendar = _gregorian;
    _components.timeZone = _timeZone;
    _formatter.calendar = _gregorian;
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
            NSArray *weekSymbols = self.gregorian.shortStandaloneWeekdaySymbols;
            _weekdays = [NSMutableArray arrayWithCapacity:weekSymbols.count];
            UIFont *weekdayFont = _appearance.preferredWeekdayFont;
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
        
        if (self.showsScopeHandle) {
            if (!_scopeHandle) {
                FSCalendarScopeHandle *handle = [[FSCalendarScopeHandle alloc] initWithFrame:CGRectZero];
                handle.calendar = self;
                [self addSubview:handle];
                self.scopeHandle = handle;
                _needsAdjustingViewFrame = YES;
                [self setNeedsLayout];
            }
        } else {
            if (_scopeHandle) {
                [self.scopeHandle removeFromSuperview];
                _needsAdjustingViewFrame = YES;
                [self setNeedsLayout];
            }
        }
        
        _collectionView.pagingEnabled = YES;
        _collectionViewLayout.scrollDirection = (UICollectionViewScrollDirection)self.scrollDirection;
        
    } else {
        
        if (_header) {
            [_header removeFromSuperview];
        }
        if (_deliver) {
            [_deliver removeFromSuperview];
        }
        if (_weekdays.count) {
            [_weekdays makeObjectsPerformSelector:@selector(removeFromSuperview)];
            [_weekdays removeAllObjects];
        }
        
        if (_scopeHandle) {
            [_scopeHandle removeFromSuperview];
        }
        
        _collectionView.pagingEnabled = NO;
        _collectionViewLayout.scrollDirection = UICollectionViewScrollDirectionVertical;
        
        [self deselectCounterpartDate:nil];
    }
    
    _preferredHeaderHeight = FSCalendarAutomaticDimension;
    _preferredWeekdayHeight = FSCalendarAutomaticDimension;
    _preferredRowHeight = FSCalendarAutomaticDimension;
    _preferredPadding = FSCalendarAutomaticDimension;
    _needsAdjustingViewFrame = YES;
    [self setNeedsLayout];
}

- (void)invalidateWeekdaySymbols
{
    BOOL useVeryShortWeekdaySymbols = (_appearance.caseOptions & (15<<4) ) == FSCalendarCaseOptionsWeekdayUsesSingleUpperCase;
    NSArray *weekdaySymbols = useVeryShortWeekdaySymbols ? _gregorian.veryShortStandaloneWeekdaySymbols : _gregorian.shortStandaloneWeekdaySymbols;
    BOOL useDefaultWeekdayCase = (_appearance.caseOptions & (15<<4) ) == FSCalendarCaseOptionsWeekdayUsesDefaultCase;
    [_weekdays enumerateObjectsUsingBlock:^(UILabel *label, NSUInteger index, BOOL *stop) {
        index += _firstWeekday-1;
        index %= 7;
        label.text = useDefaultWeekdayCase ? weekdaySymbols[index] : [weekdaySymbols[index] uppercaseString];
    }];
    if (self.visibleStickyHeaders.count) {
        [self.visibleStickyHeaders makeObjectsPerformSelector:_cmd];
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
    cell.preferredFillSelectionColor = [self preferredFillSelectionColorForDate:cell.date];
    cell.preferredFillDefaultColor = [self preferredFillDefaultColorForDate:cell.date];
    cell.preferredTitleDefaultColor = [self preferredTitleDefaultColorForDate:cell.date];
    cell.preferredTitleSelectionColor = [self preferredTitleSelectionColorForDate:cell.date];
    cell.preferredTitleOffset = [self preferredTitleOffsetForDate:cell.date];
    if (cell.subtitle) {
        cell.preferredSubtitleDefaultColor = [self preferredSubtitleDefaultColorForDate:cell.date];
        cell.preferredSubtitleSelectionColor = [self preferredSubtitleSelectionColorForDate:cell.date];
        cell.preferredSubtitleOffset = [self preferredSubtitleOffsetForDate:cell.date];
    }
    if (cell.numberOfEvents) {
        cell.preferredEventDefaultColors = [self preferredEventDefaultColorForDate:cell.date];
        cell.preferredEventSelectionColors = [self preferredEventSelectionColorsForDate:cell.date];
        cell.preferredEventOffset = [self preferredEventOffsetForDate:cell.date];
    }
    cell.preferredBorderDefaultColor = [self preferredBorderDefaultColorForDate:cell.date];
    cell.preferredBorderSelectionColor = [self preferredBorderSelectionColorForDate:cell.date];
    cell.preferredBorderRadius = [self preferredBorderRadiusForDate:cell.date];
    
    if (cell.image) {
        cell.preferredImageOffset = [self preferredImageOffsetForDate:cell.date];
    }
    
    [cell setNeedsLayout];
}

- (void)reloadDataForCell:(FSCalendarCell *)cell atIndexPath:(NSIndexPath *)indexPath
{
    cell.calendar = self;
    cell.date = [self dateForIndexPath:indexPath];
    cell.image = [self imageForDate:cell.date];
    cell.numberOfEvents = [self numberOfEventsForDate:cell.date];
    cell.title = [self titleForDate:cell.date];
    cell.subtitle  = [self subtitleForDate:cell.date];
    cell.dateIsSelected = [_selectedDates containsObject:cell.date];
    cell.dateIsToday = self.today?[self.gregorian isDate:cell.date inSameDayAsDate:self.today]:NO;
    switch (_scope) {
        case FSCalendarScopeMonth: {
            NSDate *firstPage = [self beginingOfMonth:_minimumDate];
            NSDate *month = [self.gregorian dateByAddingUnit:NSCalendarUnitMonth value:indexPath.section toDate:firstPage options:0];
            cell.month = month;
            cell.dateIsPlaceholder = ![self.gregorian isDate:cell.date equalToDate:month toUnitGranularity:NSCalendarUnitMonth] || ![self isDateInRange:cell.date];
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
    if (cell.dateIsSelected) {
        [_collectionView selectItemAtIndexPath:indexPath animated:NO scrollPosition:UICollectionViewScrollPositionNone];
    } else if ([_collectionView.indexPathsForSelectedItems containsObject:indexPath]) {
        [_collectionView deselectItemAtIndexPath:indexPath animated:NO];
    }
    [cell setNeedsLayout];
}

- (void)reloadVisibleCells
{
    FSCalendarUseWeakSelf
    [self.collectionView.indexPathsForVisibleItems enumerateObjectsUsingBlock:^(NSIndexPath *indexPath, NSUInteger idx, BOOL *stop) {
        FSCalendarUseStrongSelf
        FSCalendarCell *cell = (FSCalendarCell *)[self.collectionView cellForItemAtIndexPath:indexPath];
        [self reloadDataForCell:cell atIndexPath:indexPath];
    }];
}

- (void)selectCounterpartDate:(NSDate *)date
{
    if (_placeholderType == FSCalendarPlaceholderTypeNone) return;
    if (!self.floatingMode) {
        FSCalendarCell *cell = [_collectionView.visibleCells filteredArrayUsingPredicate:[NSPredicate predicateWithBlock:^BOOL(FSCalendarCell *  _Nonnull evaluatedObject, NSDictionary<NSString *,id> * _Nullable bindings) {
            return evaluatedObject.dateIsPlaceholder && [self.gregorian isDate:evaluatedObject.date inSameDayAsDate:date] && !evaluatedObject.dateIsSelected;
        }]].firstObject;
        cell.dateIsSelected = YES;
        [cell setNeedsLayout];
    }
}

- (void)deselectCounterpartDate:(NSDate *)date
{
    if (_placeholderType == FSCalendarPlaceholderTypeNone) return;
    if (self.floatingMode) {
        FSCalendarCell *cell = [_collectionView.visibleCells filteredArrayUsingPredicate:[NSPredicate predicateWithBlock:^BOOL(FSCalendarCell *  _Nonnull evaluatedObject, NSDictionary<NSString *,id> * _Nullable bindings) {
            return evaluatedObject.dateIsPlaceholder && evaluatedObject.dateIsSelected;
        }]].firstObject;
        cell.dateIsSelected = NO;
        [_collectionView deselectItemAtIndexPath:[_collectionView indexPathForCell:cell] animated:NO];
        [cell setNeedsLayout];
    } else {
        FSCalendarCell *cell = [_collectionView.visibleCells filteredArrayUsingPredicate:[NSPredicate predicateWithBlock:^BOOL(FSCalendarCell *  _Nonnull evaluatedObject, NSDictionary<NSString *,id> * _Nullable bindings) {
            return evaluatedObject.dateIsPlaceholder && [self.gregorian isDate:evaluatedObject.date inSameDayAsDate:date] && evaluatedObject.dateIsSelected;
        }]].firstObject;
        cell.dateIsSelected = NO;
        [_collectionView deselectItemAtIndexPath:[_collectionView indexPathForCell:cell] animated:NO];
        [cell setNeedsLayout];
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


- (void)invalidateWeekdayFont
{
    [_weekdays makeObjectsPerformSelector:@selector(setFont:) withObject:_appearance.preferredWeekdayFont];
}

- (void)invalidateWeekdayTextColor
{
    [_weekdays makeObjectsPerformSelector:@selector(setTextColor:) withObject:_appearance.weekdayTextColor];
}

- (void)invalidateViewFrames
{
    _needsAdjustingViewFrame = YES;
    _needsAdjustingTextSize = YES;
    
    _preferredHeaderHeight  = FSCalendarAutomaticDimension;
    _preferredWeekdayHeight = FSCalendarAutomaticDimension;
    _preferredRowHeight     = FSCalendarAutomaticDimension;
    _preferredPadding       = FSCalendarAutomaticDimension;
    
    [self.collectionViewLayout invalidateLayout];
    [self.collectionViewLayout layoutAttributesForElementsInRect:CGRectZero];
    [self.visibleStickyHeaders setValue:@YES forKey:@"needsAdjustingViewFrame"];
    [self.collectionView.visibleCells setValue:@YES forKey:@"needsAdjustingViewFrame"];
    [self.appearance invalidateFonts];
    [self.header setNeedsAdjustingViewFrame:YES];
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

- (NSInteger)numberOfHeadPlaceholdersForMonth:(NSDate *)month
{
    NSInteger currentWeekday = [self.gregorian component:NSCalendarUnitWeekday fromDate:month];
    NSInteger number = ((currentWeekday- _firstWeekday) + 7) % 7 ?: (7 * (!self.floatingMode&&(self.placeholderType == FSCalendarPlaceholderTypeFillSixRows)));
    return number;
}

- (NSInteger)numberOfRowsInMonth:(NSDate *)month
{
    if (!month) return 0;
    if (self.placeholderType == FSCalendarPlaceholderTypeFillSixRows) return 6;
    NSDate *firstDayOfMonth = [self beginingOfMonth:month];
    NSInteger weekdayOfFirstDay = [self.gregorian component:NSCalendarUnitWeekday fromDate:firstDayOfMonth];
    NSInteger numberOfDaysInMonth = [self numberOfDatesInMonth:month];
    NSInteger numberOfPlaceholdersForPrev = ((weekdayOfFirstDay - self.firstWeekday) + 7) % 7;
    NSInteger headDayCount = numberOfDaysInMonth + numberOfPlaceholdersForPrev;
    NSInteger numberOfRows = (headDayCount/7) + (headDayCount%7>0);
    return numberOfRows;
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

- (UIColor *)preferredFillDefaultColorForDate:(NSDate *)date
{
    if (self.delegateAppearance && [self.delegateAppearance respondsToSelector:@selector(calendar:appearance:fillDefaultColorForDate:)]) {
        UIColor *color = [self.delegateAppearance calendar:self appearance:self.appearance fillDefaultColorForDate:date];
        return color;
    }
#pragma GCC diagnostic push
#pragma GCC diagnostic ignored "-Wdeprecated-declarations"
    else if (self.delegateAppearance && [self.delegateAppearance respondsToSelector:@selector(calendar:appearance:fillColorForDate:)]) {
        UIColor *color = [self.delegateAppearance calendar:self appearance:self.appearance fillColorForDate:date];
        return color;
    }
#pragma GCC diagnostic pop
    return nil;
}

- (UIColor *)preferredFillSelectionColorForDate:(NSDate *)date
{
    if (self.delegateAppearance && [self.delegateAppearance respondsToSelector:@selector(calendar:appearance:fillSelectionColorForDate:)]) {
        UIColor *color = [self.delegateAppearance calendar:self appearance:self.appearance fillSelectionColorForDate:date];
        return color;
    }
#pragma GCC diagnostic push
#pragma GCC diagnostic ignored "-Wdeprecated-declarations"
    else if (self.delegateAppearance && [self.delegateAppearance respondsToSelector:@selector(calendar:appearance:selectionColorForDate:)]) {
        UIColor *color = [self.delegateAppearance calendar:self appearance:self.appearance selectionColorForDate:date];
        return color;
    }
#pragma GCC diagnostic pop
    return nil;
}

- (UIColor *)preferredTitleDefaultColorForDate:(NSDate *)date
{
    if (self.delegateAppearance && [self.delegateAppearance respondsToSelector:@selector(calendar:appearance:titleDefaultColorForDate:)]) {
        UIColor *color = [self.delegateAppearance calendar:self appearance:self.appearance titleDefaultColorForDate:date];
        return color;
    }
    return nil;
}

- (UIColor *)preferredTitleSelectionColorForDate:(NSDate *)date
{
    if (self.delegateAppearance && [self.delegateAppearance respondsToSelector:@selector(calendar:appearance:titleSelectionColorForDate:)]) {
        UIColor *color = [self.delegateAppearance calendar:self appearance:self.appearance titleSelectionColorForDate:date];
        return color;
    }
    return nil;
}

- (UIColor *)preferredSubtitleDefaultColorForDate:(NSDate *)date
{
    if (self.delegateAppearance && [self.delegateAppearance respondsToSelector:@selector(calendar:appearance:subtitleDefaultColorForDate:)]) {
        UIColor *color = [self.delegateAppearance calendar:self appearance:self.appearance subtitleDefaultColorForDate:date];
        return color;
    }
    return nil;
}

- (UIColor *)preferredSubtitleSelectionColorForDate:(NSDate *)date
{
    if (self.delegateAppearance && [self.delegateAppearance respondsToSelector:@selector(calendar:appearance:subtitleSelectionColorForDate:)]) {
        UIColor *color = [self.delegateAppearance calendar:self appearance:self.appearance subtitleSelectionColorForDate:date];
        return color;
    }
    return nil;
}

- (NSArray<UIColor *> *)preferredEventDefaultColorForDate:(NSDate *)date
{
    if (self.delegateAppearance && [self.delegateAppearance respondsToSelector:@selector(calendar:appearance:eventDefaultColorsForDate:)]) {
        NSArray *colors = [self.delegateAppearance calendar:self appearance:self.appearance eventDefaultColorsForDate:date];
        if (colors) {
            return colors;
        }
    }
#pragma GCC diagnostic push
#pragma GCC diagnostic ignored "-Wdeprecated-declarations"
    if (self.delegateAppearance && [self.delegateAppearance respondsToSelector:@selector(calendar:appearance:eventColorsForDate:)]) {
        NSArray *colors = [self.delegateAppearance calendar:self appearance:self.appearance eventColorsForDate:date];
        if (colors) {
            return colors;
        }
    }
    if (self.delegateAppearance && [self.delegateAppearance respondsToSelector:@selector(calendar:appearance:eventColorForDate:)]) {
        UIColor *color = [self.delegateAppearance calendar:self appearance:self.appearance eventColorForDate:date];
        if (color) {
            return @[color];
        }
    }
#pragma GCC diagnostic pop
    return nil;
}

- (NSArray<UIColor *> *)preferredEventSelectionColorsForDate:(NSDate *)date
{
    if (self.delegateAppearance && [self.delegateAppearance respondsToSelector:@selector(calendar:appearance:eventSelectionColorsForDate:)]) {
        NSArray *colors = [self.delegateAppearance calendar:self appearance:self.appearance eventSelectionColorsForDate:date];
        if (colors) {
            return colors;
        }
    }
    return nil;
}

- (UIColor *)preferredBorderDefaultColorForDate:(NSDate *)date
{
    if (self.delegateAppearance && [self.delegateAppearance respondsToSelector:@selector(calendar:appearance:borderDefaultColorForDate:)]) {
        UIColor *color = [self.delegateAppearance calendar:self appearance:self.appearance borderDefaultColorForDate:date];
        return color;
    }
    return nil;
}

- (UIColor *)preferredBorderSelectionColorForDate:(NSDate *)date
{
    if (self.delegateAppearance && [self.delegateAppearance respondsToSelector:@selector(calendar:appearance:borderSelectionColorForDate:)]) {
        UIColor *color = [self.delegateAppearance calendar:self appearance:self.appearance borderSelectionColorForDate:date];
        return color;
    }
    return nil;
}

- (CGFloat)preferredBorderRadiusForDate:(NSDate *)date
{
    if (self.delegateAppearance && [self.delegateAppearance respondsToSelector:@selector(calendar:appearance:borderRadiusForDate:)]) {
        CGFloat borderRadius = [self.delegateAppearance calendar:self appearance:self.appearance borderRadiusForDate:date];
        borderRadius = MAX(0, borderRadius);
        borderRadius = MIN(1, borderRadius);
        return borderRadius;
    }
#pragma GCC diagnostic push
#pragma GCC diagnostic ignored "-Wdeprecated-declarations"
    else if (self.delegateAppearance && [self.delegateAppearance respondsToSelector:@selector(calendar:appearance:cellShapeForDate:)]) {
        FSCalendarCellShape cellShape = [self.delegateAppearance calendar:self appearance:self.appearance cellShapeForDate:date];
        return cellShape;
    }
    else if (self.delegateAppearance && [self.delegateAppearance respondsToSelector:@selector(calendar:appearance:cellStyleForDate:)]) {
        FSCalendarCellShape cellShape = (FSCalendarCellShape)[self.delegateAppearance calendar:self appearance:self.appearance cellStyleForDate:date];
        return cellShape;
    }
#pragma GCC diagnostic pop
    return -1;
}

- (CGPoint)preferredTitleOffsetForDate:(NSDate *)date
{
    if (self.delegateAppearance && [self.delegateAppearance respondsToSelector:@selector(calendar:appearance:titleOffsetForDate:)]) {
        CGPoint point = [self.delegateAppearance calendar:self appearance:self.self.appearance titleOffsetForDate:date];
        return point;
    }
    return CGPointZero;
}

- (CGPoint)preferredSubtitleOffsetForDate:(NSDate *)date
{
    if (self.delegateAppearance && [self.delegateAppearance respondsToSelector:@selector(calendar:appearance:subtitleOffsetForDate:)]) {
        CGPoint point = [self.delegateAppearance calendar:self appearance:self.self.appearance subtitleOffsetForDate:date];
        return point;
    }
    return CGPointZero;
}

- (CGPoint)preferredImageOffsetForDate:(NSDate *)date
{
    if (self.delegateAppearance && [self.delegateAppearance respondsToSelector:@selector(calendar:appearance:imageOffsetForDate:)]) {
        CGPoint point = [self.delegateAppearance calendar:self appearance:self.self.appearance imageOffsetForDate:date];
        return point;
    }
    return CGPointZero;
}

- (CGPoint)preferredEventOffsetForDate:(NSDate *)date
{
    if (self.delegateAppearance && [self.delegateAppearance respondsToSelector:@selector(calendar:appearance:eventOffsetForDate:)]) {
        CGPoint point = [self.delegateAppearance calendar:self appearance:self.self.appearance eventOffsetForDate:date];
        return point;
    }
    return CGPointZero;
}

- (BOOL)boundingRectWillChange:(BOOL)animated
{
    if (self.delegate && [self.delegate respondsToSelector:@selector(calendar:boundingRectWillChange:animated:)]) {
        CGRect boundingRect = (CGRect){CGPointZero,[self sizeThatFits:self.frame.size]};
        if (!CGRectEqualToRect((CGRect){CGPointZero,self.frame.size}, boundingRect)) {
            [self.delegate calendar:self boundingRectWillChange:boundingRect animated:animated];
            return YES;
        }
    }
    return NO;
}

#pragma mark - DataSource

- (NSString *)titleForDate:(NSDate *)date
{
    if (_dataSource && [_dataSource respondsToSelector:@selector(calendar:titleForDate:)]) {
        return [_dataSource calendar:self titleForDate:date];
    }
    return nil;
}

- (NSString *)subtitleForDate:(NSDate *)date
{
#if !TARGET_INTERFACE_BUILDER
    if (_dataSource && [_dataSource respondsToSelector:@selector(calendar:subtitleForDate:)]) {
        return [_dataSource calendar:self subtitleForDate:date];
    }
    return nil;
#else
    return _appearance.fakeSubtitles ? @"test" : nil;
#endif
}

- (UIImage *)imageForDate:(NSDate *)date
{
    if (_dataSource && [_dataSource respondsToSelector:@selector(calendar:imageForDate:)]) {
        return [_dataSource calendar:self imageForDate:date];
    }
    return nil;
}

- (NSInteger)numberOfEventsForDate:(NSDate *)date
{
#if !TARGET_INTERFACE_BUILDER
    
    if (_dataSource && [_dataSource respondsToSelector:@selector(calendar:numberOfEventsForDate:)]) {
        return [_dataSource calendar:self numberOfEventsForDate:date];
    }
#pragma GCC diagnostic push
#pragma GCC diagnostic ignored "-Wdeprecated-declarations"
    if (_dataSource && [_dataSource respondsToSelector:@selector(calendar:hasEventForDate:)]) {
        return [_dataSource calendar:self hasEventForDate:date];
    }
#pragma GCC diagnostic pop
    
#else
    if (self.appearance.fakeEventDots) {
        if ([@[@3,@5] containsObject:@([self dayOfDate:date])]) {
            return 1;
        }
        if ([@[@8,@16] containsObject:@([self dayOfDate:date])]) {
            return 2;
        }
        if ([@[@20,@25] containsObject:@([self dayOfDate:date])]) {
            return 3;
        }
    }
#endif
    
    return 0;
    
}

- (NSDate *)minimumDateForCalendar
{
#if TARGET_INTERFACE_BUILDER
    return _minimumDate;
#else
    NSDate *minimumDate;
    if (_dataSource && [_dataSource respondsToSelector:@selector(minimumDateForCalendar:)]) {
        minimumDate = [_dataSource minimumDateForCalendar:self];
    }
    if (!minimumDate) {
        self.formatter.dateFormat = @"yyyy-MM-dd";
        minimumDate = [self.formatter dateFromString:@"1970-01-01"];
    } else {
        minimumDate = [self.gregorian dateBySettingHour:0 minute:0 second:0 ofDate:minimumDate options:0];
    }
    return minimumDate;
#endif
}

- (NSDate *)maximumDateForCalendar
{
#if TARGET_INTERFACE_BUILDER
    return _maximumDate;
#else
    NSDate *maximumDate;
    if (_dataSource && [_dataSource respondsToSelector:@selector(maximumDateForCalendar:)]) {
        maximumDate = [_dataSource maximumDateForCalendar:self];
    }
    if (!maximumDate) {
        self.formatter.dateFormat = @"yyyy-MM-dd";
        maximumDate = [self.formatter dateFromString:@"2099-12-31"];
    } else {
        maximumDate = [self.gregorian dateBySettingHour:0 minute:0 second:0 ofDate:maximumDate options:0];
    }
    return maximumDate;
#endif
}

- (void)requestBoundingDatesIfNecessary
{
    if (!_hasRequestedBoundingDates) {
        _hasRequestedBoundingDates = YES;
        _minimumDate = self.minimumDateForCalendar;
        _maximumDate = self.maximumDateForCalendar;
    }
}

- (NSDate *)beginingOfMonth:(NSDate *)month
{
    if (!month) return nil;
    NSDateComponents *components = [self.gregorian components:NSCalendarUnitYear|NSCalendarUnitMonth|NSCalendarUnitDay|NSCalendarUnitHour fromDate:month];
    components.day = 1;
    return [self.gregorian dateFromComponents:components];
}

- (NSDate *)endOfMonth:(NSDate *)month
{
    if (!month) return nil;
    NSDateComponents *components = [self.gregorian components:NSCalendarUnitYear|NSCalendarUnitMonth|NSCalendarUnitDay|NSCalendarUnitHour fromDate:month];
    components.month++;
    components.day = 0;
    return [self.gregorian dateFromComponents:components];
}

- (NSDate *)beginingOfWeek:(NSDate *)week
{
    if (!week) return nil;
    NSDateComponents *weekdayComponents = [self.gregorian components:NSCalendarUnitWeekday fromDate:week];
    NSDateComponents *components = self.components;
    components.day = - (weekdayComponents.weekday - self.gregorian.firstWeekday);
    components.day = (components.day-7) % 7;
    NSDate *beginningOfWeek = [self.gregorian dateByAddingComponents:components toDate:week options:0];
    beginningOfWeek = [self.gregorian dateBySettingHour:0 minute:0 second:0 ofDate:beginningOfWeek options:0];
    components.day = NSIntegerMax;
    return beginningOfWeek;
}

- (NSDate *)endOfWeek:(NSDate *)week
{
    if (!week) return nil;
    NSDateComponents *weekdayComponents = [self.gregorian components:NSCalendarUnitWeekday fromDate:week];
    NSDateComponents *components = self.components;
    components.day = - (weekdayComponents.weekday - self.gregorian.firstWeekday);
    components.day = (components.day-7) % 7 + 6;
    NSDate *endOfWeek = [self.gregorian dateByAddingComponents:components toDate:week options:0];
    endOfWeek = [self.gregorian dateBySettingHour:0 minute:0 second:0 ofDate:endOfWeek options:0];
    components.day = NSIntegerMax;
    return endOfWeek;
}

- (NSDate *)middleOfWeek:(NSDate *)week
{
    if (!week) return nil;
    NSDateComponents *weekdayComponents = [self.gregorian components:NSCalendarUnitWeekday fromDate:week];
    NSDateComponents *componentsToSubtract = self.components;
    componentsToSubtract.day = - (weekdayComponents.weekday - self.gregorian.firstWeekday) + 3;
    NSDate *middleOfWeek = [self.gregorian dateByAddingComponents:componentsToSubtract toDate:week options:0];
    NSDateComponents *components = [self.gregorian components:NSCalendarUnitYear|NSCalendarUnitMonth|NSCalendarUnitDay|NSCalendarUnitHour fromDate:middleOfWeek];
    middleOfWeek = [self.gregorian dateFromComponents:components];
    componentsToSubtract.day = NSIntegerMax;
    return middleOfWeek;
}

- (NSInteger)numberOfDatesInMonth:(NSDate *)month
{
    if (!month) return 0;
    NSRange days = [self.gregorian rangeOfUnit:NSCalendarUnitDay
                                       inUnit:NSCalendarUnitMonth
                                      forDate:month];
    return days.length;
}

- (void)setIdentifier:(NSString *)identifier
{
    if (![identifier isEqualToString:_gregorian.calendarIdentifier]) {
        self.gregorian = [[NSCalendar alloc] initWithCalendarIdentifier:identifier];
        [self invalidateDateTools];
        [self invalidateWeekdaySymbols];
        if (self.hasValidateVisibleLayout) {
            [self reloadData];
        }
        _minimumDate = [self dateByIgnoringTimeComponentsOfDate:_minimumDate];
        _currentPage = [self dateByIgnoringTimeComponentsOfDate:_currentPage];
        BOOL suppress = _supressEvent;
        _supressEvent = YES;
        [self scrollToPageForDate:_today animated:NO];
        _supressEvent = suppress;
    }
}

- (NSString *)identifier
{
    return self.gregorian.calendarIdentifier;
}

@end


