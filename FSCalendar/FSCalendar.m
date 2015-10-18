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
#import "NSDate+FSExtension.h"
#import "NSString+FSExtension.h"
#import "FSCalendarDynamicHeader.h"
#import "FSCalendarHeaderTouchDeliver.h"

#import "FSCalendarConstance.h"

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
    FSCalendarAppearance *_appearance;
    NSMutableArray *_selectedDates;
    NSDate *_minimumDate;
    NSDate *_maximumDate;
}
@property (strong, nonatomic) NSMutableArray             *weekdays;
@property (strong, nonatomic) NSMapTable                 *stickyHeaderMapTable;

@property (weak  , nonatomic) UIView                     *contentView;
@property (weak  , nonatomic) UIView                     *daysContainer;
@property (weak  , nonatomic) CAShapeLayer               *maskLayer;
@property (weak  , nonatomic) UIView                     *topBorder;
@property (weak  , nonatomic) UIView                     *bottomBorder;
@property (weak  , nonatomic) UICollectionView           *collectionView;
@property (weak  , nonatomic) UICollectionViewFlowLayout *collectionViewLayout;

@property (weak  , nonatomic) FSCalendarHeader           *header;
@property (weak  , nonatomic) FSCalendarHeaderTouchDeliver *deliver;

@property (strong, nonatomic) NSCalendar                 *calendar;
@property (assign, nonatomic) CGFloat                    rowHeight;

@property (assign, nonatomic) BOOL                       ibEditing;
@property (assign, nonatomic) BOOL                       needsAdjustingMonthPosition;
@property (assign, nonatomic) BOOL                       needsAdjustingViewFrame;
@property (assign, nonatomic) BOOL                       needsAdjustingTextSize;
@property (assign, nonatomic) BOOL                       needsReloadingSelectingDates;
@property (assign, nonatomic) BOOL                       supressEvent;

@property (readonly, nonatomic) NSInteger currentSection;
@property (readonly, nonatomic) CGFloat preferedHeaderHeight;
@property (readonly, nonatomic) BOOL floatingMode;
@property (readonly, nonatomic) NSArray *visibleStickyHeaders;

@property (readonly, nonatomic) id<FSCalendarDelegateAppearance> delegateAppearance;

- (void)orientationDidChange:(NSNotification *)notification;

- (NSDate *)dateForIndexPath:(NSIndexPath *)indexPath;
- (NSIndexPath *)indexPathForDate:(NSDate *)date;

- (void)scrollToDate:(NSDate *)date;
- (void)scrollToDate:(NSDate *)date animated:(BOOL)animated;
- (void)scrollToPageForDate:(NSDate *)date animated:(BOOL)animated;

- (BOOL)isDateInRange:(NSDate *)date;
- (BOOL)isDateSelected:(NSDate *)date;
- (BOOL)isDateInDifferentPage:(NSDate *)date;

- (void)selectDate:(NSDate *)date scrollToDate:(BOOL)scrollToDate forPlaceholder:(BOOL)forPlaceholder;
- (void)enqueueSelectedDate:(NSDate *)date;

- (void)adjustRowHeight;

- (void)invalidateLayout;
- (void)invalidateWeekdaySymbols;
- (void)invalidateAppearanceForCell:(FSCalendarCell *)cell;

@end

@implementation FSCalendar

@dynamic locale, selectedDate;
@synthesize scrollDirection = _scrollDirection, firstWeekday = _firstWeekday, headerHeight =_headerHeight;

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
    
    _minimumDate = [NSDate fs_dateWithYear:1970 month:1 day:1];
    _maximumDate = [NSDate fs_dateWithYear:2099 month:12 day:31];
    
    _headerHeight     = -1;
    _calendar         = [NSCalendar fs_sharedCalendar];
    _firstWeekday     = _calendar.firstWeekday;
    
    _scrollDirection = FSCalendarScrollDirectionHorizontal;
    _firstWeekday = [_calendar firstWeekday];
    _scope = FSCalendarScopeMonth;
    _selectedDates = [NSMutableArray arrayWithCapacity:1];
    
    _rowHeight = -1;
    
    _today = [NSDate date].fs_dateByIgnoringTimeComponents;
    _currentPage = _today.fs_firstDayOfMonth;
    
    _pagingEnabled = YES;
    _scrollEnabled = YES;
    _needsAdjustingViewFrame = YES;
    _needsAdjustingTextSize = YES;
    _stickyHeaderMapTable = [NSMapTable mapTableWithKeyOptions:NSMapTableStrongMemory valueOptions:NSMapTableWeakMemory];
    
    UIView *contentView = [[UIView alloc] initWithFrame:CGRectZero];
    contentView.backgroundColor = [UIColor clearColor];
    [self addSubview:contentView];
    self.contentView = contentView;
    
    CAShapeLayer *maskLayer = [CAShapeLayer layer];
    contentView.layer.mask = maskLayer;
    self.maskLayer = maskLayer;
    
    UIView *daysContainer = [[UIView alloc] initWithFrame:CGRectZero];
    daysContainer.backgroundColor = [UIColor clearColor];
    [contentView addSubview:daysContainer];
    self.daysContainer = daysContainer;
    
    UICollectionViewFlowLayout *collectionViewLayout = [[UICollectionViewFlowLayout alloc] init];
    collectionViewLayout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
    collectionViewLayout.minimumInteritemSpacing = 0;
    collectionViewLayout.minimumLineSpacing = 0;
    collectionViewLayout.itemSize = CGSizeMake(1, 1);
    collectionViewLayout.sectionInset = UIEdgeInsetsZero;
    
    UICollectionView *collectionView = [[UICollectionView alloc] initWithFrame:CGRectZero
                                                          collectionViewLayout:collectionViewLayout];
    collectionView.dataSource = self;
    collectionView.delegate = self;
    collectionView.clipsToBounds = NO;
    collectionView.backgroundColor = [UIColor clearColor];
    collectionView.bounces = YES;
    collectionView.pagingEnabled = YES;
    collectionView.showsHorizontalScrollIndicator = NO;
    collectionView.showsVerticalScrollIndicator = NO;
    collectionView.delaysContentTouches = NO;
    collectionView.canCancelContentTouches = YES;
    collectionView.scrollsToTop = NO;
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
    
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIDeviceOrientationDidChangeNotification object:nil];
}

