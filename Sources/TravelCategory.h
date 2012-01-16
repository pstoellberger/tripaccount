//
//  TravelCategory.h
//  Reiseabrechnung
//
//  Created by Martin Maier on 10/08/2011.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Travel.h"

@interface Travel (OpenClose)

@property (nonatomic, readonly) NSString *totalCostLabel;
@property (nonatomic, readonly) NSString *location;
@property (nonatomic, readonly) NSArray *sortedEntries;
@property (nonatomic, readonly) NSArray *sortedCurrencies;
@property (nonatomic, readonly) NSArray *sortedTransfers;
@property (nonatomic, readonly) BOOL hasEntriesWithNotes;
@property (nonatomic, readonly) BOOL hasParticipantsWithNotes;
@property (nonatomic, readonly) BOOL hasEntriesWithText;
@property (nonatomic, readonly) NSString *notesHTML;

- (void)open:(BOOL)useLatestRates;
- (void)close;
- (BOOL)isWeightInUse;
- (NSNumber *)totalWeight;
- (BOOL)isClosed;
- (BOOL)isOpen;
- (BOOL)hasEntriesWithNotes;
- (BOOL)hasEntriesWithText;
- (BOOL)hasParticipantsWithNotes;

@end
