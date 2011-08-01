//
//  CurrencyHelper.m
//  Reiseabrechnung
//
//  Created by Martin Maier on 01/08/2011.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "CurrencyHelperCategory.h"
#import "ExchangeRate.h"

@implementation Currency (CurrencyHelper)

- (double)convertToCurrency:(Currency *)currency amount:(double)amount {
    
    NSLog(@"converting %@ to %@", self.name, currency.name);
    
    if ([self isEqual:currency]) {
        return amount;
    }
    
    double returnValue = amount;
    
    ExchangeRate *rateSelf = [self rate];
    ExchangeRate *rateCurrency = [currency rate];
    
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

        Currency *euro = self.rate.baseCurrency;
        double amountInEuro = [self convertToCurrency:euro amount:amount];
        returnValue = [euro convertToCurrency:currency amount:amountInEuro];
        
    }
    
    return returnValue;
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
