//
//  ViewDidLoadExampleViewController.h
//  FSCalendar
//
//  Created by DingWenchao on 6/25/15.
//  Copyright (c) 2015 =. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FSCalendar.h"

@interface ViewDidLoadExampleViewController : UIViewController <FSCalendarDataSource, FSCalendarDelegate>

@property (weak, nonatomic) FSCalendar *calendar;

@end
