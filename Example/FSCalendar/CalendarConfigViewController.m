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
    [[self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:1]] setAccessoryType:self.viewController.subtitle?UITableViewCellAccessoryCheckmark:UITableViewCellAccessoryNone];
    
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    [tableView.visibleCells setValue:@(UITableViewCellAccessoryNone) forKeyPath:@"accessoryType"];
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
        self.viewController.subtitle = !self.viewController.subtitle;
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.05 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [self.navigationController popViewControllerAnimated:YES];
        });
    }
}


@end
