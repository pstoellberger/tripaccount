//
//  Travel.m
//  Reiseabrechnung
//
//  Created by Martin Maier on 01/11/2011.
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

@dynamic closedDate;
@dynamic selectedTab;
@dynamic name;
@dynamic closed;
@dynamic displaySort;
@dynamic notes;
@dynamic city;
@dynamic created;
@dynamic selectedRow;
@dynamic lastCurrencyUsed;
@dynamic rates;
@dynamic participants;
@dynamic transfers;
@dynamic entries;
@dynamic currencies;
@dynamic lastParticipantUsed;
@dynamic displayCurrency;
@dynamic country;
@dynamic transferBaseCurrency;

@end
