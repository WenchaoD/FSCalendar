//
//  FullScreenExample.m
//  FSCalendar
//
//  Created by Wenchao Ding on 9/16/15.
//  Copyright (c) 2015 Wenchao Ding. All rights reserved.
//

#import "FullScreenExampleViewController.h"
#import <EventKit/EventKit.h>
#import "FSCalendar.h"
#import "FSCalendarExtensions.h"

NS_ASSUME_NONNULL_BEGIN

@interface FullScreenExampleViewController()<FSCalendarDataSource,FSCalendarDelegate,FSCalendarDelegateAppearance>

@property (weak, nonatomic) FSCalendar *calendar;

@property (assign, nonatomic) BOOL showsLunar;
@property (assign, nonatomic) BOOL showsEvents;

@property (strong, nonatomic) NSCache *cache;

- (void)todayItemClicked:(id)sender;
- (void)lunarItemClicked:(id)sender;
- (void)eventItemClicked:(id)sender;

@property (strong, nonatomic) NSCalendar *lunarCalendar;
@property (strong, nonatomic) NSCalendar *gregorian;
@property (strong, nonatomic) NSDateFormatter *dateFormatter;

@property (strong, nonatomic) NSDate *minimumDate;
@property (strong, nonatomic) NSDate *maximumDate;

@property (strong, nonatomic) NSArray<NSString *> *lunarChars;
@property (strong, nonatomic) NSArray<EKEvent *> *events;

@property (nonatomic, weak) UIView *operaterView;

@property (nonatomic, assign) BOOL isFullScreen;

@property (strong, nonatomic) NSDictionary *lunarsDict;

- (void)loadCalendarEvents;
- (nullable NSArray<EKEvent *> *)eventsForDate:(NSDate *)date;

@end

NS_ASSUME_NONNULL_END

@implementation FullScreenExampleViewController

#pragma mark - Life cycle
- (void)viewDidLoad
{
	[super viewDidLoad];
	
	self.title = @"FSCalendar";
	self.view.backgroundColor = [UIColor colorWithRed:0.95 green:0.95 blue:0.95 alpha:1.0];
	
	[self setup];
	
	[self loadCalendarEvents];
	
	
	/*
	 dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(3 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
	 self.minimumDate = [self.dateFormatter dateFromString:@"2015-02-01"];
	 self.maximumDate = [self.dateFormatter dateFromString:@"2015-06-10"];
	 [self.calendar reloadData];
	 });
	 */
}

