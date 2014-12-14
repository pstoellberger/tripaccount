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
#import "DataInitialiser.h"

@implementation UnitTests

- (void) setUp {
    
    NSArray *bundles = [NSArray arrayWithObject:[NSBundle bundleForClass:[self class]]];
    model = [[NSManagedObjectModel mergedModelFromBundles:bundles] retain];
    
    NSError *error = nil;
    coordinator = [[[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:model] retain];
    context = [[[NSManagedObjectContext alloc] init] retain];
    [context setPersistentStoreCoordinator:coordinator];
    
    if (error) {
        NSLog(@"%@", error);
    }
    
    ReiseabrechnungAppDelegate *appDelegate = [[ReiseabrechnungAppDelegate alloc] init];
    appDelegate.managedObjectContext = context;
    
    [appDelegate initUserDefaults];
    
    NSString *version = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleVersion"];
    NSString *dataInitkey = [NSString stringWithFormat:@"dataInitForVersion%@", version];
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:dataInitkey];
    
    DataInitialiser *di = [[DataInitialiser alloc] init];
    [di performDataInitialisations:appDelegate.window inContext:appDelegate.managedObjectContext withBundle:[NSBundle bundleForClass:[self class]]];
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
    
    
    XCTAssertEqual([chf convertTravelAmount:travel currency:chf amount:2.2], 2.2);
    XCTAssertEqual([eur convertTravelAmount:travel currency:eur amount:2.2], 2.2);
    
    XCTAssertEqual([chf convertTravelAmount:travel currency:eur amount:2], 2 / 1.1); // = 1.8
    XCTAssertEqual([eur convertTravelAmount:travel currency:chf amount:2], 2 * 1.1); // = 2.2
    
    XCTAssertEqual([usd convertTravelAmount:travel currency:eur amount:2], 2 / 1.5); 
    XCTAssertEqual([eur convertTravelAmount:travel currency:usd amount:2], 2 * 1.5); 
    
    XCTAssertEqual([chf convertTravelAmount:travel currency:usd amount:2], 2 / 1.1 * 1.5);
    XCTAssertEqual([usd convertTravelAmount:travel currency:chf amount:2], 2 / 1.5 * 1.1);

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

- (ReceiverWeight *)newReceiverWeight:(Participant *)particpant withAmount:(NSNumber *)amount {
    ReceiverWeight *rw = [NSEntityDescription insertNewObjectForEntityForName:@"ReceiverWeight" inManagedObjectContext:context];
    rw.participant = particpant;
    rw.weight = amount;
    return rw;
}

- (void)assertTransfer:(NSSet *)transfers fromParticipant:(Participant *)p1 toParticipant:(Participant *)p2 withAmount:(NSNumber *)amount {

    BOOL returnValue = NO;
    NSNumber *foundValue = nil;
    for (Transfer *transfer in transfers) {
        if ([transfer.debtor.name isEqualToString:p1.name] && [transfer.debtee.name isEqualToString:p2.name]) {
            if ([[NSString stringWithFormat:@"%ld",lroundf([transfer.amount doubleValue])] isEqualToString:[NSString stringWithFormat:@"%ld",lroundf([amount doubleValue])]])  {
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
    XCTAssertTrue(returnValue, [NSString stringWithFormat:@"Could not find person %@ owes %@ to %@ (found value: %@)", p1.name, amount, p2.name, foundValue]);
    
}

- (void)testCalculationWeight {
    
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
    e1.amount = [NSNumber numberWithInt:28];
    [e1 addReceiverWeightsObject:[self newReceiverWeight:p1 withAmount:[NSNumber numberWithInt:7]]];
    [e1 addReceiverWeightsObject:[self newReceiverWeight:p2 withAmount:[NSNumber numberWithInt:9]]];
    [e1 addReceiverWeightsObject:[self newReceiverWeight:p3 withAmount:[NSNumber numberWithInt:12]]];
    [travel addEntriesObject:e1];
    
    [Summary updateSummaryOfTravel:travel eliminateCircularDebts:YES applyCashierOption:NO];
    
    [self assertTransfer:travel.transfers fromParticipant:p2 toParticipant:p1 withAmount:[NSNumber numberWithDouble:9]];
    [self assertTransfer:travel.transfers fromParticipant:p3 toParticipant:p1 withAmount:[NSNumber numberWithDouble:12]];
    
    
    e1 = [NSEntityDescription insertNewObjectForEntityForName:@"Entry" inManagedObjectContext:context];
    e1.payer = p2;
    e1.currency = eur;
    e1.amount = [NSNumber numberWithInt:100];
    [e1 addReceiverWeightsObject:[self newReceiverWeight:p1 withAmount:[NSNumber numberWithDouble:1.5]]];
    [e1 addReceiverWeightsObject:[self newReceiverWeight:p2 withAmount:[NSNumber numberWithInt:10]]];
    [e1 addReceiverWeightsObject:[self newReceiverWeight:p3 withAmount:[NSNumber numberWithInt:1]]];
    [travel addEntriesObject:e1];
    
    [Summary updateSummaryOfTravel:travel eliminateCircularDebts:YES applyCashierOption:NO];
    
    [self assertTransfer:travel.transfers fromParticipant:p1 toParticipant:p2 withAmount:[NSNumber numberWithDouble:3]];
    [self assertTransfer:travel.transfers fromParticipant:p3 toParticipant:p1 withAmount:[NSNumber numberWithDouble:12]];
    [self assertTransfer:travel.transfers fromParticipant:p3 toParticipant:p2 withAmount:[NSNumber numberWithDouble:8]];
    
    e1 = [NSEntityDescription insertNewObjectForEntityForName:@"Entry" inManagedObjectContext:context];
    e1.payer = p3;
    e1.currency = eur;
    e1.amount = [NSNumber numberWithInt:12];
    [e1 addReceiverWeightsObject:[self newReceiverWeight:p1 withAmount:[NSNumber numberWithDouble:1.5]]];
    [e1 addReceiverWeightsObject:[self newReceiverWeight:p2 withAmount:[NSNumber numberWithDouble:0.5]]];
    [travel addEntriesObject:e1];
    
    [Summary updateSummaryOfTravel:travel eliminateCircularDebts:YES applyCashierOption:NO];
    
    [self assertTransfer:travel.transfers fromParticipant:p1 toParticipant:p2 withAmount:[NSNumber numberWithDouble:3]];
    [self assertTransfer:travel.transfers fromParticipant:p3 toParticipant:p1 withAmount:[NSNumber numberWithDouble:3]];
    [self assertTransfer:travel.transfers fromParticipant:p3 toParticipant:p2 withAmount:[NSNumber numberWithDouble:5]];
    
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
    
    [Summary updateSummaryOfTravel:travel eliminateCircularDebts:YES applyCashierOption:NO];
    
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
    
    
    [Summary updateSummaryOfTravel:travel eliminateCircularDebts:NO applyCashierOption:NO];
    
    [self assertTransfer:travel.transfers fromParticipant:p1 toParticipant:p2 withAmount:[NSNumber numberWithDouble:(500.0/3-100.0/3)]];
    [self assertTransfer:travel.transfers fromParticipant:p3 toParticipant:p1 withAmount:[NSNumber numberWithDouble:(100.0/3)]];
    [self assertTransfer:travel.transfers fromParticipant:p3 toParticipant:p2 withAmount:[NSNumber numberWithDouble:(500.0/3)]];
    
    Entry *e3 = [NSEntityDescription insertNewObjectForEntityForName:@"Entry" inManagedObjectContext:context];
    e3.payer = p3;
    e3.currency = eur;
    e3.amount = [NSNumber numberWithInt:20];
    [e3 addReceiverWeightsObject:[self newReceiverWeight:p2]];
    [travel addEntriesObject:e3];
    
    
    [Summary updateSummaryOfTravel:travel eliminateCircularDebts:NO applyCashierOption:NO];
    
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
    
    
    [Summary updateSummaryOfTravel:travel eliminateCircularDebts:NO applyCashierOption:NO];
    
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
    
    
    [Summary updateSummaryOfTravel:travel eliminateCircularDebts:NO applyCashierOption:NO];
    
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
    
    [Summary updateSummaryOfTravel:travel eliminateCircularDebts:NO applyCashierOption:NO];
    
    [self assertTransfer:travel.transfers fromParticipant:p1 toParticipant:p2 withAmount:[NSNumber numberWithDouble:(500.0/3-100.0/3-10/2-1.4242/3)]];
    [self assertTransfer:travel.transfers fromParticipant:p1 toParticipant:p3 withAmount:[NSNumber numberWithDouble:(42728.0/3-(100.0/3+1.4242/3))]];
    [self assertTransfer:travel.transfers fromParticipant:p2 toParticipant:p3 withAmount:[NSNumber numberWithDouble:(42728.0/3-(500.0/3-20))]];
}


- (void)assertDebtAmount:(NSDictionary *)dict fromParticipant:(Participant *)p1 toParticipant:(Participant *)p2 withAmount:(NSNumber *)amount {

    ParticipantKey *key = [[ParticipantKey alloc] initWithReceiver:p1 andPayer:p2];
    XCTAssertTrue([dict objectForKey:key] != nil, [NSString stringWithFormat:@"Could not find person %@ owes to %@", p1.name, p2.name]);
    
    XCTAssertTrue([self firstDouble:[amount doubleValue] isEqualTo:[[dict objectForKey:key] doubleValue]], [NSString stringWithFormat:@"Amount for debt between %@ and %@ is not %@ (as expected) but %@", p1.name, p2.name, amount, [dict objectForKey:key]]);
    
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
    
    Summary *summary = [Summary createSummary:travel eliminateCircularDebts:YES applyCashierOption:NO];
    NSMutableDictionary *dict = [NSMutableDictionary dictionaryWithCapacity:10];
    summary.accounts = dict;
    
    ParticipantKey *key = [[ParticipantKey alloc] initWithReceiver:p1 andPayer:p3];
    [dict setObject:[NSNumber numberWithInt:100] forKey:key];
    key = [[ParticipantKey alloc] initWithReceiver:p2 andPayer:p1];
    [dict setObject:[NSNumber numberWithInt:200] forKey:key];
    key = [[ParticipantKey alloc] initWithReceiver:p3 andPayer:p2];
    [dict setObject:[NSNumber numberWithInt:300] forKey:key];
    
    [summary eliminateCircularDebts:dict];
    
    XCTAssertEqual([dict count], (NSUInteger) 2);
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
    
    Summary *summary = [Summary createSummary:travel eliminateCircularDebts:YES applyCashierOption:NO];
    NSMutableDictionary *dict = [NSMutableDictionary dictionaryWithCapacity:10];
    summary.accounts = dict;
    
    ParticipantKey *key = [[ParticipantKey alloc] initWithReceiver:p1 andPayer:p3];
    [dict setObject:[NSNumber numberWithInt:100] forKey:key];
    
    key = [[ParticipantKey alloc] initWithReceiver:p2 andPayer:p1];
    [dict setObject:[NSNumber numberWithInt:200] forKey:key];
    
    key = [[ParticipantKey alloc] initWithReceiver:p3 andPayer:p2];
    [dict setObject:[NSNumber numberWithInt:1000] forKey:key];
    
    key = [[ParticipantKey alloc] initWithReceiver:p4 andPayer:p3];
    [dict setObject:[NSNumber numberWithInt:400] forKey:key];
    
    key = [[ParticipantKey alloc] initWithReceiver:p2 andPayer:p4];
    [dict setObject:[NSNumber numberWithInt:500] forKey:key];
    
    [summary eliminateCircularDebts:dict];
    
    XCTAssertEqual([dict count], (NSUInteger) 3);
    [self assertDebtAmount:dict fromParticipant:p2 toParticipant:p1 withAmount:[NSNumber numberWithInt:100]];
    [self assertDebtAmount:dict fromParticipant:p3 toParticipant:p2 withAmount:[NSNumber numberWithInt:500]];
    [self assertDebtAmount:dict fromParticipant:p2 toParticipant:p4 withAmount:[NSNumber numberWithInt:100]];
}

- (void)testCashierOption {
    
    Currency *eur = [self currencyWithCode:@"EUR"];
    
    Travel *travel = [NSEntityDescription insertNewObjectForEntityForName:@"Travel" inManagedObjectContext:context];
    [travel addCurrenciesObject:eur];
    
    Participant *pEvicka = [NSEntityDescription insertNewObjectForEntityForName:@"Participant" inManagedObjectContext:context];
    pEvicka.name = @"Evicka";
    Participant *pHonza = [NSEntityDescription insertNewObjectForEntityForName:@"Participant" inManagedObjectContext:context];
    pHonza.name = @"Honza";
    Participant *pLudek = [NSEntityDescription insertNewObjectForEntityForName:@"Participant" inManagedObjectContext:context];
    pLudek.name = @"Ludek";
    Participant *pMarek = [NSEntityDescription insertNewObjectForEntityForName:@"Participant" inManagedObjectContext:context];
    pMarek.name = @"Marek";
    Participant *pMichael = [NSEntityDescription insertNewObjectForEntityForName:@"Participant" inManagedObjectContext:context];
    pMichael.name = @"Michael";
    Participant *pTomas = [NSEntityDescription insertNewObjectForEntityForName:@"Participant" inManagedObjectContext:context];
    pTomas.name = @"Tomas";
    Participant *pVaclav = [NSEntityDescription insertNewObjectForEntityForName:@"Participant" inManagedObjectContext:context];
    pVaclav.name = @"Vaclav";
    Participant *pDan = [NSEntityDescription insertNewObjectForEntityForName:@"Participant" inManagedObjectContext:context];
    pDan.name = @"Dan";
    
    [travel addParticipantsObject:pEvicka];
    [travel addParticipantsObject:pHonza];
    [travel addParticipantsObject:pLudek];
    [travel addParticipantsObject:pMarek];
    [travel addParticipantsObject:pMichael];
    [travel addParticipantsObject:pTomas];
    [travel addParticipantsObject:pVaclav];
    [travel addParticipantsObject:pDan];
    
    Summary *summary = [Summary createSummary:travel];
    NSMutableDictionary *dict = [NSMutableDictionary dictionaryWithCapacity:10];
    summary.accounts = dict;
    
    // Evica
    
    ParticipantKey *key = [[ParticipantKey alloc] initWithReceiver:pEvicka andPayer:pDan];
    [dict setObject:[NSNumber numberWithDouble:1234.15] forKey:key];
    
    key = [[ParticipantKey alloc] initWithReceiver:pEvicka andPayer:pLudek];
    [dict setObject:[NSNumber numberWithDouble:70.93] forKey:key];
    
    key = [[ParticipantKey alloc] initWithReceiver:pEvicka andPayer:pMarek];
    [dict setObject:[NSNumber numberWithDouble:809.74] forKey:key];
    
    key = [[ParticipantKey alloc] initWithReceiver:pEvicka andPayer:pTomas];
    [dict setObject:[NSNumber numberWithDouble:266.28] forKey:key];
    
    key = [[ParticipantKey alloc] initWithReceiver:pEvicka andPayer:pVaclav];
    [dict setObject:[NSNumber numberWithDouble:4.81] forKey:key];
    
    // Honza
    
    key = [[ParticipantKey alloc] initWithReceiver:pHonza andPayer:pDan];
    [dict setObject:[NSNumber numberWithDouble:2246.98] forKey:key];
    
    key = [[ParticipantKey alloc] initWithReceiver:pHonza andPayer:pEvicka];
    [dict setObject:[NSNumber numberWithDouble:100.00] forKey:key];
    
    key = [[ParticipantKey alloc] initWithReceiver:pHonza andPayer:pLudek];
    [dict setObject:[NSNumber numberWithDouble:302.79] forKey:key];
    
    key = [[ParticipantKey alloc] initWithReceiver:pHonza andPayer:pMarek];
    [dict setObject:[NSNumber numberWithDouble:1746.85] forKey:key];
    
    key = [[ParticipantKey alloc] initWithReceiver:pHonza andPayer:pTomas];
    [dict setObject:[NSNumber numberWithDouble:366.28] forKey:key];
    
    key = [[ParticipantKey alloc] initWithReceiver:pHonza andPayer:pVaclav];
    [dict setObject:[NSNumber numberWithDouble:104.81] forKey:key];
    
    // Ludek
    
    key = [[ParticipantKey alloc] initWithReceiver:pLudek andPayer:pDan];
    [dict setObject:[NSNumber numberWithDouble:1944.19] forKey:key];
    
    key = [[ParticipantKey alloc] initWithReceiver:pLudek andPayer:pMarek];
    [dict setObject:[NSNumber numberWithDouble:1786.80] forKey:key];
    
    key = [[ParticipantKey alloc] initWithReceiver:pLudek andPayer:pTomas];
    [dict setObject:[NSNumber numberWithDouble:195.35] forKey:key];
    
    // Marek
    
    key = [[ParticipantKey alloc] initWithReceiver:pMarek andPayer:pDan];
    [dict setObject:[NSNumber numberWithDouble:805.59] forKey:key];
    
    // Michael
    
    key = [[ParticipantKey alloc] initWithReceiver:pMichael andPayer:pDan];
    [dict setObject:[NSNumber numberWithDouble:1134.15] forKey:key];
    
    key = [[ParticipantKey alloc] initWithReceiver:pMichael andPayer:pEvicka];
    [dict setObject:[NSNumber numberWithDouble:100.00] forKey:key];
    
    key = [[ParticipantKey alloc] initWithReceiver:pMichael andPayer:pLudek];
    [dict setObject:[NSNumber numberWithDouble:170.93] forKey:key];
    
    key = [[ParticipantKey alloc] initWithReceiver:pMichael andPayer:pMarek];
    [dict setObject:[NSNumber numberWithDouble:870.20] forKey:key];
    
    key = [[ParticipantKey alloc] initWithReceiver:pMichael andPayer:pTomas];
    [dict setObject:[NSNumber numberWithDouble:366.28] forKey:key];
    
    key = [[ParticipantKey alloc] initWithReceiver:pMichael andPayer:pVaclav];
    [dict setObject:[NSNumber numberWithDouble:104.81] forKey:key];
    
    // Tomas
    
    key = [[ParticipantKey alloc] initWithReceiver:pTomas andPayer:pDan];
    [dict setObject:[NSNumber numberWithDouble:767.86] forKey:key];
    
    key = [[ParticipantKey alloc] initWithReceiver:pTomas andPayer:pMarek];
    [dict setObject:[NSNumber numberWithDouble:602.78] forKey:key];
    
    // Vaclav
    
    key = [[ParticipantKey alloc] initWithReceiver:pVaclav andPayer:pDan];
    [dict setObject:[NSNumber numberWithDouble:1163.42] forKey:key];
    
    key = [[ParticipantKey alloc] initWithReceiver:pVaclav andPayer:pLudek];
    [dict setObject:[NSNumber numberWithDouble:66.12] forKey:key];
    
    key = [[ParticipantKey alloc] initWithReceiver:pVaclav andPayer:pMarek];
    [dict setObject:[NSNumber numberWithDouble:666.52] forKey:key];
    
    key = [[ParticipantKey alloc] initWithReceiver:pVaclav andPayer:pTomas];
    [dict setObject:[NSNumber numberWithDouble:261.47] forKey:key];
    
    [summary applyCashierOption:pDan withParticipants:travel.participants];
    
    XCTAssertEqual([dict count], (NSUInteger) 7);
    
    [self assertDebtAmount:dict fromParticipant:pEvicka toParticipant:pDan withAmount:[NSNumber numberWithDouble:2185.9]];
    [self assertDebtAmount:dict fromParticipant:pHonza toParticipant:pDan withAmount:[NSNumber numberWithDouble:4867.7]];
    [self assertDebtAmount:dict fromParticipant:pLudek toParticipant:pDan withAmount:[NSNumber numberWithDouble:3315.56]];
    [self assertDebtAmount:dict fromParticipant:pDan toParticipant:pMarek withAmount:[NSNumber numberWithDouble:5677.3]];
    [self assertDebtAmount:dict fromParticipant:pMichael toParticipant:pDan withAmount:[NSNumber numberWithDouble:2746.37]];
    [self assertDebtAmount:dict fromParticipant:pDan toParticipant:pTomas withAmount:[NSNumber numberWithDouble:85.01]];
    [self assertDebtAmount:dict fromParticipant:pVaclav toParticipant:pDan withAmount:[NSNumber numberWithDouble:1943.1]];
}

- (void)testCashierOption2 {
    
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
    
    Entry *e1 = [NSEntityDescription insertNewObjectForEntityForName:@"Entry" inManagedObjectContext:context];
    e1.payer = p1;
    e1.receivers = travel.participants;
    [e1 addReceiverWeightsObject:[self newReceiverWeight:p1 withAmount:[NSNumber numberWithInt:1]]];
    [e1 addReceiverWeightsObject:[self newReceiverWeight:p2 withAmount:[NSNumber numberWithInt:1]]];
    [e1 addReceiverWeightsObject:[self newReceiverWeight:p3 withAmount:[NSNumber numberWithInt:1]]];
    [e1 addReceiverWeightsObject:[self newReceiverWeight:p4 withAmount:[NSNumber numberWithInt:1]]];
    e1.amount = [NSNumber numberWithInt:100];
    e1.currency = eur;
    
    Entry *e2 = [NSEntityDescription insertNewObjectForEntityForName:@"Entry" inManagedObjectContext:context];
    e2.payer = p2;
    [e2 addReceiverWeightsObject:[self newReceiverWeight:p1 withAmount:[NSNumber numberWithInt:1]]];
    [e2 addReceiverWeightsObject:[self newReceiverWeight:p2 withAmount:[NSNumber numberWithInt:1]]];
    [e2 addReceiverWeightsObject:[self newReceiverWeight:p3 withAmount:[NSNumber numberWithInt:1]]];
    [e2 addReceiverWeightsObject:[self newReceiverWeight:p4 withAmount:[NSNumber numberWithInt:1]]];
    e2.amount = [NSNumber numberWithInt:100];
    e2.currency = eur;
    
    [travel addEntriesObject:e1];
    [travel addEntriesObject:e2];
    
    Summary *summary = [Summary createSummary:travel]; 
    
    XCTAssertEqual(summary.accounts.count, (NSUInteger) 3);
}

- (void)testCashierDetection {
    
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
    
    Entry *e1 = [NSEntityDescription insertNewObjectForEntityForName:@"Entry" inManagedObjectContext:context];
    e1.payer = p1;
    e1.receivers = travel.participants;
    [e1 addReceiverWeightsObject:[self newReceiverWeight:p1 withAmount:[NSNumber numberWithInt:1]]];
    [e1 addReceiverWeightsObject:[self newReceiverWeight:p2 withAmount:[NSNumber numberWithInt:1]]];
    [e1 addReceiverWeightsObject:[self newReceiverWeight:p3 withAmount:[NSNumber numberWithInt:1]]];
    [e1 addReceiverWeightsObject:[self newReceiverWeight:p4 withAmount:[NSNumber numberWithInt:1]]];
    e1.amount = [NSNumber numberWithInt:100];
    e1.currency = eur;
    
    Entry *e2 = [NSEntityDescription insertNewObjectForEntityForName:@"Entry" inManagedObjectContext:context];
    e2.payer = p2;
    [e2 addReceiverWeightsObject:[self newReceiverWeight:p1 withAmount:[NSNumber numberWithInt:1]]];
    [e2 addReceiverWeightsObject:[self newReceiverWeight:p2 withAmount:[NSNumber numberWithInt:1]]];
    [e2 addReceiverWeightsObject:[self newReceiverWeight:p3 withAmount:[NSNumber numberWithInt:1]]];
    [e2 addReceiverWeightsObject:[self newReceiverWeight:p4 withAmount:[NSNumber numberWithInt:1]]];
    e2.amount = [NSNumber numberWithInt:50];
    e2.currency = eur;
    
    Entry *e3 = [NSEntityDescription insertNewObjectForEntityForName:@"Entry" inManagedObjectContext:context];
    e3.payer = p2;
    [e3 addReceiverWeightsObject:[self newReceiverWeight:p1 withAmount:[NSNumber numberWithInt:1]]];
    [e3 addReceiverWeightsObject:[self newReceiverWeight:p2 withAmount:[NSNumber numberWithInt:1]]];
    [e3 addReceiverWeightsObject:[self newReceiverWeight:p3 withAmount:[NSNumber numberWithInt:1]]];
    [e3 addReceiverWeightsObject:[self newReceiverWeight:p4 withAmount:[NSNumber numberWithInt:1]]];
    e3.amount = [NSNumber numberWithInt:50];
    e3.currency = eur;
    
    [travel addEntriesObject:e1];
    [travel addEntriesObject:e2];
    [travel addEntriesObject:e3];
    
    Summary *summary = [Summary createSummary:travel];
    
    XCTAssertEqual([summary decideCashier:travel], p2);
    
    travel.cashier = p1;
    XCTAssertEqual([summary decideCashier:travel], p1);
    
    travel.cashier = p2;
    XCTAssertEqual([summary decideCashier:travel], p2);
}

- (void)testCashierOptionGenericCompare {
    
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
    Participant *p5 = [NSEntityDescription insertNewObjectForEntityForName:@"Participant" inManagedObjectContext:context];
    p5.name = @"p5";
    
    [travel addParticipantsObject:p1];
    [travel addParticipantsObject:p2];
    [travel addParticipantsObject:p3];
    [travel addParticipantsObject:p4];
    [travel addParticipantsObject:p5];
    
    for (int times=0; times < 10; times++) {
        
        [travel removeEntries:travel.entries];
        int entryCount = ((arc4random() % 20) + 20);
        for (int i=0; i < entryCount; i++) {
            Entry *e1 = [NSEntityDescription insertNewObjectForEntityForName:@"Entry" inManagedObjectContext:context];
            e1.payer = [[travel.participants allObjects] objectAtIndex:(arc4random() % travel.participants.count)];
            e1.receivers = travel.participants;
            [e1 addReceiverWeightsObject:[self newReceiverWeight:p1 withAmount:[NSNumber numberWithInt:1]]];
            [e1 addReceiverWeightsObject:[self newReceiverWeight:p2 withAmount:[NSNumber numberWithInt:1]]];
            [e1 addReceiverWeightsObject:[self newReceiverWeight:p3 withAmount:[NSNumber numberWithInt:1]]];
            [e1 addReceiverWeightsObject:[self newReceiverWeight:p4 withAmount:[NSNumber numberWithInt:1]]];
            [e1 addReceiverWeightsObject:[self newReceiverWeight:p5 withAmount:[NSNumber numberWithInt:1]]];
            e1.amount = [NSNumber numberWithInt:((arc4random() % 501) + 100)];
            e1.currency = eur;
            
            [travel addEntriesObject:e1];
        }

        Summary *summary = [Summary createSummary:travel];
        
        Summary *summaryWO = [Summary createSummary:travel eliminateCircularDebts:YES applyCashierOption:NO];
        
        NSNumberFormatter *formatter = [[NSNumberFormatter alloc] init];
        [formatter setMaximumFractionDigits:1];
        [formatter setRoundingMode: NSNumberFormatterRoundDown];
        
        for (Participant *p in travel.participants) {
            double account1 = [self accountForParticipant:p fromSummary:summary];
            double account2 = [self accountForParticipant:p fromSummary:summaryWO];
            XCTAssertTrue([self firstDouble:account1 isEqualTo:account2]);
        }
    }
}

#define kVerySmallValue (0.02)

- (BOOL)firstDouble:(double)first isEqualTo:(double)second {
    
    if(fabsf(first - second) < kVerySmallValue)
        return YES;
    else
        return NO;
}

- (double)accountForParticipant:(Participant *)p fromSummary:(Summary *)summary {
    double account = 0;
    for (ParticipantKey *key in [summary.accounts keyEnumerator]) {
        if ([p isEqual:key.payer]) {
            account += [[summary.accounts objectForKey:key] doubleValue];
        } else if ([p isEqual:key.receiver]) {
            account -= [[summary.accounts objectForKey:key] doubleValue];
        }
    }
    return account;
}
@end
