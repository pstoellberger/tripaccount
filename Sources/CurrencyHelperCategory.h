//
//  CurrencyHelper.h
//  Reiseabrechnung
//
//  Created by Martin Maier on 01/08/2011.
//  Copyright 2011 Martin Maier. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Currency.h"

@interface Currency (CurrencyHelper)

- (double)convertTravelAmount:(Travel *)travel currency:(Currency *)currency amount:(double)amount;
- (NSArray *)allBaseCurrencies;
- (ExchangeRate *)defaultRate;
- (ExchangeRate *)rateWithTravel:(Travel *)targetTravel;

@end
