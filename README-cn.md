# FSCalendar

## 特点
### 1. 自定义颜色样式
![appearance](https://cloud.githubusercontent.com/assets/5186464/6208969/20ee842a-b5fb-11e4-8875-132d42893b9e.png)

### 2. 副标题支持（方便使用农历或节日）
![subtitle1](https://cloud.githubusercontent.com/assets/5186464/6209081/54d8a4cc-b5fc-11e4-981e-d4bb21a45628.png)

## 使用方法
pod 'FSCalendar'
并且
"#import "FSCalendar.h"

### 1. 原生DataSource/Delegate模式 (可以用IBOutlet连接)
    _calendar.dataSource = self; 
    _calendar.delegate = self;
    
#### FSCalendarDataSource
- (NSString *)calendar:(FSCalendar *)calendar subtitleForDay:(NSDate *)date; // 设置副标题，本例中为农历
- (BOOL)calendar:(FSCalendar *)calendar hasEventForDate:(NSDate *)date; // 设置事件标记

#### FSCalendarDelegate
- (BOOL)calendar:(FSCalendar *)calendar shouldSelectDate:(NSDate *)date; // 是否允许点击选中某个日期
- (void)calendar:(FSCalendar *)calendar didSelectDate:(NSDate *)date; // 点击某个日期后的回调
- (void)calendarCurrentMonthDidChange:(FSCalendar *)calendar; // 当前月份变化后的回调，用calendar.currentMonth获得包含年份和月份的NSDate对象
    
### 2. 更换滑动方向
    _calendar.flow = FSCalendarFlowVertical; // 更换垂直方向滚动,默认位水平FSCalendarFlowHorizontal
    
### 3. 灵活更换样式
    [[FSCalendar appearance] setWeekdayTextColor:[UIColor redColor]];   // 周标记的颜色
    [[FSCalendar appearance] setHeaderTitleColor:[UIColor darkGrayColor]]; // 头部显示年月的字体颜色
    [[FSCalendar appearance] setEventColor:[UIColor greenColor]]; // 事件标记色
    [[FSCalendar appearance] setSelectionColor:[UIColor blueColor]]; // 选中日的背景色
    [[FSCalendar appearance] setHeaderDateFormat:@"yyyy-MM"]; // 头部日期格式
    [[FSCalendar appearance] setMinDissolvedAlpha:0.5]; // 更换位1.0，头部则不再有透明度
    [[FSCalendar appearance] setTodayColor:[UIColor redColor]]; // 当前日的背景色
    [[FSCalendar appearance] setUnitStyle:FSCalendarUnitStyleCircle]; // 选中日和当前日的北京形状，可以是Circle或Rectangle
    
### 4. 显示年月的头部 (支持IBOutlet)
    FSCalendarHeader *header = [[FSCalendarHeader alloc] initWithFrame:CGRectMake(0,0,_calendar.frame.size.width,44)];
    _calendar.header = header;

## 系统版本
ios 7.0

## 欢迎
1. 提交issue
2. 提交pull request
3. 如果您使用了FSCalendar，请在[这里](https://github.com/f33chobits/FSCalendar/issues/2)上传您的日历的颜色搭配~
