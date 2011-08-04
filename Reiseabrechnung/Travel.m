//
//  Travel.m
//  Reiseabrechnung
//
//  Created by Martin Maier on 8/4/11.
//  Copyright (c) 2011 Martin Maier. All rights reserved.
//

#import "Travel.h"
#import "Country.h"
#import "Currency.h"
#import "Entry.h"
#import "ExchangeRate.h"
#import "Participant.h"
#import "Transfer.h"


@implementation Travel
@dynamic name;
@dynamic closed;
@dynamic notes;
@dynamic city;
@dynamic created;
@dynamic selectedRow;
@dynamic selectedTab;
@dynamic rates;
@dynamic participants;
@dynamic transfers;
@dynamic entries;
@dynamic lastParticipantUsed;
@dynamic transferBaseCurrency;
@dynamic country;
@dynamic currencies;
@dynamic lastCurrencyUsed;

@end
