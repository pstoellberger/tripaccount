//
//  Currency.m
//  Reiseabrechnung
//
//  Created by Martin Maier on 01/08/2011.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
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
@dynamic defaults;
@dynamic ratesWithBaseCurrency;
@dynamic travels;
@dynamic rate;
@dynamic entries;

@end
