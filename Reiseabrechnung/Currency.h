//
//  Currency.h
//  Reiseabrechnung
//
//  Created by Martin Maier on 25/08/2011.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class AppDefaults, Country, Entry, ExchangeRate, Transfer, Travel;

@interface Currency : NSManagedObject {
@private
}
@property (nonatomic, retain) NSNumber * digits;
@property (nonatomic, retain) NSString * code;
@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) NSSet *countries;
@property (nonatomic, retain) NSSet *rates;
@property (nonatomic, retain) AppDefaults *defaults;
@property (nonatomic, retain) NSSet *ratesWithBaseCurrency;
@property (nonatomic, retain) NSSet *transfersWithBaseCurrency;
@property (nonatomic, retain) NSSet *travels;
@property (nonatomic, retain) NSSet *lastUsedInTravel;
@property (nonatomic, retain) NSSet *entries;
@property (nonatomic, retain) NSSet *displayedInTravel;
@property (nonatomic, retain) NSSet *transfers;
@end

@interface Currency (CoreDataGeneratedAccessors)

- (void)addCountriesObject:(Country *)value;
- (void)removeCountriesObject:(Country *)value;
- (void)addCountries:(NSSet *)values;
- (void)removeCountries:(NSSet *)values;

- (void)addRatesObject:(ExchangeRate *)value;
- (void)removeRatesObject:(ExchangeRate *)value;
- (void)addRates:(NSSet *)values;
- (void)removeRates:(NSSet *)values;

- (void)addRatesWithBaseCurrencyObject:(ExchangeRate *)value;
- (void)removeRatesWithBaseCurrencyObject:(ExchangeRate *)value;
- (void)addRatesWithBaseCurrency:(NSSet *)values;
- (void)removeRatesWithBaseCurrency:(NSSet *)values;

- (void)addTransfersWithBaseCurrencyObject:(Travel *)value;
- (void)removeTransfersWithBaseCurrencyObject:(Travel *)value;
- (void)addTransfersWithBaseCurrency:(NSSet *)values;
- (void)removeTransfersWithBaseCurrency:(NSSet *)values;

- (void)addTravelsObject:(Travel *)value;
- (void)removeTravelsObject:(Travel *)value;
- (void)addTravels:(NSSet *)values;
- (void)removeTravels:(NSSet *)values;

- (void)addLastUsedInTravelObject:(Travel *)value;
- (void)removeLastUsedInTravelObject:(Travel *)value;
- (void)addLastUsedInTravel:(NSSet *)values;
- (void)removeLastUsedInTravel:(NSSet *)values;

- (void)addEntriesObject:(Entry *)value;
- (void)removeEntriesObject:(Entry *)value;
- (void)addEntries:(NSSet *)values;
- (void)removeEntries:(NSSet *)values;

- (void)addDisplayedInTravelObject:(Travel *)value;
- (void)removeDisplayedInTravelObject:(Travel *)value;
- (void)addDisplayedInTravel:(NSSet *)values;
- (void)removeDisplayedInTravel:(NSSet *)values;

- (void)addTransfersObject:(Transfer *)value;
- (void)removeTransfersObject:(Transfer *)value;
- (void)addTransfers:(NSSet *)values;
- (void)removeTransfers:(NSSet *)values;

@end
