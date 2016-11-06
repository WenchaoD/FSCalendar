//
//  ScopeHandleViewController.m
//  FSCalendar
//
//  Created by dingwenchao on 5/8/16.
//  Copyright © 2016 wenchaoios. All rights reserved.
//

#import "DIVExampleViewController.h"
#import "DIVCalendarCell.h"
#import "FSCalendarExtensions.h"

typedef NS_ENUM(NSUInteger, SelectionType) {
    SelectionTypeNone,
    SelectionTypeSingle,
    SelectionTypeLeftBorder,
    SelectionTypeMiddle,
    SelectionTypeRightBorder
};


@interface DIVExampleViewController () <FSCalendarDataSource,FSCalendarDelegate,FSCalendarDelegateAppearance>

@property (weak, nonatomic) FSCalendar *calendar;

@property (weak, nonatomic) UILabel *eventLabel;

@property (strong, nonatomic) NSCalendar *gregorian;
@property (strong, nonatomic) NSDateFormatter *dateFormatter;

@end

@implementation DIVExampleViewController

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.title = @"FSCalendar";
    }
    return self;
}

- (void)loadView
{
    UIView *view = [[UIView alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    view.backgroundColor = [UIColor groupTableViewBackgroundColor];
    self.view = view;
    
    CGFloat height = [[UIDevice currentDevice].model hasPrefix:@"iPad"] ? 450 : 300;
    FSCalendar *calendar = [[FSCalendar alloc] initWithFrame:CGRectMake(0,  CGRectGetMaxY(self.navigationController.navigationBar.frame), view.frame.size.width, height)];
    calendar.dataSource = self;
    calendar.delegate = self;
    calendar.scopeGesture.enabled = YES;
    calendar.allowsMultipleSelection = YES;
//    calendar.backgroundColor = [UIColor whiteColor];
    [view addSubview:calendar];
    self.calendar = calendar;
    
    calendar.calendarHeaderView.backgroundColor = [[UIColor lightGrayColor] colorWithAlphaComponent:0.1];
    calendar.calendarWeekdayView.backgroundColor = [[UIColor lightGrayColor] colorWithAlphaComponent:0.1];
    calendar.appearance.eventSelectionColor = [UIColor whiteColor];
    calendar.appearance.eventOffset = CGPointMake(0, -7);
    calendar.today = nil; // Hide the today circle
    [calendar registerClass:[DIVCalendarCell class] forCellReuseIdentifier:@"cell"];
    
    
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0, CGRectGetMaxY(calendar.frame)+10, self.view.frame.size.width, 50)];
    label.textAlignment = NSTextAlignmentCenter;
    label.font = [UIFont preferredFontForTextStyle:UIFontTextStyleSubheadline];
    [self.view addSubview:label];
    self.eventLabel = label;
    
    NSMutableAttributedString *attributedText = [[NSMutableAttributedString alloc] initWithString:@""];
    NSTextAttachment *attatchment = [[NSTextAttachment alloc] init];
    attatchment.image = [UIImage imageNamed:@"icon_cat"];
    attatchment.bounds = CGRectMake(0, -3, attatchment.image.size.width, attatchment.image.size.height);
    [attributedText appendAttributedString:[NSAttributedString attributedStringWithAttachment:attatchment]];
    [attributedText appendAttributedString:[[NSAttributedString alloc] initWithString:@"  Hey Daily Event  "]];
    [attributedText appendAttributedString:[NSAttributedString attributedStringWithAttachment:attatchment]];
    self.eventLabel.attributedText = attributedText.copy;
    
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.gregorian = [NSCalendar calendarWithIdentifier:NSCalendarIdentifierGregorian];
    self.dateFormatter = [[NSDateFormatter alloc] init];
    self.dateFormatter.dateFormat = @"yyyy-MM-dd";
    
//    [self.calendar selectDate:[self.gregorian dateByAddingUnit:NSCalendarUnitDay value:1 toDate:[NSDate date] options:0]];

    // Uncomment this to perform an 'initial-week-scope'
    // self.calendar.scope = FSCalendarScopeWeek;
}

- (void)dealloc
{
    NSLog(@"%s",__FUNCTION__);
}

- (NSString *)calendar:(FSCalendar *)calendar titleForDate:(NSDate *)date
{
    if ([self.gregorian isDateInToday:date]) {
        return @"今";
    }
    return nil;
}

- (FSCalendarCell *)calendar:(FSCalendar *)calendar cellForDate:(NSDate *)date atMonthPosition:(FSCalendarMonthPosition)position
{
    DIVCalendarCell *cell = [calendar dequeueReusableCellWithIdentifier:@"cell" forDate:date atMonthPosition:position];
    return cell;
}

