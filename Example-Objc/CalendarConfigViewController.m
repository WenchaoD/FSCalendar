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

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [super tableView:tableView cellForRowAtIndexPath:indexPath];
    if (indexPath.section == 0) {
        cell.accessoryType = self.viewController.theme == indexPath.row ? UITableViewCellAccessoryCheckmark : UITableViewCellAccessoryNone;
    } else if (indexPath.section == 1) {
        cell.accessoryType = self.viewController.lunar ? UITableViewCellAccessoryCheckmark : UITableViewCellAccessoryNone;
    } else if (indexPath.section == 2) {
        cell.accessoryType = indexPath.row == 1 - self.viewController.scrollDirection ? UITableViewCellAccessoryCheckmark : UITableViewCellAccessoryNone;
    } else if (indexPath.section == 4) {
        cell.accessoryType = indexPath.row == self.viewController.firstWeekday - 1 ? UITableViewCellAccessoryCheckmark : UITableViewCellAccessoryNone;
    }
    return cell;
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
    } else if (indexPath.section == 1) {
        self.viewController.lunar = !self.viewController.lunar;
    } else if (indexPath.section == 2) {
        if (self.viewController.scrollDirection == 1 - indexPath.row) {
            return;
        }
        self.viewController.scrollDirection = (FSCalendarScrollDirection)(1-indexPath.row);
    } else if (indexPath.section == 3) {
        self.viewController.selectedDate = _datePicker.date;
        [[tableView cellForRowAtIndexPath:indexPath] setAccessoryType:UITableViewCellAccessoryNone];
    } else if (indexPath.section == 4) {
        if (self.viewController.firstWeekday == indexPath.row + 1) {
            return;
        }
        self.viewController.firstWeekday = indexPath.row + 1;
    }
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.05 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self.navigationController popViewControllerAnimated:YES];
    });
}

@end
