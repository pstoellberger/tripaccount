//
//  Summary.m
//  Reiseabrechnung
//
//  Created by Martin Maier on 01/07/2011.
//  Copyright 2011 Martin Maier. All rights reserved.
//

#import "Summary.h"
#import "Entry.h"
#import "Participant.h"
#import "Currency.h"
#import "ExchangeRate.h"
#import "CurrencyHelperCategory.h"
#import "Transfer.h"
#import "ReiseabrechnungAppDelegate.h"
#import "EntryCategory.h"
#import "ReceiverWeight.h"
#import "TransferCycle.h"

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

- (NSString *)description {
    return [NSString stringWithFormat:@"P: %@ -> R: %@", payer.name, receiver.name];
}

- (id)copyWithZone:(NSZone *)zone {
    return [[ParticipantKey alloc] initWithReceiver:self.receiver andPayer:self.payer];
}

- (void)dealloc {
    self.payer = nil;
    self.receiver = nil;
    [super dealloc];
}

@end

// ------ SUMMARY IMPLEMENTATION ----------

@interface Summary ()
- (NSNumber *) getAccountOfPerson:(Participant *)person1 withPerson:(Participant *)person2;
- (void) setAccountOfPerson:(Participant *)person1 withPerson:(Participant *)person2 toBalance:(NSNumber *)balance;
- (int) getMultiplierFromPerson:(Participant *)person1 withPerson:(Participant *)person2;
- (NSNumber *)roundNumber:(NSNumber *)input;
- (void) eliminateCircularDebts:(NSMutableDictionary *)arrayOfTransfers;
- (TransferCycle *) walkPath:(NSDictionary *)arrayOfParticipantKeys andKnoten:(NSMutableDictionary *)knoten andParticipant:(Participant *)participant andCycle:(TransferCycle *)cycle;
- (Participant *)getParticipant:(NSSet *)participants byObjectId:(NSManagedObjectID *)participantId;
@end

@implementation Summary

@synthesize accounts=_accountsX, baseCurrency=_baseCurrency;

+ (void)updateSummaryOfTravel:(Travel *)travel {
    [self updateSummaryOfTravel:travel eliminateCircularDebts:YES applyCashierOption:YES];
}

+ (void)updateSummaryOfTravel:(Travel *)travel eliminateCircularDebts:(BOOL)performEliminateCircularDebts applyCashierOption:(BOOL)applyCashierOption {
    
    [Crittercism leaveBreadcrumb:[NSString stringWithFormat:@"%@: %@ ", self.class, @"updateSummaryOrTravel"]];
        
    Summary *summary = [Summary createSummary:travel eliminateCircularDebts:performEliminateCircularDebts applyCashierOption:applyCashierOption];
    NSMutableDictionary *dic = summary.accounts;
    
    [travel removeTransfers:travel.transfers];
    
    travel.transferBaseCurrency = summary.baseCurrency;
    
    for (NSString* key in [dic keyEnumerator]) {
        ParticipantKey *participantKey = (ParticipantKey *)key;
        
        Transfer *transfer = [NSEntityDescription insertNewObjectForEntityForName: @"Transfer" inManagedObjectContext: [travel managedObjectContext]];
        transfer.debtor = participantKey.payer;
        transfer.debtee = participantKey.receiver;
        transfer.amount = [dic objectForKey:key];
        transfer.travel = travel;
        transfer.currency = travel.transferBaseCurrency;
        [travel addTransfersObject:transfer];
    }
    
    [ReiseabrechnungAppDelegate saveContext:[travel managedObjectContext]];
}


+ (Summary *)createSummary:(Travel *)travel {
    return [self createSummary:travel eliminateCircularDebts:YES applyCashierOption:YES];
}

