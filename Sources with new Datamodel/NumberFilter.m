//
//  NumberFilter.m
//  Reiseabrechnung
//
//  Created by Martin Maier on 25/08/2011.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "NumberFilter.h"
#import "UIFactory.h"

@implementation NumberFilter

- (NSArray *)filters {
    return [NSArray arrayWithObject:@"decimalNumber"];
}

- (NSObject *)filterInvoked:(NSString *)filter withArguments:(NSArray *)args onValue:(NSObject *)value {
    
    if ([value isKindOfClass:[NSNumber class]]) {
        return [UIFactory formatNumber:(NSNumber *)value];
    } else {
        return value;
    }
}

@end