#pragma mark - Overriden methods

- (void)layoutSubviews
{
    [super layoutSubviews];
    _supressEvent = YES;
    
    if (_needsAdjustingViewFrame) {
    
        _contentView.frame = self.bounds;
        CGFloat padding = kFSCalendarDefaultWeekHeight*0.1;
        
        _header.frame = CGRectMake(0, 0, self.fs_width, _headerHeight == -1 ? kFSCalendarDefaultHeaderHeight : _headerHeight);
        CGFloat width = _contentView.fs_width/_weekdays.count;
        CGFloat height = kFSCalendarDefaultWeekHeight;
        [_weekdays enumerateObjectsUsingBlock:^(UILabel *weekdayLabel, NSUInteger idx, BOOL *stop) {
            NSUInteger absoluteIndex = ((idx-(_firstWeekday-1))+7)%7;
            weekdayLabel.frame = CGRectMake(absoluteIndex*width,
                                            _header.fs_height,
                                            width,
                                            height);
        }];
        
        _deliver.frame = _header.frame;
        _deliver.hidden = _header.hidden;
        
        _collectionView.contentInset = UIEdgeInsetsZero;
        _collectionViewLayout.sectionInset = UIEdgeInsetsMake(padding, 0, padding, 0);
        if (_rowHeight == -1) {
            [self adjustRowHeight];
        }
        if (_pagingEnabled) {
            
            _collectionViewLayout.headerReferenceSize = CGSizeZero;
            switch (_scope) {
                case FSCalendarScopeMonth: {
                    CGFloat contentHeight = _rowHeight*6 + padding*2;
                    _daysContainer.frame = CGRectMake(0, (kFSCalendarDefaultWeekHeight+_header.fs_height), self.fs_width, contentHeight);
                    _collectionView.frame = _daysContainer.bounds;
                    _collectionViewLayout.itemSize = CGSizeMake(
                                                                _collectionView.fs_width/7-(_collectionViewLayout.scrollDirection == UICollectionViewScrollDirectionVertical)*0.1,
                                                                _rowHeight
                                                                );
                    break;
                }
                case FSCalendarScopeWeek: {
                    CGFloat contentHeight = _rowHeight + padding*2;
                    _daysContainer.frame = CGRectMake(0, kFSCalendarDefaultWeekHeight+_header.fs_height, self.fs_width, MAX(kFSCalendarMinimumRowHeight, contentHeight));
                    _collectionView.frame = _daysContainer.bounds;
                    _collectionViewLayout.itemSize = CGSizeMake(_collectionView.fs_width/7, _rowHeight);
                    break;
                }
                default: {
                    break;
                }
            }
        } else {
            
            _collectionViewLayout.headerReferenceSize = CGSizeMake(_contentView.fs_width, self.preferedHeaderHeight);
            CGFloat contentHeight = _contentView.fs_height;
            _daysContainer.frame = CGRectMake(0, 0, self.fs_width, contentHeight);
            _collectionView.frame = _daysContainer.bounds;
            _collectionViewLayout.itemSize = CGSizeMake(
                                                        _collectionView.fs_width/7-(_collectionViewLayout.scrollDirection == UICollectionViewScrollDirectionVertical)*0.1,
                                                        _rowHeight
                                                        );
            
        }
        _topBorder.frame = CGRectMake(0, -1, self.fs_width, 1);
        _bottomBorder.frame = CGRectMake(0, self.fs_height, self.fs_width, 1);
        
    }
    if (_needsAdjustingTextSize) {
        _needsAdjustingTextSize = NO;
        [_appearance adjustTitleIfNecessary];
    }
    
    if (_needsReloadingSelectingDates) {
        _needsReloadingSelectingDates = NO;
        [self.selectedDates enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
            [self selectDate:obj scrollToDate:NO];
        }];
    }
    
    if (_needsAdjustingMonthPosition) {
        _needsAdjustingMonthPosition = NO;
        [self scrollToDate:_pagingEnabled?_currentPage:(_currentPage?:self.selectedDate)];
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
    [self selectDate:[NSDate fs_dateWithYear:date.fs_year month:date.fs_month day:_appearance.fakedSelectedDay?:1]];
}

