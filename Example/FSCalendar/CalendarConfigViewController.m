//
//  CalendarConfigViewController.m
//  FSCalendar
//
//  Created by Wenchao Ding on 2/15/15.
//  Copyright (c) 2015 =. All rights reserved.
//

#import "CalendarConfigViewController.h"
#import "FScalendar.h"

static int theme = 0;

@implementation CalendarConfigViewController

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self tableView:self.tableView didSelectRowAtIndexPath:[NSIndexPath indexPathForRow:theme inSection:0]];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    [tableView.visibleCells setValue:@(UITableViewCellAccessoryNone) forKeyPath:@"accessoryType"];
    [[tableView cellForRowAtIndexPath:indexPath] setAccessoryType:UITableViewCellAccessoryCheckmark];
    if (indexPath.row == theme) {
        return;
    }
    theme = indexPath.row;
    
    if (!self.isMovingToParentViewController && !self.isBeingPresented) {
        switch (indexPath.row) {
            case 0:
            {
                [[FSCalendar appearance] setWeekdayTextColor:[UIColor colorWithRed:0.0 green:122.0/255.0 blue:1.0 alpha:1.0]];
                [[FSCalendar appearance] setHeaderTitleColor:[UIColor colorWithRed:0.0 green:122.0/255.0 blue:1.0 alpha:1.0]];
                [[FSCalendar appearance] setEventColor:[UIColor cyanColor]];
                [[FSCalendar appearance] setSelectionColor:[UIColor blackColor]];
                [[FSCalendar appearance] setHeaderDateFormat:@"yyyy-M"];
                [[FSCalendar appearance] setMinDissolvedAlpha:0.2];
                [[FSCalendar appearance] setTodayColor:[UIColor orangeColor]];
                [[FSCalendar appearance] setUnitStyle:FSCalendarUnitStyleCircle];
                [[FSCalendar appearance] setWeekdayTextColor:[UIColor colorWithRed:0.0 green:122.0/255.0 blue:1.0 alpha:1.0]];
                break;
            }
            case 1:
            {
                [[FSCalendar appearance] setWeekdayTextColor:[UIColor redColor]];
                [[FSCalendar appearance] setHeaderTitleColor:[UIColor darkGrayColor]];
                [[FSCalendar appearance] setEventColor:[UIColor greenColor]];
                [[FSCalendar appearance] setSelectionColor:[UIColor blueColor]];
                [[FSCalendar appearance] setHeaderDateFormat:@"yyyy-MM"];
                [[FSCalendar appearance] setMinDissolvedAlpha:0.5];
                [[FSCalendar appearance] setTodayColor:[UIColor redColor]];
                [[FSCalendar appearance] setUnitStyle:FSCalendarUnitStyleCircle];
                [[FSCalendar appearance] setWeekdayTextColor:[UIColor darkTextColor]];
                break;
            }
            case 2:
            {
                [[FSCalendar appearance] setWeekdayTextColor:[UIColor redColor]];
                [[FSCalendar appearance] setHeaderTitleColor:[UIColor redColor]];
                [[FSCalendar appearance] setEventColor:[UIColor greenColor]];
                [[FSCalendar appearance] setSelectionColor:[UIColor blueColor]];
                [[FSCalendar appearance] setHeaderDateFormat:@"yyyy/MM"];
                [[FSCalendar appearance] setMinDissolvedAlpha:1.0];
                [[FSCalendar appearance] setUnitStyle:FSCalendarUnitStyleRectangle];
                [[FSCalendar appearance] setTodayColor:[UIColor orangeColor]];
                [[FSCalendar appearance] setWeekdayTextColor:[UIColor redColor]];
                break;
            }
            default:
                break;
        }
        
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.05 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [self.navigationController popViewControllerAnimated:YES];
        });
    }
}


@end
