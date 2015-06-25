//
//  CalendarConfigViewController.h
//  FSCalendar
//
//  Created by Wenchao Ding on 2/15/15.
//  Copyright (c) 2015 =. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "StoryboardExampleViewController.h"

@interface CalendarConfigViewController : UITableViewController

@property (weak, nonatomic) StoryboardExampleViewController *viewController;

@property (weak, nonatomic) IBOutlet UIDatePicker *datePicker;

@end
