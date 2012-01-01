//
//  TransferCycle.m
//  Reiseabrechnung
//
//  Created by Martin Maier on 12/12/2011.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "TransferCycle.h"


@implementation TransferCycle

@synthesize participantKeys, minWeight;

- (id)init {
    self = [super init];
    if (self) {
        self.participantKeys = [NSMutableArray arrayWithCapacity:5];
        self.minWeight = [NSNumber numberWithInt:INT_MAX];
    }
    return self;
}


- (id)mutableCopyWithZone:(NSZone *)zone {
    TransferCycle *newCycle = [[TransferCycle allocWithZone:zone] init];
    newCycle.minWeight = self.minWeight;
    newCycle.participantKeys = [NSMutableArray arrayWithArray:self.participantKeys];
    return newCycle;
}

- (void)dealloc {
    [participantKeys release];
    [minWeight release];
    [super dealloc];
}

@end
