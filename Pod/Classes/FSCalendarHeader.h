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

@property (assign, nonatomic) CGFloat minDissolveAlpha;
@property (copy,   nonatomic) NSString *dateFormat;

@property (strong, nonatomic) UIFont  *titleFont ;
@property (strong, nonatomic) UIColor *titleColor ;
@property (assign, nonatomic) CGFloat scrollOffset;

@property (assign, nonatomic) FSCalendar *calendar;

@end
