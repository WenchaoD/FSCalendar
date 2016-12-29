//
//  FSCalendarScopeExampleViewController.h
//  FSCalendar
//
//  Created by Wenchao Ding on 8/29/15.
//  Copyright (c) 2015 Wenchao Ding. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FSCalendar.h"

NS_ASSUME_NONNULL_BEGIN

@interface FSCalendarScopeExampleViewController : UIViewController <UITableViewDataSource, UITableViewDelegate, FSCalendarDataSource, FSCalendarDelegate, UIGestureRecognizerDelegate>

@property (weak, nonatomic) IBOutlet FSCalendar *calendar;
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet UISwitch *animationSwitch;

@property (strong, nonatomic) NSDateFormatter *dateFormatter;
@property (strong, nonatomic) UIPanGestureRecognizer *scopeGesture;

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *calendarHeightConstraint;

- (IBAction)toggleClicked:(id)sender;

@end


NS_ASSUME_NONNULL_END
