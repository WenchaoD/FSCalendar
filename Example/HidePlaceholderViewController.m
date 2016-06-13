//
//  HidePlaceholderViewController.m
//  FSCalendar
//
//  Created by dingwenchao on 3/9/16.
//  Copyright © 2016 wenchaoios. All rights reserved.
//

#import "HidePlaceholderViewController.h"

#define kContainerFrame (CGRectMake(0, CGRectGetMaxY(calendar.frame), CGRectGetWidth(self.view.frame), 50))

@implementation HidePlaceholderViewController

#pragma mark - Life cycle

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
    UIView *view;
    UIButton *button;
    
    view = [[UIView alloc] initWithFrame:[UIScreen mainScreen].bounds];
    view.backgroundColor = [UIColor groupTableViewBackgroundColor];
    self.view = view;
    
    
    // 450 for iPad and 300 for iPhone
    CGFloat height = [[UIDevice currentDevice].model hasPrefix:@"iPad"] ? 450 : 300;
    FSCalendar *calendar = [[FSCalendar alloc] initWithFrame:CGRectMake(0, CGRectGetMaxY(self.navigationController.navigationBar.frame), CGRectGetWidth(self.view.frame), height)];
    calendar.backgroundColor = [UIColor whiteColor];
    calendar.dataSource = self;
    calendar.delegate = self;
    calendar.showsPlaceholders = NO;
    calendar.currentPage = [calendar dateFromString:@"2016-06" format:@"yyyy-MM"];
//    calendar.firstWeekday = 2;
//    calendar.scrollDirection = FSCalendarScrollDirectionVertical;
    [self.view addSubview:calendar];
    self.calendar = calendar;
    
    view = [[UIView alloc] initWithFrame:kContainerFrame];
    [self.view addSubview:view];
    self.bottomContainer = view;
    
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(15, 0, 200, 50)];
    label.font = [UIFont preferredFontForTextStyle:UIFontTextStyleSubheadline];
    [self.bottomContainer addSubview:label];
    self.eventLabel = label;
    
    button = [UIButton buttonWithType:UIButtonTypeSystem];
    button.frame = CGRectMake(CGRectGetMaxX(self.eventLabel.frame)+10, 10, 60, 30);
    [button setTitle:@"PREV" forState:UIControlStateNormal];
    [button addTarget:self action:@selector(prevClicked:) forControlEvents:UIControlEventTouchUpInside];
    button.layer.borderWidth = 1;
    button.layer.borderColor = button.tintColor.CGColor;
    button.layer.cornerRadius = 6;
    [self.bottomContainer addSubview:button];
    self.prevButton = button;
    
    button = [UIButton buttonWithType:UIButtonTypeSystem];
    button.frame = CGRectMake(CGRectGetMaxX(self.prevButton.frame)+10, 10, 60, 30);
    [button setTitle:@"NEXT" forState:UIControlStateNormal];
    [button addTarget:self action:@selector(nextClicked:) forControlEvents:UIControlEventTouchUpInside];
    button.layer.borderWidth = 1;
    button.layer.borderColor = button.tintColor.CGColor;
    button.layer.cornerRadius = 6;
    [self.bottomContainer addSubview:button];
    self.nextButton = button;
    
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    NSMutableAttributedString *attributedText = [[NSMutableAttributedString alloc] initWithString:@""];
    NSTextAttachment *attatchment = [[NSTextAttachment alloc] init];
    attatchment.image = [UIImage imageNamed:@"icon_cat"];
    attatchment.bounds = CGRectMake(0, -3, attatchment.image.size.width, attatchment.image.size.height);
    [attributedText appendAttributedString:[NSAttributedString attributedStringWithAttachment:attatchment]];
    [attributedText appendAttributedString:[[NSAttributedString alloc] initWithString:@"  Hey Daily Event  "]];
    [attributedText appendAttributedString:[NSAttributedString attributedStringWithAttachment:attatchment]];
    self.eventLabel.attributedText = attributedText.copy;
    
}

- (void)dealloc
{
    NSLog(@"%s",__FUNCTION__);
}

#pragma mark - <FSCalendarDelegate>

- (void)calendar:(FSCalendar *)calendar boundingRectWillChange:(CGRect)bounds animated:(BOOL)animated
{
    calendar.frame = (CGRect){calendar.frame.origin,bounds.size};
    self.bottomContainer.frame = kContainerFrame;
}

#pragma mark - Target action

- (void)nextClicked:(id)sender
{
    NSDate *nextMonth = [self.calendar dateByAddingMonths:1 toDate:self.calendar.currentPage];
    [self.calendar setCurrentPage:nextMonth animated:YES];
}

- (void)prevClicked:(id)sender
{
    NSDate *prevMonth = [self.calendar dateBySubstractingMonths:1 fromDate:self.calendar.currentPage];
    [self.calendar setCurrentPage:prevMonth animated:YES];
}

@end
