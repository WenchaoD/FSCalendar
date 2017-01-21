//
//  FSCalendarAnimationLayout.m
//  FSCalendar
//
//  Created by dingwenchao on 1/3/16.
//  Copyright © 2016 Wenchao Ding. All rights reserved.
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

@property (assign, nonatomic) CGFloat *widths;
@property (assign, nonatomic) CGFloat *heights;
@property (assign, nonatomic) CGFloat *lefts;
@property (assign, nonatomic) CGFloat *tops;

@property (assign, nonatomic) CGFloat *sectionHeights;
@property (assign, nonatomic) CGFloat *sectionTops;
@property (assign, nonatomic) CGFloat *sectionBottoms;
@property (assign, nonatomic) CGFloat *sectionRowCounts;

@property (assign, nonatomic) CGSize estimatedItemSize;

@property (assign, nonatomic) CGSize contentSize;
@property (assign, nonatomic) CGSize collectionViewSize;
@property (assign, nonatomic) NSInteger numberOfSections;

@property (assign, nonatomic) FSCalendarSeparators separators;

@property (strong, nonatomic) NSMutableDictionary<NSIndexPath *, UICollectionViewLayoutAttributes *> *itemAttributes;
@property (strong, nonatomic) NSMutableDictionary<NSIndexPath *, UICollectionViewLayoutAttributes *> *headerAttributes;
@property (strong, nonatomic) NSMutableDictionary<NSIndexPath *, UICollectionViewLayoutAttributes *> *rowSeparatorAttributes;

- (void)didReceiveNotifications:(NSNotification *)notification;

@end

@implementation FSCalendarCollectionViewLayout

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.estimatedItemSize = CGSizeZero;
        self.widths = NULL;
        self.heights = NULL;
        self.tops = NULL;
        self.lefts = NULL;
        
        self.sectionHeights = NULL;
        self.sectionTops = NULL;
        self.sectionBottoms = NULL;
        self.sectionRowCounts = NULL;
        
        self.scrollDirection = UICollectionViewScrollDirectionHorizontal;
        self.sectionInsets = UIEdgeInsetsMake(5, 0, 5, 0);
        
        self.itemAttributes = [NSMutableDictionary dictionary];
        self.headerAttributes = [NSMutableDictionary dictionary];
        self.rowSeparatorAttributes = [NSMutableDictionary dictionary];
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didReceiveNotifications:) name:UIDeviceOrientationDidChangeNotification object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didReceiveNotifications:) name:UIScreenDidConnectNotification object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didReceiveNotifications:) name:UIApplicationDidReceiveMemoryWarningNotification object:nil];
        
        [self registerClass:[FSCalendarSeparator class] forDecorationViewOfKind:kFSCalendarSeparatorInterRows];
    }
    return self;
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIApplicationDidReceiveMemoryWarningNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIDeviceOrientationDidChangeNotification object:nil];
    
    free(self.widths);
    free(self.heights);
    free(self.tops);
    free(self.lefts);
    
    free(self.sectionHeights);
    free(self.sectionTops);
    free(self.sectionRowCounts);
    free(self.sectionBottoms);
}

