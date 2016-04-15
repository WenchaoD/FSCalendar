//
//  ButtonsViewController.h
//  FSCalendar
//
//  Created by dingwenchao on 4/15/16.
//  Copyright © 2016 wenchaoios. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FSCalendar.h"

@interface ButtonsViewController : UIViewController <FSCalendarDataSource, FSCalendarDelegate>

@property (weak, nonatomic) FSCalendar *calendar;
@property (weak, nonatomic) UIButton *previousButton;
@property (weak, nonatomic) UIButton *nextButton;

- (void)previousClicked:(id)sender;
- (void)nextClicked:(id)sender;

@end
