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
    
    CGFloat padding = _calendar.preferedWeekdayHeight*0.1;
    self.sectionInset = UIEdgeInsetsMake(padding, 0, padding, 0);
    if (_calendar.pagingEnabled) {
        
        self.headerReferenceSize = CGSizeZero;
        switch (_calendar.scope) {
            case FSCalendarScopeMonth: {
                self.itemSize = CGSizeMake(
                                           self.collectionView.fs_width/7-(self.scrollDirection == UICollectionViewScrollDirectionVertical)*0.1,
                                           _calendar.preferedRowHeight
                                          );
                break;
            }
            case FSCalendarScopeWeek: {
                self.itemSize = CGSizeMake(self.collectionView.fs_width/7, _calendar.preferedRowHeight);
                break;
            }
            default: {
                break;
            }
        }
        
    } else {
        
        self.headerReferenceSize = CGSizeMake(self.collectionView.fs_width, _calendar.preferedHeaderHeight+10+_calendar.preferedWeekdayHeight);
        self.itemSize = CGSizeMake(
                                   self.collectionView.fs_width/7-(self.scrollDirection == UICollectionViewScrollDirectionVertical)*0.1,
                                   _calendar.preferedRowHeight
                                  );
        
    }
}

@end
