//
//  FSCalendarDelegationFactory.h
//  FSCalendar
//
//  Created by dingwenchao on 19/12/2016.
//  Copyright © 2016 wenchaoios. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "FSCalendarDelegationProxy.h"

@interface FSCalendarDelegationFactory : NSObject

+ (FSCalendarDelegationProxy *)dataSourceProxy;
+ (FSCalendarDelegationProxy *)delegateProxy;

@end
