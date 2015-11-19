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
#import "DelegateAppearanceViewController.h"
#import "CalendarIdentifierViewController.h"

@implementation FSTableViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.navigationItem.backBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"" style:UIBarButtonItemStylePlain target:nil action:nil];
    
    self.viewControllers = @[
                             [CalendarIdentifierViewController class],
                             [DelegateAppearanceViewController class],
                             [FullScreenExampleViewController class],
                             [MultipleSelectionViewController class],
                             [NSObject class],
                             [NSObject class],
                             [LoadViewExampleViewController class],
                             [ViewDidLoadExampleViewController class] // Deprecated
                            ];
    
    self.tableView.rowHeight = [[UIDevice currentDevice].model hasSuffix:@"iPad"] ? 60.0 : 44.0;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    id viewControllerClass = self.viewControllers[indexPath.row];
    if ([viewControllerClass isSubclassOfClass:[UIViewController class]]) {
        [self.navigationController pushViewController:[[viewControllerClass alloc] init] animated:YES];
    }
}

@end
