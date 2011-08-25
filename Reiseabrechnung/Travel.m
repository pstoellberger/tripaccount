//
//  Travel.m
//  Reiseabrechnung
//
//  Created by Martin Maier on 25/08/2011.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
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
@dynamic displaySort;
@dynamic lastCurrencyUsed;
@dynamic rates;
@dynamic participants;
@dynamic transfers;
@dynamic entries;
@dynamic currencies;
@dynamic transferBaseCurrency;
@dynamic lastParticipantUsed;
@dynamic country;
@dynamic displayCurrency;

@end
