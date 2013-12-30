//
//  EntryNotManaged.m
//  Reiseabrechnung
//
//  Created by Martin Maier on 01/07/2011.
//  Copyright 2011 Martin Maier. All rights reserved.
//

#import "EntryNotManaged.h"
#import "Entry.h"
#import "ReceiverWeightNotManaged.h"
#import "ReceiverWeight.h"


@implementation EntryNotManaged

@synthesize amount;
@synthesize checked;
@synthesize date;
@synthesize text;
@synthesize travel;
@synthesize type;
@synthesize payer;
@synthesize notes;
@synthesize receiverWeights;
@synthesize currency;


- (id)init {
    self = [super init];
    if (self) {
        self.text = nil;
        self.currency = nil;
        self.date = [NSDate date];
        self.payer = nil;
        self.amount = 0;
        self.travel = nil;
        self.receiverWeights = [NSMutableSet set];
        self.type = nil;
        self.notes = nil;
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
        self.receiverWeights = [NSMutableSet set];
        self.travel = entry.travel;
        self.type = entry.type;
        self.notes = entry.notes;
    }
    return self;
}

- (NSArray *)sortedReceivers {
    
    NSArray *allSortDescriptor = [NSArray arrayWithObject:[[[NSSortDescriptor alloc] initWithKey:@"name" ascending:YES] autorelease]];
    NSMutableArray *receivers = [NSMutableArray arrayWithCapacity:[self.receiverWeights count]];
    for (ReceiverWeightNotManaged *recWeight in self.receiverWeights) {
        [receivers addObject:recWeight.participant];
    }
    return [receivers sortedArrayUsingDescriptors:allSortDescriptor];

}

- (NSArray *)activeReceiverWeights {
    
    NSMutableArray *activeReceiverWeights = [NSMutableArray arrayWithCapacity:[self.receiverWeights count]];
    for (ReceiverWeightNotManaged *recWeight in self.receiverWeights) {
        if (recWeight.active) {
            [activeReceiverWeights addObject:recWeight];
        }
    }
    return activeReceiverWeights;
}

- (BOOL)receiverWeightsDifferFromDefault {
    
    for (ReceiverWeight *recWeight in self.receiverWeights) {
        if (![recWeight.weight isEqualToNumber:recWeight.participant.weight]) {
            return YES;
        }
    }
    return NO;
    
}

- (void)dealloc {
    [amount release];
    [checked release];
    [date release];
    [text release];
    [travel release];
    [type release];
    [notes release];
    [payer release];
    [receiverWeights release];
    [currency release];
    [super dealloc];
}
@end
