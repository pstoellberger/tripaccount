//
//  ReceiverWeightNotManaged.m
//  Reiseabrechnung
//
//  Created by Martin Maier on 04/12/2011.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "ReceiverWeightNotManaged.h"

@implementation ReceiverWeightNotManaged

@synthesize weight=_weight, participant=_participant, entry=_entry, active=_active;

- (id)init {
    self = [super init];
    if (self) {
        self.weight = [NSNumber numberWithDouble:1.0];
        self.active = YES;
    }
    return self;
}

- (id)initWithParticiant:(Participant *)participant andWeight:(NSNumber *)weight {
    self = [self init];
    if (self) {
        self.participant = participant;
        self.weight = weight;
    }
    return self;
}

- (void)dealloc {
    [_weight release];
    [_participant release];
    [_entry release];
    [super dealloc];
}

@end
