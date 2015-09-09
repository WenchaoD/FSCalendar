//
//  MultipleSelectionViewController.h
//  FSCalendar
//
//  Created by dingwenchao on 9/9/15.
//  Copyright (c) 2015 wenchaoios. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FSCalendar.h"
#import "NSDate+FSExtension.h"

@interface MultipleSelectionViewController : UIViewController <FSCalendarDataSource,FSCalendarDelegate>

@property (weak, nonatomic) FSCalendar *calendar;

@end
