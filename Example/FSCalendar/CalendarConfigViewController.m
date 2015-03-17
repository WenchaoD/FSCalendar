//
//  CalendarConfigViewController.m
//  FSCalendar
//
//  Created by Wenchao Ding on 2/15/15.
//  Copyright (c) 2015 =. All rights reserved.
//

#import "CalendarConfigViewController.h"
#import "FScalendar.h"

@implementation CalendarConfigViewController

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self.tableView.visibleCells setValue:@(UITableViewCellAccessoryNone) forKeyPath:@"accessoryType"];
    [[self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:self.viewController.theme inSection:0]] setAccessoryType:UITableViewCellAccessoryCheckmark];
    [[self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:1]] setAccessoryType:self.viewController.lunar?UITableViewCellAccessoryCheckmark:UITableViewCellAccessoryNone];
    [[self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:1 - self.viewController.flow inSection:2]] setAccessoryType:UITableViewCellAccessoryCheckmark];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    [[tableView visibleCells] enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        if ([tableView indexPathForCell:obj].section == indexPath.section) {
            [obj setAccessoryType:UITableViewCellAccessoryNone];
        }
    }];
    [[tableView cellForRowAtIndexPath:indexPath] setAccessoryType:UITableViewCellAccessoryCheckmark];
    if (indexPath.section == 0) {
        if (indexPath.row == self.viewController.theme) {
            return;
        }
        self.viewController.theme = indexPath.row;
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.05 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [self.navigationController popViewControllerAnimated:YES];
        });
    } else if (indexPath.section == 1) {
        self.viewController.lunar = !self.viewController.lunar;
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.05 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [self.navigationController popViewControllerAnimated:YES];
        });
    } else if (indexPath.section == 2) {
        self.viewController.flow = (FSCalendarFlow)(1-indexPath.row);
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.05 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [self.navigationController popViewControllerAnimated:YES];
        });
    } else if (indexPath.section == 3) {
        self.viewController.selectedDate = _datePicker.date;
        [[tableView cellForRowAtIndexPath:indexPath] setAccessoryType:UITableViewCellAccessoryNone];
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.05 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [self.navigationController popViewControllerAnimated:YES];
        });
    }
}

@end
