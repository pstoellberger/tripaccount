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
#import "ReiseabrechnungAppDelegate.h"

@implementation Travel (OpenClose)

- (void)open:(BOOL)useLatestRates {
    
    NSLog(@"Opening travel with name %@ and country %@", self.name, self.country.nameI18N);
    
    self.closed = [NSNumber numberWithInt:0];
    self.closedDate = nil;
    
    if (useLatestRates) {
        
        NSLog(@"... by using latest exchange rates");
        
        [self removeRates:self.rates];
        
        for (Currency *currency in self.currencies) {
            [self addRatesObject:currency.defaultRate];
        }  
    }
    
}

- (void)close {
    
    NSLog(@"Closing travel with name %@ and country %@", self.name, self.country.nameI18N);
    
    self.closed = [NSNumber numberWithInt:1];
    
    for (Entry *entry in self.entries) {
        entry.checked = [NSNumber numberWithInt:0];
    }
    
    self.closedDate = [NSDate date];
    
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

- (NSArray *)sortedEntries {
    
    NSSortDescriptor *sortNameDescriptor = nil;
    if ([self.displaySort isEqual:[NSNumber numberWithInt:0]]) {
        sortNameDescriptor = [[[NSSortDescriptor alloc] initWithKey:@"payer.name" ascending:YES] autorelease];
    } else if ([self.displaySort isEqual:[NSNumber numberWithInt:1]]) {
        sortNameDescriptor = [[[NSSortDescriptor alloc] initWithKey:[NSString stringWithFormat:@"type.%@", [Type sortAttributeI18N]] ascending:YES] autorelease];
    } else if ([self.displaySort isEqual:[NSNumber numberWithInt:2]]) {
        sortNameDescriptor = [[[NSSortDescriptor alloc] initWithKey:@"dateWithOutTime" ascending:YES] autorelease];
    }
    
    NSArray *allSortDescriptors = [NSArray arrayWithObjects:sortNameDescriptor, [[[NSSortDescriptor alloc] initWithKey:@"dateWithOutTime" ascending:YES] autorelease], nil];
    
    return [[self.entries allObjects] sortedArrayUsingDescriptors:allSortDescriptors];
}

- (NSArray *)sortedCurrencies {
    
    return [Currency sortCurrencies:[self.currencies allObjects] inManagedObjectContext:[self managedObjectContext]];
}

- (NSArray *)sortedTransfers {
    
    NSArray *allSortDescriptors = [NSArray arrayWithObjects:[[[NSSortDescriptor alloc] initWithKey:@"debtor.name" ascending:YES] autorelease], [[[NSSortDescriptor alloc] initWithKey:@"debtee.name" ascending:YES] autorelease], nil];
    
    return [[self.transfers allObjects] sortedArrayUsingDescriptors:allSortDescriptors];
}

- (NSString *)location {
    
    if (self.city != nil && [self.city length] > 0) {
        return [NSString stringWithFormat:@"%@, %@", self.city, self.country.nameI18N];
    } else {
        return self.country.nameI18N;
    }
}

- (NSString *)totalCostLabel {
    
    double totalCosts = 0;
    for (Entry *entry in self.entries) {
        totalCosts = totalCosts + [entry.currency convertTravelAmount:self currency:self.displayCurrency amount:[entry.amount doubleValue]];
    }
    return [NSString stringWithFormat:@"%@ %@", [UIFactory formatNumber:[NSNumber numberWithDouble:totalCosts]], self.displayCurrency.code];
    
}

- (BOOL)isWeightInUse {
    for (Participant *p in self.participants) {
        if ([p.weight doubleValue] != 1.0) {
            return YES;
        }
    }
    return NO;
}

- (NSNumber *)totalWeight {
    double totalWeight = 0;
    for (Participant *p in self.participants) {
        totalWeight += [p.weight doubleValue];
    }
    return [NSNumber numberWithDouble:totalWeight];
}

@end