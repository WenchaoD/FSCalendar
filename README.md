
![logo](https://cloud.githubusercontent.com/assets/5186464/16540124/efc51f72-408b-11e6-934a-4e750b8b55bb.png)
<br/><br/>
[![Apps Using](https://img.shields.io/badge/Apps%20Using-%3E%2010,000-00BFFF.svg?style=plastic)](https://cocoapods.org/pods/FSCalendar)
[![Total Downloads](https://img.shields.io/badge/Total%20Downloads-%3E%20500,000-00BFFF.svg?style=plastic)](https://cocoapods.org/pods/FSCalendar)
<br>
[![Travis](https://travis-ci.org/WenchaoD/FSCalendar.svg?branch=master)](https://travis-ci.org/WenchaoD/FSCalendar)
[![Version](https://img.shields.io/cocoapods/v/FSCalendar.svg?style=flat)](http://cocoadocs.org/docsets/FSCalendar)
[![Platform](https://img.shields.io/badge/platform-iOS%207%2B-blue.svg?style=flat)](http://cocoadocs.org/docsets/FSCalendar)
[![Carthage compatible](https://img.shields.io/badge/Carthage-compatible-4BC51D.svg?style=flat)](https://github.com/Carthage/Carthage)
<br>
[![Languages](https://img.shields.io/badge/language-objc%20|%20swift-FF69B4.svg?style=plastic)](#)

# Table of contents
* [Screenshots](#screenshots)
* [Installation](#installation)
* [Pre-knowledge](#pre-knowledge)
* [Support](#support)
* [Contact](#contact)

## <a id="screenshots"></a>Screenshots 

### iPhone
![fscalendar](https://cloud.githubusercontent.com/assets/5186464/10262249/4fabae40-69f2-11e5-97ab-afbacd0a3da2.jpg)

### iPad
![fscalendar-ipad](https://cloud.githubusercontent.com/assets/5186464/10927681/d2448cb6-82dc-11e5-9d11-f664a06698a7.jpg)

### Safe Orientation
![fscalendar-scope-orientation-autolayout](https://cloud.githubusercontent.com/assets/5186464/20325758/ea125e1e-abc0-11e6-9e29-491acbcb0d07.gif)

### Today Extension
|    iOS8/9    |    iOS10    |
|--------------|-------------|
|![today1](https://cloud.githubusercontent.com/assets/5186464/20288375/ed3fba0e-ab0d-11e6-8b15-43d3dc656f22.gif)|![today2](https://cloud.githubusercontent.com/assets/5186464/20288378/f11e318c-ab0d-11e6-8d1d-9d89b563e9d7.gif)|

### Interactive Scope Gesture
| ![1](https://cloud.githubusercontent.com/assets/5186464/21559640/e92a9ccc-ce8a-11e6-8c60-e52204f33249.gif) |
| ---- |

### DIY support
|  ![1](https://cloud.githubusercontent.com/assets/5186464/20026983/22354a0e-a342-11e6-8ae6-0614ea7f35ae.gif)    |
| -------------  |
> To customize your own cell, view DIY Example in `Example-Swift` or `Example-Objc`


### Swipe-To-Choose

|Single-Selection<br/>Swipe-To-Choose|Multiple-Selection<br/>Swipe-To-Choose|DIY<br/>Swipe-To-Choose|
|----------|--------|--------|
|![1](https://cloud.githubusercontent.com/assets/5186464/20257768/cb1905d4-aa86-11e6-9ef7-af76f9caa024.gif)|![2](https://cloud.githubusercontent.com/assets/5186464/20257826/254070ec-aa87-11e6-81b1-1815453fd464.gif)|![3](https://cloud.githubusercontent.com/assets/5186464/20257836/2ffa3252-aa87-11e6-8ff9-3b40f5b2307b.gif)|

## Achievement of Users <a id="achievement"></a>

|  ![1](https://cloud.githubusercontent.com/assets/5186464/21747193/3111e4ee-d59a-11e6-8e4d-ca695b53e421.png)    |  ![2](https://cloud.githubusercontent.com/assets/5186464/21747393/42a753fa-d5a0-11e6-9cb2-de7cc642e69e.png)  |  ![3](https://cloud.githubusercontent.com/assets/5186464/21897255/ff78fcdc-d923-11e6-9d59-62119bc4343f.png)  |  ![4](https://cloud.githubusercontent.com/assets/5186464/21747192/3111cacc-d59a-11e6-8626-44cd75ebd794.png)  |
| ------------- | ------------- | ------------- | ------------- |

#### [***More Achievements***](https://github.com/WenchaoD/FSCalendar/wiki/) are available in [***FSCalendar Gallery***](https://github.com/WenchaoD/FSCalendar/wiki/)  

# <a id="installation"></a>Installation

## CocoaPods:

* For iOS8+: 👍

```ruby
use_frameworks!
target '<Your Target Name>' do
    pod 'FSCalendar'
end
```

* For iOS7+:

```ruby
target '<Your Target Name>' do
	pod 'FSCalendar'
end
```

> [NSCalendarExtension](https://github.com/WenchaoD/NSCalendarExtension) is required to get iOS7 compatibility.

## Carthage: 
* For iOS8+

```ruby
github "WenchaoD/FSCalendar"
```

## SPM:

Add dependency:
```swift
.package(url: "https://github.com/WenchaoD/FSCalendar.git", from: "2.8.2")
```

## Manually:
* Drag all files under `FSCalendar` folder into your project. 👍

> Alternatively to give it a test run, simply press `command+u` in `Example-Objc` or `Example-Swift` and launch the ***UITest Target***. <br>
> Only the methods marked "👍" support IBInspectable / IBDesignable feature. [Have fun with Interface builder](#roll_with_interface_builder)


# Setup

## Use Interface Builder

1、 Drag an UIView object to ViewController Scene
2、 Change the `Custom Class` to `FSCalendar`<br/>
3、 Link `dataSource` and `delegate` to the ViewController <br/>

![fscalendar-ib](https://cloud.githubusercontent.com/assets/5186464/9488580/a360297e-4c0d-11e5-8548-ee9274e7c4af.jpg)

4、 Finally, implement `FSCalendarDataSource` and `FSCalendarDelegate` in your `ViewController`

## Or use code

```objc
@property (weak , nonatomic) FSCalendar *calendar;
```
```objc
// In loadView(Recommended) or viewDidLoad
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
fileprivate weak var calendar: FSCalendar!
```
```swift
// In loadView or viewDidLoad
let calendar = FSCalendar(frame: CGRect(x: 0, y: 0, width: 320, height: 300))
calendar.dataSource = self
calendar.delegate = self
view.addSubview(calendar)
self.calendar = calendar
```

> To use **FSCalendar** in Swift3, see `Example-Swift` for details.


## <a id='adjusts_frame_dynamicly' /></a>Warning 
`FSCalendar` ***doesn't*** update frame by itself, Please implement

* For ***AutoLayout***

```objc
- (void)calendar:(FSCalendar *)calendar boundingRectWillChange:(CGRect)bounds animated:(BOOL)animated
{
    self.calendarHeightConstraint.constant = CGRectGetHeight(bounds);
    // Do other updates here
    [self.view layoutIfNeeded];
}
```

* For ***Manual Layout***

```objc
- (void)calendar:(FSCalendar *)calendar boundingRectWillChange:(CGRect)bounds animated:(BOOL)animated
{
    calendar.frame = (CGRect){calendar.frame.origin,bounds.size};
    // Do other updates here
}
```

* If you are using ***Masonry***

```objc
- (void)calendar:(FSCalendar *)calendar boundingRectWillChange:(CGRect)bounds animated:(BOOL)animated
{
    [calendar mas_updateConstraints:^(MASConstraintMaker *make) {
        make.height.equalTo(@(bounds.size.height));
        // Do other updates
    }];
    [self.view layoutIfNeeded];
}
```

* If you are using ***SnapKit***

```swift
func calendar(_ calendar: FSCalendar, boundingRectWillChange bounds: CGRect, animated: Bool) {
    calendar.snp.updateConstraints { (make) in
        make.height.equalTo(bounds.height)
        // Do other updates
    }
    self.view.layoutIfNeeded()
}
```

### <a id="roll_with_interface_builder"></a> Roll with Interface Builder
![fscalendar - ibdesignable](https://cloud.githubusercontent.com/assets/5186464/9301716/2e76a2ca-4503-11e5-8450-1fa7aa93e9fd.gif)

# <a id="pre-knowledge"></a>Pre-knowledge

> In `Swift3`, `NSDate` and `NSDateFormatter` have been renamed to ***Date*** and ***DateFormatter*** , see `Example-Swift` for details.

## How to create NSDate object

* By **NSCalendar**.

```objc
self.gregorian = [NSCalendar calendarWithIdentifier:NSCalendarIdentifierGregorian];
```

Then:

```objc
NSDate *date = [gregorian dateWithEra:1 year:2016 month:9 day:10 hour:0 minute:0 second:0 nanosecond:0];
// 2016-09-10 00:00:00
```


* Or by **NSDateFormatter**

```objc
self.formatter = [[NSDateFormatter alloc] init];
self.formatter.dateFormat = @"yyyy-MM-dd";
```

Then:

```objc
NSDate *date = [self.formatter dateFromString:@"2016-09-10"];
```

## How to print out NSDate object

* Use **NSDateFormatter**

```objc
self.formatter = [[NSDateFormatter alloc] init];
self.formatter.dateFormat = @"yyyy/MM/dd";
```

```objc
NSString *string = [self.formatter stringFromDate:date];
NSLog(@"Date is %@", string);
```

## How to manipulate NSDate with NSCalendar

```objc
self.gregorian = [NSCalendar calendarWithIdentifier:NSCalendarIdentifierGregorian];
```
* Get component of NSDate

```objc
NSInteger era = [self.gregorian component:NSCalendarUnitEra fromDate:date];
NSInteger year = [self.gregorian component:NSCalendarUnitYear fromDate:date];
NSInteger month = [self.gregorian component:NSCalendarUnitMonth fromDate:date];
NSInteger day = [self.gregorian component:NSCalendarUnitDay fromDate:date];
NSInteger hour = [self.gregorian component:NSCalendarUnitHour fromDate:date];
NSInteger minute = [self.gregorian component:NSCalendarUnitMinute fromDate:date];
...

```

* Get next **month**

```objc
NSDate *nextMonth = [self.gregorain dateByAddingUnit:NSCalendarUnitMonth value:1 toDate:date options:0];
```

* Get next **day**

```objc
NSDate *nextDay = [self.gregorain dateByAddingUnit:NSCalendarUnitDay value:1 toDate:date options:0];
```

* Is date in today/tomorrow/yesterday/weekend

```objc
BOOL isToday = [self.gregorian isDateInToday:date];
BOOL isYesterday = [self.gregorian isDateInYesterday:date];
BOOL isTomorrow = [self.gregorian isDateInTomorrow:date];
BOOL isWeekend = [self.gregorian isDateInWeekend:date];
```

* Compare two dates

```objc

BOOL sameDay = [self.gregorian isDate:date1 inSameDayAsDate:date2];
// Yes if the date1 and date2 are in same day


[self.gregorian compareDate:date1 toDate:date2 toUnitGranularity:unit];
// compare the era/year/month/day/hour/minute .etc ...
// return NSOrderAscending/NSOrderSame/NSOrderDecending

BOOL inSameUnit = [self.gregorian isDate:date1 equalToDate:date2 toUnitGranularity:unit];
// if the given unit (era/year/month/day/hour/minute .etc) are the same


```


## <a id="support"></a>Support this repo
* [**★Star**](#) this repo 
<br/>
* Support with &nbsp; <a href="https://www.paypal.me/WenchaoD" target="_blank"><img src="https://www.paypalobjects.com/webstatic/i/logo/rebrand/ppcom.svg" width="100" height="40" style="margin-bottom:-15px;"></a>
<br/>
* Support with <a href="https://user-images.githubusercontent.com/5186464/45949944-46960480-c030-11e8-9e90-30b015698cf6.png" target="_blank"><img src="http://a1.mzstatic.com/us/r30/Purple49/v4/50/16/b3/5016b341-39c1-b47b-2994-d7e23823baed/icon175x175.png" width="40" height="40" style="margin-bottom:-15px;-webkit-border-radius:10px;border:1px solid rgba(30, 154, 236, 1);"></a> or
<a href="https://cloud.githubusercontent.com/assets/5186464/15096872/b06f3a3a-153c-11e6-89f9-2e9c7b88ef42.png" target="_blank"><img src="http://a4.mzstatic.com/us/r30/Purple49/v4/23/31/14/233114f8-2e8d-7b63-8dc5-85d29893061e/icon175x175.jpeg" height="40" width="40" style="margin-bottom:-15px; -webkit-border-radius: 10px;border:1px solid rgba(43, 177, 0, 1)"></a>


<br/>


## <a id='contact'/></a> Contact
* 微博： [**@WenchaoD**](http://weibo.com/WenchaoD)
* Twitter：[**@WenchaoD**](https://twitter.com/WenchaoD)
* <a id='qq_group'/></a>QQ支持群: <br><br>
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
![fscalendar](https://cloud.githubusercontent.com/assets/5186464/18407011/8e4b6e48-7738-11e6-9fad-0e23cc881516.JPG)

> If your made a beautiful calendar with this library in your app, please take a screen shot and [@me](https://twitter.com/WenchaoD) in twitter. Your help really means a lot to me! <br/>


# License
FSCalendar is available under the MIT license. See the LICENSE file for more info.

### [Documentation](http://cocoadocs.org/docsets/FSCalendar/) | [More Usage](https://github.com/WenchaoD/FSCalendar/blob/master/MOREUSAGE.md) | [简书](http://www.jianshu.com/notebooks/4276521/latest)
