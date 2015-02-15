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

@property (weak, nonatomic) IBOutlet FSCalendar *calendar;

- (IBAction)changeFlowClicked:(id)sender;

@end
