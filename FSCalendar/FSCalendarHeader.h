//
//  FSCalendarHeader.h
//  Pods
//
//  Created by Wenchao Ding on 29/1/15.
//
//

#import <UIKit/UIKit.h>
#import "FSCalendarCollectionView.h"

@class FSCalendar,FSCalendarAppearance;

@interface FSCalendarHeader : UIView

@property (weak, nonatomic) FSCalendarCollectionView *collectionView;
@property (weak, nonatomic) FSCalendar *calendar;
@property (weak, nonatomic) FSCalendarAppearance *appearance;

@property (assign, nonatomic) CGFloat scrollOffset;
@property (assign, nonatomic) UICollectionViewScrollDirection scrollDirection;
@property (assign, nonatomic) BOOL scrollEnabled;

- (void)reloadData;

@end


@interface FSCalendarHeaderCell : UICollectionViewCell

@property (weak, nonatomic) UILabel *titleLabel;
@property (weak, nonatomic) FSCalendarHeader *header;

@end


@interface FSCalendarHeaderTouchDeliver : UIView

@property (weak, nonatomic) FSCalendar *calendar;
@property (weak, nonatomic) FSCalendarHeader *header;

@end
