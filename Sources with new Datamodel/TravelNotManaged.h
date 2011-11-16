//
//  TravelNotManaged.h
//  Reiseabrechnung
//
//  Created by Martin Maier on 01/07/2011.
//  Copyright 2011 Martin Maier. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Currency.h"
#import "Participant.h"
#import "Country.h"

@interface TravelNotManaged : NSObject 

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
