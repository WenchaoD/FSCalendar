//
//  FSCalendarHeader.m
//  Pods
//
//  Created by Wenchao Ding on 29/1/15.
//
//

#import "FSCalendar.h"
#import "UIView+FSExtension.h"
#import "FSCalendarHeader.h"
#import "FSCalendarCollectionView.h"
#import "FSCalendarDynamicHeader.h"

@interface FSCalendarHeader ()<UICollectionViewDataSource,UICollectionViewDelegate>

@property (weak, nonatomic) UICollectionViewFlowLayout *collectionViewLayout;

@property (assign, nonatomic) BOOL needsAdjustingMonthPosition;

@end

@implementation FSCalendarHeader

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
    _scrollDirection = UICollectionViewScrollDirectionHorizontal;
    _scrollEnabled = YES;
    _needsAdjustingMonthPosition = YES;
    _needsAdjustingViewFrame = YES;
    
    UICollectionViewFlowLayout *collectionViewLayout = [[UICollectionViewFlowLayout alloc] init];
    collectionViewLayout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
    collectionViewLayout.minimumInteritemSpacing = 0;
    collectionViewLayout.minimumLineSpacing = 0;
    collectionViewLayout.sectionInset = UIEdgeInsetsZero;
    collectionViewLayout.itemSize = CGSizeMake(1, 1);
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
        _collectionView.frame = CGRectMake(0, self.fs_height*0.1, self.fs_width, self.fs_height*0.9);
        _collectionViewLayout.itemSize = CGSizeMake(
                                                        _collectionView.fs_width*((_scrollDirection==UICollectionViewScrollDirectionHorizontal)?0.5:1),
                                                        _collectionView.fs_height
                                                       );
    }
    
    if (_needsAdjustingMonthPosition) {
        _needsAdjustingMonthPosition = NO;
        if (self.scrollDirection == UICollectionViewScrollDirectionHorizontal) {
            [_collectionView setContentOffset:CGPointMake((_scrollOffset+0.5)*_collectionViewLayout.itemSize.width, 0) animated:NO];
        } else {
            [_collectionView setContentOffset:CGPointMake(0, _scrollOffset * _collectionViewLayout.itemSize.height) animated:NO];
        }
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
                    NSDate *minimumPage = [_calendar beginingOfMonthOfDate:_calendar.minimumDate];
                    NSInteger count = [_calendar monthsFromDate:minimumPage toDate:_calendar.maximumDate] + 1;
                    return count;
                }
                case UICollectionViewScrollDirectionHorizontal: {
                    // 这里需要默认多出两项，否则当contentOffset为负时，切换到其他页面时会自动归零
                    // 2 more pages to prevent scrollView from auto bouncing while push/present to other UIViewController
                    NSDate *minimumPage = [_calendar beginingOfMonthOfDate:_calendar.minimumDate];
                    NSInteger count = [_calendar monthsFromDate:minimumPage toDate:_calendar.maximumDate] + 1;
                    return count + 2;
                }
                default: {
                    break;
                }
            }
            break;
        }
        case FSCalendarScopeWeek: {
            NSDate *minimumPage = [_calendar beginingOfMonthOfDate:_calendar.minimumDate];
            NSInteger count = [_calendar weeksFromDate:minimumPage toDate:_calendar.maximumDate] + 1;
            return count + 2;
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
                    NSDate *date = [_calendar dateByAddingMonths:indexPath.item-1 toDate:_calendar.minimumDate];
                    text = [_calendar.formatter stringFromDate:date];
                }
            } else {
                NSDate *date = [_calendar dateByAddingMonths:indexPath.item toDate:_calendar.minimumDate];
                text = [_calendar.formatter stringFromDate:date];
            }
            break;
        }
        case FSCalendarScopeWeek: {
            if ((indexPath.item == 0 || indexPath.item == [collectionView numberOfItemsInSection:0] - 1)) {
                text = nil;
            } else {
                NSDate *firstPage = [_calendar middleOfWeekFromDate:_calendar.minimumDate];
                NSDate *date = [_calendar dateByAddingWeeks:indexPath.item-1 toDate:firstPage];
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
        _appearance  = calendar.appearance;
    }
}


- (void)setScrollOffset:(CGFloat)scrollOffset
{
    if (_scrollOffset != scrollOffset) {
        _scrollOffset = scrollOffset;
    }
    _needsAdjustingMonthPosition = YES;
    [self setNeedsLayout];
}

- (void)setScrollDirection:(UICollectionViewScrollDirection)scrollDirection
{
    if (_scrollDirection != scrollDirection) {
        _scrollDirection = scrollDirection;
        _collectionViewLayout.scrollDirection = scrollDirection;
        _needsAdjustingMonthPosition = YES;
        _needsAdjustingViewFrame = YES;
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


