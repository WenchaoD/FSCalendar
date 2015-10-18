//
//  RollViewController.h
//  FSCalendar
//
//  Created by dingwenchao on 10/16/15.
//  Copyright (c) 2015 wenchaoios. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FSCalendar.h"
#import "NSDate+FSExtension.h"

@interface RollViewController : UIViewController <FSCalendarDataSource,FSCalendarDelegate,FSCalendarDelegateAppearance>

@property (weak, nonatomic) FSCalendar *calendar;

@end
