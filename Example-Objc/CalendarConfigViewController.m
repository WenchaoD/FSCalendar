//
//  CalendarConfigViewController.m
//  FSCalendar
//
//  Created by Wenchao Ding on 2/15/15.
//  Copyright (c) 2015 Wenchao Ding. All rights reserved.
//

#import "CalendarConfigViewController.h"
#import "FScalendar.h"

@interface CalendarConfigViewController ()

@property (weak, nonatomic) IBOutlet UIDatePicker *datePicker;

@end

@implementation CalendarConfigViewController

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [super tableView:tableView cellForRowAtIndexPath:indexPath];
    switch (indexPath.section) {
        case 0: {
            cell.accessoryType = self.theme == indexPath.row ? UITableViewCellAccessoryCheckmark : UITableViewCellAccessoryNone;
            break;
        }
        case 1: {
            cell.accessoryType = self.lunar ? UITableViewCellAccessoryCheckmark : UITableViewCellAccessoryNone;
            break;
        }
        case 2: {
            cell.accessoryType = indexPath.row == 1 - self.scrollDirection ? UITableViewCellAccessoryCheckmark : UITableViewCellAccessoryNone;
            break;
        }
        case 4: {
            cell.accessoryType = indexPath.row == self.firstWeekday - 1 ? UITableViewCellAccessoryCheckmark : UITableViewCellAccessoryNone;
            break;
        }
        default:
            break;
    }
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    switch (indexPath.section) {
        case 0: {
            self.theme = indexPath.row;
            break;
        }
        case 1: {
            self.lunar = !self.lunar;
            break;
        }
        case 2: {
            self.scrollDirection = (FSCalendarScrollDirection)(1-indexPath.row);
            break;
        }
        case 3: {
            self.selectedDate = self.datePicker.date;
            break;
        }
        case 4: {
            self.firstWeekday = indexPath.row + 1;
            break;
        }
        default:
            break;
    }
    [tableView reloadSections:[NSIndexSet indexSetWithIndex:indexPath.section]  withRowAnimation:UITableViewRowAnimationAutomatic];
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.05 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self performSegueWithIdentifier:@"unwind2StoryboardExample" sender:self];
    });
}

@end
