//
//  UnitTests.m
//  UnitTests
//
//  Created by Martin Maier on 01/08/2011.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "UnitTests.h"
#import "ReiseabrechnungAppDelegate.h"
#import "CurrencyHelperCategory.h"
#import "ExchangeRate.h"

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
    
    chf.rate.rate = [NSNumber numberWithDouble:1.1];
    usd.rate.rate = [NSNumber numberWithDouble:1.5];
    
    STAssertEquals([chf convertToCurrency:chf amount:2.2], 2.2, nil);
    STAssertEquals([eur convertToCurrency:eur amount:2.2], 2.2, nil);
    
    STAssertEquals([chf convertToCurrency:eur amount:2], 2 / 1.1, nil); // = 1.8
    STAssertEquals([eur convertToCurrency:chf amount:2], 2 * 1.1, nil); // = 2.2
    
    STAssertEquals([usd convertToCurrency:eur amount:2], 2 / 1.5, nil); 
    STAssertEquals([eur convertToCurrency:usd amount:2], 2 * 1.5, nil); 
    
    STAssertEquals([chf convertToCurrency:usd amount:2], 2 / 1.1 * 1.5, nil);
    STAssertEquals([usd convertToCurrency:chf amount:2], 2 / 1.5 * 1.1, nil);

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
