//
//  FSCalendarCollectionView.h
//  FSCalendar
//
//  Created by Wenchao Ding on 10/25/15.
//  Copyright (c) 2015 Wenchao Ding. All rights reserved.
//

#import <UIKit/UIKit.h>
@class FSCalendarCollectionView;

@protocol FSCalendarCollectionViewDataSource <UICollectionViewDataSource>

@end

@protocol FSCalendarCollectionViewDelegate <UICollectionViewDelegate>

@optional
- (void)collectionViewDidFinishLayoutSubviews:(FSCalendarCollectionView *)collectionView;

@end

@interface FSCalendarCollectionView : UICollectionView

@property (assign, nonatomic) id<FSCalendarCollectionViewDataSource> dataSource;
@property (assign, nonatomic) id<FSCalendarCollectionViewDelegate> delegate;

@end
