//
//  ScopeHandleViewController.h
//  FSCalendar
//
//  Created by dingwenchao on 5/8/16.
//  Copyright © 2016 wenchaoios. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FSCalendar.h"

@interface ScopeHandleViewController : UIViewController <FSCalendarDataSource,FSCalendarDelegate>

@property (weak, nonatomic) FSCalendar *calendar;

@end
