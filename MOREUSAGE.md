# More usage

### If you want `FSCalendar` to scroll vertically

* Objective - c

```objective-c
_calendar.scrollDirection = FSCalendarScrollDirectionVertical;
```

* Swift

```swift
calendar.scrollDirection = .vertical 
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

## Focus on selected date on ***week mode***
![fscalendar-scope](https://cloud.githubusercontent.com/assets/5186464/12474251/aec94a32-c054-11e5-8b30-9e3d03d9a846.gif)

* There are cases such as `Changing Scope`、`Changing month while showsPlaceholders is false` will trigger a bounds changing of FSCalendar, make sure the frame is adjusted in `-calendar:boundingRectWillChange:animated:`

```objc
// For autoLayout
- (void)calendar:(FSCalendar *)calendar boundingRectWillChange:(CGRect)bounds animated:(BOOL)animated
{
    _calendarHeightConstraint.constant = CGRectGetHeight(bounds);
    [self.view layoutIfNeeded];
}
```

```objc
// For manual layout
- (void)calendar:(FSCalendar *)calendar boundingRectWillChange:(CGRect)bounds animated:(BOOL)animated
{
    calendar.frame = (CGRect){calendar.frame.origin,bounds.size};
}
```

### For week mode

* Objective-C

```objective-c
_calendar.scope = FSCalendarScopeWeek;
```

* Swift

```swift
calendar.scope = .week 
```

### For month mode

* Objective - c

```objective-c
_calendar.scope = FSCalendarScopeMonth; // By default
```

* Swift

```swift
calendar.scope = .month 
```

![fscalendar-scope](https://cloud.githubusercontent.com/assets/5186464/12474251/aec94a32-c054-11e5-8b30-9e3d03d9a846.gif)

### To select more than one date

* Objective-C 

```objective-c
calendar.allowsMultipleSelection = YES;
```

* Swift

```swift
calendar.allowsMultipleSelection = true;
```


![fscalendar-mulipleselection](https://cloud.githubusercontent.com/assets/5186464/9751497/368f55f6-56d8-11e5-9af5-0d09ba13f0eb.png)

### If you want `FSCalendar` to use `Monday` as the first column (or any other weekday)

* Objective-C 

```objective-c
_calendar.firstWeekday = 2; 
```

* Swift

```swift
calendar.firstWeekday = 2
```

![fscalendar---monday](https://cloud.githubusercontent.com/assets/5186464/8448782/c92505e4-1ffd-11e5-95c0-9bf3c8bec669.png)


### The date format of header can be customized

* Objective-C 

```objective-c
calendar.appearance.headerDateFormat = @"MMM yy";
```

* Swift

```swift
calendar.appearance.headerDateFormat = "MMM yy"
```

![fscalendar---headerformat](https://cloud.githubusercontent.com/assets/5186464/8449322/15d79168-2003-11e5-997a-06c6721dd807.png)

### You can define the appearance

* Objective-c

```objective-c
_calendar.appearance.weekdayTextColor = [UIColor redColor];
_calendar.appearance.headerTitleColor = [UIColor redColor];
_calendar.appearance.eventColor = [UIColor greenColor];
_calendar.appearance.selectionColor = [UIColor blueColor];
_calendar.appearance.todayColor = [UIColor orangeColor];
_calendar.appearance.todaySelectionColor = [UIColor blackColor];
```

* Swift

```objective-c
calendar.appearance.weekdayTextColor = UIColor.redColor
calendar.appearance.headerTitleColor = UIColor.redColor
calendar.appearance.eventColor = UIColor.greenColor
calendar.appearance.selectionColor = UIColor.blueColor
calendar.appearance.todayColor = UIColor.orangeColor
calendar.appearance.todaySelectionColor = UIColor.blackColor
```


![fscalendar---colors](https://cloud.githubusercontent.com/assets/5186464/8449300/d55d1c7a-2002-11e5-8de6-be04f3783456.png)

### The day shape doesn't have to be a circle

* Objective-C

```objective-c
calendar.appearance.borderRadius = 0
```

* Swift

```swift
calendar.appearance.borderRadius = 0
```

![fscalendar---rectangle](https://cloud.githubusercontent.com/assets/5186464/8449186/d38ea39c-2001-11e5-99f4-32fcd6120a01.png)

### `FSCalendar` can show subtitle for each day

* Objective-C

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
func calendar(_ calendar: FSCalendar!, subtitleFor date: NSDate!) -> String! {
    return yourSubtitle
}
```

![fscalendar---subtitle2](https://cloud.githubusercontent.com/assets/5186464/8449075/b0bb34ee-2000-11e5-9c4a-401bc708d9ea.png)
<br/>
![fscalendar---subtitle1](https://cloud.githubusercontent.com/assets/5186464/8449076/b0be3d88-2000-11e5-9c5d-22ecd325b6cc.png)

### And event dot for some days

* Objective-C

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
func calendar(_ calendar: FSCalendar!, imageFor date: NSDate!) -> UIImage! {
    return anyImage
}
```

![fscalendar---image](https://cloud.githubusercontent.com/assets/5186464/8449772/e94d3126-2006-11e5-8871-e4f8dbce81ea.png)

#### You can hide top and bottom borders

* Objective-C

```objective-c
calendar.clipsToBounds = YES
```

* Swift

```swift
calendar.clipsToBounds = true
```

![fscalendar---image](https://cloud.githubusercontent.com/assets/403372/13673426/3c207c16-e6d9-11e5-9c2a-111c4c15582f.png)

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
 

### You will get notified when `FSCalendar` changes the month or week

* Objective-C

```objective-c
- (void)calendarCurrentMonthDidChange:(FSCalendar *)calendar
{
    // Do something
}
```

* Swift

```swift
func calendarCurrentMonthDidChange(_ calendar: FSCalendar!) {
    // Do something
}
```

* `fakeSubtitles` and `fakedSelectedDay` is only used for preview in Interface Builder


## Q & A

### Q:&nbsp;&nbsp;What if I don't need the `today` circle?
Just nill-out the `today` property like:

```objc
self.calendar.today = nil;
```

### Q:&nbsp;&nbsp;Can we hide this?
![fscalendar---headeralpha](https://cloud.githubusercontent.com/assets/5186464/8450978/217855ca-2012-11e5-8b97-a9b45ece4e71.png)

```objc
self.calendar.appearance.headerMinimumDissolvedAlpha = 0.0;
```

### Q:&nbsp;&nbsp;Can we refresh the calendar after a network request?
Yes. Like UITableView or UICollectionView, there is also `reloadData` in `FSCalendar`;

```objc
[self.calendar reloadData];
```
