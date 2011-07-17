//
//  EntryNotManaged.m
//  Reiseabrechnung
//
//  Created by Martin Maier on 01/07/2011.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "EntryNotManaged.h"


@implementation EntryNotManaged

@synthesize text, currency, date, payer, amount, travel, receivers;

- (id)init {
    self = [super init];
    if (self) {
        text = @"";
        currency = nil;
        date = [[NSDate date] retain];
        payer = nil;
        amount = 0;
        travel = nil;
        receivers = [[NSSet alloc] init];
    }
    return self;
}

@end
