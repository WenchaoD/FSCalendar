//
//  FSCalendarCell.h
//  Pods
//
//  Created by Wenchao Ding on 12/3/15.
//
//

#import <UIKit/UIKit.h>
#import "FSCalendar.h"
#import "FSCalendarEventIndicator.h"

@interface FSCalendarCell : UICollectionViewCell

@property (weak, nonatomic) FSCalendar *calendar;
@property (weak, nonatomic) FSCalendarAppearance *appearance;

@property (weak, nonatomic) UILabel  *titleLabel;
@property (weak, nonatomic) UILabel  *subtitleLabel;
@property (weak, nonatomic) UIImageView *imageView;

@property (weak, nonatomic) CAShapeLayer *shapeLayer;
@property (weak, nonatomic) FSCalendarEventIndicator *eventIndicator;

@property (strong, nonatomic) NSDate   *date;
@property (strong, nonatomic) NSDate   *month;
@property (strong, nonatomic) NSString *title;
@property (strong, nonatomic) NSString *subtitle;
@property (strong, nonatomic) UIImage  *image;

@property (assign, nonatomic) BOOL needsAdjustingViewFrame;
@property (assign, nonatomic) NSInteger numberOfEvents;

@property (assign, nonatomic) BOOL dateIsPlaceholder;
@property (assign, nonatomic) BOOL dateIsSelected;
@property (assign, nonatomic) BOOL dateIsToday;

@property (readonly, nonatomic) BOOL weekend;

@property (strong, nonatomic) UIColor *preferredFillDefaultColor;
@property (strong, nonatomic) UIColor *preferredFillSelectionColor;
@property (strong, nonatomic) UIColor *preferredTitleDefaultColor;
@property (strong, nonatomic) UIColor *preferredTitleSelectionColor;
@property (strong, nonatomic) UIColor *preferredSubtitleDefaultColor;
@property (strong, nonatomic) UIColor *preferredSubtitleSelectionColor;
@property (strong, nonatomic) UIColor *preferredBorderDefaultColor;
@property (strong, nonatomic) UIColor *preferredBorderSelectionColor;
@property (assign, nonatomic) CGPoint preferredTitleOffset;
@property (assign, nonatomic) CGPoint preferredSubtitleOffset;
@property (assign, nonatomic) CGPoint preferredImageOffset;
@property (assign, nonatomic) CGPoint preferredEventOffset;

@property (strong, nonatomic) NSArray<UIColor *> *preferredEventDefaultColors;
@property (strong, nonatomic) NSArray<UIColor *> *preferredEventSelectionColors;
@property (assign, nonatomic) CGFloat preferredBorderRadius;
@property (assign, nonatomic) CGFloat preferredCellDiameter;

- (void)invalidateTitleFont;
- (void)invalidateSubtitleFont;
- (void)invalidateTitleTextColor;
- (void)invalidateSubtitleTextColor;

- (void)invalidateBorderColors;
- (void)invalidateFillColors;
- (void)invalidateEventColors;
- (void)invalidateBorderRadius;
- (void)invalidateCellDiameter;

- (void)invalidateImage;

- (UIColor *)colorForCurrentStateInDictionary:(NSDictionary *)dictionary;
- (void)performSelecting;

@end
