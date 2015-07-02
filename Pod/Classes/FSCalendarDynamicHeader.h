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
@property (readonly, nonatomic) NSArray *weekdays;

@end

@interface FSCalendarAppearance (Dynamic)

@property (readonly, nonatomic) NSMutableDictionary *backgroundColors;
@property (readonly, nonatomic) NSMutableDictionary *titleColors;
@property (readonly, nonatomic) NSMutableDictionary *subtitleColors;

- (void)adjustTitleIfNecessary;

@end



@interface FSCalendarHeader (Dynamic)

@property (readonly, nonatomic) UICollectionView *collectionView;

@end

