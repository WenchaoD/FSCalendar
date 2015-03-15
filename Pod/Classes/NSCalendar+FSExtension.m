//
//  NSCalendar+FSExtension.m
//  Pods
//
//  Created by Wenchao Ding on 12/3/15.
//
//

#import "NSCalendar+FSExtension.h"

@implementation NSCalendar (FSExtension)

+ (instancetype)fs_sharedCalendar
{
    static id instance;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [NSCalendar currentCalendar];
    });
    return instance;
}

@end
