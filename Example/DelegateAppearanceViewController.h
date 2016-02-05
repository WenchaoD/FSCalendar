//
//  RollViewController.h
//  FSCalendar
//
//  Created by dingwenchao on 10/16/15.
//  Copyright (c) 2015 wenchaoios. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FSCalendar.h"

@interface DelegateAppearanceViewController : UIViewController <FSCalendarDataSource,FSCalendarDelegate,FSCalendarDelegateAppearance>

@property (weak, nonatomic) FSCalendar *calendar;

@property (strong, nonatomic) NSDictionary *selectionColors;
@property (strong, nonatomic) NSDictionary *borderDefaultColors;
@property (strong, nonatomic) NSDictionary *borderSelectionColors;

@property (strong, nonatomic) NSArray *datesWithEvent;
@property (strong, nonatomic) NSArray *datesWithMultipleEvents;

@end
