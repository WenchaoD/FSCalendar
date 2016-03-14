//
//  FSCalendarAnimationLayout.m
//  FSCalendar
//
//  Created by dingwenchao on 1/3/16.
//  Copyright © 2016 wenchaoios. All rights reserved.
//

#import "FSCalendarFlowLayout.h"
#import "FSCalendarDynamicHeader.h"
#import "FSCalendar.h"
#import "UIView+FSExtension.h"
#import <objc/runtime.h>

@implementation FSCalendarFlowLayout

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.scrollDirection = UICollectionViewScrollDirectionHorizontal;
        self.minimumInteritemSpacing = 0;
        self.minimumLineSpacing = 0;
        self.itemSize = CGSizeMake(1, 1);
        self.sectionInset = UIEdgeInsetsZero;
    }
    return self;
}

- (void)prepareLayout
{
    [super prepareLayout];
    
    
    CGFloat rowHeight = self.calendar.preferredRowHeight;
    
    if (!self.calendar.floatingMode) {
        
        self.headerReferenceSize = CGSizeZero;
        
        CGFloat padding = self.calendar.preferredWeekdayHeight*0.1;
        if (self.scrollDirection == UICollectionViewScrollDirectionHorizontal) {
            padding = FSCalendarFloor(padding);
            rowHeight = FSCalendarFloor(rowHeight*2)*0.5; // Round to nearest multiple of 0.5. e.g. (16.8->16.5),(16.2->16.0)
        }
        self.sectionInset = UIEdgeInsetsMake(padding, 0, padding, 0);
        switch (self.calendar.scope) {
                
            case FSCalendarScopeMonth: {
                
                CGSize itemSize = CGSizeMake(
                                             self.collectionView.fs_width/7.0-(self.scrollDirection == UICollectionViewScrollDirectionVertical)*0.1,
                                             rowHeight
                                             );
                self.itemSize = itemSize;
                
                break;
            }
            case FSCalendarScopeWeek: {
                
                CGSize itemSize = CGSizeMake(self.collectionView.fs_width/7.0, rowHeight);
                self.itemSize = itemSize;
                
                break;
                
            }
                
        }
    } else {
        
        CGFloat headerHeight = self.calendar.preferredWeekdayHeight*1.5+self.calendar.preferredHeaderHeight;
        self.headerReferenceSize = CGSizeMake(self.collectionView.fs_width, headerHeight);
        
        CGSize itemSize = CGSizeMake(
                                     self.collectionView.fs_width/7-(self.scrollDirection == UICollectionViewScrollDirectionVertical)*0.1,
                                     rowHeight
                                     );
        self.itemSize = itemSize;
        
        self.sectionInset = UIEdgeInsetsZero;
        
    }
    
}

@end
