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

@implementation UnitTests

- (void) setUp {
    NSArray *bundles = [NSArray arrayWithObject:[NSBundle bundleForClass:[self class]]];
    model = [[NSManagedObjectModel mergedModelFromBundles:bundles] retain];
    //NSLog(@"Model: %@", model);
    
    coordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:model];
    context = [[NSManagedObjectContext alloc] init];
    [context setPersistentStoreCoordinator:coordinator];
    
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

@end
