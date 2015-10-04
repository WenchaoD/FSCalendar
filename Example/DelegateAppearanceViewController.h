//
//  DelegateAppearanceViewController.h
//  FSCalendar
//
//  Created by Wenchao Ding on 10/2/15.
//  Copyright © 2015 wenchaoios. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FSCalendar.h"

@interface DelegateAppearanceViewController : UIViewController <FSCalendarDataSource,FSCalendarDelegate,FSCalendarDelegateAppearance>

@property (weak, nonatomic) FSCalendar *calendar;

@end
