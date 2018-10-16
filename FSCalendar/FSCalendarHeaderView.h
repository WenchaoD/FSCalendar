//
//  FSCalendarHeader.h
//  Pods
//
//  Created by Wenchao Ding on 29/1/15.
//
//

#import <UIKit/UIKit.h>

@class FSCalendar, FSCalendarAppearance, FSCalendarHeaderLayout, FSCalendarCollectionView;

@interface FSCalendarHeaderView : UIView

@property (weak, nonatomic) FSCalendarCollectionView *collectionView;
@property (weak, nonatomic) FSCalendarHeaderLayout *collectionViewLayout;
@property (weak, nonatomic) FSCalendar *calendar;

@property (assign, nonatomic) UICollectionViewScrollDirection scrollDirection;
@property (assign, nonatomic) BOOL scrollEnabled;

- (void)setScrollOffset:(CGFloat)scrollOffset;
- (void)setScrollOffset:(CGFloat)scrollOffset animated:(BOOL)animated;
- (void)reloadData;
- (void)configureAppearance;

@end


@interface FSCalendarHeaderCell : UICollectionViewCell

@property (weak, nonatomic) UILabel *titleLabel;
@property (weak, nonatomic) FSCalendarHeaderView *header;

@end

@interface FSCalendarHeaderLayout : UICollectionViewFlowLayout

@end

@interface FSCalendarHeaderTouchDeliver : UIView

@property (weak, nonatomic) FSCalendar *calendar;
@property (weak, nonatomic) FSCalendarHeaderView *header;

@end
