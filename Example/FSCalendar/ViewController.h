//
//  FSViewController.h
//  Chinese-Lunar-Calendar
//
//  Created by Wenchao Ding on 01/29/2015.
//  Copyright (c) 2014 Wenchao Ding. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FSCalendar.h"

@interface ViewController : UIViewController<UIScrollViewDelegate, FSCalendarDataSource, FSCalendarDelegate>

@property (weak,   nonatomic) IBOutlet FSCalendar *calendar;

@property (assign, nonatomic) NSInteger      theme;
@property (assign, nonatomic) FSCalendarFlow flow;
@property (assign, nonatomic) BOOL           lunar;
@property (copy,   nonatomic) NSDate         *selectedDate;
@property (assign, nonatomic) NSUInteger     firstWeekday;

@end
