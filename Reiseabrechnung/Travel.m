//
//  Travel.m
//  Reiseabrechnung
//
//  Created by Martin Maier on 02/08/2011.
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
@dynamic closed;
@dynamic notes;
@dynamic city;
@dynamic created;
@dynamic selectedRow;
@dynamic selectedTab;
@dynamic name;
@dynamic participants;
@dynamic entries;
@dynamic currencies;
@dynamic lastParticipantUsed;
@dynamic country;
@dynamic transfers;
@dynamic transferBaseCurrency;
@dynamic rates;

@end
