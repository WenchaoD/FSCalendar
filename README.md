
![fscalendar](https://cloud.githubusercontent.com/assets/5186464/6655324/213a814a-cb36-11e4-9add-f80515a83291.png)<br/><br/>
[![Version](https://img.shields.io/cocoapods/v/FSCalendar.svg?style=flat)](http://cocoadocs.org/docsets/FSCalendar)
[![License](https://img.shields.io/cocoapods/l/FSCalendar.svg?style=flat)](http://cocoadocs.org/docsets/FSCalendar)
[![Platform](https://img.shields.io/cocoapods/p/FSCalendar.svg?style=flat)](http://cocoadocs.org/docsets/FSCalendar)
[![Carthage compatible](https://img.shields.io/badge/Carthage-compatible-4BC51D.svg?style=flat)](https://github.com/Carthage/Carthage)

![fscalendar---takealook](https://cloud.githubusercontent.com/assets/5186464/8448508/0abae54e-1ffb-11e5-9963-c02e4d44a0af.png)
![fscalendar-takealoot-weekmode](https://cloud.githubusercontent.com/assets/5186464/9626369/b9621d4a-518f-11e5-9464-055475d36c42.png)



# Installation

## Cocoapods:

* For iOS8+: 👍
```ruby
use_frameworks!
pod 'FSCalendar'
```

* For iOS7+:
```ruby
pod 'FSCalendar'
```

## Carthage: 
* For iOS8+
```ruby
github "WenchaoIOS/FSCalendar"
```

## Manually:
* Drag all files under `FSCalendar` folder into your project. 👍

## Support IBInspectable / IBDesignable
Only the methods marked "👍" support IBInspectable / IBDesignable feature. [Have fun with Interface builder](#roll_with_interface_builder)

# Setup

## Use Interface Builder (Recommended)

1. Drag an UIView object to ViewController Scene
2. Change the `Custom Class` to `FSCalendar`<br/>
3. Link `dataSource` and `delegate` to the ViewController <br/>

![fscalendar-ib](https://cloud.githubusercontent.com/assets/5186464/9488580/a360297e-4c0d-11e5-8548-ee9274e7c4af.jpg)

4. Finally, you should implement `FSCalendarDataSource` and `FSCalendarDelegate` in ViewController.m

## Or use code

```objective-c
@property (weak , nonatomic) FSCalendar *calendar;
```
```objective-c
// In loadView or viewDidLoad
FSCalendar *calendar = [[FSCalendar alloc] initWithFrame:CGRectMake(0, 0, 320, 300)];
calendar.dataSource = self;
calendar.delegate = self;
[self.view addSubview:calendar];
self.calendar = calendar;
```
<br/>

## Or swift

* To use `FSCalendar` in swift, you need to [Create Bridge Header](https://developer.apple.com/library/ios/documentation/Swift/Conceptual/BuildingCocoaApps/MixandMatch.html) first.


```swift
private weak var calendar: FSCalendar!
```
```swift
// In loadView or viewDidLoad
let calendar = FSCalendar(frame: CGRect(x: 0, y: 0, width: 320, height: 300))
calendar.dataSource = self
calendar.delegate = self
view.addSubview(calendar)
self.calendar = calendar
```

## More usage

### If you want `FSCalendar` to scroll vertically

* Objective - c

```objective-c
_calendar.scrollDirection = FSCalendarScrollDirectionVertical;
```

* Swift

```swift
calendar.scrollDirection = .Vertical 
```

![fscalendar-vertical](https://cloud.githubusercontent.com/assets/5186464/8448624/384e344c-1ffc-11e5-8b0b-1c3951dab2e1.gif)

### If you want `FSCalendar` to scroll horizontally (Default)

* Objective - c

```objective-c
_calendar.scrollDirection = FSCalendarScrollDirectionHorizontal; // By default
```

* Swift

```swift
calendar.scrollDirection = .Horizontal 
```

![fscalendar-horizontal](https://cloud.githubusercontent.com/assets/5186464/8448696/059e9acc-1ffd-11e5-8a95-aff6d871c6e1.gif)

### For week mode

* Objective - c

```objective-c
_calendar.scope = FSCalendarScopeWeek;
```

* Swift

```swift
calendar.scope = .Week 
```

### For month mode

* Objective - c

```objective-c
_calendar.scope = FSCalendarScopeMonth; // By default
```

* Swift

```swift
calendar.scope = .Month 
```

![fscalendarscope](https://cloud.githubusercontent.com/assets/5186464/9562222/b0318d40-4e98-11e5-97dc-1694cbd26a74.gif)

### To select more than one date

```objective-c
_calendar.allowsMultipleSelection = YES;
```

![fscalendar-mulipleselection](https://cloud.githubusercontent.com/assets/5186464/9751497/368f55f6-56d8-11e5-9af5-0d09ba13f0eb.png)

### If you want `FSCalendar` to use `Monday` as the first column (or any other weekday)

```objective-c
_calendar.firstWeekday = 2; 
```

![fscalendar---monday](https://cloud.githubusercontent.com/assets/5186464/8448782/c92505e4-1ffd-11e5-95c0-9bf3c8bec669.png)


### The date format of header can be customized

```objective-c
_calendar.appearance.headerDateFormat = @"MMM yy";
```

![fscalendar---headerformat](https://cloud.githubusercontent.com/assets/5186464/8449322/15d79168-2003-11e5-997a-06c6721dd807.png)

### You can define the appearance

```objective-c
_calendar.appearance.weekdayTextColor = [UIColor redColor];
_calendar.appearance.headerTitleColor = [UIColor redColor];
_calendar.appearance.eventColor = [UIColor greenColor];
_calendar.appearance.selectionColor = [UIColor blueColor];
_calendar.appearance.todayColor = [UIColor orangeColor];
_calendar.appearance.todaySelectionColor = [UIColor blackColor];
```

![fscalendar---colors](https://cloud.githubusercontent.com/assets/5186464/8449300/d55d1c7a-2002-11e5-8de6-be04f3783456.png)

### The day shape doesn't have to be a circle

* Objective - c
```objective-c
_calendar.appearance.cellStyle = FSCalendarCellStyleRectangle;
```

* Swift
```swift
calendar.appearance.cellStyle = .Rectangle
```

![fscalendar---rectangle](https://cloud.githubusercontent.com/assets/5186464/8449186/d38ea39c-2001-11e5-99f4-32fcd6120a01.png)

### `FSCalendar` can show subtitle for each day

* Objective - c

```objective-c
// FSCalendarDataSource
- (NSString *)calendar:(FSCalendar *)calendar subtitleForDate:(NSDate *)date
{
    return yourSubtitle;
}
```

* Swift

```swift
// FSCalendarDataSource
func calendar(calendar: FSCalendar!, subtitleForDate date: NSDate!) -> String! {
    return yourSubtitle
}
```

![fscalendar---subtitle2](https://cloud.githubusercontent.com/assets/5186464/8449075/b0bb34ee-2000-11e5-9c4a-401bc708d9ea.png)
<br/>
![fscalendar---subtitle1](https://cloud.githubusercontent.com/assets/5186464/8449076/b0be3d88-2000-11e5-9c5d-22ecd325b6cc.png)

### And event dot for some days

* Objective - c

```objective-c
// FSCalendarDataSource
- (BOOL)calendar:(FSCalendar *)calendar hasEventForDate:(NSDate *)date
{
    return shouldShowEventDot;
}
```

* Swift

```swift
// FSCalendarDataSource
func calendar(calendar: FSCalendar!, hasEventForDate date: NSDate!) -> Bool {
    return shouldShowEventDot
}
```

### Or image for some days

* Objective - c

```objective-c
// FSCalendarDataSource
- (UIImage *)calendar:(FSCalendar *)calendar imageForDate:(NSDate *)date
{
    return anyImage;
}
```

* Swift

```swift
// FSCalendarDataSource
func calendar(calendar: FSCalendar!, imageForDate date: NSDate!) -> UIImage! {
    return anyImage
}
```

![fscalendar---image](https://cloud.githubusercontent.com/assets/5186464/8449772/e94d3126-2006-11e5-8871-e4f8dbce81ea.png)

#### There are left and right boundaries

```objective-c
// FSCalendarDataSource
- (NSDate *)minimumDateForCalendar:(FSCalendar *)calendar
{
    return yourMinimumDate;
}

- (NSDate *)maximumDateForCalendar:(FSCalendar *)calendar
{
    return yourMaximumDate;
}
```

### You can do something when a date is selected

* Objective - c

```objective-c
// FSCalendarDelegate
- (void)calendar:(FSCalendar *)calendar didSelectDate:(NSDate *)date
{
    // Do something
}
```

* Swift

```swift
// FSCalendarDelegate
func calendar(calendar: FSCalendar!, didSelectDate date: NSDate!) {
    
}

```

### You can prevent it from being selected

* Objective - c

```objective-c
// FSCalendarDelegate
- (BOOL)calendar:(FSCalendar *)calendar shouldSelectDate:(NSDate *)date
{
    if ([dateShouldNotBeSelected]) {
        return NO;
    }
    return YES;
}
```

* Swift

```swift
func calendar(calendar: FSCalendar!, shouldSelectDate date: NSDate!) -> Bool {
    if dateShouldNotBeSelected {
        return false
    }
    return true
}
```
 

### You will get notified when `FSCalendar` changes the month

* Objective - c

```objective-c
- (void)calendarCurrentMonthDidChange:(FSCalendar *)calendar
{
    // Do something
}
```

* Swift

```swift
func calendarCurrentMonthDidChange(calendar: FSCalendar!) {
    // Do something
}
```

### `FSCalendar` can be used on `iPad`.
![fscalendar-ipad](https://cloud.githubusercontent.com/assets/5186464/6502151/b4ce3092-c35b-11e4-827a-498d73579d78.jpg)

### <a id="roll_with_interface_builder"></a> Roll with Interface Builder

![fscalendar - ibdesignable](https://cloud.githubusercontent.com/assets/5186464/9301716/2e76a2ca-4503-11e5-8450-1fa7aa93e9fd.gif)


* `fakeSubtitles` and `fakedSelectedDay` is only used for preview in Interface Builder

## Known issues
* The title size changed as we change frame size of FSCalendar: Automatically adjusting font size based on frame size is default behavior of FSCalendadr, to disable it:

```objective-c    
_calendar.appearance.autoAdjustTitleSize = NO; 
_calendar.appearance.titleFont = otherTitleFont;
_calendar.appearance.subtitleFont = otherSubtitleFont;
```

`titleFont` and `subtitleFont` would not take any effect if `autoAdjustTitleSize` value is `YES`

* What if I don't need the `today` circle?

```objective-c
_calendar.appearance.todayColor = [UIColor clearColor];
_calendar.appearance.titleTodayColor = _calendar.appearance.titleDefaultColor;
_calendar.appearance.subtitleTodayColor = _calendar.appearance.subtitleDefaultColor;
```

* Can we hide this?
![fscalendar---headeralpha](https://cloud.githubusercontent.com/assets/5186464/8450978/217855ca-2012-11e5-8b97-a9b45ece4e71.png)

```objective-c
_calendar.appearance.headerMinimumDissolvedAlpha = 0.0;
```

# License

FSCalendar is available under the MIT license. See the LICENSE file for more info.

# Support
* If FSCalendar cannot meet your requirment, tell me in issues or send your pull requests
* If you like this control and use it in your app, submit your app's link address [here](https://www.cocoacontrols.com/controls/fscalendar).It would be a great support.

# Contact
* email: `f33chobits@gmail.com`
* skype: `wenchao.ding`

# Donate
* Paypal - f33chobits@gmail.com

