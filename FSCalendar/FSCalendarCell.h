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

@property (assign, nonatomic) BOOL dateIsPlaceholder;
@property (assign, nonatomic) BOOL dateIsSelected;
@property (assign, nonatomic) BOOL dateIsToday;

@property (readonly, nonatomic) BOOL weekend;

@property (strong, nonatomic) UIColor *preferedSelectionColor;
@property (strong, nonatomic) UIColor *preferedTitleDefaultColor;
@property (strong, nonatomic) UIColor *preferedTitleSelectionColor;
@property (strong, nonatomic) UIColor *preferedSubtitleDefaultColor;
@property (strong, nonatomic) UIColor *preferedSubtitleSelectionColor;
@property (strong, nonatomic) UIColor *preferedEventColor;
@property (strong, nonatomic) UIColor *preferedBorderDefaultColor;
@property (strong, nonatomic) UIColor *preferedBorderSelectionColor;
@property (assign, nonatomic) FSCalendarCellShape preferedCellShape;

- (UIColor *)colorForCurrentStateInDictionary:(NSDictionary *)dictionary;
- (void)performSelecting;

@end
