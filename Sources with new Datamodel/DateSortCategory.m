//
//  DateSortCategory.m
//  Reiseabrechnung
//
//  Created by Martin Maier on 29/07/2011.
//  Copyright 2011 Martin Maier. All rights reserved.
//

#import "DateSortCategory.h"
#import "UIFactory.h"

@implementation Entry (DateWithOutTime)

- (NSDate *)dateWithOutTime {
    
    [self willAccessValueForKey:@"dateWithOutTime"];
    NSDate *date = [self valueForKey:@"date"];
    [self didAccessValueForKey:@"dateWithOutTime"];
    
    return [UIFactory createDateWithoutTimeFromDate:date];    
}

@end