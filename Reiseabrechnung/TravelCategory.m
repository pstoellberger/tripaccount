//
//  TravelCategory.m
//  Reiseabrechnung
//
//  Created by Martin Maier on 10/08/2011.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "TravelCategory.h"
#import "Entry.h"
#import "ExchangeRate.h"
#import "Currency.h"
#import "CurrencyHelperCategory.h"
#import "Country.h"

@implementation Travel (OpenClose)

- (void)open:(BOOL)useLatestRates {
    
    NSLog(@"Opening travel with name %@ and country %@", self.name, self.country.name);
    
    self.closed = [NSNumber numberWithInt:0];
    
    if (useLatestRates) {
        
        NSLog(@"... by using latest exchange rates");
        
        [self removeRates:self.rates];
        
        for (Currency *currency in self.currencies) {
            [self addRatesObject:currency.defaultRate];
        }  
    }
    
}

- (void)close {
    
    NSLog(@"Closing travel with name %@ and country %@", self.name, self.country.name);
    
    self.closed = [NSNumber numberWithInt:1];
    
    for (Entry *entry in self.entries) {
        entry.checked = [NSNumber numberWithInt:0];
    }
    
    // copying exchange rates (=freeze)
    NSMutableSet *addRates = [NSMutableSet set];
    for (ExchangeRate *rate in self.rates) {
        ExchangeRate *newRate = [NSEntityDescription insertNewObjectForEntityForName: @"ExchangeRate" inManagedObjectContext: [self managedObjectContext]];
        newRate.rate = rate.rate;
        newRate.baseCurrency = rate.baseCurrency;
        newRate.counterCurrency = rate.counterCurrency;
        newRate.edited = rate.edited;
        newRate.defaultRate = NO;
        newRate.lastUpdated = rate.lastUpdated;
        [addRates addObject:newRate];
    }
    [self removeRates:self.rates];
    [self addRates:addRates];
    
}

@end