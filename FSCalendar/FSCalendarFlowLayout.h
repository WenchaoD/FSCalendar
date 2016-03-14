//
//  FSCalendarAnimationLayout.h
//  FSCalendar
//
//  Created by dingwenchao on 1/3/16.
//  Copyright © 2016 wenchaoios. All rights reserved.
//

#import <UIKit/UIKit.h>

@class FSCalendar;

typedef NS_ENUM(NSUInteger, FSCalendarScope);

@interface FSCalendarFlowLayout : UICollectionViewFlowLayout <UICollectionViewDelegateFlowLayout>

@property (weak, nonatomic) FSCalendar *calendar;


@end
