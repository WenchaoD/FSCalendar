//
//  FSCalendarHeader.m
//  Pods
//
//  Created by Wenchao Ding on 29/1/15.
//
//

#import "FSCalendar.h"
#import "FSCalendarExtensions.h"
#import "FSCalendarHeaderView.h"
#import "FSCalendarCollectionView.h"
#import "FSCalendarDynamicHeader.h"

@interface FSCalendarHeaderView ()<UICollectionViewDataSource,UICollectionViewDelegate>

@property (readonly, nonatomic) BOOL hasValidateVisibleLayout;

- (void)scrollToOffset:(CGFloat)scrollOffset;

@end

@implementation FSCalendarHeaderView

#pragma mark - Life cycle

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
    _needsAdjustingViewFrame = YES;
    _scrollDirection = UICollectionViewScrollDirectionHorizontal;
    _scrollEnabled = YES;
    
    FSCalendarHeaderLayout *collectionViewLayout = [[FSCalendarHeaderLayout alloc] init];
    self.collectionViewLayout = collectionViewLayout;
    
    FSCalendarCollectionView *collectionView = [[FSCalendarCollectionView alloc] initWithFrame:CGRectZero collectionViewLayout:collectionViewLayout];
    collectionView.scrollEnabled = NO;
    collectionView.userInteractionEnabled = NO;
    collectionView.backgroundColor = [UIColor clearColor];
    collectionView.dataSource = self;
    collectionView.delegate = self;
    collectionView.showsHorizontalScrollIndicator = NO;
    collectionView.showsVerticalScrollIndicator = NO;
    [self addSubview:collectionView];
    [collectionView registerClass:[FSCalendarHeaderCell class] forCellWithReuseIdentifier:@"cell"];
    self.collectionView = collectionView;
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    if (_needsAdjustingViewFrame) {
        _needsAdjustingViewFrame = NO;
        _collectionViewLayout.itemSize = CGSizeMake(1, 1);
        [_collectionViewLayout invalidateLayout];
        _collectionView.frame = CGRectMake(0, self.fs_height*0.1, self.fs_width, self.fs_height*0.9);
    }
    
    if (_needsAdjustingMonthPosition) {
        _needsAdjustingMonthPosition = NO;
        [self scrollToOffset:_scrollOffset];
    };
    
}

- (void)dealloc
{
    _collectionView.dataSource = nil;
    _collectionView.delegate = nil;
}

#pragma mark - <UICollectionViewDataSource>

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
    return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    switch (self.calendar.scope) {
        case FSCalendarScopeMonth: {
            switch (_scrollDirection) {
                case UICollectionViewScrollDirectionVertical: {
                    NSDate *minimumPage = [_calendar.gregorian fs_firstDayOfMonth:_calendar.minimumDate];
                    NSInteger months = [self.calendar.gregorian components:NSCalendarUnitMonth fromDate:minimumPage toDate:self.calendar.maximumDate options:0].month + 1;
                    return months;
                }
                case UICollectionViewScrollDirectionHorizontal: {
                    // 2 more pages to prevent scrollView from auto bouncing while push/present to other UIViewController
                    NSDate *minimumPage = [_calendar.gregorian fs_firstDayOfMonth:_calendar.minimumDate];
                    NSInteger months = [self.calendar.gregorian components:NSCalendarUnitMonth fromDate:minimumPage toDate:self.calendar.maximumDate options:0].month + 1;
                    return months + 2;
                }
                default: {
                    break;
                }
            }
            break;
        }
        case FSCalendarScopeWeek: {
            NSDate *minimumPage = [self.calendar.gregorian fs_firstDayOfMonth:_calendar.minimumDate];
            NSInteger weeks = [self.calendar.gregorian components:NSCalendarUnitWeekOfYear fromDate:minimumPage toDate:self.calendar.maximumDate options:0].weekOfYear + 1;
            return weeks + 2;
        }
        default: {
            break;
        }
    }
    return 0;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    FSCalendarHeaderCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"cell" forIndexPath:indexPath];
    cell.header = self;
    cell.titleLabel.font = _appearance.preferredHeaderTitleFont;
    cell.titleLabel.textColor = _appearance.headerTitleColor;
    _calendar.formatter.dateFormat = _appearance.headerDateFormat;
    BOOL usesUpperCase = (_appearance.caseOptions & 15) == FSCalendarCaseOptionsHeaderUsesUpperCase;
    NSString *text = nil;
    switch (self.calendar.scope) {
        case FSCalendarScopeMonth: {
            if (_scrollDirection == UICollectionViewScrollDirectionHorizontal) {
                // 多出的两项需要制空
                if ((indexPath.item == 0 || indexPath.item == [collectionView numberOfItemsInSection:0] - 1)) {
                    text = nil;
                } else {
                    NSDate *date = [self.calendar.gregorian dateByAddingUnit:NSCalendarUnitMonth value:indexPath.item-1 toDate:self.calendar.minimumDate options:0];
                    text = [_calendar.formatter stringFromDate:date];
                }
            } else {
                NSDate *date = [self.calendar.gregorian dateByAddingUnit:NSCalendarUnitMonth value:indexPath.item toDate:self.calendar.minimumDate options:0];
                text = [_calendar.formatter stringFromDate:date];
            }
            break;
        }
        case FSCalendarScopeWeek: {
            if ((indexPath.item == 0 || indexPath.item == [collectionView numberOfItemsInSection:0] - 1)) {
                text = nil;
            } else {
                NSDate *firstPage = [self.calendar.gregorian fs_middleDayOfWeek:self.calendar.minimumDate];
                NSDate *date = [self.calendar.gregorian dateByAddingUnit:NSCalendarUnitWeekOfYear value:indexPath.item-1 toDate:firstPage options:0];
                text = [_calendar.formatter stringFromDate:date];
            }
            break;
        }
        default: {
            break;
        }
    }
    text = usesUpperCase ? text.uppercaseString : text;
    cell.titleLabel.text = text;
    [cell setNeedsLayout];
    return cell;
}

