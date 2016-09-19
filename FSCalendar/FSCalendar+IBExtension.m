//
//  FSCalendar+IBExtension.m
//  FSCalendar
//
//  Created by Wenchao Ding on 8/14/15.
//  Copyright © 2016 Wenchao Ding. All rights reserved.
//

#import "FSCalendar+IBExtension.h"

@implementation FSCalendar (IBExtension)

- (void)setValue:(id)value forUndefinedKey:(NSString *)key
{
#if !TARGET_INTERFACE_BUILDER
    if ([key hasPrefix:@"fake"]) {
        return;
    }
#endif
    if (key.length) {
        NSString *setter = [NSString stringWithFormat:@"set%@%@:",[key substringToIndex:1].uppercaseString,[key substringFromIndex:1]];
        if ([self.appearance respondsToSelector:NSSelectorFromString(setter)]) {
            return [self.appearance setValue:value forKey:key];
        }
    }
    return [super setValue:value forUndefinedKey:key];
    
}

@end

