//
//  Travel.m
//  Reiseabrechnung
//
//  Created by Martin Maier on 29/06/2011.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "Travel.h"

@implementation Travel

@synthesize name, created, currency, participants, entries;

- (id)init {
    self = [super init];
    if (self) {
        participants = [[NSMutableArray alloc] init];
        entries = [[NSMutableArray alloc] init];
    }
    return self;
}

@end
