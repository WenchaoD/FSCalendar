# FSCalendar

[![Version](https://img.shields.io/cocoapods/v/FSCalendar.svg?style=flat)](http://cocoadocs.org/docsets/FSCalendar)
[![License](https://img.shields.io/cocoapods/l/FSCalendar.svg?style=flat)](http://cocoadocs.org/docsets/FSCalendar)
[![Platform](https://img.shields.io/cocoapods/p/FSCalendar.svg?style=flat)](http://cocoadocs.org/docsets/FSCalendar)

## 特点
### 1. 手势+方向支持
![animate](https://cloud.githubusercontent.com/assets/5186464/6260896/de303034-b820-11e4-9f01-8d98e0ac94aa.gif) 
![fscalendar-click](https://cloud.githubusercontent.com/assets/5186464/6479246/6156c458-c27d-11e4-97da-52b424b45ec3.gif)
### 2. 自定义颜色样式
![appearance](https://cloud.githubusercontent.com/assets/5186464/6208969/20ee842a-b5fb-11e4-8875-132d42893b9e.png)
### 3. 副标题（方便使用农历或节日）
![subtitle1](https://cloud.githubusercontent.com/assets/5186464/6209081/54d8a4cc-b5fc-11e4-981e-d4bb21a45628.png)
### 4. iPad兼容
![fscalendar-ipad](https://cloud.githubusercontent.com/assets/5186464/6502151/b4ce3092-c35b-11e4-827a-498d73579d78.jpg)

## 使用方法
* cocoapods安装: `pod 'FSCalendar'`
* 手动安装: 将‘FSCalendar’ Group下的所有.h和.m文件拖到项目中

```objective-c
"#import "FSCalendar.h"
```
### 1. 原生DataSource/Delegate模式 (可以用IBOutlet连接)
```objective-c
self.calendar.dataSource = self; 
self.calendar.delegate = self;
```    
#### FSCalendarDataSource
```objective-c
- (NSString *)calendar:(FSCalendar *)calendar subtitleForDate:(NSDate *)date; // 设置副标题，本例中为农历
- (BOOL)calendar:(FSCalendar *)calendar hasEventForDate:(NSDate *)date; // 设置事件标记
```
#### FSCalendarDelegate
```objective-c
- (BOOL)calendar:(FSCalendar *)calendar shouldSelectDate:(NSDate *)date; // 是否允许点击选中某个日期
- (void)calendar:(FSCalendar *)calendar didSelectDate:(NSDate *)date; // 点击某个日期后的回调
- (void)calendarCurrentMonthDidChange:(FSCalendar *)calendar; //
```
当前月份变化后的回调，用calendar.currentMonth获得包含年份和月份的NSDate对象
    
### 2. 更换滑动方向
```objective-c
self.calendar.flow = FSCalendarFlowVertical; // 更换垂直方向滚动,默认位水平FSCalendarFlowHorizontal
```    
### 3. 灵活更换样式
```objective-c
[[FSCalendar appearance] setWeekdayTextColor:[UIColor redColor]];   // 周标记的颜色
[[FSCalendar appearance] setHeaderTitleColor:[UIColor darkGrayColor]]; // 头部显示年月的字体颜色
[[FSCalendar appearance] setEventColor:[UIColor greenColor]]; // 事件标记色
[[FSCalendar appearance] setSelectionColor:[UIColor blueColor]]; // 选中日的背景色
[[FSCalendar appearance] setHeaderDateFormat:@"yyyy-MM"]; // 头部日期格式
[[FSCalendar appearance] setMinDissolvedAlpha:0.5]; // 更换位1.0，头部则不再有透明度
[[FSCalendar appearance] setTodayColor:[UIColor redColor]]; // 当前日的背景色
[[FSCalendar appearance] setUnitStyle:FSCalendarUnitStyleCircle]; // 选中日和当前日的北京形状，可以是Circle或Rectangle
```  
### 4. 显示年月的头部 (支持IBOutlet)
```objective-c
FSCalendarHeader *header = [[FSCalendarHeader alloc] initWithFrame:CGRectMake(0,0,_calendar.frame.size.width,44)];
self.calendar.header = header;
```
## 系统版本
ios 7.0

## 已知问题
1. 字体大小随着FSCalendar的Frame大小儿改变  
    `FSCalendar`默认情况下根据`frame`的`size`改变字体的大小，若想禁用此功能:

```objective-c
self.calendar.autoAdjustTitle = NO; 
self.calendar.titleFont = [Your custom font]
self.calendar.subtitleFont = [Your custom font]
```

`titleFont` 和 `subtitleFont` 也可以用`UIAppearance`来设置，但是只要`autoAdjustTitle`的值为`YES`就不会起任何作用



## 欢迎
1. 提交issue或pull request
2. 如果您使用了FSCalendar，请在[这里](https://github.com/f33chobits/FSCalendar/issues/2)上传您的日历的颜色搭配~
