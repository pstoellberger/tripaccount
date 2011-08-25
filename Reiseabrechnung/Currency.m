//
//  Currency.m
//  Reiseabrechnung
//
//  Created by Martin Maier on 25/08/2011.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "Currency.h"
#import "AppDefaults.h"
#import "Country.h"
#import "Entry.h"
#import "ExchangeRate.h"
#import "Transfer.h"
#import "Travel.h"


@implementation Currency
@dynamic digits;
@dynamic code;
@dynamic name;
@dynamic countries;
@dynamic rates;
@dynamic defaults;
@dynamic ratesWithBaseCurrency;
@dynamic transfersWithBaseCurrency;
@dynamic travels;
@dynamic lastUsedInTravel;
@dynamic entries;
@dynamic displayedInTravel;
@dynamic transfers;

@end
