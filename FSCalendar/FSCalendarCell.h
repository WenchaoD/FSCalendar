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

@property (weak, nonatomic) FSCalendar *calendar;
@property (weak, nonatomic) FSCalendarAppearance *appearance;

@property (weak, nonatomic) UILabel  *titleLabel;
@property (weak, nonatomic) UILabel  *subtitleLabel;
@property (weak, nonatomic) UIImageView *imageView;

@property (weak, nonatomic) CAShapeLayer *backgroundLayer;
@property (weak, nonatomic) CAShapeLayer *eventLayer;

@property (strong, nonatomic) NSDate   *date;
@property (strong, nonatomic) NSString *subtitle;
@property (strong, nonatomic) UIImage  *image;

@property (assign, nonatomic) BOOL hasEvent;
@property (assign, nonatomic) BOOL deselecting;

@property (assign, nonatomic) BOOL dateIsPlaceholder;
@property (assign, nonatomic) BOOL dateIsSelected;
@property (assign, nonatomic) BOOL dateIsToday;

@property (readonly, nonatomic) BOOL weekend;

- (UIColor *)colorForCurrentStateInDictionary:(NSDictionary *)dictionary;

- (void)performSelecting;
- (void)performDeselecting;

@end