- (CGSize)sizeThatFits:(CGSize)size
{
    if (_rowHeight == -1) {
        [self adjustRowHeight];
    }
    CGFloat headerHeight = _header.fs_height ?: _headerHeight;
    headerHeight = headerHeight == -1 ? kFSCalendarDefaultHeaderHeight : headerHeight;
 
    if (!self.floatingMode) {
        switch (_scope) {
            case FSCalendarScopeMonth: {
                CGFloat height = kFSCalendarDefaultWeekHeight + headerHeight + 6 * _rowHeight + kFSCalendarDefaultWeekHeight*0.2;
                return CGSizeMake(size.width, height);
            }
            case FSCalendarScopeWeek: {
                return CGSizeMake(size.width, kFSCalendarDefaultWeekHeight + headerHeight + _rowHeight + kFSCalendarDefaultWeekHeight*0.2);
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
            sections = [_maximumDate fs_monthsFrom:_minimumDate.fs_firstDayOfMonth] + 1;
            break;
        case FSCalendarScopeWeek:
            sections = [_maximumDate fs_weeksFrom:_minimumDate.fs_firstDayOfWeek] + 1;
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
        NSDate *currentPage = [_minimumDate.fs_firstDayOfMonth fs_dateByAddingMonths:section];
        NSDate *firstDayOfMonth = [NSDate fs_dateWithYear:currentPage.fs_year
                                                    month:currentPage.fs_month
                                                      day:1];
        NSInteger numberOfRows = (firstDayOfMonth.fs_weekday-_calendar.firstWeekday+currentPage.fs_numberOfDaysInMonth)/7 + ((firstDayOfMonth.fs_weekday-_calendar.firstWeekday+currentPage.fs_numberOfDaysInMonth)%7 !=0 );
        return numberOfRows * 7;
    }
    return 7;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    FSCalendarCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"cell" forIndexPath:indexPath];
    cell.calendar = self;
    cell.appearance = _appearance;
    cell.date = [self dateForIndexPath:indexPath];
    cell.image = [self imageForDate:cell.date];
    cell.subtitle  = [self subtitleForDate:cell.date];
    cell.hasEvent = [self hasEventForDate:cell.date];
    cell.dateIsSelected = [self.selectedDates containsObject:cell.date];
    cell.dateIsToday = [cell.date fs_isEqualToDateForDay:_today];
    
    [self invalidateAppearanceForCell:cell];
    
    switch (_scope) {
        case FSCalendarScopeMonth: {
            NSDate *month = [_minimumDate.fs_firstDayOfMonth fs_dateByAddingMonths:indexPath.section].fs_dateByIgnoringTimeComponents;
            cell.dateIsPlaceholder = ![cell.date fs_isEqualToDateForMonth:month] || ![self isDateInRange:cell.date];
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
        default: {
            break;
        }
    }
    cell.selected &= (cell.dateIsSelected && !cell.dateIsPlaceholder);
    [cell setNeedsLayout];
    return cell;
}

- (UICollectionReusableView *)collectionView:(UICollectionView *)collectionView viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath
{
    if (self.floatingMode) {
        if ([kind isEqualToString:UICollectionElementKindSectionHeader]) {
            FSCalendarStickyHeader *stickyHeader = [collectionView dequeueReusableSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:@"header" forIndexPath:indexPath];
            stickyHeader.calendar = self;
            stickyHeader.month = [_minimumDate fs_dateByAddingMonths:indexPath.section].fs_dateByIgnoringTimeComponents.fs_firstDayOfMonth;
            [stickyHeader setNeedsLayout];
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
    _daysContainer.clipsToBounds = NO;
    
    [cell performSelecting];
    if (!_supressEvent) {
        [self didSelectDate:[self dateForIndexPath:indexPath]];
    }
    
    if (!self.floatingMode) {
        [collectionView.visibleCells enumerateObjectsUsingBlock:^(FSCalendarCell *cell, NSUInteger idx, BOOL *stop) {
            if (cell.dateIsPlaceholder) {
                cell.dateIsSelected = [self.selectedDates containsObject:cell.date];
                cell.dateIsToday = [cell.date fs_isEqualToDateForDay:_today];
                [cell setNeedsLayout];
            }
        }];
    }
}

- (BOOL)collectionView:(UICollectionView *)collectionView shouldSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    FSCalendarCell *cell = (FSCalendarCell *)[collectionView cellForItemAtIndexPath:indexPath];
    if (cell.dateIsPlaceholder) {
        if ([self isDateInRange:cell.date]) {
            [self selectDate:cell.date scrollToDate:YES forPlaceholder:YES];
        } else if (![cell.date fs_isEqualToDateForMonth:_currentPage]) {
            [self scrollToPageForDate:cell.date animated:YES];
        }
        return NO;
    }
    if ([collectionView.indexPathsForSelectedItems containsObject:indexPath] || [self.selectedDates containsObject:[self dateForIndexPath:indexPath]]) {
        if (self.allowsMultipleSelection) {
            if ([self collectionView:collectionView shouldDeselectItemAtIndexPath:indexPath]) {
                [collectionView deselectItemAtIndexPath:indexPath animated:YES];
                [self collectionView:collectionView didDeselectItemAtIndexPath:indexPath];
            }
        } else {
            [self didSelectDate:self.selectedDate];
        }
        return NO;
    }
    BOOL shouldSelect = YES;
    if (shouldSelect && cell.date && [self isDateInRange:cell.date] && !_supressEvent) {
        shouldSelect &= [self shouldSelectDate:cell.date];
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
        _daysContainer.clipsToBounds = NO;
        cell.dateIsSelected = NO;
        [cell setNeedsLayout];
    }
    NSDate *selectedDate = cell.date ?: [self dateForIndexPath:indexPath];
    [_selectedDates removeObject:selectedDate];
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
    _daysContainer.clipsToBounds = YES;
    if (_supressEvent) {
        return;
    }
    if (self.floatingMode && _collectionView.indexPathsForVisibleItems.count) {
        
        NSMutableOrderedSet *visibleSections = [NSMutableOrderedSet orderedSetWithCapacity:2];
        [_collectionView.indexPathsForVisibleItems enumerateObjectsUsingBlock:^(NSIndexPath *indexPath, NSUInteger idx, BOOL *stop) {
            if (indexPath.item == 0) {
                [visibleSections addObject:@(indexPath.section)];
            }
        }];
        [visibleSections sortUsingComparator:^NSComparisonResult(id obj1, id obj2) {
            return [obj1 compare:obj2] == NSOrderedDescending;
        }];
        NSInteger minimumSectionOnScreen = [visibleSections[0] integerValue];
        CGRect cellFrame = [_collectionView layoutAttributesForItemAtIndexPath:[NSIndexPath indexPathForItem:0 inSection:minimumSectionOnScreen]].frame;
        CGFloat headerTop = cellFrame.origin.y-_collectionViewLayout.headerReferenceSize.height;
        CGRect headerFrame = CGRectMake(0, headerTop, _collectionView.fs_width, _collectionViewLayout.headerReferenceSize.height);
        CGRect headerFrameOnScreen = [_collectionView convertRect:headerFrame toView:_daysContainer];
        if (headerFrameOnScreen.origin.y >= MIN(self.rowHeight*2.5,_collectionView.fs_height*0.5)) {
            minimumSectionOnScreen--;
        }
        NSDate *currentPage = [self.minimumDate.fs_firstDayOfMonth fs_dateByAddingMonths:minimumSectionOnScreen];
        if (![currentPage fs_isEqualToDateForMonth:_currentPage]) {
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
    _daysContainer.clipsToBounds = YES;
    if (!_pagingEnabled || !_scrollEnabled) {
        return;
    }
    CGFloat pannedOffset = 0, targetOffset = 0, currentOffset = 0, contentSize = 0;
    switch (_collectionViewLayout.scrollDirection) {
        case UICollectionViewScrollDirectionHorizontal: {
            pannedOffset = [scrollView.panGestureRecognizer translationInView:scrollView].x;
            targetOffset = (*targetContentOffset).x;
            currentOffset = scrollView.contentOffset.x;
            contentSize = scrollView.fs_width;
            break;
        }
        case UICollectionViewScrollDirectionVertical: {
            pannedOffset = [scrollView.panGestureRecognizer translationInView:scrollView].y;
            targetOffset = (*targetContentOffset).y;
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
                _currentPage = [_minimumDate fs_dateByAddingMonths:targetOffset/contentSize].fs_dateByIgnoringTimeComponents.fs_firstDayOfMonth;
                break;
            }
            case FSCalendarScopeWeek: {
                _currentPage = [_minimumDate fs_dateByAddingWeeks:targetOffset/contentSize].fs_dateByIgnoringTimeComponents.fs_firstDayOfWeek;
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
    _needsAdjustingViewFrame = YES;
    _needsAdjustingMonthPosition = YES;
    _needsAdjustingTextSize = YES;
    [self setNeedsLayout];
    [self adjustRowHeight];
    [_collectionViewLayout invalidateLayout]; // Necessary in Swift. Anyone can tell why?
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
                _header.scrollDirection = _collectionViewLayout.scrollDirection;
                if (!CGRectEqualToRect(_collectionView.frame, CGRectZero)) {
                    _needsAdjustingMonthPosition = YES;
                    [self reloadData];
                }
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
        [_calendar setFirstWeekday:firstWeekday];
        [self reloadData];
    }
}

- (void)setToday:(NSDate *)today
{
    if (![self isDateInRange:today]) {
        [NSException raise:@"currentDate out of range" format:@""];
    }
    if (![_today fs_isEqualToDateForDay:today]) {
        today = today.fs_dateByIgnoringTimeComponents;
        _today = today;
        switch (_scope) {
            case FSCalendarScopeMonth: {
                _currentPage = today.fs_firstDayOfMonth;
                break;
            }
            case FSCalendarScopeWeek: {
                _currentPage = today.fs_firstDayOfWeek;
                break;
            }
            default: {
                break;
            }
        }
        _needsAdjustingMonthPosition = YES;
        [self setNeedsLayout];
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
    if ([self isDateInDifferentPage:currentPage]) {
        currentPage = currentPage.fs_dateByIgnoringTimeComponents;
        [self scrollToPageForDate:currentPage animated:animated];
    }
}

- (void)setHeaderHeight:(CGFloat)headerHeight
{
    if (_headerHeight != headerHeight) {
        _headerHeight = headerHeight;
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
    if (![_calendar.locale isEqual:locale]) {
        _calendar.locale = locale;
        _header.dateFormatter.locale = locale;
        [self invalidateWeekdaySymbols];
        [self reloadData];
    }
}

- (NSLocale *)locale
{
    return _calendar.locale;
}

- (NSInteger)currentSection
{
    switch (_scope) {
        case FSCalendarScopeMonth: {
            return [_currentPage fs_monthsFrom:_minimumDate];
        }
        case FSCalendarScopeWeek: {
            return [_currentPage fs_weeksFrom:_minimumDate];
        }
        default: {
            break;
        }
    }
    return 0;
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

- (NSDate *)selectedDate
{
    return self.selectedDates.lastObject;
}

- (NSArray *)selectedDates
{
    return _selectedDates;
}

- (CGFloat)preferedHeaderHeight
{
    if (_headerHeight == -1) {
        return _pagingEnabled ? kFSCalendarDefaultHeaderHeight : kFSCalendarDefaultStickyHeaderHeight;
    }
    return _headerHeight;
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
    _minimumDate = self.minimumDateForCalendar;
    _maximumDate = self.maximumDateForCalendar;
    
    [_weekdays setValue:[UIFont systemFontOfSize:_appearance.weekdayTextSize] forKey:@"font"];
    
    CGFloat width = self.fs_width/_weekdays.count;
    CGFloat height = kFSCalendarDefaultWeekHeight;
    [_weekdays enumerateObjectsUsingBlock:^(UILabel *weekdayLabel, NSUInteger idx, BOOL *stop) {
        NSUInteger absoluteIndex = ((idx-(_firstWeekday-1))+7)%7;
        weekdayLabel.frame = CGRectMake(absoluteIndex * width,
                                        _header.fs_height,
                                        width,
                                        height);
    }];
    
    [_collectionView reloadData];
    [_header reloadData];
    
    _needsReloadingSelectingDates = YES;
    [self setNeedsLayout];
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
        NSInteger section = self.currentSection;
        
        m_set_scope
        
        void(^completion)(void) = ^{
            switch (scope) {
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
            _needsAdjustingMonthPosition = YES;
            _needsAdjustingViewFrame = YES;
            [self setNeedsLayout];
            [self reloadData];
        };
        
        BOOL weekToMonth = prevScope == FSCalendarScopeWeek && scope == FSCalendarScopeMonth;
        NSInteger rowNumber = -1;
        
        switch (prevScope) {
            case FSCalendarScopeMonth: {
                FSCalendarCell *cell = (FSCalendarCell *)[_collectionView cellForItemAtIndexPath:[NSIndexPath indexPathForItem:0 inSection:section]];
                _currentPage = cell.date ?: _today;
                break;
            }
            case FSCalendarScopeWeek: {
                
                NSDate *currentPage = _currentPage;
                
                if (rowNumber == -1) {
                    NSDate *firstDayOfMonth = [currentPage fs_dateByAddingMonths:1].fs_firstDayOfMonth;
                    NSInteger numberOfPlaceholdersForPrev = ((firstDayOfMonth.fs_weekday - _firstWeekday) + 7) % 7 ?: 7;
                    NSDate *firstDateOfPage = [firstDayOfMonth fs_dateBySubtractingDays:numberOfPlaceholdersForPrev];
                    for (int i = 0; i < 6; i++) {
                        if ([currentPage fs_isEqualToDateForDay:[firstDateOfPage fs_dateByAddingDays:7*i]]) {
                            rowNumber = i;
                            _currentPage = firstDayOfMonth;
                            break;
                        }
                    }
                }
                if (rowNumber == -1) {
                    NSDate *firstDayOfMonth = currentPage.fs_firstDayOfMonth;
                    NSInteger numberOfPlaceholdersForPrev = ((firstDayOfMonth.fs_weekday - _firstWeekday) + 7) % 7 ?: 7;
                    NSDate *firstDateOfPage = [firstDayOfMonth fs_dateBySubtractingDays:numberOfPlaceholdersForPrev];
                    for (int i = 0; i < 6; i++) {
                        if ([currentPage fs_isEqualToDateForDay:[firstDateOfPage fs_dateByAddingDays:7*i]]) {
                            rowNumber = i;
                            _currentPage = firstDayOfMonth;
                            break;
                        }
                    }
                }
                _currentPage = _currentPage ?: _today;
                completion();
                
                break;
            }
            default: {
                break;
            }
        }
        
        void(^resizeBlock)() = ^{
            
            CGSize size = [self sizeThatFits:self.frame.size];
            void(^transitionCompletion)() = ^{
                _maskLayer.path = [UIBezierPath bezierPathWithRect:(CGRect){CGPointZero,size}].CGPath;
                [_maskLayer removeAllAnimations];
                _daysContainer.clipsToBounds = _collectionView.isDecelerating || _collectionView.isTracking || _collectionView.isDragging;
                if (!weekToMonth) {
                    completion();
                }
            };
            
            if (animated) {
                
                CABasicAnimation *path = [CABasicAnimation animationWithKeyPath:@"path"];
                path.fromValue = (id)_maskLayer.path;
                path.toValue = (id)[UIBezierPath bezierPathWithRect:(CGRect){CGPointZero,size}].CGPath;
                path.duration = 0.3;
                path.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
                path.fillMode = kCAFillModeForwards;
                path.removedOnCompletion = NO;
                
                CABasicAnimation *translation = nil;
                if (weekToMonth && rowNumber != -1) {
                    translation = [CABasicAnimation animationWithKeyPath:@"transform.translation.y"];
                    translation.fromValue = @(-rowNumber*_rowHeight);
                    translation.toValue = @0;
                    translation.duration = 0.3;
                }
                
                [CATransaction begin];
                [CATransaction setCompletionBlock:transitionCompletion];
                
                _needsAdjustingViewFrame = weekToMonth;
                
                [_maskLayer addAnimation:path forKey:@"path"];
                
                if (translation) {
                    [_collectionView.layer addAnimation:translation forKey:@"translation"];
                }
                
                [CATransaction commit];
                
                if (_delegate && [_delegate respondsToSelector:@selector(calendarCurrentScopeWillChange:animated:)]) {
                    [UIView beginAnimations:@"delegateTranslation" context:"translation"];
                    [UIView setAnimationCurve:UIViewAnimationCurveEaseInOut];
                    [UIView setAnimationDuration:0.3];
                    _bottomBorder.frame = CGRectMake(0, size.height, self.fs_width, 1);
                    [_delegate calendarCurrentScopeWillChange:self animated:animated];
                    [UIView commitAnimations];
                }
                
            } else {
                
                _needsAdjustingViewFrame = weekToMonth;
                _bottomBorder.frame = CGRectMake(0, size.height, self.fs_width, 1);
                transitionCompletion();
                
                if (_delegate && [_delegate respondsToSelector:@selector(calendarCurrentScopeWillChange:animated:)]) {
                    [_delegate calendarCurrentScopeWillChange:self animated:animated];
                }
                
            }
            
        };
        
        if (animated) {
            dispatch_async(dispatch_get_main_queue(), ^{
                resizeBlock();
            });
        } else {
            resizeBlock();
        }
    }
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
    if (![_selectedDates containsObject:date.fs_dateByIgnoringTimeComponents]) {
        return;
    }
    date = date.fs_dateByIgnoringTimeComponents;
    [_selectedDates removeObject:date];
    NSIndexPath *indexPath = [self indexPathForDate:date];
    if ([_collectionView.indexPathsForSelectedItems containsObject:indexPath]) {
        [_collectionView deselectItemAtIndexPath:indexPath animated:YES];
        FSCalendarCell *cell = (FSCalendarCell *)[_collectionView cellForItemAtIndexPath:indexPath];
        cell.dateIsSelected = NO;
        [cell setNeedsLayout];
        
        [_collectionView.visibleCells enumerateObjectsUsingBlock:^(FSCalendarCell *cell, NSUInteger idx, BOOL *stop) {
            if (cell.dateIsPlaceholder && [cell.date fs_isEqualToDateForDay:date] && cell.dateIsSelected) {
                cell.dateIsSelected = NO;
                [cell setNeedsLayout];
                *stop = YES;
            }
        }];
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
    NSDate *targetDate = [date fs_daysFrom:_minimumDate] < 0 ? _minimumDate.copy : date;
    targetDate = [targetDate fs_daysFrom:_maximumDate] > 0 ? _maximumDate.copy : date;
    targetDate = targetDate.fs_dateByIgnoringTimeComponents;
    NSIndexPath *targetIndexPath = [self indexPathForDate:targetDate];
    
    BOOL shouldSelect = !_supressEvent;
    if (forPlaceholder) {
        
        // 跨月份选中日期，需要触发各类事件
        if (self.allowsMultipleSelection && [self isDateSelected:targetDate]) {
            // 在多选模式下，点击了已经选中的跨月日期
            BOOL shouldDeselect = [self shouldDeselectDate:targetDate];
            if (!shouldDeselect) {
                return;
            }
        }
        shouldSelect &= [self shouldSelectDate:targetDate];
        if (shouldSelect && ![self isDateSelected:targetDate]) {
            if (_collectionView.indexPathsForSelectedItems.count && self.selectedDate && !self.allowsMultipleSelection) {
                NSIndexPath *currentIndexPath = [self indexPathForDate:self.selectedDate];
                [_collectionView deselectItemAtIndexPath:currentIndexPath animated:YES];
                [self collectionView:_collectionView didDeselectItemAtIndexPath:currentIndexPath];
            }
            if ([self collectionView:_collectionView shouldSelectItemAtIndexPath:targetIndexPath]) {
                [_collectionView selectItemAtIndexPath:targetIndexPath animated:YES scrollPosition:UICollectionViewScrollPositionNone];
                [self collectionView:_collectionView didSelectItemAtIndexPath:targetIndexPath];
            }
        }
    } else if (![_selectedDates containsObject:targetDate]){
        // 手动选中日期时，需先反选已经选中的日期，但不触发事件
        if (self.selectedDate && !self.allowsMultipleSelection) {
            NSIndexPath *currentIndexPath = [self indexPathForDate:self.selectedDate];
            FSCalendarCell *cell = (FSCalendarCell *)[_collectionView cellForItemAtIndexPath:currentIndexPath];
            cell.dateIsSelected = NO;
            [cell setNeedsLayout];
            _daysContainer.clipsToBounds = NO;
            [_selectedDates removeLastObject];
        }
        [_collectionView selectItemAtIndexPath:targetIndexPath animated:YES scrollPosition:UICollectionViewScrollPositionNone];
        
        FSCalendarCell *cell = (FSCalendarCell *)[_collectionView cellForItemAtIndexPath:targetIndexPath];
        _daysContainer.clipsToBounds = NO;
        [cell performSelecting];
        
        [_collectionView.visibleCells enumerateObjectsUsingBlock:^(FSCalendarCell *cell, NSUInteger idx, BOOL *stop) {
            if (cell.dateIsPlaceholder && [cell.date fs_isEqualToDateForDay:targetDate] && !cell.dateIsSelected) {
                cell.dateIsSelected = YES;
                [cell performSelecting];
                *stop = YES;
            }
        }];
        
        [self enqueueSelectedDate:targetDate];
    }
    
    if (scrollToDate) {
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
    NSDate * targetDate = [date fs_daysFrom:_minimumDate] < 0 ? _minimumDate : date;
    targetDate = [targetDate fs_daysFrom:_maximumDate] > 0 ? _maximumDate : date;
    NSInteger scrollOffset = 0;
    switch (_scope) {
        case FSCalendarScopeMonth: {
            scrollOffset = [targetDate fs_monthsFrom:_minimumDate.fs_firstDayOfMonth];
            break;
        }
        case FSCalendarScopeWeek: {
            scrollOffset = [targetDate fs_weeksFrom:_minimumDate.fs_firstDayOfWeek];
            break;
        }
        default: {
            break;
        }
    }
    
    if (_pagingEnabled) {
        
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
        CGRect itemFrame = [_collectionView layoutAttributesForItemAtIndexPath:[NSIndexPath indexPathForItem:0 inSection:scrollOffset]].frame;
        if (self.floatingMode && CGRectEqualToRect(itemFrame, CGRectZero)) {
            _currentPage = targetDate;
            _needsAdjustingMonthPosition = YES;
            [self setNeedsLayout];
        } else {
            CGRect headerFrame = CGRectOffset(itemFrame, 0, -_collectionViewLayout.headerReferenceSize.height);
            [_collectionView setContentOffset:headerFrame.origin animated:animated];
        }
    }
    
    if (_header && !animated) {
        _header.scrollOffset = scrollOffset;
    }
    _supressEvent = NO;
}

- (void)scrollToPageForDate:(NSDate *)date animated:(BOOL)animated
{
    if (!_collectionView.tracking && !_collectionView.decelerating) {
        if (!self.floatingMode && [self isDateInDifferentPage:date]) {
            [self willChangeValueForKey:@"currentPage"];
            switch (_scope) {
                case FSCalendarScopeMonth: {
                    _currentPage = date.fs_firstDayOfMonth;
                    break;
                }
                case FSCalendarScopeWeek: {
                    _currentPage = date.fs_firstDayOfWeek;
                    break;
                }
                default: {
                    break;
                }
            }
            if (!_supressEvent && !CGSizeEqualToSize(_collectionView.frame.size, CGSizeZero)) {
                _supressEvent = YES;
                [self currentPageDidChange];
                _supressEvent = NO;
            }
            [self didChangeValueForKey:@"currentPage"];
            [self scrollToDate:_currentPage animated:animated];
        } else if (!_pagingEnabled) {
            [self scrollToDate:date.fs_firstDayOfMonth animated:animated];
        }
    }
}

- (NSDate *)dateForIndexPath:(NSIndexPath *)indexPath
{
    switch (_scope) {
        case FSCalendarScopeMonth: {
            NSDate *currentPage = [_minimumDate.fs_firstDayOfMonth fs_dateByAddingMonths:indexPath.section];
            NSDate *firstDayOfMonth = [NSDate fs_dateWithYear:currentPage.fs_year
                                                        month:currentPage.fs_month
                                                          day:1];
            NSInteger numberOfPlaceholdersForPrev = ((firstDayOfMonth.fs_weekday - _firstWeekday) + 7) % 7 ?: (7 * !self.floatingMode);
            NSDate *firstDateOfPage = [firstDayOfMonth fs_dateBySubtractingDays:numberOfPlaceholdersForPrev];
            switch (_collectionViewLayout.scrollDirection) {
                case UICollectionViewScrollDirectionHorizontal: {
                    NSUInteger    rows = indexPath.item % 6;
                    NSUInteger columns = indexPath.item / 6;
                    return [firstDateOfPage fs_dateByAddingDays:7 * rows + columns];
                }
                case UICollectionViewScrollDirectionVertical: {
                    return [firstDateOfPage fs_dateByAddingDays:indexPath.item];
                }
                default:
                    break;
            }
            break;
        }
        case FSCalendarScopeWeek: {
            NSDate *currentPage = [_minimumDate.fs_firstDayOfWeek fs_dateByAddingWeeks:indexPath.section];
            return [currentPage fs_dateByAddingDays:indexPath.item];
        }
        default: {
            break;
        }
    }
    return nil;
}

- (NSIndexPath *)indexPathForDate:(NSDate *)date
{
    NSInteger item = 0;
    NSInteger section = 0;
    switch (_scope) {
        case FSCalendarScopeMonth: {
            section = [date fs_monthsFrom:_minimumDate.fs_firstDayOfMonth];
            NSDate *firstDayOfMonth = date.fs_firstDayOfMonth;
            NSInteger numberOfPlaceholdersForPrev = ((firstDayOfMonth.fs_weekday - _firstWeekday) + 7) % 7 ?: (7 * !self.floatingMode);
            NSDate *firstDateOfPage = [firstDayOfMonth fs_dateBySubtractingDays:numberOfPlaceholdersForPrev];
            switch (_collectionViewLayout.scrollDirection) {
                case UICollectionViewScrollDirectionHorizontal: {
                    NSInteger vItem = [date fs_daysFrom:firstDateOfPage];
                    NSInteger rows = vItem/7;
                    NSInteger columns = vItem%7;
                    item = columns*6 + rows;
                    break;
                }
                case UICollectionViewScrollDirectionVertical: {
                    item = [date fs_daysFrom:firstDateOfPage];
                    break;
                }
                default:
                    break;
            }
            break;
        }
        case FSCalendarScopeWeek: {
            section = [date fs_weeksFrom:_minimumDate.fs_firstDayOfWeek];
            item = ((date.fs_weekday - _firstWeekday) + 7) % 7;
            break;
        }
        default: {
            break;
        }
    }
    return [NSIndexPath indexPathForItem:item inSection:section];
}

- (BOOL)isDateInRange:(NSDate *)date
{
    return [date fs_daysFrom:_minimumDate] >= 0 && [date fs_daysFrom:_maximumDate] <= 0;
}

- (BOOL)isDateSelected:(NSDate *)date
{
    return [self.selectedDates containsObject:date] || [_collectionView.indexPathsForSelectedItems containsObject:[self indexPathForDate:date]];
}

- (BOOL)isDateInDifferentPage:(NSDate *)date
{
    if (self.floatingMode) {
        return ![date fs_isEqualToDateForMonth:_currentPage];
    }
    switch (_scope) {
        case FSCalendarScopeMonth:
            return ![date fs_isEqualToDateForMonth:_currentPage];
        case FSCalendarScopeWeek:
            return ![date fs_isEqualToDateForWeek:_currentPage];
    }
}

- (void)adjustRowHeight
{
    CGFloat headerHeight = _headerHeight == -1 ? kFSCalendarDefaultHeaderHeight : _headerHeight;
    CGFloat contentHeight = self.fs_height-kFSCalendarDefaultWeekHeight - headerHeight;
    CGFloat padding = kFSCalendarDefaultWeekHeight*0.1;
    if (!self.floatingMode) {
        switch (_scope) {
            case FSCalendarScopeMonth: {
                _rowHeight = (contentHeight-padding*2)/6;
                break;
            }
            case FSCalendarScopeWeek: {
                _rowHeight = MAX((contentHeight-padding*2)/6, kFSCalendarMinimumRowHeight);
                break;
            }
            default: {
                break;
            }
        }
    } else {
        _rowHeight = kFSCalendarMinimumRowHeight;
    }
}

- (void)invalidateLayout
{
    if (!self.floatingMode) {
        
        if (!_header) {
            
            FSCalendarHeader *header = [[FSCalendarHeader alloc] initWithFrame:CGRectZero];
            header.appearance = _appearance;
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
            NSArray *weekSymbols = _calendar.shortStandaloneWeekdaySymbols;
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
        
    }
    
    _needsAdjustingViewFrame = YES;
    [self setNeedsLayout];
}

- (void)invalidateWeekdaySymbols
{
    NSArray *weekdaySymbols = _appearance.useVeryShortWeekdaySymbols ? _calendar.veryShortStandaloneWeekdaySymbols : _calendar.shortStandaloneWeekdaySymbols;
    [_weekdays enumerateObjectsUsingBlock:^(UILabel *label, NSUInteger index, BOOL *stop) {
        label.text = weekdaySymbols[index];
    }];
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

- (void)enqueueSelectedDate:(NSDate *)date
{
    if (!self.allowsMultipleSelection) {
        [_selectedDates removeAllObjects];
    }
    if (![_selectedDates containsObject:date]) {
        [_selectedDates addObject:date];
    }
    [_selectedDates sortUsingComparator:^NSComparisonResult(NSDate *d1, NSDate *d2) {
        return [d1 compare:d2] == NSOrderedDescending;
    }];
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
    return _ibEditing && ([@[@3,@5,@8,@16,@20,@25] containsObject:@(date.fs_day)]);
}

- (NSDate *)minimumDateForCalendar
{
    if (_dataSource && [_dataSource respondsToSelector:@selector(minimumDateForCalendar:)]) {
        _minimumDate = [_dataSource minimumDateForCalendar:self].fs_dateByIgnoringTimeComponents;
    }
    if (!_minimumDate) {
        _minimumDate = [NSDate fs_dateWithYear:1970 month:1 day:1];
    }
    return _minimumDate;
}

- (NSDate *)maximumDateForCalendar
{
    if (_dataSource && [_dataSource respondsToSelector:@selector(maximumDateForCalendar:)]) {
        _maximumDate = [_dataSource maximumDateForCalendar:self].fs_dateByIgnoringTimeComponents;
    }
    if (!_maximumDate) {
        _maximumDate = [NSDate fs_dateWithYear:2099 month:12 day:31];
    }
    return _maximumDate;
}

@end


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