- (void)setup {
	
	self.isFullScreen = 0;
	self.gregorian = [[NSCalendar alloc] initWithCalendarIdentifier:NSCalendarIdentifierGregorian];
	
	self.dateFormatter = [[NSDateFormatter alloc] init];
	self.dateFormatter.dateFormat = @"yyyy-MM-dd";
	
	self.minimumDate = [self.dateFormatter dateFromString:@"2016-02-03"];
	self.maximumDate = [self.dateFormatter dateFromString:@"2018-04-10"];
	
	self.dateFormatter.calendar = [NSCalendar calendarWithIdentifier:NSCalendarIdentifierChinese];
	self.dateFormatter.calendar.locale = [NSLocale localeWithLocaleIdentifier:@"zh-CN"];
	
	_lunarsDict = @{@"2":@"初二",@"3":@"初三",@"4":@"初四",@"5":@"初五",@"6":@"初六",@"7":@"初七",@"8":@"初八",@"9":@"初九",@"10":@"初十",@"11":@"十一",@"12":@"十二",@"13":@"十三",@"14":@"十四",@"15":@"十五",@"16":@"十六",@"17":@"十七",@"18":@"十八",@"19":@"十九",@"20":@"二十",@"21":@"二一",@"22":@"二二",@"23":@"二三",@"24":@"二四",@"25":@"二五",@"26":@"二六",@"27":@"二七",@"28":@"二八",@"29":@"二九",@"30":@"三十"};
	
	UIView *operaterView = [[UIView alloc] initWithFrame:CGRectMake(0, 64, SCREEN_WIDTH, 35)];
	self.operaterView = operaterView;
	[self.view addSubview:operaterView];
	
	UIButton *todayButton = [UIButton new];
	[operaterView addSubview:todayButton];
	todayButton.fs_height = 35;
	todayButton.fs_width = (operaterView.fs_width - 3) / 4;
	todayButton.fs_x = 0;
	todayButton.titleLabel.font = FONT_S;
	[todayButton setTitle:@"今天" forState:UIControlStateNormal];
	[todayButton setTitleColor:[UIColor redColor] forState:UIControlStateNormal];
	[todayButton addTarget:self action:@selector(todayItemClicked:) forControlEvents:UIControlEventTouchUpInside];
	
	UIView *line = [UIView new];
	[operaterView addSubview:line];
	line.backgroundColor = [UIColor lightGrayColor];
	line.fs_width = 1;
	line.fs_height = 35;
	line.fs_x = todayButton.fs_right;
	
	UIButton *lunarsButton = [UIButton new];
	[operaterView addSubview:lunarsButton];
	lunarsButton.fs_height = 35;
	lunarsButton.fs_width = (operaterView.fs_width - 3) / 4;
	lunarsButton.fs_x = line.fs_right;
	lunarsButton.titleLabel.font = FONT_S;
	[lunarsButton setTitleColor:[UIColor redColor] forState:UIControlStateNormal];
	[lunarsButton setTitle:@"阴历" forState:UIControlStateNormal];
	[lunarsButton addTarget:self action:@selector(lunarItemClicked:) forControlEvents:UIControlEventTouchUpInside];
	
	UIView *lineTwo = [UIView new];
	[operaterView addSubview:lineTwo];
	lineTwo.backgroundColor = [UIColor lightGrayColor];
	lineTwo.fs_width = 1;
	lineTwo.fs_height = 35;
	lineTwo.fs_x = lunarsButton.fs_right;
	
	UIButton *eventButton = [UIButton new];
	[operaterView addSubview:eventButton];
	eventButton.fs_height = 35;
	eventButton.fs_width = (operaterView.fs_width - 3) / 4;
	eventButton.fs_x = lineTwo.fs_right;
	eventButton.titleLabel.font = FONT_S;
	[eventButton setTitleColor:[UIColor redColor] forState:UIControlStateNormal];
	[eventButton setTitle:@"事件" forState:UIControlStateNormal];
	[eventButton addTarget:self action:@selector(eventItemClicked:) forControlEvents:UIControlEventTouchUpInside];
	
	UIView *lineThree = [UIView new];
	[operaterView addSubview:lineThree];
	lineThree.backgroundColor = [UIColor lightGrayColor];
	lineThree.fs_width = 1;
	lineThree.fs_height = 35;
	lineThree.fs_x = eventButton.fs_right;
	
	UIButton *fullButton = [UIButton new];
	[operaterView addSubview:fullButton];
	fullButton.fs_height = 35;
	fullButton.fs_width = (operaterView.fs_width - 3) / 4;
	fullButton.fs_x = lineThree.fs_right;
	fullButton.titleLabel.font = FONT_S;
	[fullButton setTitleColor:[UIColor redColor] forState:UIControlStateNormal];
	[fullButton setTitle:@"全屏" forState:UIControlStateNormal];
	[fullButton addTarget:self action:@selector(fullItemClicked:) forControlEvents:UIControlEventTouchUpInside];
	
	FSCalendar *calendar = [[FSCalendar alloc] initWithFrame:CGRectMake(0, 64+self.operaterView.fs_height, self.view.bounds.size.width, 300)];
	self.calendar.accessibilityIdentifier = @"calendar";
	calendar.backgroundColor = [UIColor whiteColor];
	calendar.dataSource = self;
	calendar.delegate = self;
	calendar.allowsMultipleSelection = YES;
	calendar.firstWeekday = 2;
	calendar.appearance.caseOptions = FSCalendarCaseOptionsWeekdayUsesSingleUpperCase|FSCalendarCaseOptionsHeaderUsesUpperCase;
	[self.view addSubview:calendar];
	self.calendar = calendar;
	
	UIBarButtonItem *rightItem = [[UIBarButtonItem alloc] initWithTitle:@"完成" style:UIBarButtonItemStylePlain target:self action:@selector(onTapCompleteButton:)];
	
	[rightItem setTitleTextAttributes:@{NSForegroundColorAttributeName:[UIColor redColor], NSFontAttributeName:FONT_S} forState:UIControlStateNormal];
	
	self.navigationItem.rightBarButtonItems = @[rightItem];
}

- (void)didReceiveMemoryWarning
{
	[super didReceiveMemoryWarning];
	[self.cache removeAllObjects];
}

- (void)dealloc
{
	NSLog(@"%s",__FUNCTION__);
}

#pragma mark - Target actions

- (void)todayItemClicked:(id)sender
{
	[self.calendar setCurrentPage:[NSDate date] animated:YES];
}

- (void)lunarItemClicked:(id)sender {
	self.showsLunar = !self.showsLunar;
	[self.calendar reloadData];
}

- (void)eventItemClicked:(id)sender{
	self.showsEvents = !self.showsEvents;
	[self.calendar reloadData];
}


