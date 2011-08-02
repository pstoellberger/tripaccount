//
//  Currency.h
//  Reiseabrechnung
//
//  Created by Martin Maier on 02/08/2011.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class AppDefaults, Country, Entry, ExchangeRate, Travel;

@interface Currency : NSManagedObject {
@private
}
@property (nonatomic, retain) NSNumber * digits;
@property (nonatomic, retain) NSString * code;
@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) NSSet *countries;
@property (nonatomic, retain) ExchangeRate *rate;
@property (nonatomic, retain) AppDefaults *defaults;
@property (nonatomic, retain) NSSet *ratesWithBaseCurrency;
@property (nonatomic, retain) NSSet *travels;
@property (nonatomic, retain) NSSet *entries;
@property (nonatomic, retain) NSSet *transfersWithBaseCurrency;
@end

@interface Currency (CoreDataGeneratedAccessors)

- (void)addCountriesObject:(Country *)value;
- (void)removeCountriesObject:(Country *)value;
- (void)addCountries:(NSSet *)values;
- (void)removeCountries:(NSSet *)values;

- (void)addRatesWithBaseCurrencyObject:(ExchangeRate *)value;
- (void)removeRatesWithBaseCurrencyObject:(ExchangeRate *)value;
- (void)addRatesWithBaseCurrency:(NSSet *)values;
- (void)removeRatesWithBaseCurrency:(NSSet *)values;

- (void)addTravelsObject:(Travel *)value;
- (void)removeTravelsObject:(Travel *)value;
- (void)addTravels:(NSSet *)values;
- (void)removeTravels:(NSSet *)values;

- (void)addEntriesObject:(Entry *)value;
- (void)removeEntriesObject:(Entry *)value;
- (void)addEntries:(NSSet *)values;
- (void)removeEntries:(NSSet *)values;

- (void)addTransfersWithBaseCurrencyObject:(Travel *)value;
- (void)removeTransfersWithBaseCurrencyObject:(Travel *)value;
- (void)addTransfersWithBaseCurrency:(NSSet *)values;
- (void)removeTransfersWithBaseCurrency:(NSSet *)values;

@end
