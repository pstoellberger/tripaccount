//
//  Travel.m
//  Reiseabrechnung
//
//  Created by Martin Maier on 26/08/2011.
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
@dynamic selectedTab;
@dynamic name;
@dynamic closed;
@dynamic displaySort;
@dynamic notes;
@dynamic city;
@dynamic created;
@dynamic selectedRow;
@dynamic closedDate;
@dynamic lastCurrencyUsed;
@dynamic rates;
@dynamic participants;
@dynamic transfers;
@dynamic entries;
@dynamic currencies;
@dynamic transferBaseCurrency;
@dynamic displayCurrency;
@dynamic country;
@dynamic lastParticipantUsed;

@end