- (void)fullItemClicked:(id)sender{
	self.isFullScreen = !self.isFullScreen;
	UIButton *fullButton = self.operaterView.subviews.lastObject;
	
	if (!self.isFullScreen) {
		[fullButton setTitle:@"全屏" forState:UIControlStateNormal];
	} else {
		[fullButton setTitle:@"半屏" forState:UIControlStateNormal];
	}
	if (self.isFullScreen) {
		self.calendar.pagingEnabled = NO; // important
		self.calendar.placeholderType = FSCalendarPlaceholderTypeFillHeadTail;
		self.calendar.frame = CGRectMake(0, 64+self.operaterView.fs_height, SCREEN_WIDTH, SCREEN_HEIGHT-64-self.operaterView.fs_height);
	} else {
		self.calendar.pagingEnabled = YES;
		self.calendar.placeholderType = FSCalendarPlaceholderTypeNone;;
		self.calendar.frame = CGRectMake(0, 64+self.operaterView.fs_height, self.view.bounds.size.width, 300);
		
		[self.calendar setNeedsConfigureAppearance];
	}
	//	[self.view layoutIfNeeded];
}

- (void)onTapCompleteButton: (id)sender {
	if (self.delegate && [self.delegate conformsToProtocol:@protocol(FullScreenExampleViewControllerDelegate)]) {
		self.datesSelected = self.calendar.selectedDates.copy;
		// 外面代理方法中可以实现,跳回上一层控制器,拿到本层选定的日期做业务.
		[self.delegate dateSelectController:self didSelect:self.datesSelected];
	}
}

#pragma mark - FSCalendarDataSource

- (NSDate *)minimumDateForCalendar:(FSCalendar *)calendar
{
	return self.minimumDate;
}

- (NSDate *)maximumDateForCalendar:(FSCalendar *)calendar
{
	return self.maximumDate;
}

- (NSString *)calendar:(FSCalendar *)calendar subtitleForDate:(NSDate *)date
{
	if (_showsEvents) {
		EKEvent *event = [self eventsForDate:date].firstObject;
		if (event) {
			return event.title;
		}
	}
	if (_showsLunar) {
		self.dateFormatter.dateFormat = @"d";
		if ([[self.dateFormatter stringFromDate:date] isEqualToString:@"1"]) {
			self.dateFormatter.dateFormat = @"M";
			NSString *month = FORMAT(@"%@月",[self.dateFormatter stringFromDate:date]);
			if ([month containsString:@"bis"]) {
				month = [month stringByReplacingOccurrencesOfString:@"bis" withString:@""];
				month = FORMAT(@"闰%@",month);
			}
			
			return month;
		} else {
			return _lunarsDict[[self.dateFormatter stringFromDate:date]];
		}
	}
	return nil;
}

#pragma mark - FSCalendarDelegate

- (BOOL)calendar:(FSCalendar *)calendar shouldSelectDate:(NSDate *)date atMonthPosition:(FSCalendarMonthPosition)monthPosition {
	// 今天以前不能选中.
	return [self date:date isEqualOrAfter:[NSDate date]];
}

- (void)calendar:(FSCalendar *)calendar didSelectDate:(NSDate *)date atMonthPosition:(FSCalendarMonthPosition)monthPosition
{
	NSLog(@"did select %@",[self.dateFormatter stringFromDate:date]);
}

- (void)calendarCurrentPageDidChange:(FSCalendar *)calendar
{
	NSLog(@"did change page %@",[self.dateFormatter stringFromDate:calendar.currentPage]);
}

- (NSInteger)calendar:(FSCalendar *)calendar numberOfEventsForDate:(NSDate *)date
{
	if (!self.showsEvents) return 0;
	if (!self.events) return 0;
	NSArray<EKEvent *> *events = [self eventsForDate:date];
	return events.count;
}

- (NSArray<UIColor *> *)calendar:(FSCalendar *)calendar appearance:(FSCalendarAppearance *)appearance eventDefaultColorsForDate:(NSDate *)date
{
	if (!self.showsEvents) return nil;
	if (!self.events) return nil;
	NSArray<EKEvent *> *events = [self eventsForDate:date];
	NSMutableArray<UIColor *> *colors = [NSMutableArray arrayWithCapacity:events.count];
	[events enumerateObjectsUsingBlock:^(EKEvent * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
		[colors addObject:[UIColor colorWithCGColor:obj.calendar.CGColor]];
	}];
	return colors.copy;
}

#pragma mark - Private methods