- (void)collectionView:(UICollectionView *)collectionView didEndDisplayingCell:(UICollectionViewCell *)cell forItemAtIndexPath:(NSIndexPath *)indexPath
{
    [cell setNeedsLayout];
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    [_collectionView.visibleCells makeObjectsPerformSelector:@selector(setNeedsLayout)];
}

#pragma mark - Properties


- (void)setCalendar:(FSCalendar *)calendar
{
    if (![_calendar isEqual:calendar]) {
        _calendar = calendar;
        _appearance = calendar.appearance;
    }
}


- (void)setScrollOffset:(CGFloat)scrollOffset
{
    if (_scrollOffset != scrollOffset) {
        _scrollOffset = scrollOffset;
    }
    if (self.hasValidateVisibleLayout) {
        [self scrollToOffset:scrollOffset];
    } else {
        _needsAdjustingMonthPosition = YES;
        [self setNeedsLayout];
    }
}

- (void)scrollToOffset:(CGFloat)scrollOffset
{
#if TARGET_INTERFACE_BUILDER
    _needsAdjustingMonthPosition = YES;
#endif
    if (self.scrollDirection == UICollectionViewScrollDirectionHorizontal) {
        CGFloat step = self.collectionView.fs_width*((self.scrollDirection==UICollectionViewScrollDirectionHorizontal)?0.5:1);
        [_collectionView setContentOffset:CGPointMake((scrollOffset+0.5)*step, 0) animated:NO];
    } else {
        CGFloat step = self.collectionView.fs_height;
        [_collectionView setContentOffset:CGPointMake(0, scrollOffset*step) animated:NO];
    }
}

- (void)setScrollDirection:(UICollectionViewScrollDirection)scrollDirection
{
    if (_scrollDirection != scrollDirection) {
        _scrollDirection = scrollDirection;
        _collectionViewLayout.scrollDirection = scrollDirection;
        _needsAdjustingMonthPosition = YES;
        [self setNeedsLayout];
    }
}

- (void)setScrollEnabled:(BOOL)scrollEnabled
{
    if (_scrollEnabled != scrollEnabled) {
        _scrollEnabled = scrollEnabled;
        [_collectionView.visibleCells makeObjectsPerformSelector:@selector(setNeedsLayout)];
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

#pragma mark - Public

- (void)reloadData
{
    [_collectionView reloadData];
}

@end


@implementation FSCalendarHeaderCell

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        titleLabel.textAlignment = NSTextAlignmentCenter;
        titleLabel.lineBreakMode = NSLineBreakByWordWrapping;
        titleLabel.numberOfLines = 0;
        [self.contentView addSubview:titleLabel];
        self.titleLabel = titleLabel;
    }
    return self;
}

- (void)setBounds:(CGRect)bounds
{
    [super setBounds:bounds];
    _titleLabel.frame = bounds;
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    self.titleLabel.frame = self.contentView.bounds;
    
    if (self.header.scrollDirection == UICollectionViewScrollDirectionHorizontal) {
        CGFloat position = [self.contentView convertPoint:CGPointMake(CGRectGetMidX(self.contentView.bounds), CGRectGetMidY(self.contentView.bounds)) toView:self.header].x;
        CGFloat center = CGRectGetMidX(self.header.bounds);
        if (self.header.scrollEnabled) {
            self.contentView.alpha = 1.0 - (1.0-self.header.appearance.headerMinimumDissolvedAlpha)*ABS(center-position)/self.fs_width;
        } else {
            self.contentView.alpha = (position > 0 && position < self.header.fs_width*0.75);
        }
    } else if (self.header.scrollDirection == UICollectionViewScrollDirectionVertical) {
        CGFloat position = [self.contentView convertPoint:CGPointMake(CGRectGetMidX(self.contentView.bounds), CGRectGetMidY(self.contentView.bounds)) toView:self.header].y;
        CGFloat center = CGRectGetMidY(self.header.bounds);
        self.contentView.alpha = 1.0 - (1.0-self.header.appearance.headerMinimumDissolvedAlpha)*ABS(center-position)/self.fs_height;
    }
    
}

- (void)invalidateHeaderFont
{
    _titleLabel.font = self.header.appearance.preferredHeaderTitleFont;
}

- (void)invalidateHeaderTextColor
{
    _titleLabel.textColor = self.header.appearance.headerTitleColor;
}

@end


@implementation FSCalendarHeaderLayout

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.scrollDirection = UICollectionViewScrollDirectionHorizontal;
        self.minimumInteritemSpacing = 0;
        self.minimumLineSpacing = 0;
        self.sectionInset = UIEdgeInsetsZero;
        self.itemSize = CGSizeMake(1, 1);
    }
    return self;
}

- (void)prepareLayout
{
    [super prepareLayout];
    
    self.itemSize = CGSizeMake(
                               self.collectionView.fs_width*((self.scrollDirection==UICollectionViewScrollDirectionHorizontal)?0.5:1),
                               self.collectionView.fs_height
                              );
    
}

@end

@implementation FSCalendarHeaderTouchDeliver

- (UIView *)hitTest:(CGPoint)point withEvent:(UIEvent *)event
{
    UIView *hitView = [super hitTest:point withEvent:event];
    if (hitView == self) {
        return _calendar.collectionView ?: hitView;
    }
    return hitView;
}

@end


