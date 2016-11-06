//
//  FSViewController.h
//  Chinese-Lunar-Calendar
//
//  Created by Wenchao Ding on 01/29/2015.
//  Copyright (c) 2014 Wenchao Ding. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FSCalendar.h"

@interface StoryboardExampleViewController : UIViewController<FSCalendarDataSource, FSCalendarDelegate, FSCalendarDelegateAppearance>

@property (weak  , nonatomic) IBOutlet FSCalendar *calendar;
@property (weak  , nonatomic) IBOutlet NSLayoutConstraint *calendarHeightConstraint;

@property (assign, nonatomic) NSInteger      theme;
@property (assign, nonatomic) FSCalendarScrollDirection scrollDirection;
@property (assign, nonatomic) BOOL           lunar;
@property (strong, nonatomic) NSDate         *selectedDate;
@property (assign, nonatomic) NSUInteger     firstWeekday;

@property (strong, nonatomic) NSArray *datesShouldNotBeSelected;
@property (strong, nonatomic) NSArray *datesWithEvent;

@end