+ (Summary *)createSummary:(Travel *)travel eliminateCircularDebts:(BOOL)performEliminateCircularDebts applyCashierOption:(BOOL)applyCashierOption {
    Summary *summary = [[[Summary alloc] init] autorelease];
    
    if (!summary.baseCurrency) {
        summary.baseCurrency = ((Entry *) [travel.entries anyObject]).currency.defaultRate.baseCurrency;
    }
    
    for (Entry *entry in travel.entries) {
        
        if ([entry.receiverWeights count] > 0) {
            
            // convert to base currency
            double baseAmount = [entry.currency convertTravelAmount:travel currency:summary.baseCurrency amount:[entry.amount doubleValue]];
            
            // divide an expense in equal parts
            double divAmount = baseAmount / entry.totalReceiverWeights;
            
            // add the amount to the 'account' between two people
            for (ReceiverWeight *recWeight in entry.receiverWeights) {
                Participant *receiver = recWeight.participant;
                if (![receiver isEqual:entry.payer]) {
                    NSNumber *balance = [summary getAccountOfPerson:entry.payer withPerson:receiver];
                    NSLog(@"Balance between %@ and %@ is %@", entry.payer.name, receiver.name, balance);
                    [summary setAccountOfPerson:entry.payer withPerson:receiver toBalance:[NSNumber numberWithDouble:([balance doubleValue] + (divAmount * [recWeight.weight doubleValue]))]];
                }
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
    
    if (performEliminateCircularDebts) {
        [summary eliminateCircularDebts:summary.accounts];
    }
    
    if (applyCashierOption) {
        [summary applyCashierOption:[summary decideCashier:travel] withParticipants:travel.participants];
    }
    
    if (performEliminateCircularDebts) {
        [summary eliminateCircularDebts:summary.accounts];
    }
    
    return summary;
}

- (id)init {
    self = [super init];
    if (self) {
        NSNumberFormatter *newFormatter = [[NSNumberFormatter alloc] init];
        [newFormatter setMaximumFractionDigits:2];
        [newFormatter setRoundingMode: NSNumberFormatterRoundDown];
        
        self.formatter = newFormatter;
        [newFormatter release];
    }
    return self;
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
        //NSLog(@"%@ is ascending to %@", person1.name, person2.name);
        return 1;
        
    } else {
        //NSLog(@"%@ is descending to %@", person1.name, person2.name);
        return -1;
    }
}

- (void) setAccountOfPerson:(Participant *)person1 withPerson:(Participant *)person2 toBalance:(NSNumber *)balance {
    ParticipantKey *key = [self createKey:(Participant *)person1 withPerson:(Participant *)person2];
    int multiplier = [self getMultiplierFromPerson:person1 withPerson:person2];
    //NSLog(@"Balance between %@ and %@ is %@ with multiplier %d", person1.name, person2.name, balance, multiplier);
    [self.accounts setObject:[NSNumber numberWithDouble:([balance doubleValue] * multiplier)] forKey:key];
}

- (NSNumber *) getAccountOfPerson:(Participant *)person1 withPerson:(Participant *)person2 {
    
    if (!self.accounts) {
        NSMutableDictionary *newAccounts = [[NSMutableDictionary alloc] init];
        self.accounts = newAccounts;
        [newAccounts release];
    }
    
    int multiplier = [self getMultiplierFromPerson:person1 withPerson:person2];
    ParticipantKey *key = [self createKey:(Participant *)person1 withPerson:(Participant *)person2];
    
    NSNumber *returnValue = [self.accounts objectForKey:key];
    if (!returnValue) {
        returnValue = [NSNumber numberWithInt:0];
        [self.accounts setObject:returnValue forKey:key];
        //NSLog(@"Creating account for %@ and %@", key.payer.name, key.receiver.name);
    }
    return [NSNumber numberWithDouble:([returnValue doubleValue] * multiplier)];
    
}

/* Transfer circular elimiations */

#define STATE_INIT 0
#define STATE_IN_PROGRESS 1
#define STATE_DONE 2

- (void) eliminateCircularDebts:(NSMutableDictionary *)arrayOfParticipantKeys {
    
    [Crittercism leaveBreadcrumb:[NSString stringWithFormat:@"%@: %@ ", self.class, @"eliminateCircularDebts"]];
    
    Participant *startParticipant = nil;
    NSMutableDictionary *knoten = [NSMutableDictionary dictionaryWithCapacity:[arrayOfParticipantKeys count]];
    for (ParticipantKey *pKey in arrayOfParticipantKeys.keyEnumerator) {
        if (!startParticipant) {
            startParticipant = pKey.receiver;
        }
        [knoten setObject:[NSNumber numberWithInt:STATE_INIT] forKey:[pKey.receiver objectID]];
        [knoten setObject:[NSNumber numberWithInt:STATE_INIT] forKey:[pKey.payer objectID]];
    }
    
    TransferCycle *cycle = [[[TransferCycle alloc] init] autorelease];
    
    while(startParticipant && (cycle = [self walkPath:arrayOfParticipantKeys andKnoten:(NSMutableDictionary *)knoten andParticipant:startParticipant andCycle:cycle])) {
        
        BOOL removed = NO;
        for (ParticipantKey *key in cycle.participantKeys) {
            NSNumber *oldValue = (NSNumber *) [arrayOfParticipantKeys objectForKey:key];
            double newValueDbl = [oldValue doubleValue] - [cycle.minWeight doubleValue];
            NSNumber *newValue = [self roundNumber:[NSNumber numberWithDouble:newValueDbl]];
            
            if ([newValue doubleValue] == 0) {
                [arrayOfParticipantKeys removeObjectForKey:key];
                removed = YES;
            } else {
                [arrayOfParticipantKeys setObject:[NSNumber numberWithDouble:newValueDbl] forKey:key];
            }
            
        }
        
        if (!removed) {
            NSLog(@"This should never happen!");
            break;
        }
        
        [knoten removeAllObjects];
        for (ParticipantKey *pKey in arrayOfParticipantKeys.keyEnumerator) {
            [knoten setObject:[NSNumber numberWithInt:STATE_INIT] forKey:[pKey.receiver objectID]];
            [knoten setObject:[NSNumber numberWithInt:STATE_INIT] forKey:[pKey.payer objectID]];
        }
        cycle = [[[TransferCycle alloc] init] autorelease];
    }
    
}

- (NSNumber *)roundNumber:(NSNumber *)input {
    return [self.formatter numberFromString:[self.formatter stringFromNumber:input]];
}

- (TransferCycle *) walkPath:(NSDictionary *)arrayOfParticipantKeys andKnoten:(NSMutableDictionary *)knoten andParticipant:(Participant *)participant andCycle:(TransferCycle *)cycle {
    
    TransferCycle *returnCycle = nil;
    
    if ([((NSNumber *) [knoten objectForKey:[participant objectID]]) intValue] == STATE_IN_PROGRESS) {
        
        while(![((ParticipantKey *)[cycle.participantKeys objectAtIndex:0]).payer isEqual:participant]) {
            [cycle.participantKeys removeObjectAtIndex:0];
        }
        
        NSLog(@"Cycle found:");
        for (ParticipantKey *key in cycle.participantKeys) {
            NSLog(@"%@ -> %@", key.payer.name, key.receiver.name);
        }
        
        returnCycle = cycle;
        
    } else {
        
        if ([((NSNumber *) [knoten objectForKey:[participant objectID]]) intValue] == STATE_INIT) {
            
            [knoten setObject:[NSNumber numberWithInt:STATE_IN_PROGRESS] forKey:[participant objectID]];
            
            for (ParticipantKey *key in [arrayOfParticipantKeys keyEnumerator]) {
                if ([key.payer isEqual:participant]) {
                    TransferCycle *newCycle = [[cycle mutableCopyWithZone:nil] autorelease];
                    [newCycle.participantKeys addObject:key];
                    if ([[arrayOfParticipantKeys objectForKey:key] doubleValue] < [[cycle minWeight] doubleValue]) {
                        newCycle.minWeight = [arrayOfParticipantKeys objectForKey:key];     
                    }
                    returnCycle = [self walkPath:arrayOfParticipantKeys andKnoten:knoten andParticipant:key.receiver andCycle:newCycle];
                    
                    if (returnCycle) {
                        break;
                    }
                }
            }
            
            [knoten setObject:[NSNumber numberWithInt:STATE_DONE] forKey:[participant objectID]];
        }
        
    }
    
    return returnCycle;
}

- (void) applyCashierOption:(Participant *)cashier withParticipants:(NSSet *)participants {
    
    [Crittercism leaveBreadcrumb:[NSString stringWithFormat:@"%@: %@ ", self.class, @"applyCashierOption"]];
    
    NSMutableDictionary *clearingService = [NSMutableDictionary dictionary];
    for (ParticipantKey* key in [self.accounts keyEnumerator]) {
        NSNumber *value = (NSNumber *) [self.accounts objectForKey:key];
        NSNumber *payerAccount = (NSNumber *) [clearingService objectForKey:[key.payer objectID]];
        if (!payerAccount) {
            [clearingService setObject:value forKey:[key.payer objectID]];
        } else {
            double newValueDbl = [payerAccount doubleValue] + [value doubleValue];
            NSNumber *newValue = [NSNumber numberWithDouble:newValueDbl];
            [clearingService setObject:newValue forKey:[key.payer objectID]];
        }
        NSNumber *receiverAccount = (NSNumber *) [clearingService objectForKey:[key.receiver objectID]];
        if (!receiverAccount) {
            NSNumber *negNumber = [NSNumber numberWithDouble:([value doubleValue] * -1)];
            [clearingService setObject:negNumber forKey:[key.receiver objectID]];
        } else {
            double newValueDbl = [receiverAccount doubleValue] - [value doubleValue];
            NSNumber *newValue = [NSNumber numberWithDouble:newValueDbl];
            [clearingService setObject:newValue forKey:[key.receiver objectID]];
        }
    }
    
    [self.accounts removeAllObjects];
    for (NSManagedObjectID* participantId in [clearingService keyEnumerator]) {
        Participant *participant = [self getParticipant:participants byObjectId:participantId];
        if (![participant isEqual:cashier]) {
            NSNumber *value = (NSNumber *) [clearingService objectForKey:participantId];
            if ([value doubleValue] > 0) {
                ParticipantKey *key = [[ParticipantKey alloc] initWithReceiver:cashier andPayer:participant];
                [self.accounts setObject:value forKey:key];
                [key release];
            } else if ([value doubleValue] < 0) {
                ParticipantKey *key = [[ParticipantKey alloc] initWithReceiver:participant andPayer:cashier];
                NSNumber *posNumber = [NSNumber numberWithDouble:([value doubleValue]* -1)];
                [self.accounts setObject:posNumber forKey:key];
                [key release];
            }
            // skip case amount == 0
        }
    }
}

- (Participant *)getParticipant:(NSSet *)participants byObjectId:(NSManagedObjectID *)participantId {
    for (Participant *participantOfList in participants) {
        if ([participantOfList.objectID isEqual:participantId]) {
            return participantOfList;
        }
    }
    return nil;
}

// decide who should be used as cashier
// the person with the most expenses is the cashier
- (Participant *)decideCashier:(Travel *)travel {
    
    if (travel.cashier) {
        return travel.cashier;
    }
    
    NSMutableDictionary *payerStats = [NSMutableDictionary dictionary];
    for (Entry* entry in [travel.entries allObjects]) {
        NSNumber *value = (NSNumber *) [payerStats objectForKey:entry.payer.objectID];
        if (!value) {
            [payerStats setObject:[NSNumber numberWithInt:1] forKey:entry.payer.objectID];
        } else {
            [payerStats setObject:[NSNumber numberWithInt:([value intValue] + 1)] forKey:entry.payer.objectID];
        }
    }
    
    NSManagedObjectID* participantId = nil;
    int highestValue = 0;
    for (NSManagedObjectID* objectId in [payerStats keyEnumerator]) {
        if ([[payerStats objectForKey:objectId] intValue] > highestValue) {
            highestValue = [[payerStats objectForKey:objectId] intValue];
            participantId = objectId;
        }
    }
    
    return [self getParticipant:travel.participants byObjectId:participantId];
}


- (void)dealloc {
    self.baseCurrency = nil;
    self.accounts = nil;
    self.formatter = nil;
    [super dealloc];
}

@end
