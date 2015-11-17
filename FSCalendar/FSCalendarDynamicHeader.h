//
//  FSCalendarDynamicHeader.h
//  Pods
//
//  Created by DingWenchao on 6/29/15.
//
//  动感头文件，仅供框架内部使用。
//  Private header, don't use it.
//

#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>

#import "FSCalendar.h"
#import "FSCalendarCell.h"
#import "FSCalendarHeader.h"


@interface FSCalendar (Dynamic)

@property (readonly, nonatomic) FSCalendarHeader *header;
@property (readonly, nonatomic) UICollectionView *collectionView;
@property (readonly, nonatomic) UICollectionViewFlowLayout *collectionViewLayout;
@property (readonly, nonatomic) NSArray *weekdays;
@property (readonly, nonatomic) BOOL ibEditing;
@property (readonly, nonatomic) BOOL floatingMode;
@property (readonly, nonatomic) NSArray *visibleStickyHeaders;
@property (readonly, nonatomic) CGFloat preferedHeaderHeight;
@property (readonly, nonatomic) CGFloat preferedWeekdayHeight;
@property (readonly, nonatomic) CGFloat preferedRowHeight;

@property (readonly, nonatomic) NSCalendar *calendar;
@property (readonly, nonatomic) NSDateComponents *components;
@property (readonly, nonatomic) NSDateFormatter *formatter;

- (void)invalidateHeaders;
- (void)invalidateWeekdaySymbols;
- (void)invalidateAppearanceForCell:(FSCalendarCell *)cell;

@end

@interface FSCalendarAppearance (Dynamic)

@property (readwrite, nonatomic) FSCalendar *calendar;

@property (readonly, nonatomic) NSDictionary *backgroundColors;
@property (readonly, nonatomic) NSDictionary *titleColors;
@property (readonly, nonatomic) NSDictionary *subtitleColors;
@property (readonly, nonatomic) NSDictionary *borderColors;

- (void)adjustTitleIfNecessary;

@end


@interface FSCalendarHeader (Dynamic)

@property (readonly, nonatomic) UICollectionView *collectionView;

@end

