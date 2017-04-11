//
//  DIYExampleViewController.m
//  FSCalendar
//
//  Created by dingwenchao on 5/8/16.
//  Copyright © 2016 Wenchao Ding. All rights reserved.
//

#import "DIYExampleViewController.h"
#import "FSCalendar.h"
#import "DIYCalendarCell.h"
#import "FSCalendarExtensions.h"

@interface DIYExampleViewController () <FSCalendarDataSource,FSCalendarDelegate,FSCalendarDelegateAppearance>

@property (weak, nonatomic) FSCalendar *calendar;

@property (weak, nonatomic) UILabel *eventLabel;
@property (strong, nonatomic) NSCalendar *gregorian;
@property (strong, nonatomic) NSDateFormatter *dateFormatter;

- (void)configureCell:(FSCalendarCell *)cell forDate:(NSDate *)date atMonthPosition:(FSCalendarMonthPosition)position;

@end

@implementation DIYExampleViewController

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
    calendar.swipeToChooseGesture.enabled = YES;
    calendar.allowsMultipleSelection = YES;
    [view addSubview:calendar];
    self.calendar = calendar;
    
    calendar.calendarHeaderView.backgroundColor = [[UIColor lightGrayColor] colorWithAlphaComponent:0.1];
    calendar.calendarWeekdayView.backgroundColor = [[UIColor lightGrayColor] colorWithAlphaComponent:0.1];
    calendar.appearance.eventSelectionColor = [UIColor whiteColor];
    calendar.appearance.eventOffset = CGPointMake(0, -7);
    calendar.today = nil; // Hide the today circle
    [calendar registerClass:[DIYCalendarCell class] forCellReuseIdentifier:@"cell"];
    
    UIPanGestureRecognizer *scopeGesture = [[UIPanGestureRecognizer alloc] initWithTarget:calendar action:@selector(handleScopeGesture:)];
    [calendar addGestureRecognizer:scopeGesture];
    
    
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
    
    [self.calendar selectDate:[self.gregorian dateByAddingUnit:NSCalendarUnitDay value:-1 toDate:[NSDate date] options:0] scrollToDate:NO];
    [self.calendar selectDate:[NSDate date] scrollToDate:NO];
    [self.calendar selectDate:[self.gregorian dateByAddingUnit:NSCalendarUnitDay value:1 toDate:[NSDate date] options:0] scrollToDate:NO];
    
    // Uncomment this to perform an 'initial-week-scope'
    // self.calendar.scope = FSCalendarScopeWeek;
    
    // For UITest
    self.calendar.accessibilityIdentifier = @"calendar";
}

- (void)dealloc
{
    NSLog(@"%s",__FUNCTION__);
}

#pragma mark - FSCalendarDataSource

- (NSDate *)minimumDateForCalendar:(FSCalendar *)calendar
{
    return [self.dateFormatter dateFromString:@"2016-07-08"];
}

- (NSDate *)maximumDateForCalendar:(FSCalendar *)calendar
{
    return [self.gregorian dateByAddingUnit:NSCalendarUnitMonth value:5 toDate:[NSDate date] options:0];
}

- (NSString *)calendar:(FSCalendar *)calendar titleForDate:(NSDate *)date
{
    if ([self.gregorian isDateInToday:date]) {
        return @"今";
    }
    return nil;
}

- (FSCalendarCell *)calendar:(FSCalendar *)calendar cellForDate:(NSDate *)date atMonthPosition:(FSCalendarMonthPosition)monthPosition
{
    DIYCalendarCell *cell = [calendar dequeueReusableCellWithIdentifier:@"cell" forDate:date atMonthPosition:monthPosition];
    return cell;
}

- (void)calendar:(FSCalendar *)calendar willDisplayCell:(FSCalendarCell *)cell forDate:(NSDate *)date atMonthPosition: (FSCalendarMonthPosition)monthPosition
{
    [self configureCell:cell forDate:date atMonthPosition:monthPosition];
}

- (NSInteger)calendar:(FSCalendar *)calendar numberOfEventsForDate:(NSDate *)date
{
    return 2;
}

#pragma mark - FSCalendarDelegate

