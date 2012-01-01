//
//  TravelNotManaged.m
//  Reiseabrechnung
//
//  Created by Martin Maier on 01/07/2011.
//  Copyright 2011 Martin Maier. All rights reserved.
//

#import "TravelNotManaged.h"


@implementation TravelNotManaged

@synthesize name;
@synthesize closed;
@synthesize notes;
@synthesize city;
@synthesize created;
@synthesize selectedRow;
@synthesize selectedTab;
@synthesize rates;
@synthesize participants;
@synthesize transfers;
@synthesize entries;
@synthesize lastParticipantUsed;
@synthesize transferBaseCurrency;
@synthesize country;
@synthesize currencies;
@synthesize lastCurrencyUsed;

- (void)dealloc {
    [name release];
    [notes release];
    [city release];
    [created release];
    [selectedRow release];
    [selectedTab release];
    [rates release];
    [participants release];
    [transfers release];
    [entries release];
    [lastParticipantUsed release];
    [transferBaseCurrency release];
    [country release];
    [currencies release];
    [lastCurrencyUsed release];
    [super dealloc];
}


@end
