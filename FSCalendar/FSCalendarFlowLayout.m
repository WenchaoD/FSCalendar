//
//  FSCalendarFlowLayout.m
//  FSCalendar
//
//  Created by Wenchao Ding on 10/25/15.
//  Copyright (c) 2015 wenchaoios. All rights reserved.
//

#import "FSCalendarFlowLayout.h"
#import "UIView+FSExtension.h"
#import "FSCalendarDynamicHeader.h"

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

    CGFloat rowHeight = _calendar.preferedRowHeight;
    
    if (!_calendar.floatingMode) {
        
        self.headerReferenceSize = CGSizeZero;
        switch (_calendar.scope) {
            case FSCalendarScopeMonth: {
                self.itemSize = CGSizeMake(
                                           self.collectionView.fs_width/7-(self.scrollDirection == UICollectionViewScrollDirectionVertical)*0.1,
                                           rowHeight
                                          );
                CGFloat padding = (self.collectionView.fs_height-rowHeight*6)/2;
                self.sectionInset = UIEdgeInsetsMake(padding, 0, padding, 0);
                break;
            }
            case FSCalendarScopeWeek: {
                self.itemSize = CGSizeMake(self.collectionView.fs_width/7, rowHeight);
                CGFloat padding = (self.collectionView.fs_height-rowHeight)/2;
                self.sectionInset = UIEdgeInsetsMake(padding, 0, padding, 0);
                break;
            }
            default: {
                break;
            }
        }
        
    } else {
        
        CGFloat headerHeight = _calendar.preferedWeekdayHeight*1.5+_calendar.preferedHeaderHeight;
        self.headerReferenceSize = CGSizeMake(self.collectionView.fs_width, headerHeight);
        self.itemSize = CGSizeMake(
                                   self.collectionView.fs_width/7-(self.scrollDirection == UICollectionViewScrollDirectionVertical)*0.1,
                                   rowHeight
                                  );
        
    }
}

@end
