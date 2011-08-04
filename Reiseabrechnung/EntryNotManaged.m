//
//  EntryNotManaged.m
//  Reiseabrechnung
//
//  Created by Martin Maier on 01/07/2011.
//  Copyright 2011 Martin Maier. All rights reserved.
//

#import "EntryNotManaged.h"
#import "Entry.h"


@implementation EntryNotManaged

@synthesize text, currency, date, payer, amount, travel, receivers, type;

- (id)init {
    self = [super init];
    if (self) {
        self.text = nil;
        self.currency = nil;
        self.date = [NSDate date];
        self.payer = nil;
        self.amount = 0;
        self.travel = nil;
        self.receivers = [NSSet set];
        self.type = nil;
    }
    return self;
}

- (id)initWithEntry:(Entry *)entry {
    self = [super init];
    if (self) {
        self.text = entry.text;
        self.currency = entry.currency;
        self.date = entry.date;
        self.payer = entry.payer;
        self.amount = entry.amount;
        self.travel = entry.travel;
        self.receivers = entry.receivers;
        self.type = entry.type;
    }
    return self;
}

@end
