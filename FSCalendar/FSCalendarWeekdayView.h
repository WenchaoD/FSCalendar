//
//  FSCalendarWeekdayView.h
//  FSCalendar
//
//  Created by dingwenchao on 03/11/2016.
//  Copyright © 2016 wenchaoios. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@class FSCalendar;

@interface FSCalendarWeekdayView : UIView

@property (readonly, nonatomic) NSHashTable<UILabel *> *weekdayLabels;
@property (readonly, nonatomic) UIView *contentView;

@property (weak, nonatomic) FSCalendar *calendar;

- (void)invalidateWeekdaySymbols;

@end

NS_ASSUME_NONNULL_END