- (void)calendar:(FSCalendar *)calendar boundingRectWillChange:(CGRect)bounds animated:(BOOL)animated
{
    calendar.frame = (CGRect){calendar.frame.origin,bounds.size};
    
    self.eventLabel.frame = CGRectMake(0, CGRectGetMaxY(calendar.frame)+10, self.view.frame.size.width, 50);
    
}

- (BOOL)calendar:(FSCalendar *)calendar shouldSelectDate:(NSDate *)date atMonthPosition:(FSCalendarMonthPosition)monthPosition
{
    return monthPosition == FSCalendarMonthPositionCurrent;
}

- (BOOL)calendar:(FSCalendar *)calendar shouldDeselectDate:(NSDate *)date atMonthPosition:(FSCalendarMonthPosition)monthPosition
{
    return monthPosition == FSCalendarMonthPositionCurrent;
}

- (void)calendar:(FSCalendar *)calendar didSelectDate:(NSDate *)date atMonthPosition:(FSCalendarMonthPosition)monthPosition
{
    NSLog(@"did select date %@",[self.dateFormatter stringFromDate:date]);
    [self configureVisibleCells];
}

- (void)calendar:(FSCalendar *)calendar didDeselectDate:(NSDate *)date atMonthPosition:(FSCalendarMonthPosition)monthPosition
{
    NSLog(@"did deselect date %@",[self.dateFormatter stringFromDate:date]);
    [self configureVisibleCells];
}

- (NSArray<UIColor *> *)calendar:(FSCalendar *)calendar appearance:(FSCalendarAppearance *)appearance eventDefaultColorsForDate:(NSDate *)date
{
    if ([self.gregorian isDateInToday:date]) {
        return @[[UIColor orangeColor]];
    }
    return @[appearance.eventDefaultColor];
}

#pragma mark - Private methods

- (void)configureVisibleCells
{
    [self.calendar.visibleCells enumerateObjectsUsingBlock:^(__kindof FSCalendarCell * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        NSDate *date = [self.calendar dateForCell:obj];
        FSCalendarMonthPosition position = [self.calendar monthPositionForCell:obj];
        [self configureCell:obj forDate:date atMonthPosition:position];
    }];
}

- (void)configureCell:(FSCalendarCell *)cell forDate:(NSDate *)date atMonthPosition:(FSCalendarMonthPosition)monthPosition
{
    
    DIYCalendarCell *diyCell = (DIYCalendarCell *)cell;
    
    // Custom today circle
    diyCell.circleImageView.hidden = ![self.gregorian isDateInToday:date];
    
    // Configure selection layer
    if (monthPosition == FSCalendarMonthPositionCurrent) {
        
        SelectionType selectionType = SelectionTypeNone;
        if ([self.calendar.selectedDates containsObject:date]) {
            NSDate *previousDate = [self.gregorian dateByAddingUnit:NSCalendarUnitDay value:-1 toDate:date options:0];
            NSDate *nextDate = [self.gregorian dateByAddingUnit:NSCalendarUnitDay value:1 toDate:date options:0];
            if ([self.calendar.selectedDates containsObject:date]) {
                if ([self.calendar.selectedDates containsObject:previousDate] && [self.calendar.selectedDates containsObject:nextDate]) {
                    selectionType = SelectionTypeMiddle;
                } else if ([self.calendar.selectedDates containsObject:previousDate] && [self.calendar.selectedDates containsObject:date]) {
                    selectionType = SelectionTypeRightBorder;
                } else if ([self.calendar.selectedDates containsObject:nextDate]) {
                    selectionType = SelectionTypeLeftBorder;
                } else {
                    selectionType = SelectionTypeSingle;
                }
            }
        } else {
            selectionType = SelectionTypeNone;
        }
        
        if (selectionType == SelectionTypeNone) {
            diyCell.selectionLayer.hidden = YES;
            return;
        }
        
        diyCell.selectionLayer.hidden = NO;
        diyCell.selectionType = selectionType;
        
    } else {
        
        diyCell.circleImageView.hidden = YES;
        diyCell.selectionLayer.hidden = YES;
        
    }
}

@end
