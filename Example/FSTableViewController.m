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
#import "MultipleSelectionViewController.h"
#import "FullScreenExampleViewController.h"
#import "RollViewController.h"

@implementation FSTableViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.navigationItem.backBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"" style:UIBarButtonItemStyleBordered target:nil action:nil];
    
    self.viewControllers = @[
                             [RollViewController class],
                             [FullScreenExampleViewController class],
                             [MultipleSelectionViewController class],
                             [NSObject class],
                             [NSObject class],
                             [LoadViewExampleViewController class],
                             [ViewDidLoadExampleViewController class] // Deprecated
                            ];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    id viewControllerClass = self.viewControllers[indexPath.row];
    if ([viewControllerClass isSubclassOfClass:[UIViewController class]]) {
        [self.navigationController pushViewController:[[viewControllerClass alloc] init] animated:YES];
    }
}

@end
