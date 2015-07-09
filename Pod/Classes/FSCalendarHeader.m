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

@property (readonly, nonatomic) FSCalendar *calendar;

- (void)updateAlphaForCell:(UICollectionViewCell *)cell;

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
    [_dateFormatter setLocalizedDateFormatFromTemplate:_appearance.headerDateFormat];   //.dateFormat = _appearance.headerDateFormat;
    if (_scrollDirection == UICollectionViewScrollDirectionHorizontal) {
        // 多出的两项需要制空
        if ((indexPath.item == 0 || indexPath.item == [collectionView numberOfItemsInSection:0] - 1 )) {
            cell.titleLabel.text = nil;
        } else {
            NSDate *date = [self.calendar.minimumDate fs_dateByAddingMonths:indexPath.item - 1].fs_dateByIgnoringTimeComponents;
            cell.titleLabel.text = [[_dateFormatter stringFromDate:date] capitalizedString];
        }
    } else {
        NSDate *date = [self.calendar.minimumDate fs_dateByAddingMonths:indexPath.item].fs_dateByIgnoringTimeComponents;
        cell.titleLabel.text = [_dateFormatter stringFromDate:date];
    }
    return cell;
}

- (void)collectionView:(UICollectionView *)collectionView willDisplayCell:(UICollectionViewCell *)cell forItemAtIndexPath:(NSIndexPath *)indexPath
{
    [self updateAlphaForCell:cell];
}

#pragma mark - Properties

- (void)setScrollOffset:(CGFloat)scrollOffset
{
    if (_scrollOffset != scrollOffset) {
        _scrollOffset = scrollOffset;
    }
    if (self.scrollDirection == UICollectionViewScrollDirectionHorizontal) {
        _collectionView.contentOffset = CGPointMake((_scrollOffset+0.5)*_collectionViewFlowLayout.itemSize.width, 0);
    } else {
        _collectionView.contentOffset = CGPointMake(0, _scrollOffset * _collectionViewFlowLayout.itemSize.height);
    }
    dispatch_async(dispatch_get_main_queue(), ^{
        NSArray *cells = _collectionView.visibleCells;
        [cells enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
            [self updateAlphaForCell:obj];
        }];
    });
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

- (void)updateAlphaForCell:(UICollectionViewCell *)cell
{
    [[cell.contentView viewWithTag:100] setFrame:cell.contentView.bounds];
    if (self.scrollDirection == UICollectionViewScrollDirectionHorizontal) {
        CGFloat position = [cell convertPoint:CGPointMake(CGRectGetMidX(cell.bounds), CGRectGetMidY(cell.bounds)) toView:self].x;
        CGFloat center = CGRectGetMidX(self.bounds);
        cell.contentView.alpha = 1.0 - (1.0-_appearance.headerMinimumDissolvedAlpha)*ABS(center-position)/_collectionViewFlowLayout.itemSize.width;
    } else {
        CGFloat position = [cell convertPoint:CGPointMake(CGRectGetMidX(cell.bounds), CGRectGetMidY(cell.bounds)) toView:self].y;
        CGFloat center = CGRectGetMidY(self.bounds);
        cell.contentView.alpha = 1.0 - (1.0-_appearance.headerMinimumDissolvedAlpha)*ABS(center-position)/_collectionViewFlowLayout.itemSize.height;
    }
}


- (FSCalendar *)calendar
{
    return (FSCalendar *)self.superview;
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

@end

