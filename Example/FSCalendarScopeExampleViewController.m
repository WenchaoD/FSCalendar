//
//  FSCalendarScopeExampleViewController.m
//  FSCalendar
//
//  Created by Wenchao Ding on 8/29/15.
//  Copyright (c) 2015 wenchaoios. All rights reserved.
//

#import "FSCalendarScopeExampleViewController.h"

@implementation FSCalendarScopeExampleViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    [_calendar selectDate:[NSDate date]];
}

- (void)calendar:(FSCalendar *)calendar boundingRectWillChange:(CGRect)bounds animated:(BOOL)animated
{
    _calendarHeightConstraint.constant = CGRectGetHeight(bounds);
    [self.view layoutIfNeeded];
}

- (void)calendar:(FSCalendar *)calendar didSelectDate:(NSDate *)date
{
    NSLog(@"did select date %@",[calendar stringFromDate:date format:@"yyyy/MM/dd"]);
    
    NSMutableArray *selectedDates = [NSMutableArray arrayWithCapacity:calendar.selectedDates.count];
    [calendar.selectedDates enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        [selectedDates addObject:[calendar stringFromDate:date format:@"yyyy/MM/dd"]];
    }];
    NSLog(@"selected dates is %@",selectedDates);
    
}

#pragma mark - <UITableViewDataSource>

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 2;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    FSCalendarScope scopeForIndexPath = indexPath.row == 0 ? FSCalendarScopeMonth : FSCalendarScopeWeek;
    NSString *identifier = @[@"cell_month",@"cell_week"][indexPath.row];
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
    cell.accessoryType = _calendar.scope == scopeForIndexPath ? UITableViewCellAccessoryCheckmark : UITableViewCellAccessoryNone;
    return cell;
}

#pragma mark - <UITableViewDelegate>

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    [tableView.visibleCells setValue:@(UITableViewCellAccessoryNone) forKey:@"accessoryType"];
    [tableView cellForRowAtIndexPath:indexPath].accessoryType = UITableViewCellAccessoryCheckmark;
    
    FSCalendarScope selectedScope = indexPath.row == 0 ? FSCalendarScopeMonth : FSCalendarScopeWeek;
    [_calendar setScope:selectedScope animated:_animationSwitch.on];
    
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 20;
}

- (IBAction)toggleClicked:(id)sender
{
    if (self.calendar.scope == FSCalendarScopeMonth) {
        [self.calendar setScope:FSCalendarScopeWeek animated:_animationSwitch.on];
    } else {
        [self.calendar setScope:FSCalendarScopeMonth animated:_animationSwitch.on];
    }
}

@end
