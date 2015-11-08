//
//  LoadViewExampleViewController.h
//  FSCalendar
//
//  Created by DingWenchao on 6/25/15.
//  Copyright (c) 2015 =. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FSCalendar.h"

@interface LoadViewExampleViewController : UIViewController<FSCalendarDataSource, FSCalendarDelegate>

@property (weak, nonatomic) FSCalendar *calendar;

@property (strong, nonatomic) NSDictionary *images;

@end