- (void)prepareLayout
{
    if (CGSizeEqualToSize(self.collectionViewSize, self.collectionView.frame.size) && self.numberOfSections == self.collectionView.numberOfSections && self.separators == self.calendar.appearance.separators) {
        return;
    }
    self.collectionViewSize = self.collectionView.frame.size;
    self.separators = self.calendar.appearance.separators;
    
    [self.itemAttributes removeAllObjects];
    [self.headerAttributes removeAllObjects];
    [self.rowSeparatorAttributes removeAllObjects];
    
    self.headerReferenceSize = ({
        CGSize headerSize = CGSizeZero;
        if (self.calendar.floatingMode) {
            CGFloat headerHeight = self.calendar.preferredWeekdayHeight*1.5+self.calendar.preferredHeaderHeight;
            headerSize = CGSizeMake(self.collectionView.fs_width, headerHeight);
        }
        headerSize;
    });
    self.estimatedItemSize = ({
        CGFloat width = (self.collectionView.fs_width-self.sectionInsets.left-self.sectionInsets.right)/7.0;
        CGFloat height = ({
            CGFloat height = FSCalendarStandardRowHeight;
            if (!self.calendar.floatingMode) {
                switch (self.calendar.transitionCoordinator.representingScope) {
                    case FSCalendarScopeMonth: {
                        height = (self.collectionView.fs_height-self.sectionInsets.top-self.sectionInsets.bottom)/6.0;
                        break;
                    }
                    case FSCalendarScopeWeek: {
                        height = (self.collectionView.fs_height-self.sectionInsets.top-self.sectionInsets.bottom);
                        break;
                    }
                    default:
                        break;
                }
            }
            height;
        });
        CGSize size = CGSizeMake(width, height);
        size;
    });
    
    // Calculate item widths and lefts
    free(self.widths);
    self.widths = ({
        NSInteger columnCount = 7;
        size_t columnSize = sizeof(CGFloat)*columnCount;
        CGFloat *widths = malloc(columnSize);
        CGFloat contentWidth = self.collectionView.fs_width - self.sectionInsets.left - self.sectionInsets.right;
        FSCalendarSliceCake(contentWidth, columnCount, widths);
        widths;
    });
    
    free(self.lefts);
    self.lefts = ({
        NSInteger columnCount = 7;
        size_t columnSize = sizeof(CGFloat)*columnCount;
        CGFloat *lefts = malloc(columnSize);
        lefts[0] = self.sectionInsets.left;
        for (int i = 1; i < columnCount; i++) {
            lefts[i] = lefts[i-1] + self.widths[i-1];
        }
        lefts;
    });
    
    // Calculate item heights and tops
    free(self.heights);
    self.heights = ({
        NSInteger rowCount = self.calendar.transitionCoordinator.representingScope == FSCalendarScopeWeek ? 1 : 6;
        size_t rowSize = sizeof(CGFloat)*rowCount;
        CGFloat *heights = malloc(rowSize);
        if (!self.calendar.floatingMode) {
            CGFloat contentHeight = self.collectionView.fs_height - self.sectionInsets.top - self.sectionInsets.bottom;
            FSCalendarSliceCake(contentHeight, rowCount, heights);
        } else {
            for (int i = 0; i < rowCount; i++) {
                heights[i] = self.estimatedItemSize.height;
            }
        }
        heights;
    });
    
    free(self.tops);
    self.tops = ({
        NSInteger rowCount = self.calendar.transitionCoordinator.representingScope == FSCalendarScopeWeek ? 1 : 6;
        size_t rowSize = sizeof(CGFloat)*rowCount;
        CGFloat *tops = malloc(rowSize);
        tops[0] = self.sectionInsets.top;
        for (int i = 1; i < rowCount; i++) {
            tops[i] = tops[i-1] + self.heights[i-1];
        }
        tops;
    });
    
    // Calculate content size
    self.numberOfSections = self.collectionView.numberOfSections;
    self.contentSize = ({
        CGSize contentSize = CGSizeZero;
        if (!self.calendar.floatingMode) {
            CGFloat width = self.collectionView.fs_width;
            CGFloat height = self.collectionView.fs_height;
            switch (self.scrollDirection) {
                case UICollectionViewScrollDirectionHorizontal: {
                    width *= self.numberOfSections;
                    break;
                }
                case UICollectionViewScrollDirectionVertical: {
                    height *= self.numberOfSections;
                    break;
                }
                default:
                    break;
            }
            contentSize = CGSizeMake(width, height);
        } else {
            free(self.sectionHeights);
            self.sectionHeights = malloc(sizeof(CGFloat)*self.numberOfSections);
            free(self.sectionRowCounts);
            self.sectionRowCounts = malloc(sizeof(NSInteger)*self.numberOfSections);
            CGFloat width = self.collectionView.fs_width;
            CGFloat height = 0;
            for (int i = 0; i < self.numberOfSections; i++) {
                NSInteger rowCount = [self.calendar.calculator numberOfRowsInSection:i];
                self.sectionRowCounts[i] = rowCount;
                CGFloat sectionHeight = self.headerReferenceSize.height;
                for (int j = 0; j < rowCount; j++) {
                    sectionHeight += self.heights[j];
                }
                self.sectionHeights[i] = sectionHeight;
                height += sectionHeight;
            }
            free(self.sectionTops);
            self.sectionTops = malloc(sizeof(CGFloat)*self.numberOfSections);
            free(self.sectionBottoms);
            self.sectionBottoms = malloc(sizeof(CGFloat)*self.numberOfSections);
            self.sectionTops[0] = 0;
            self.sectionBottoms[0] = self.sectionHeights[0];
            for (int i = 1; i < self.numberOfSections; i++) {
                self.sectionTops[i] = self.sectionTops[i-1] + self.sectionHeights[i-1];
                self.sectionBottoms[i] = self.sectionTops[i] + self.sectionHeights[i];
            }
            contentSize = CGSizeMake(width, height);
        }
        contentSize;
    });
    
    [self.calendar adjustMonthPosition];
}

- (CGSize)collectionViewContentSize
{
    return self.contentSize;
}

