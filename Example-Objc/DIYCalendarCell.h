//
//  DIYCalendarCell.h
//  FSCalendar
//
//  Created by dingwenchao on 02/11/2016.
//  Copyright © 2016 Wenchao Ding. All rights reserved.
//

#import <FSCalendar/FSCalendar.h>

typedef NS_ENUM(NSUInteger, SelectionType) {
    SelectionTypeNone,
    SelectionTypeSingle,
    SelectionTypeLeftBorder,
    SelectionTypeMiddle,
    SelectionTypeRightBorder
};


@interface DIYCalendarCell : FSCalendarCell

@property (weak, nonatomic) UIImageView *circleImageView;

@property (weak, nonatomic) CAShapeLayer *selectionLayer;

@property (assign, nonatomic) SelectionType selectionType;

@end
