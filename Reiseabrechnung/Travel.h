//
//  Travel.h
//  Reiseabrechnung
//
//  Created by Martin Maier on 8/4/11.
//  Copyright (c) 2011 Martin Maier. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Country, Currency, Entry, ExchangeRate, Participant, Transfer;

@interface Travel : NSManagedObject {
@private
}
@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) NSNumber * closed;
@property (nonatomic, retain) NSString * notes;
@property (nonatomic, retain) NSString * city;
@property (nonatomic, retain) NSDate * created;
@property (nonatomic, retain) NSNumber * selectedRow;
@property (nonatomic, retain) NSNumber * selectedTab;
@property (nonatomic, retain) NSSet *rates;
@property (nonatomic, retain) NSSet *participants;
@property (nonatomic, retain) NSSet *transfers;
@property (nonatomic, retain) NSSet *entries;
@property (nonatomic, retain) Participant *lastParticipantUsed;
@property (nonatomic, retain) Currency *transferBaseCurrency;
@property (nonatomic, retain) Country *country;
@property (nonatomic, retain) NSSet *currencies;
@property (nonatomic, retain) Currency *lastCurrencyUsed;
@end

@interface Travel (CoreDataGeneratedAccessors)

- (void)addRatesObject:(ExchangeRate *)value;
- (void)removeRatesObject:(ExchangeRate *)value;
- (void)addRates:(NSSet *)values;
- (void)removeRates:(NSSet *)values;

- (void)addParticipantsObject:(Participant *)value;
- (void)removeParticipantsObject:(Participant *)value;
- (void)addParticipants:(NSSet *)values;
- (void)removeParticipants:(NSSet *)values;

- (void)addTransfersObject:(Transfer *)value;
- (void)removeTransfersObject:(Transfer *)value;
- (void)addTransfers:(NSSet *)values;
- (void)removeTransfers:(NSSet *)values;

- (void)addEntriesObject:(Entry *)value;
- (void)removeEntriesObject:(Entry *)value;
- (void)addEntries:(NSSet *)values;
- (void)removeEntries:(NSSet *)values;

- (void)addCurrenciesObject:(Currency *)value;
- (void)removeCurrenciesObject:(Currency *)value;
- (void)addCurrencies:(NSSet *)values;
- (void)removeCurrencies:(NSSet *)values;

@end
