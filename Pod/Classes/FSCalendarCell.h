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

@property (weak,   nonatomic) FSCalendarAppearance *appearance;

@property (strong, nonatomic) NSDate   *date;
@property (strong, nonatomic) NSDate   *month;
@property (strong, nonatomic) NSString *subtitle;
@property (strong, nonatomic) UIImage  *image;

@property (weak,   nonatomic) UILabel  *titleLabel;
@property (weak,   nonatomic) UILabel  *subtitleLabel;

@property (assign, nonatomic) BOOL     hasEvent;

@property (readonly, getter = isPlaceholder) BOOL placeholder;

- (void)performSelecting;
- (void)performDeselecting;


@end
