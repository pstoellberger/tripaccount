//
//  CurrencyHelper.m
//  Reiseabrechnung
//
//  Created by Martin Maier on 01/08/2011.
//  Copyright 2011 Martin Maier. All rights reserved.
//

#import "CurrencyHelperCategory.h"
#import "ExchangeRate.h"
#import "Travel.h"

@implementation Currency (CurrencyHelper)

- (double)convertTravelAmount:(Travel *)travel currency:(Currency *)currency amount:(double)amount {
    
    NSLog(@"converting %@ to %@", self.name, currency.name);
    
    if ([self isEqual:currency]) {
        return amount;
    }
    
    double returnValue = amount;
    
    ExchangeRate *rateSelf = [self rateWithTravel:travel];
    ExchangeRate *rateCurrency = [currency rateWithTravel:travel];
    
    if ([rateSelf.counterCurrency isEqual:currency]) {
        
        returnValue = returnValue * [rateSelf.rate doubleValue];
        
    } else if ([rateSelf.baseCurrency isEqual:currency]) {
        
        returnValue = returnValue / [rateSelf.rate doubleValue];
        
    } else if ([rateCurrency.counterCurrency isEqual:self]) {
        
        returnValue = returnValue / [rateCurrency.rate doubleValue];
        
    } else if ([rateCurrency.baseCurrency isEqual:self]) {
        
        returnValue = returnValue * [rateCurrency.rate doubleValue];
        
    } else {
        
        // no direct connection found -> convert to a base currency

        Currency *euro = [self rateWithTravel:travel].baseCurrency;
        double amountInEuro = [self convertTravelAmount:travel currency:euro amount:amount];
        returnValue = [euro convertTravelAmount:travel currency:currency amount:amountInEuro];
        
    }
    
    return returnValue;
}

- (ExchangeRate *)defaultRate {
    
    ExchangeRate *returnRate = nil;
    for (ExchangeRate *defaultRate in self.rates) {
        if ([defaultRate.defaultRate intValue] == 1) {
            returnRate = defaultRate;
            break;
        }
    }
    return returnRate;
}

- (ExchangeRate *)rateWithTravel:(Travel *)targetTravel {
    
    ExchangeRate *returnRate = nil;
    for (ExchangeRate *defaultRate in self.rates) {
        if ([defaultRate.travels containsObject:targetTravel]) {
            returnRate = defaultRate;
            break;
        }
    }
    return returnRate;    
}

- (ExchangeRate *)travelRate:(Travel *)travel {
    
    ExchangeRate *returnRate = nil;
    for (ExchangeRate *rate in travel.rates) {
        if ([rate.counterCurrency isEqual:self]) {
            returnRate = rate;
        }
    }
    if (!returnRate) {
        NSLog(@"ERROR currency %@ not registered with travel %@", self.name, travel.name);
    }
    return returnRate;
}

- (NSArray *)allBaseCurrencies {
        
    NSFetchRequest *req = [[NSFetchRequest alloc] init];
    req.entity = [NSEntityDescription entityForName:@"Currency" inManagedObjectContext: self.managedObjectContext];
    req.predicate = [NSPredicate predicateWithFormat:@"ratesWithBaseCurrency.@count > 0"];
    NSArray *allBaseCurrencies = [self.managedObjectContext executeFetchRequest:req error:nil];
    [req release];
    
    return allBaseCurrencies;
}

@end