- (void)loadCalendarEvents
{
	__weak typeof(self) weakSelf = self;
	EKEventStore *store = [[EKEventStore alloc] init];
	[store requestAccessToEntityType:EKEntityTypeEvent completion:^(BOOL granted, NSError *error) {
		
		if(granted) {
			NSDate *startDate = self.minimumDate;
			NSDate *endDate = self.maximumDate;
			NSPredicate *fetchCalendarEvents = [store predicateForEventsWithStartDate:startDate endDate:endDate calendars:nil];
			NSArray<EKEvent *> *eventList = [store eventsMatchingPredicate:fetchCalendarEvents];
			NSArray<EKEvent *> *events = [eventList filteredArrayUsingPredicate:[NSPredicate predicateWithBlock:^BOOL(EKEvent * _Nullable event, NSDictionary<NSString *,id> * _Nullable bindings) {
				return event.calendar.subscribed;
			}]];
			
			dispatch_async(dispatch_get_main_queue(), ^{
				if (!weakSelf) return;
				weakSelf.events = events;
				[weakSelf.calendar reloadData];
			});
			
		} else {
			
			// Alert
			UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"Permission Error" message:@"Permission of calendar is required for fetching events." preferredStyle:UIAlertControllerStyleAlert];
			[alertController addAction:[UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleCancel handler:nil]];
			[self presentViewController:alertController animated:YES completion:nil];
		}
	}];
	
}

- (NSArray<EKEvent *> *)eventsForDate:(NSDate *)date
{
	NSArray<EKEvent *> *events = [self.cache objectForKey:date];
	if ([events isKindOfClass:[NSNull class]]) {
		return nil;
	}
	NSArray<EKEvent *> *filteredEvents = [self.events filteredArrayUsingPredicate:[NSPredicate predicateWithBlock:^BOOL(EKEvent * _Nullable evaluatedObject, NSDictionary<NSString *,id> * _Nullable bindings) {
		return [evaluatedObject.occurrenceDate isEqualToDate:date];
	}]];
	if (filteredEvents.count) {
		[self.cache setObject:filteredEvents forKey:date];
	} else {
		[self.cache setObject:[NSNull null] forKey:date];
	}
	return filteredEvents;
}

- (BOOL)date:(NSDate *)dateA isTheSameMonthThan:(NSDate *)dateB
{
	NSDateComponents *componentsA = [self.gregorian components:NSCalendarUnitYear|NSCalendarUnitMonth fromDate:dateA];
	NSDateComponents *componentsB = [self.gregorian components:NSCalendarUnitYear|NSCalendarUnitMonth fromDate:dateB];
	
	return componentsA.year == componentsB.year && componentsA.month == componentsB.month;
}

- (BOOL)date:(NSDate *)dateA isTheSameWeekThan:(NSDate *)dateB
{
	NSDateComponents *componentsA = [self.gregorian components:NSCalendarUnitYear|NSCalendarUnitWeekOfYear fromDate:dateA];
	NSDateComponents *componentsB = [self.gregorian components:NSCalendarUnitYear|NSCalendarUnitWeekOfYear fromDate:dateB];
	
	return componentsA.year == componentsB.year && componentsA.weekOfYear == componentsB.weekOfYear;
}

- (BOOL)date:(NSDate *)dateA isTheSameDayThan:(NSDate *)dateB
{
	NSDateComponents *componentsA = [self.gregorian components:NSCalendarUnitYear|NSCalendarUnitMonth|NSCalendarUnitDay fromDate:dateA];
	NSDateComponents *componentsB = [self.gregorian components:NSCalendarUnitYear|NSCalendarUnitMonth|NSCalendarUnitDay fromDate:dateB];
	
	return componentsA.year == componentsB.year && componentsA.month == componentsB.month && componentsA.day == componentsB.day;
}

- (BOOL)date:(NSDate *)dateA isEqualOrBefore:(NSDate *)dateB
{
	if([dateA compare:dateB] == NSOrderedAscending || [self date:dateA isTheSameDayThan:dateB]){
		return YES;
	}
	
	return NO;
}

- (BOOL)date:(NSDate *)dateA isEqualOrAfter:(NSDate *)dateB
{
	if([dateA compare:dateB] == NSOrderedDescending || [self date:dateA isTheSameDayThan:dateB]){
		return YES;
	}
	
	return NO;
}

- (BOOL)date:(NSDate *)date isEqualOrAfter:(NSDate *)startDate andEqualOrBefore:(NSDate *)endDate
{
	if([self date:date isEqualOrAfter:startDate] && [self date:date isEqualOrBefore:endDate]){
		return YES;
	}
	
	return NO;
}

- (NSDate*)nextDay:(NSDate *)date{
	NSDateComponents *dateComponents = [[NSDateComponents alloc] init];
	dateComponents.day = +1;
	NSDate *newDate = [[NSCalendar currentCalendar] dateByAddingComponents:dateComponents toDate:date options:0];
	return newDate;
}
@end
