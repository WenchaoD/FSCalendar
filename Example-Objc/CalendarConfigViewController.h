//
//  CalendarConfigViewController.h
//  FSCalendar
//
//  Created by Wenchao Ding on 2/15/15.
//  Copyright (c) 2015 Wenchao Ding. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FSCalendar.h"

NS_ASSUME_NONNULL_BEGIN

@interface CalendarConfigViewController : UITableViewController

@property (assign, nonatomic) NSInteger      theme;
@property (assign, nonatomic) BOOL           lunar;
@property (assign, nonatomic) NSUInteger     firstWeekday;
@property (assign, nonatomic) FSCalendarScrollDirection scrollDirection;
@property (strong, nonatomic) NSDate         *selectedDate;

@end

NS_ASSUME_NONNULL_END
