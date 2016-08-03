//
//  FSTableViewController.m
//  FSCalendar
//
//  Created by DingWenchao on 6/25/15.
//  Copyright (c) 2015 =. All rights reserved.
//

#import "FSTableViewController.h"
#import "LoadViewExampleViewController.h"
#import "MultipleSelectionViewController.h"
#import "FullScreenExampleViewController.h"
#import "DelegateAppearanceViewController.h"
#import "CalendarIdentifierViewController.h"
#import "HidePlaceholderViewController.h"
#import "ButtonsViewController.h"
#import "ScopeHandleViewController.h"
#import "HDReservationManagerVC.h"

@implementation FSTableViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.navigationItem.backBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"" style:UIBarButtonItemStyleBordered target:nil action:nil];
    
    self.viewControllers = @[
                             [ScopeHandleViewController class],
                             [ButtonsViewController class],
                             [HidePlaceholderViewController class],
                             [CalendarIdentifierViewController class],
                             [DelegateAppearanceViewController class],
                             [FullScreenExampleViewController class],
                             [MultipleSelectionViewController class],
                             [NSObject class],
                             [NSObject class],
                             [LoadViewExampleViewController class]
                            ];
    
    self.tableView.rowHeight = [[UIDevice currentDevice].model hasSuffix:@"iPad"] ? 60.0 : 44.0;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    if (self.tableView.indexPathForSelectedRow) {
        [self.tableView deselectRowAtIndexPath:self.tableView.indexPathForSelectedRow animated:animated];
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.row==10) {
        [self.navigationController pushViewController:[[HDReservationManagerVC alloc] init] animated:YES];
    }else{
        id viewControllerClass = self.viewControllers[indexPath.row];
        if ([viewControllerClass isSubclassOfClass:[UIViewController class]]) {
            [self.navigationController pushViewController:[[viewControllerClass alloc] init] animated:YES];
        }
    }
   
}

@end
