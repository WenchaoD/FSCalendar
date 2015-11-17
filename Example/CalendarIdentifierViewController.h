//
//  CalendarIdentifierViewController.h
//  FSCalendar
//
//  Created by dingwenchao on 11/16/15.
//  Copyright © 2015 wenchaoios. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FSCalendar.h"

@interface CalendarIdentifierViewController : UIViewController <FSCalendarDataSource,FSCalendarDelegate,UIPickerViewDataSource,UIPickerViewDelegate>

@property (weak, nonatomic) FSCalendar *calendar;
@property (weak, nonatomic) UIPickerView *pickerView;

@property (strong, nonatomic) NSArray *identifiers;

- (void)todayItemClicked:(id)sender;

@end
