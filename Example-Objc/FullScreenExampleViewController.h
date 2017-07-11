//
//  FullScreenExample.h
//  FSCalendar
//
//  Created by Wenchao Ding on 9/16/15.
//  Copyright (c) 2015 Wenchao Ding. All rights reserved.
//

#import <UIKit/UIKit.h>

@class FullScreenExampleViewController;

@protocol FullScreenExampleViewControllerDelegate <NSObject>

- (void)dateSelectController:(FullScreenExampleViewController *)controller didSelect: (NSArray *)dates;
@end

@interface FullScreenExampleViewController : UIViewController
// 提供给外面选中日期的接口
@property (nonatomic, weak) id<FullScreenExampleViewControllerDelegate> delegate;
// 记录已选中的日期
@property (nonatomic, strong) NSArray *datesSelected;
@end
