//
//  FSCalendarStaticHeader.h
//  FSCalendar
//
//  Created by dingwenchao on 9/17/15.
//  Copyright (c) 2015 wenchaoios. All rights reserved.
//

#import <UIKit/UIKit.h>

@class FSCalendar,FSCalendarAppearance;

@interface FSCalendarStickyHeader : UICollectionReusableView

@property (weak, nonatomic) FSCalendar *calendar;
@property (weak, nonatomic) FSCalendarAppearance *appearance;

@property (weak, nonatomic) UILabel *titleLabel;

@property (strong, nonatomic) NSArray *weekdayLabels;
@property (strong, nonatomic) NSDate *month;

- (void)invalidateHeaderFont;
- (void)invalidateHeaderTextColor;
- (void)invalidateWeekdayFont;
- (void)invalidateWeekdayTextColor;

- (void)invalidateWeekdaySymbols;

@end