- (NSArray *)layoutAttributesForElementsInRect:(CGRect)rect
{
    // Clipping
    rect = CGRectIntersection(rect, CGRectMake(0, 0, self.contentSize.width, self.contentSize.height));
    if (CGRectIsEmpty(rect)) return nil;
    
    // Calculating attributes
    NSMutableArray<UICollectionViewLayoutAttributes *> *layoutAttributes = [NSMutableArray array];
    
    if (!self.calendar.floatingMode) {
        
        switch (self.scrollDirection) {
            case UICollectionViewScrollDirectionHorizontal: {
                
                NSInteger wholeSections = rect.size.width/self.collectionView.fs_width;
                NSInteger numberOfColumns = wholeSections*7;
                NSInteger numberOfRows = self.calendar.transitionCoordinator.representingScope == FSCalendarScopeMonth ? 6 : 1;
                
                NSInteger startSection = rect.origin.x/self.collectionView.fs_width;
                CGFloat widthDelta1 = FSCalendarMod(CGRectGetMinX(rect), self.collectionView.fs_width) - self.sectionInsets.left;
                widthDelta1 = MAX(0, widthDelta1);
                NSInteger columnCountDelta1 = FSCalendarFloor(widthDelta1/self.estimatedItemSize.width);
                numberOfColumns += (7-columnCountDelta1) % 7;
                NSInteger startColumn = startSection*7 + columnCountDelta1%7;
                
                CGFloat widthDelta2 = FSCalendarMod(CGRectGetMaxX(rect), self.collectionView.fs_width - self.sectionInsets.left);
                widthDelta2 = MAX(0, widthDelta2);
                
                NSInteger columnCountDelta2 = FSCalendarCeil(widthDelta2/self.estimatedItemSize.width);
                numberOfColumns += columnCountDelta2%7;
                
                NSInteger endColumn = startColumn + numberOfColumns - 1;
                
                for (NSInteger column = startColumn; column <= endColumn; column++) {
                    for (NSInteger row = 0; row < numberOfRows; row++) {
                        NSInteger section = column / 7;
                        NSInteger item = column % 7 + row * 7;
                        NSIndexPath *indexPath = [NSIndexPath indexPathForItem:item inSection:section];
                        UICollectionViewLayoutAttributes *itemAttributes = [self layoutAttributesForItemAtIndexPath:indexPath];
                        [layoutAttributes addObject:itemAttributes];
                        
                        UICollectionViewLayoutAttributes *rowSeparatorAttributes = [self layoutAttributesForDecorationViewOfKind:kFSCalendarSeparatorInterRows atIndexPath:indexPath];
                        if (rowSeparatorAttributes) {
                            [layoutAttributes addObject:rowSeparatorAttributes];
                        }
                    }
                }
                
                break;
            }
            case UICollectionViewScrollDirectionVertical: {
                
                NSInteger wholeSections = rect.size.height/self.collectionView.fs_height;
                NSInteger numberOfRows = wholeSections*6;
                
                NSInteger startSection = rect.origin.y/self.collectionView.fs_height;
                CGFloat heightDelta1 = FSCalendarMod(CGRectGetMinY(rect), self.collectionView.fs_height)-self.sectionInsets.top;
                heightDelta1 = MAX(0, heightDelta1);
                NSInteger rowCountDelta1 = FSCalendarFloor(heightDelta1/self.estimatedItemSize.height);
                numberOfRows += (6-rowCountDelta1) % 6;
                NSInteger startRow = startSection*6 + rowCountDelta1%6;
                
                CGFloat heightDelta2 = FSCalendarMod(CGRectGetMaxY(rect), self.collectionView.fs_height);
                heightDelta2 = MAX(0, heightDelta2-self.sectionInsets.bottom);
                
                NSInteger rowCountDelta2 = FSCalendarCeil(heightDelta2/self.estimatedItemSize.height);
                numberOfRows += rowCountDelta2;
                
                NSInteger endRow = startRow + numberOfRows - 1;
                
                for (NSInteger row = startRow; row <= endRow; row++) {
                    for (NSInteger column = 0; column < 7; column++) {
                        NSInteger section = row / 6;
                        NSInteger item = column + (row % 6) * 7;
                        NSIndexPath *indexPath = [NSIndexPath indexPathForItem:item inSection:section];
                        UICollectionViewLayoutAttributes *itemAttributes = [self layoutAttributesForItemAtIndexPath:indexPath];
                        [layoutAttributes addObject:itemAttributes];
                        
                        UICollectionViewLayoutAttributes *rowSeparatorAttributes = [self layoutAttributesForDecorationViewOfKind:kFSCalendarSeparatorInterRows atIndexPath:indexPath];
                        if (rowSeparatorAttributes) {
                            [layoutAttributes addObject:rowSeparatorAttributes];
                        }
                        
                    }
                }
                
                break;
            }
            default:
                break;
        }

    } else {
        
        NSInteger startSection = [self searchStartSection:rect :0 :self.numberOfSections-1];
        NSInteger startRowIndex = ({
            CGFloat heightDelta1 = MIN(self.sectionBottoms[startSection]-CGRectGetMinY(rect)-self.sectionInsets.bottom, self.sectionRowCounts[startSection]*self.estimatedItemSize.height);
            NSInteger startRowCount = FSCalendarCeil(heightDelta1/self.estimatedItemSize.height);
            NSInteger startRowIndex = self.sectionRowCounts[startSection]-startRowCount;
            startRowIndex;
        });
        
        NSInteger endSection = [self searchEndSection:rect :startSection :self.numberOfSections-1];
        NSInteger endRowIndex = ({
            CGFloat heightDelta2 = MAX(CGRectGetMaxY(rect) - self.sectionTops[endSection]- self.headerReferenceSize.height - self.sectionInsets.top, 0);
            NSInteger endRowCount = FSCalendarCeil(heightDelta2/self.estimatedItemSize.height);
            NSInteger endRowIndex = endRowCount - 1;
            endRowIndex;
        });
        for (NSInteger section = startSection; section <= endSection; section++) {
            NSInteger startRow = (section == startSection) ? startRowIndex : 0;
            NSInteger endRow = (section == endSection) ? endRowIndex : self.sectionRowCounts[section]-1;
            UICollectionViewLayoutAttributes *headerAttributes = [self layoutAttributesForSupplementaryViewOfKind:UICollectionElementKindSectionHeader atIndexPath:[NSIndexPath indexPathForItem:0 inSection:section]];
            [layoutAttributes addObject:headerAttributes];
            for (NSInteger row = startRow; row <= endRow; row++) {
                for (NSInteger column = 0; column < 7; column++) {
                    NSInteger item = row * 7 + column;
                    NSIndexPath *indexPath = [NSIndexPath indexPathForItem:item inSection:section];
                    UICollectionViewLayoutAttributes *itemAttributes = [self layoutAttributesForItemAtIndexPath:indexPath];
                    [layoutAttributes addObject:itemAttributes];
                    UICollectionViewLayoutAttributes *rowSeparatorAttributes = [self layoutAttributesForDecorationViewOfKind:kFSCalendarSeparatorInterRows atIndexPath:indexPath];
                    if (rowSeparatorAttributes) {
                        [layoutAttributes addObject:rowSeparatorAttributes];
                    }
                }
            }
        }
        
    }
    return [NSArray arrayWithArray:layoutAttributes];
    
}

