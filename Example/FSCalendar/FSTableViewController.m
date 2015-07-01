//
//  FSTableViewController.m
//  FSCalendar
//
//  Created by DingWenchao on 6/25/15.
//  Copyright (c) 2015 =. All rights reserved.
//

#import "FSTableViewController.h"
#import "LoadViewExampleViewController.h"
#import "ViewDidLoadExampleViewController.h"

@implementation FSTableViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.navigationItem.backBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"" style:UIBarButtonItemStyleBordered target:nil action:nil];

}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.row == 0) {
        
        // Storyboard Example
        return;
        
    } else if (indexPath.row == 1) {
        
        // LoadView Example
        LoadViewExampleViewController *viewController = [[LoadViewExampleViewController alloc] init];
        viewController.title = @"FSCalendar";
        [self.navigationController pushViewController:viewController animated:YES];
        
    } else if (indexPath.row == 2) {
        
        // ViewDidLoad Example
        ViewDidLoadExampleViewController *viewController = [[ViewDidLoadExampleViewController alloc] init];
        viewController.title = @"FSCalendar";
        [self.navigationController pushViewController:viewController animated:YES
         ];
    }
}

@end
