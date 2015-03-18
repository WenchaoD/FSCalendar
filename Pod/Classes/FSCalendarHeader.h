//
//  FSCalendarHeader.h
//  Pods
//
//  Created by Wenchao Ding on 29/1/15.
//
//

#import <UIKit/UIKit.h>

@class FSCalendarHeader, FSCalendar;

@interface FSCalendarHeader : UIView

@property (assign, nonatomic) CGFloat                         minDissolveAlpha;
@property (assign, nonatomic) CGFloat                         scrollOffset;
@property (copy,   nonatomic) NSString                        *dateFormat;

@property (weak,   nonatomic) UIColor                         *titleColor;
@property (weak,   nonatomic) UIFont                          *titleFont;

@property (assign, nonatomic) UICollectionViewScrollDirection scrollDirection;

- (void)reloadData;

@end