// Items
- (UICollectionViewLayoutAttributes *)layoutAttributesForItemAtIndexPath:(NSIndexPath *)indexPath
{
    FSCalendarCoordinate coordinate = [self.calendar.calculator coordinateForIndexPath:indexPath];
    NSInteger column = coordinate.column;
    NSInteger row = coordinate.row;
    UICollectionViewLayoutAttributes *attributes = self.itemAttributes[indexPath];
    if (!attributes) {
        attributes = [UICollectionViewLayoutAttributes layoutAttributesForCellWithIndexPath:indexPath];
        CGRect frame = ({
            CGFloat x, y;
            switch (self.scrollDirection) {
                case UICollectionViewScrollDirectionHorizontal: {
                    x = self.lefts[column] + indexPath.section * self.collectionView.fs_width;
                    y = self.tops[row];
                    break;
                }
                case UICollectionViewScrollDirectionVertical: {
                    x = self.lefts[column];
                    if (!self.calendar.floatingMode) {
                        y = self.tops[row] + indexPath.section * self.collectionView.fs_height;
                    } else {
                        y = self.sectionTops[indexPath.section] + self.headerReferenceSize.height + self.tops[row];
                    }
                    break;
                }
                default:
                    break;
            }
            CGFloat width = self.widths[column];
            CGFloat height = self.heights[row];
            CGRect frame = CGRectMake(x, y, width, height);
            frame;
        });
        attributes.frame = frame;
        self.itemAttributes[indexPath] = attributes;
    }
    return attributes;
}

