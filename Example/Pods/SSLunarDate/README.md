SSLunarDate
===========

SSLunarDate

This is an iOS Chinese Lunar date framework, which can convert the NSDate to a Lunar date which widely used in China.
The code is licensed by GPL2, even I perfer some other license, 
but because the core of this algorithm is licensed by GPL, so I don't have another option.

Talking about the usage of this lib, you can refer the SSLunarDate.h for detail, I can give a small example Here.

    SSLunarDate *lunar = [[SSLunarDate alloc] init];
    NSLog(@"month:%@ day:%@", [lunar monthString], [lunar dayString]);
    NSLog(@"full string:%@ %@", [lunar string], [lunar zodiacString]);
    
You can get this:

    month:正月 day:廿九
    full string:癸巳年正月廿九 蛇

For the other part of this lib, please refer SSLunarDate.h.
It can now convert 1900-2049 's lunar calendar.

I'm also working on adding a Holiday checking function too, to check lunar holiday and normal calendar holiday.
