//
//  FSCalendarHeader.h
//  Pods
//
//  Created by Wenchao Ding on 29/1/15.
//
//

#import <UIKit/UIKit.h>

@class FSCalendarHeader, FSCalendar, FSCalendarAppearance;

@interface FSCalendarHeader : UIView

@property (assign  , nonatomic) CGFloat     scrollOffset;
@property (strong  , nonatomic) NSDate      *minimumDate;
@property (strong  , nonatomic) NSDate      *maximumDate;

@property (weak, nonatomic) FSCalendarAppearance *appearance;

@property (assign  , nonatomic) UICollectionViewScrollDirection scrollDirection;

- (void)reloadData;

@end