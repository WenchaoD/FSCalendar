//
//  FSCalendarCell.h
//  Pods
//
//  Created by Wenchao Ding on 12/3/15.
//
//

#import <UIKit/UIKit.h>

@interface FSCalendarCell : UICollectionViewCell

@property (strong, nonatomic) UILabel *titleLabel;
@property (strong, nonatomic) UILabel *subtitleLabel;

@property (strong, nonatomic) NSDictionary *titleColors;
@property (strong, nonatomic) NSDictionary *subtitleColors;
@property (strong, nonatomic) NSDictionary *backgroundColors;

@property (copy, nonatomic) NSDate *date;
@property (copy, nonatomic) NSDate *month;

@property (assign, nonatomic) FSCalendarCellStyle *style;

@end