// Section headers
- (UICollectionViewLayoutAttributes *)layoutAttributesForSupplementaryViewOfKind:(NSString *)elementKind atIndexPath:(NSIndexPath *)indexPath
{
    if ([elementKind isEqualToString:UICollectionElementKindSectionHeader]) {
        UICollectionViewLayoutAttributes *attributes = self.headerAttributes[indexPath];
        if (!attributes) {
            attributes = [UICollectionViewLayoutAttributes layoutAttributesForSupplementaryViewOfKind:UICollectionElementKindSectionHeader withIndexPath:indexPath];
            attributes.frame = CGRectMake(0, self.sectionTops[indexPath.section], self.collectionView.fs_width, self.headerReferenceSize.height);
            self.headerAttributes[indexPath] = attributes;
        }
        return attributes;
    }
    return nil;
}

// Separators
- (UICollectionViewLayoutAttributes *)layoutAttributesForDecorationViewOfKind:(NSString *)elementKind atIndexPath:(NSIndexPath *)indexPath
{
    if ([elementKind isEqualToString:kFSCalendarSeparatorInterRows] && (self.separators & FSCalendarSeparatorInterRows)) {
        UICollectionViewLayoutAttributes *attributes = self.rowSeparatorAttributes[indexPath];
        if (!attributes) {
            FSCalendarCoordinate coordinate = [self.calendar.calculator coordinateForIndexPath:indexPath];
            if (coordinate.row >= [self.calendar.calculator numberOfRowsInSection:indexPath.section]-1) {
                return nil;
            }
            attributes = [UICollectionViewLayoutAttributes layoutAttributesForDecorationViewOfKind:kFSCalendarSeparatorInterRows withIndexPath:indexPath];
            CGFloat x, y;
            if (!self.calendar.floatingMode) {
                switch (self.scrollDirection) {
                    case UICollectionViewScrollDirectionHorizontal: {
                        x = self.lefts[coordinate.column] + indexPath.section * self.collectionView.fs_width;
                        y = self.tops[coordinate.row]+self.heights[coordinate.row];
                        break;
                    }
                    case UICollectionViewScrollDirectionVertical: {
                        x = 0;
                        y = self.tops[coordinate.row]+self.heights[coordinate.row] + indexPath.section * self.collectionView.fs_height;
                        break;
                    }
                    default:
                        break;
                }
            } else {
                x = 0;
                y = self.sectionTops[indexPath.section] + self.headerReferenceSize.height + self.tops[coordinate.row] + self.heights[coordinate.row];
            }
            CGFloat width = self.collectionView.fs_width;
            CGFloat height = FSCalendarStandardSeparatorThickness;
            attributes.frame = CGRectMake(x, y, width, height);
            attributes.zIndex = NSIntegerMax;
            self.rowSeparatorAttributes[indexPath] = attributes;
        }
        return attributes;
    }
    return nil;
}

#pragma mark - Notifications

- (void)didReceiveNotifications:(NSNotification *)notification
{
    if ([notification.name isEqualToString:UIDeviceOrientationDidChangeNotification]) {
        [self invalidateLayout];
    }
    if ([notification.name isEqualToString:UIApplicationDidReceiveMemoryWarningNotification]) {
        [self.itemAttributes removeAllObjects];
        [self.headerAttributes removeAllObjects];
        [self.rowSeparatorAttributes removeAllObjects];
    }
}

#pragma mark - Private properties

- (void)setScrollDirection:(UICollectionViewScrollDirection)scrollDirection
{
    if (_scrollDirection != scrollDirection) {
        _scrollDirection = scrollDirection;
        self.collectionViewSize = CGSizeAutomatic;
    }
}

#pragma mark - Private functions

- (NSInteger)searchStartSection:(CGRect)rect :(NSInteger)left :(NSInteger)right
{
    NSInteger mid = left + (right-left)/2;
    CGFloat y = rect.origin.y;
    CGFloat minY = self.sectionTops[mid];
    CGFloat maxY = self.sectionBottoms[mid];
    if (y >= minY && y < maxY) {
        return mid;
    } else if (y < minY) {
        return [self searchStartSection:rect :left :mid];
    } else {
        return [self searchStartSection:rect :mid+1 :right];
    }
}

- (NSInteger)searchEndSection:(CGRect)rect :(NSInteger)left :(NSInteger)right
{
    NSInteger mid = left + (right-left)/2;
    CGFloat y = CGRectGetMaxY(rect);
    CGFloat minY = self.sectionTops[mid];
    CGFloat maxY = self.sectionBottoms[mid];
    if (y > minY && y <= maxY) {
        return mid;
    } else if (y <= minY) {
        return [self searchEndSection:rect :left :mid];
    } else {
        return [self searchEndSection:rect :mid+1 :right];
    }
}

@end


#undef kFSCalendarSeparatorInterColumns
#undef kFSCalendarSeparatorInterRows


