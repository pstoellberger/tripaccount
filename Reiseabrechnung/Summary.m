//
//  Summary.m
//  Reiseabrechnung
//
//  Created by Martin Maier on 01/07/2011.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "Summary.h"
#import "Entry.h"
#import "Participant.h"
#import "Currency.h"
#import "ExchangeRate.h"
#import "CurrencyHelperCategory.h"

@implementation ParticipantKey

@synthesize payer, receiver;

- (id) initWithReceiver:(Participant *)newReceiver andPayer:(Participant *)newPayer {
    self = [super init];
    if (self) {
        self.payer = newPayer;
        self.receiver = newReceiver;
    }
    return self;
}
- (BOOL)isEqual:(id)object {
    if (![object isKindOfClass:[ParticipantKey class]]) {
        return false;
    } else {
        ParticipantKey *compareObject = (ParticipantKey *) object;
        return ([self.payer isEqual:compareObject.payer] && [self.receiver isEqual:compareObject.receiver]);
    }
}
- (NSUInteger)hash {
    return self.payer.hash + self.receiver.hash;
}
- (id)copyWithZone:(NSZone *)zone {
    return [[ParticipantKey alloc] initWithReceiver:self.receiver andPayer:self.payer];
}

@end

// ------ SUMMARY IMPLEMENTATION ----------

@interface Summary ()
- (NSNumber *) getAccountOfPerson:(Participant *)person1 withPerson:(Participant *)person2;
- (void) setAccountOfPerson:(Participant *)person1 withPerson:(Participant *)person2 toBalance:(NSNumber *)balance;
- (int) getMultiplierFromPerson:(Participant *)person1 withPerson:(Participant *)person2;
@end

@implementation Summary

@synthesize results=_results, accounts=_accounts, baseCurrency=_baseCurrency;

- (id) init {
    self = [super init];
    if (self) {
        _accounts = nil;
    }
    return self;
}

+ (Summary *) createSummary:(Travel *) travel {
    Summary *summary = [[[Summary alloc] init] autorelease];
    
    if (!summary.baseCurrency) {
        summary.baseCurrency = ((Entry *) [travel.entries anyObject]).currency.rate.baseCurrency;
    }
      
    for (Entry *entry in travel.entries) {
        
        // convert to base currency
        double baseAmount = [entry.currency convertToCurrency:summary.baseCurrency amount:[entry.amount doubleValue]];
        
        // divide an expense in equal parts
        double divAmount = baseAmount / [entry.receivers count];

        // add the amount to the 'account' between two people
        for (Participant *receiver in entry.receivers) {
            if (![receiver isEqual:entry.payer]) {
                NSNumber *balance = [summary getAccountOfPerson:entry.payer withPerson:receiver];
                NSLog(@"Balance between %@ and %@ is %@", entry.payer.name, receiver.name, balance);
                [summary setAccountOfPerson:entry.payer withPerson:receiver toBalance:[NSNumber numberWithDouble:([balance doubleValue] + divAmount)]];
            }
        }
    }
    
    // remove account with zero (-> entries balanced out)
    NSMutableArray *removeArray = [NSMutableArray array];
    for (ParticipantKey *key in [summary.accounts keyEnumerator]) {
        if ([[summary.accounts objectForKey:key] doubleValue] == 0) {
            [removeArray addObject:key];
        }
    };
    [summary.accounts removeObjectsForKeys:removeArray];
  
    [removeArray removeAllObjects];
    NSMutableDictionary *addDict = [NSMutableDictionary dictionary];
    
    // bring to presentable form (remove negative accounts)
    for (ParticipantKey *key in [summary.accounts keyEnumerator]) {
        
        NSNumber *amount = [summary.accounts objectForKey:key];
        if ([amount doubleValue] < 0) {
            
            [removeArray addObject:key];
            
            //interchange payer and receveiver
            ParticipantKey *newKey = [[ParticipantKey alloc] init];
            newKey.payer = key.receiver;
            newKey.receiver = key.payer;
            
            [addDict setObject:[NSNumber numberWithDouble:-[amount doubleValue]] forKey:newKey];
            [newKey release];
            
        }
    };
    [summary.accounts removeObjectsForKeys:removeArray];
    [summary.accounts addEntriesFromDictionary:addDict];
    
    return summary;
}

- (ParticipantKey *)createKey:(Participant *)person1 withPerson:(Participant *)person2 {
    
    ParticipantKey *key = [[[ParticipantKey alloc] initWithReceiver:person1 andPayer:person2] autorelease];
    
    if ([self getMultiplierFromPerson:person1 withPerson:person2] == -1) {
        key = [[[ParticipantKey alloc] initWithReceiver:person2 andPayer:person1] autorelease];
    } 
    return key;
}

- (int) getMultiplierFromPerson:(Participant *)person1 withPerson:(Participant *)person2 {
    if ([person1.name compare:person2.name] == NSOrderedAscending) {
        NSLog(@"%@ is ascending to %@", person1.name, person2.name);
        return 1;
        
    } else {
        NSLog(@"%@ is descending to %@", person1.name, person2.name);
        return -1;
    }
}

- (void) setAccountOfPerson:(Participant *)person1 withPerson:(Participant *)person2 toBalance:(NSNumber *)balance {
    ParticipantKey *key = [self createKey:(Participant *)person1 withPerson:(Participant *)person2];
    int multiplier = [self getMultiplierFromPerson:person1 withPerson:person2];
    NSLog(@"Balance between %@ and %@ is %@ with multiplier %d", person1.name, person2.name, balance, multiplier);
    [_accounts setObject:[NSNumber numberWithDouble:([balance doubleValue] * multiplier)] forKey:key];
}

- (NSNumber *) getAccountOfPerson:(Participant *)person1 withPerson:(Participant *)person2 {
    
    if (!_accounts) {
        _accounts = [[NSMutableDictionary alloc] init];
    }
    
    int multiplier = [self getMultiplierFromPerson:person1 withPerson:person2];
    ParticipantKey *key = [self createKey:(Participant *)person1 withPerson:(Participant *)person2];
 
    NSNumber *returnValue = [_accounts objectForKey:key];
    if (!returnValue) {
        returnValue = [[[NSNumber alloc] initWithInt:0] autorelease];
        [_accounts setObject:returnValue forKey:key];
        NSLog(@"Creating account for %@ and %@", key.payer.name, key.receiver.name);
    }
    return [NSNumber numberWithDouble:([returnValue doubleValue] * multiplier)];
    
}

@end
