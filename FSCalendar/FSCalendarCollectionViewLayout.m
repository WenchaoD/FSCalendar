//
//  FSCalendarAnimationLayout.m
//  FSCalendar
//
//  Created by dingwenchao on 1/3/16.
//  Copyright © 2016 wenchaoios. All rights reserved.
//

#import "FSCalendarCollectionViewLayout.h"
#import "FSCalendar.h"
#import "FSCalendarDynamicHeader.h"
#import "FSCalendarCollectionView.h"
#import "FSCalendarExtensions.h"
#import "FSCalendarConstants.h"

#define kFSCalendarSeparatorInterRows @"FSCalendarSeparatorInterRows"
#define kFSCalendarSeparatorInterColumns @"FSCalendarSeparatorInterColumns"

@interface FSCalendarCollectionViewLayout ()

@end

@implementation FSCalendarCollectionViewLayout

- (instancetype)init
{
    self = [super init];
    if (self) {
        
        self.scrollDirection = UICollectionViewScrollDirectionHorizontal;
        self.minimumInteritemSpacing = 0;
        self.minimumLineSpacing = 0;
        self.itemSize = CGSizeMake(1, 1);
        self.sectionInset = UIEdgeInsetsZero;
        
        [self registerClass:[FSCalendarSeparator class] forDecorationViewOfKind:kFSCalendarSeparatorInterRows];
        
    }
    return self;
}

- (void)prepareLayout
{
    [super prepareLayout];
    
    CGFloat rowHeight = self.calendar.preferredRowHeight;
    
    if (!self.calendar.floatingMode) {
        
        self.headerReferenceSize = CGSizeZero;
        
        CGFloat padding = self.calendar.preferredPadding;
        if (self.scrollDirection == UICollectionViewScrollDirectionHorizontal) {
            padding = FSCalendarFloor(padding);
            rowHeight = FSCalendarFloor(rowHeight*2)*0.5-1; // Round to nearest multiple of 0.5. e.g. (16.8->16.5),(16.2->16.0)
        }
        self.sectionInset = UIEdgeInsetsMake(padding, 0, padding, 0);
        switch (self.calendar.scope) {
                
            case FSCalendarScopeMonth: {
                
                CGFloat columnWidth = self.collectionView.fs_width/7.0-(self.scrollDirection == UICollectionViewScrollDirectionVertical)*0.1;
                CGSize itemSize = CGSizeMake(columnWidth,rowHeight);
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
        
        CGFloat columnWidth = self.collectionView.fs_width/7.0-(self.scrollDirection == UICollectionViewScrollDirectionVertical)*0.1;
        
        CGSize itemSize = CGSizeMake(columnWidth,rowHeight);
        self.itemSize = itemSize;
        
        self.sectionInset = UIEdgeInsetsZero;
        
    }
    
}

- (NSArray *)layoutAttributesForElementsInRect:(CGRect)rect
{
    NSArray<UICollectionViewLayoutAttributes *> *attributesArray = [super layoutAttributesForElementsInRect:rect];
    
    // Clean on week mode
    if (self.calendar.scope == FSCalendarScopeWeek) {
        return attributesArray;
    }
    
    if ((self.calendar.appearance.separators & FSCalendarSeparatorInterRows) != 0) {
        
        // Get row leadings
        NSArray<UICollectionViewLayoutAttributes *> *visibleRows = [attributesArray filteredArrayUsingPredicate:[NSPredicate predicateWithBlock:^BOOL(UICollectionViewLayoutAttributes * _Nullable evaluatedObject, NSDictionary<NSString *,id> * _Nullable bindings) {
            
            if (evaluatedObject.representedElementCategory != UICollectionElementCategoryCell) {
                return NO;
            }
            
            NSInteger numberOfRows = [self.calendar.calculator numberOfRowsInSection:evaluatedObject.indexPath.section];
            
            switch (self.scrollDirection) {
                case UICollectionViewScrollDirectionHorizontal: {
                    return evaluatedObject.indexPath.item < numberOfRows-1;
                }
                case UICollectionViewScrollDirectionVertical: {
                    BOOL isValid = evaluatedObject.indexPath.item == 0;
                    isValid |= (evaluatedObject.indexPath.item%7==0 && evaluatedObject.indexPath.item/7<numberOfRows-1);
                    return isValid;
                }
            }
            return NO;
        }]];
        
        
        NSMutableArray *decorationAttributes = [NSMutableArray array];
        for (UICollectionViewLayoutAttributes *attibutes in visibleRows) {
            UICollectionViewLayoutAttributes *layoutAttributes = [UICollectionViewLayoutAttributes layoutAttributesForDecorationViewOfKind:kFSCalendarSeparatorInterRows withIndexPath:attibutes.indexPath];
            CGFloat decorationOffset = CGRectGetMaxY(attibutes.frame);
            CGFloat extraOffset = (self.scrollDirection == UICollectionViewScrollDirectionHorizontal ? 0.5 : -0.5) * FSCalendarStandardSeparatorThickness;
            layoutAttributes.frame = CGRectMake(CGRectGetMinX(attibutes.frame), decorationOffset+extraOffset, self.self.collectionView.fs_width, FSCalendarStandardSeparatorThickness);
            layoutAttributes.zIndex = NSIntegerMax;
            [decorationAttributes addObject:layoutAttributes];
        }
        return [attributesArray arrayByAddingObjectsFromArray:decorationAttributes];
    }
    
    return attributesArray;
    
}

@end


#undef kFSCalendarSeparatorInterColumns
#undef kFSCalendarSeparatorInterRows