- (void)calendar:(FSCalendar *)calendar willDisplayCell:(FSCalendarCell *)cell forDate:(NSDate *)date atMonthPosition: (FSCalendarMonthPosition)position
{
    
    DIVCalendarCell *divCell = (DIVCalendarCell *)cell;
    
    // Custom today circle
    divCell.circleImageView.hidden = ![self.gregorian isDateInToday:date];
    
    
    // Configure selection layer
    if (position == FSCalendarMonthPositionCurrent || self.calendar.scope == FSCalendarScopeWeek) {
        
        divCell.eventIndicator.hidden = NO;
        
        SelectionType selectionType = SelectionTypeNone;
        if ([calendar.selectedDates containsObject:date]) {
            NSDate *previousDate = [self.gregorian dateByAddingUnit:NSCalendarUnitDay value:-1 toDate:date options:0];
            NSDate *nextDate = [self.gregorian dateByAddingUnit:NSCalendarUnitDay value:1 toDate:date options:0];
            if ([calendar.selectedDates containsObject:date]) {
                if ([calendar.selectedDates containsObject:previousDate] && [calendar.selectedDates containsObject:nextDate]) {
                    selectionType = SelectionTypeMiddle;
                } else if ([calendar.selectedDates containsObject:previousDate] && [calendar.selectedDates containsObject:date]) {
                    selectionType = SelectionTypeRightBorder;
                } else if ([calendar.selectedDates containsObject:nextDate]) {
                    selectionType = SelectionTypeLeftBorder;
                } else {
                    selectionType = SelectionTypeSingle;
                }
            }
        } else {
            selectionType = SelectionTypeNone;
        }
        
        if (selectionType == SelectionTypeNone) {
            divCell.selectionLayer.hidden = YES;
            return;
        }
        
        divCell.selectionLayer.hidden = NO;
        
        if (selectionType == SelectionTypeMiddle) {
            
            divCell.selectionLayer.path = [UIBezierPath bezierPathWithRect:divCell.selectionLayer.bounds].CGPath;
            
        } else if (selectionType == SelectionTypeLeftBorder) {
            
            divCell.selectionLayer.path = [UIBezierPath bezierPathWithRoundedRect:divCell.selectionLayer.bounds byRoundingCorners:UIRectCornerTopLeft|UIRectCornerBottomLeft cornerRadii:CGSizeMake(divCell.selectionLayer.fs_width/2, divCell.selectionLayer.fs_width/2)].CGPath;
            
        } else if (selectionType == SelectionTypeRightBorder) {
            
            divCell.selectionLayer.path = [UIBezierPath bezierPathWithRoundedRect:divCell.selectionLayer.bounds byRoundingCorners:UIRectCornerTopRight|UIRectCornerBottomRight cornerRadii:CGSizeMake(divCell.selectionLayer.fs_width/2, divCell.selectionLayer.fs_width/2)].CGPath;
            
        } else if (selectionType == SelectionTypeSingle) {
            
            CGFloat diameter = MIN(divCell.selectionLayer.fs_height, divCell.selectionLayer.fs_width);
            divCell.selectionLayer.path = [UIBezierPath bezierPathWithOvalInRect:CGRectMake(divCell.contentView.fs_width/2-diameter/2, divCell.contentView.fs_height/2-diameter/2, diameter, diameter)].CGPath;
            
        }

    } else if (position == FSCalendarMonthPositionNext || position == FSCalendarMonthPositionPrevious) {
        
        divCell.circleImageView.hidden = YES;
        divCell.selectionLayer.hidden = YES;
        divCell.eventIndicator.hidden = YES; // Hide default event indicator
        if ([self.calendar.selectedDates containsObject:date]) {
            divCell.titleLabel.textColor = self.calendar.appearance.titlePlaceholderColor; // Prevent placeholders from changing text color
        }
    }
    
}

- (NSInteger)calendar:(FSCalendar *)calendar numberOfEventsForDate:(NSDate *)date
{
    return 2;
}

- (void)calendar:(FSCalendar *)calendar boundingRectWillChange:(CGRect)bounds animated:(BOOL)animated
{
    calendar.frame = (CGRect){calendar.frame.origin,bounds.size};
    
    self.eventLabel.frame = CGRectMake(0, CGRectGetMaxY(calendar.frame)+10, self.view.frame.size.width, 50);
    
}

- (void)calendar:(FSCalendar *)calendar didSelectDate:(NSDate *)date
{
    NSLog(@"did select date %@",[self.dateFormatter stringFromDate:date]);
    [calendar reloadData];
}

- (void)calendar:(FSCalendar *)calendar didDeselectDate:(NSDate *)date
{
    [calendar reloadData];
}

- (NSArray<UIColor *> *)calendar:(FSCalendar *)calendar appearance:(FSCalendarAppearance *)appearance eventDefaultColorsForDate:(NSDate *)date
{
    if ([self.gregorian isDateInToday:date]) {
        return @[[UIColor orangeColor]];
    }
    return @[appearance.eventDefaultColor];
}

@end
