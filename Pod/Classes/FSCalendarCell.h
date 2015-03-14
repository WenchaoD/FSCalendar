//
//  FSCalendarCell.h
//  Pods
//
//  Created by Wenchao Ding on 12/3/15.
//
//

#import <UIKit/UIKit.h>
#import "FSCalendar.h"

@interface FSCalendarCell : UICollectionViewCell

@property (strong, nonatomic) UILabel *titleLabel;
@property (strong, nonatomic) UILabel *subtitleLabel;

@property (weak, nonatomic) NSDictionary *titleColors;
@property (weak, nonatomic) NSDictionary *subtitleColors;
@property (weak, nonatomic) NSDictionary *backgroundColors;

@property (copy, nonatomic) NSDate *date;
@property (copy, nonatomic) NSDate *month;
@property (weak, nonatomic) NSDate *currentDate;

@property (copy, nonatomic) NSString *subtitle;

@property (assign, nonatomic) FSCalendarCellStyle cellStyle;
@property (assign, nonatomic) BOOL hasEvent;

@property (nonatomic, readonly, getter = isPlaceholder) BOOL placeholder;
@property (nonatomic, readonly, getter = isToday) BOOL today;
@property (nonatomic, readonly, getter = isWeekend) BOOL weekend;

- (void)showAnimation;
- (void)hideAnimation;
- (void)configureCell;

@end
