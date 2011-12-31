//
//  UnitTests.m
//  UnitTests
//
//  Created by Martin Maier on 01/08/2011.
//  Copyright 2011 Martin Maier. All rights reserved.
//

#import "UnitTests.h"
#import "ReiseabrechnungAppDelegate.h"
#import "CurrencyHelperCategory.h"
#import "ExchangeRate.h"
#import "Travel.h"
#import "ReceiverWeight.h"
#import "Summary.h"
#import "Transfer.h"

@implementation UnitTests

- (void) setUp {
    
    NSArray *bundles = [NSArray arrayWithObject:[NSBundle bundleForClass:[self class]]];
    model = [[NSManagedObjectModel mergedModelFromBundles:bundles] retain];
    //NSLog(@"Model: %@", model);
    
    NSError *error = nil;
    coordinator = [[[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:model] retain];
    //NSURL *storeURL = [NSURL fileURLWithPath:@"/var/tmp/test_database.sqlite"];
    //[coordinator addPersistentStoreWithType:NSSQLiteStoreType configuration:nil URL:storeURL options:nil error:&error];
    context = [[[NSManagedObjectContext alloc] init] retain];
    [context setPersistentStoreCoordinator:coordinator];
    
    if (error) {
        NSLog(@"%@", error);
    }
    
    ReiseabrechnungAppDelegate *appDelegate = [[ReiseabrechnungAppDelegate alloc] init];
    appDelegate.managedObjectContext = context;
    [appDelegate initializeStartDatabase:[NSBundle bundleForClass:[self class]]];
}

- (void) tearDown {
    [context rollback];
    [context release];
    [coordinator release];
    [model release];
}

- (void)testCurrencyConvert {
    
    Currency *chf = [self currencyWithCode:@"CHF"];
    Currency *eur = [self currencyWithCode:@"EUR"];
    Currency *usd = [self currencyWithCode:@"USD"];
    
    chf.defaultRate.rate = [NSNumber numberWithDouble:1.1];
    usd.defaultRate.rate = [NSNumber numberWithDouble:1.5];
    
    Travel *travel = [NSEntityDescription insertNewObjectForEntityForName:@"Travel" inManagedObjectContext:context];
    [travel addRatesObject:chf.defaultRate];
    [travel addRatesObject:usd.defaultRate];
    
    
    STAssertEquals([chf convertTravelAmount:travel currency:chf amount:2.2], 2.2, nil);
    STAssertEquals([eur convertTravelAmount:travel currency:eur amount:2.2], 2.2, nil);
    
    STAssertEquals([chf convertTravelAmount:travel currency:eur amount:2], 2 / 1.1, nil); // = 1.8
    STAssertEquals([eur convertTravelAmount:travel currency:chf amount:2], 2 * 1.1, nil); // = 2.2
    
    STAssertEquals([usd convertTravelAmount:travel currency:eur amount:2], 2 / 1.5, nil); 
    STAssertEquals([eur convertTravelAmount:travel currency:usd amount:2], 2 * 1.5, nil); 
    
    STAssertEquals([chf convertTravelAmount:travel currency:usd amount:2], 2 / 1.1 * 1.5, nil);
    STAssertEquals([usd convertTravelAmount:travel currency:chf amount:2], 2 / 1.5 * 1.1, nil);

}

- (Currency *)currencyWithCode:(NSString *)code {
    NSFetchRequest *req = [[NSFetchRequest alloc] init];
    req.entity = [NSEntityDescription entityForName:@"Currency" inManagedObjectContext: context];
    req.predicate = [NSPredicate predicateWithFormat:[NSString stringWithFormat:@"code == '%@'", code]];
    Currency *currency = [[context executeFetchRequest:req error:nil] lastObject];
    [req release];
    return currency;
}

- (ReceiverWeight *)newReceiverWeight:(Participant *)particpant {
    ReceiverWeight *rw = [NSEntityDescription insertNewObjectForEntityForName:@"ReceiverWeight" inManagedObjectContext:context];
    rw.participant = particpant;
    rw.weight = [NSNumber numberWithInt:1];
    return rw;
}

- (void)assertTransfer:(NSSet *)transfers fromParticipant:(Participant *)p1 toParticipant:(Participant *)p2 withAmount:(NSNumber *)amount {

    BOOL returnValue = NO;
    NSNumber *foundValue = nil;
    for (Transfer *transfer in transfers) {
        if ([transfer.debtor.name isEqualToString:p1.name] && [transfer.debtee.name isEqualToString:p2.name]) {
            if ([[NSString stringWithFormat:@"%d",lroundf([transfer.amount doubleValue])] isEqualToString:[NSString stringWithFormat:@"%d",lroundf([amount doubleValue])]])  {
                returnValue = YES;
                break;
            } else {
                //NSLog(@"%f", [amount doubleValue]);
                //NSLog(@"%f", [transfer.amount doubleValue]);
                //NSLog(@"%d", [transfer.amount floatValue] == [amount floatValue]);
                foundValue = transfer.amount;
                returnValue =  NO;
            }
        }
    }
    STAssertTrue(returnValue, [NSString stringWithFormat:@"Could not find person %@ owes %@ to %@ (found value: %@)", p1.name, amount, p2.name, foundValue]);
    
}


- (void)testCalculation {
    
    Currency *eur = [self currencyWithCode:@"EUR"];
    
    Travel *travel = [NSEntityDescription insertNewObjectForEntityForName:@"Travel" inManagedObjectContext:context];
    [travel addCurrenciesObject:eur];
    
    Participant *p1 = [NSEntityDescription insertNewObjectForEntityForName:@"Participant" inManagedObjectContext:context];
    p1.name = @"p1";
    Participant *p2 = [NSEntityDescription insertNewObjectForEntityForName:@"Participant" inManagedObjectContext:context];
    p2.name = @"p2";
    Participant *p3 = [NSEntityDescription insertNewObjectForEntityForName:@"Participant" inManagedObjectContext:context];
    p3.name = @"p3";
    
    [travel addParticipantsObject:p1];
    [travel addParticipantsObject:p2];
    [travel addParticipantsObject:p3];
    
    Entry *e1 = [NSEntityDescription insertNewObjectForEntityForName:@"Entry" inManagedObjectContext:context];
    e1.payer = p1;
    e1.currency = eur;
    e1.amount = [NSNumber numberWithInt:100];
    [e1 addReceiverWeightsObject:[self newReceiverWeight:p1]];
    [e1 addReceiverWeightsObject:[self newReceiverWeight:p2]];
    [e1 addReceiverWeightsObject:[self newReceiverWeight:p3]];
    [travel addEntriesObject:e1];
    
    [Summary updateSummaryOfTravel:travel];
    
    [self assertTransfer:travel.transfers fromParticipant:p2 toParticipant:p1 withAmount:[NSNumber numberWithDouble:(100.0/3)]];
    [self assertTransfer:travel.transfers fromParticipant:p3 toParticipant:p1 withAmount:[NSNumber numberWithDouble:(100.0/3)]];
    
    Entry *e2 = [NSEntityDescription insertNewObjectForEntityForName:@"Entry" inManagedObjectContext:context];
    e2.payer = p2;
    e2.currency = eur;
    e2.amount = [NSNumber numberWithInt:500];
    [e2 addReceiverWeightsObject:[self newReceiverWeight:p1]];
    [e2 addReceiverWeightsObject:[self newReceiverWeight:p2]];
    [e2 addReceiverWeightsObject:[self newReceiverWeight:p3]];
    [travel addEntriesObject:e2];
    
    
    [Summary updateSummaryOfTravel:travel eliminateCircularDebts:NO];
    
    [self assertTransfer:travel.transfers fromParticipant:p1 toParticipant:p2 withAmount:[NSNumber numberWithDouble:(500.0/3-100.0/3)]];
    [self assertTransfer:travel.transfers fromParticipant:p3 toParticipant:p1 withAmount:[NSNumber numberWithDouble:(100.0/3)]];
    [self assertTransfer:travel.transfers fromParticipant:p3 toParticipant:p2 withAmount:[NSNumber numberWithDouble:(500.0/3)]];
    
    Entry *e3 = [NSEntityDescription insertNewObjectForEntityForName:@"Entry" inManagedObjectContext:context];
    e3.payer = p3;
    e3.currency = eur;
    e3.amount = [NSNumber numberWithInt:20];
    [e3 addReceiverWeightsObject:[self newReceiverWeight:p2]];
    [travel addEntriesObject:e3];
    
    
    [Summary updateSummaryOfTravel:travel eliminateCircularDebts:NO];
    
    [self assertTransfer:travel.transfers fromParticipant:p1 toParticipant:p2 withAmount:[NSNumber numberWithDouble:(500.0/3-100.0/3)]];
    [self assertTransfer:travel.transfers fromParticipant:p3 toParticipant:p1 withAmount:[NSNumber numberWithDouble:(100.0/3)]];
    [self assertTransfer:travel.transfers fromParticipant:p3 toParticipant:p2 withAmount:[NSNumber numberWithDouble:(500.0/3-20)]];
    
    Entry *e4 = [NSEntityDescription insertNewObjectForEntityForName:@"Entry" inManagedObjectContext:context];
    e4.payer = p1;
    e4.currency = eur;
    e4.amount = [NSNumber numberWithInt:10];
    [e4 addReceiverWeightsObject:[self newReceiverWeight:p1]];
    [e4 addReceiverWeightsObject:[self newReceiverWeight:p2]];
    [travel addEntriesObject:e4];
    
    
    [Summary updateSummaryOfTravel:travel eliminateCircularDebts:NO];
    
    [self assertTransfer:travel.transfers fromParticipant:p1 toParticipant:p2 withAmount:[NSNumber numberWithDouble:(500.0/3-100.0/3-10/2)]];
    [self assertTransfer:travel.transfers fromParticipant:p3 toParticipant:p1 withAmount:[NSNumber numberWithDouble:(100.0/3)]];
    [self assertTransfer:travel.transfers fromParticipant:p3 toParticipant:p2 withAmount:[NSNumber numberWithDouble:(500.0/3-20)]];
    
    Entry *e5 = [NSEntityDescription insertNewObjectForEntityForName:@"Entry" inManagedObjectContext:context];
    e5.payer = p1;
    e5.currency = eur;
    e5.amount = [NSNumber numberWithDouble:1.4242];
    [e5 addReceiverWeightsObject:[self newReceiverWeight:p1]];
    [e5 addReceiverWeightsObject:[self newReceiverWeight:p2]];
    [e5 addReceiverWeightsObject:[self newReceiverWeight:p3]];
    [travel addEntriesObject:e5];
    
    
    [Summary updateSummaryOfTravel:travel eliminateCircularDebts:NO];
    
    [self assertTransfer:travel.transfers fromParticipant:p1 toParticipant:p2 withAmount:[NSNumber numberWithDouble:(500.0/3-100.0/3-10/2-1.4242/3)]];
    [self assertTransfer:travel.transfers fromParticipant:p3 toParticipant:p1 withAmount:[NSNumber numberWithDouble:(100.0/3+1.4242/3)]];
    [self assertTransfer:travel.transfers fromParticipant:p3 toParticipant:p2 withAmount:[NSNumber numberWithDouble:(500.0/3-20)]];
    
    Entry *e6 = [NSEntityDescription insertNewObjectForEntityForName:@"Entry" inManagedObjectContext:context];
    e6.payer = p3;
    e6.currency = eur;
    e6.amount = [NSNumber numberWithInt:42728];
    [e6 addReceiverWeightsObject:[self newReceiverWeight:p1]];
    [e6 addReceiverWeightsObject:[self newReceiverWeight:p2]];
    [e6 addReceiverWeightsObject:[self newReceiverWeight:p3]];
    [travel addEntriesObject:e6];
    
    [Summary updateSummaryOfTravel:travel eliminateCircularDebts:NO];
    
    [self assertTransfer:travel.transfers fromParticipant:p1 toParticipant:p2 withAmount:[NSNumber numberWithDouble:(500.0/3-100.0/3-10/2-1.4242/3)]];
    [self assertTransfer:travel.transfers fromParticipant:p1 toParticipant:p3 withAmount:[NSNumber numberWithDouble:(42728.0/3-(100.0/3+1.4242/3))]];
    [self assertTransfer:travel.transfers fromParticipant:p2 toParticipant:p3 withAmount:[NSNumber numberWithDouble:(42728.0/3-(500.0/3-20))]];
}


- (void)assertDebtAmount:(NSDictionary *)dict fromParticipant:(Participant *)p1 toParticipant:(Participant *)p2 withAmount:(NSNumber *)amount {

    ParticipantKey *key = [[ParticipantKey alloc] initWithReceiver:p1 andPayer:p2];
    STAssertTrue([dict objectForKey:key] != nil, [NSString stringWithFormat:@"Could not find person %@ owes to %@", p1.name, amount, p2.name]);
    STAssertEqualObjects([dict objectForKey:key], amount, [NSString stringWithFormat:@"Amount for debt between %@ and %@ is not %@ (as expected) but %@", p1.name, p2.name, amount, [dict objectForKey:key]]);
    
}

- (void)testRemoveCDebts1Cycle {
    
    Currency *eur = [self currencyWithCode:@"EUR"];
    
    Travel *travel = [NSEntityDescription insertNewObjectForEntityForName:@"Travel" inManagedObjectContext:context];
    [travel addCurrenciesObject:eur];
    
    Participant *p1 = [NSEntityDescription insertNewObjectForEntityForName:@"Participant" inManagedObjectContext:context];
    p1.name = @"p1";
    Participant *p2 = [NSEntityDescription insertNewObjectForEntityForName:@"Participant" inManagedObjectContext:context];
    p2.name = @"p2";
    Participant *p3 = [NSEntityDescription insertNewObjectForEntityForName:@"Participant" inManagedObjectContext:context];
    p3.name = @"p3";
    Participant *p4 = [NSEntityDescription insertNewObjectForEntityForName:@"Participant" inManagedObjectContext:context];
    p4.name = @"p4";
    
    [travel addParticipantsObject:p1];
    [travel addParticipantsObject:p2];
    [travel addParticipantsObject:p3];
    [travel addParticipantsObject:p4];
    
    Summary *summary = [Summary createSummary:travel];
    NSMutableDictionary *dict = [NSMutableDictionary dictionaryWithCapacity:10];
    summary.accounts = dict;
    
    ParticipantKey *key = [[ParticipantKey alloc] initWithReceiver:p1 andPayer:p3];
    [dict setObject:[NSNumber numberWithInt:100] forKey:key];
    key = [[ParticipantKey alloc] initWithReceiver:p2 andPayer:p1];
    [dict setObject:[NSNumber numberWithInt:200] forKey:key];
    key = [[ParticipantKey alloc] initWithReceiver:p3 andPayer:p2];
    [dict setObject:[NSNumber numberWithInt:300] forKey:key];
    
    [summary eliminateCircularDebts:dict];
    
    STAssertEquals([dict count], (NSUInteger) 2, nil);
    [self assertDebtAmount:dict fromParticipant:p2 toParticipant:p1 withAmount:[NSNumber numberWithInt:100]];
    [self assertDebtAmount:dict fromParticipant:p3 toParticipant:p2 withAmount:[NSNumber numberWithInt:200]];
}

- (void)testRemoveCDebts2Cycles {
    
    Currency *eur = [self currencyWithCode:@"EUR"];
    
    Travel *travel = [NSEntityDescription insertNewObjectForEntityForName:@"Travel" inManagedObjectContext:context];
    [travel addCurrenciesObject:eur];
    
    Participant *p1 = [NSEntityDescription insertNewObjectForEntityForName:@"Participant" inManagedObjectContext:context];
    p1.name = @"p1";
    Participant *p2 = [NSEntityDescription insertNewObjectForEntityForName:@"Participant" inManagedObjectContext:context];
    p2.name = @"p2";
    Participant *p3 = [NSEntityDescription insertNewObjectForEntityForName:@"Participant" inManagedObjectContext:context];
    p3.name = @"p3";
    Participant *p4 = [NSEntityDescription insertNewObjectForEntityForName:@"Participant" inManagedObjectContext:context];
    p4.name = @"p4";
    
    [travel addParticipantsObject:p1];
    [travel addParticipantsObject:p2];
    [travel addParticipantsObject:p3];
    [travel addParticipantsObject:p4];
    
    Summary *summary = [Summary createSummary:travel];
    NSMutableDictionary *dict = [NSMutableDictionary dictionaryWithCapacity:10];
    summary.accounts = dict;
    
    ParticipantKey *key = [[ParticipantKey alloc] initWithReceiver:p1 andPayer:p3];
    [dict setObject:[NSNumber numberWithInt:100] forKey:key];
    key = [[ParticipantKey alloc] initWithReceiver:p2 andPayer:p1];
    [dict setObject:[NSNumber numberWithInt:200] forKey:key];
    key = [[ParticipantKey alloc] initWithReceiver:p3 andPayer:p2];
    [dict setObject:[NSNumber numberWithInt:1000] forKey:key];
    key = [[ParticipantKey alloc] initWithReceiver:p3 andPayer:p4];
    [dict setObject:[NSNumber numberWithInt:400] forKey:key];
    key = [[ParticipantKey alloc] initWithReceiver:p4 andPayer:p2];
    [dict setObject:[NSNumber numberWithInt:500] forKey:key];
    
    [summary eliminateCircularDebts:dict];
    
    STAssertEquals([dict count], (NSUInteger) 2, nil);
    [self assertDebtAmount:dict fromParticipant:p2 toParticipant:p1 withAmount:[NSNumber numberWithInt:100]];
    [self assertDebtAmount:dict fromParticipant:p3 toParticipant:p2 withAmount:[NSNumber numberWithInt:200]];
    [self assertDebtAmount:dict fromParticipant:p3 toParticipant:p2 withAmount:[NSNumber numberWithInt:200]];
    [self assertDebtAmount:dict fromParticipant:p3 toParticipant:p2 withAmount:[NSNumber numberWithInt:200]];    
    [self assertDebtAmount:dict fromParticipant:p3 toParticipant:p2 withAmount:[NSNumber numberWithInt:200]];
}

@end
