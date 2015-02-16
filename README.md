# FSCalendar

## Features
### 1. Easy Appearance
![appearance](https://cloud.githubusercontent.com/assets/5186464/6208969/20ee842a-b5fb-11e4-8875-132d42893b9e.png)

### 2. Subtitle
![subtitle1](https://cloud.githubusercontent.com/assets/5186464/6209081/54d8a4cc-b5fc-11e4-981e-d4bb21a45628.png)

## Usage

To run the example project, clone the repo, and run `pod install` from the Example directory first.

### 1. Simple DataSource/Delegate Pattern
    _calendar.dataSource = self; // IBOutlet supported
    _calendar.delegate = self; // IBOutlet supported
    
### 2. Page Direction Supported
    _calendar.flow = FSCalendarFlowVertical; //Change to vertical flow, default is FSCalendarFlowHorizontal
    
### 3. Flexible Appearance Customization
    [[FSCalendar appearance] setTodayColor: [UIColor redColor]]; //Change today circle/rectangle fill color
    
    Look into FSCalendar.h to see more
    
### 4. Header
    FSCalendarHeader *header = [[FSCalendarHeader alloc]    initWithFrame:CGRectMake(0,0,_calendar.frame.size.width,_calendar.frame.size.height)]; // IBOutlet supported too

## Requirements
ios 7.0

## Installation

FSCalendar is available through [CocoaPods](http://cocoapods.org). To install
it, simply add the following line to your Podfile:

    pod "FSCalendar"

## Author

Wenchao Ding, f33chobits@gmail.com

## License

FSCalendar is available under the MIT license. See the LICENSE file for more info.

