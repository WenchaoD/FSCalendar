//
//  FSCalendarHeader.m
//  Pods
//
//  Created by Wenchao Ding on 29/1/15.
//
//

#import "FSCalendarHeader.h"
#import "FSCalendar.h"
#import "UIView+FSExtension.h"
#import "NSDate+FSExtension.h"

#define kBlueText [UIColor colorWithRed:14/255.0 green:69/255.0 blue:221/255.0 alpha:1.0]

@interface FSCalendarHeader ()<UICollectionViewDataSource,UICollectionViewDelegate>

@property (copy, nonatomic) NSDateFormatter            *dateFormatter;
@property (weak, nonatomic) UICollectionView           *collectionView;
@property (weak, nonatomic) UICollectionViewFlowLayout *collectionViewFlowLayout;

@property (assign, nonatomic) BOOL needsAdjustingMonthPosition;

@property (readonly, nonatomic) FSCalendar *calendar;

- (void)setNeedsAdjusting;

@end

@implementation FSCalendarHeader

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
    _dateFormatter            = [[NSDateFormatter alloc] init];
    _scrollDirection          = UICollectionViewScrollDirectionHorizontal;

    UICollectionViewFlowLayout *collectionViewFlowLayout = [[UICollectionViewFlowLayout alloc] init];
    collectionViewFlowLayout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
    collectionViewFlowLayout.minimumInteritemSpacing = 0;
    collectionViewFlowLayout.minimumLineSpacing = 0;
    collectionViewFlowLayout.sectionInset = UIEdgeInsetsZero;
    collectionViewFlowLayout.itemSize = CGSizeMake(1, 1);
    self.collectionViewFlowLayout = collectionViewFlowLayout;
    
    UICollectionView *collectionView = [[UICollectionView alloc] initWithFrame:CGRectZero collectionViewLayout:collectionViewFlowLayout];
    collectionView.scrollEnabled = NO;
    collectionView.userInteractionEnabled = NO;
    collectionView.backgroundColor = [UIColor clearColor];
    collectionView.dataSource = self;
    collectionView.delegate = self;
    collectionView.contentInset = UIEdgeInsetsZero;
    [self addSubview:collectionView];
    [collectionView registerClass:[FSCalendarHeaderCell class] forCellWithReuseIdentifier:@"cell"];
    self.collectionView = collectionView;
    
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    _collectionView.frame = CGRectMake(0, self.fs_height*0.1, self.fs_width, self.fs_height*0.9);
    _collectionView.contentInset = UIEdgeInsetsZero;
    _collectionViewFlowLayout.itemSize = CGSizeMake(_collectionView.fs_width * 0.5,
                                                    _collectionView.fs_height);
    if (_needsAdjustingMonthPosition) {
        _needsAdjustingMonthPosition = NO;
        if (self.scrollDirection == UICollectionViewScrollDirectionHorizontal) {
            _collectionView.contentOffset = CGPointMake((_scrollOffset+0.5)*_collectionViewFlowLayout.itemSize.width, 0);
        } else {
            _collectionView.contentOffset = CGPointMake(0, _scrollOffset * _collectionViewFlowLayout.itemSize.height);
        }
    }
}

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
    return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    NSInteger count = [self.calendar.maximumDate fs_monthsFrom:self.calendar.minimumDate.fs_firstDayOfMonth] + 1;
    if (_scrollDirection == UICollectionViewScrollDirectionHorizontal) {
        // 这里需要默认多出两项，否则当contentOffset为负时，切换到其他页面时会自动归零
        // 2 more pages to prevent scrollView from auto bouncing while push/present to other UIViewController
        return count + 2;
    }
    return count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    FSCalendarHeaderCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"cell" forIndexPath:indexPath];
    cell.titleLabel.font = _appearance.headerTitleFont;
    cell.titleLabel.textColor = _appearance.headerTitleColor;
    _dateFormatter.dateFormat = _appearance.headerDateFormat;
    if (_scrollDirection == UICollectionViewScrollDirectionHorizontal) {
        // 多出的两项需要制空
        if ((indexPath.item == 0 || indexPath.item == [collectionView numberOfItemsInSection:0] - 1 )) {
            cell.titleLabel.text = nil;
        } else {
            NSDate *date = [self.calendar.minimumDate fs_dateByAddingMonths:indexPath.item - 1].fs_dateByIgnoringTimeComponents;
            cell.titleLabel.text = [_dateFormatter stringFromDate:date];
        }
    } else {
        NSDate *date = [self.calendar.minimumDate fs_dateByAddingMonths:indexPath.item].fs_dateByIgnoringTimeComponents;
        cell.titleLabel.text = [_dateFormatter stringFromDate:date];
    }
    return cell;
}

- (void)collectionView:(UICollectionView *)collectionView willDisplayCell:(UICollectionViewCell *)cell forItemAtIndexPath:(NSIndexPath *)indexPath
{
    [cell setNeedsLayout];
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    [_collectionView.visibleCells makeObjectsPerformSelector:@selector(setNeedsLayout)];
}

#pragma mark - Properties

- (void)setScrollOffset:(CGFloat)scrollOffset
{
    if (_scrollOffset != scrollOffset) {
        _scrollOffset = scrollOffset;
    }
    [self setNeedsAdjusting];
}

- (void)setScrollDirection:(UICollectionViewScrollDirection)scrollDirection
{
    if (_scrollDirection != scrollDirection) {
        _scrollDirection = scrollDirection;
        _collectionViewFlowLayout.scrollDirection = scrollDirection;
        CGPoint newOffset = CGPointMake(
                                        scrollDirection == UICollectionViewScrollDirectionHorizontal ? (_scrollOffset-0.5)*_collectionViewFlowLayout.itemSize.width : 0,
                                        scrollDirection == UICollectionViewScrollDirectionVertical ? _scrollOffset * _collectionViewFlowLayout.itemSize.height : 0
                                        );
        _collectionView.contentOffset = newOffset;
        if (scrollDirection == UICollectionViewScrollDirectionVertical) {
            _collectionViewFlowLayout.sectionInset = UIEdgeInsetsMake(0, self.fs_width*0.25, 0, self.fs_width*0.25);
        } else {
            _collectionViewFlowLayout.sectionInset = UIEdgeInsetsZero;
        }
        [_collectionView reloadData];
    }
}

#pragma mark - Public

- (void)reloadData
{
    [_collectionView reloadData];
}

#pragma mark - Private

- (FSCalendar *)calendar
{
    return (FSCalendar *)self.superview;
}

- (void)setNeedsAdjusting
{
    _needsAdjustingMonthPosition = YES;
    [self setNeedsLayout];
}

@end


@implementation FSCalendarHeaderCell

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        titleLabel.textAlignment = NSTextAlignmentCenter;
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
        self.contentView.alpha = 1.0 - (1.0-self.header.appearance.headerMinimumDissolvedAlpha)*ABS(center-position)/self.fs_width;
    } else {
        CGFloat position = [self.contentView convertPoint:CGPointMake(CGRectGetMidX(self.contentView.bounds), CGRectGetMidY(self.contentView.bounds)) toView:self.header].y;
        CGFloat center = CGRectGetMidY(self.header.bounds);
        self.contentView.alpha = 1.0 - (1.0-self.header.appearance.headerMinimumDissolvedAlpha)*ABS(center-position)/self.fs_height;
    }
}

- (FSCalendarHeader *)header
{
    UIView *superview = self.superview;
    while (superview && ![superview isKindOfClass:[FSCalendarHeader class]]) {
        superview = superview.superview;
    }
    return (FSCalendarHeader *)superview;
}


@end

