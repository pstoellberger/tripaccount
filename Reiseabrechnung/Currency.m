//
//  Currency.m
//  Reiseabrechnung
//
//  Created by Martin Maier on 8/4/11.
//  Copyright (c) 2011 Martin Maier. All rights reserved.
//

#import "Currency.h"
#import "AppDefaults.h"
#import "Country.h"
#import "Entry.h"
#import "ExchangeRate.h"
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
@dynamic entries;
@dynamic lastUsedInTravel;

@end
