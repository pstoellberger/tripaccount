//
//  ReiseabrechnungAppDelegate.m
//  Reiseabrechnung
//
//  Created by Martin Maier on 28/06/2011.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "ReiseabrechnungAppDelegate.h"
#import "RootViewController.h"
#import "Currency.h"
#import "Country.h"
#import "Type.h"
#import "UIFactory.h" 
#import "ShadowNavigationController.h"
#import "FirstLetterCategory.h"
#import "AppDefaults.h"
#import "CurrencyRefresh.h"
#import "ExchangeRate.h"

@implementation ReiseabrechnungAppDelegate

@synthesize window=_window;
@synthesize navController=_navController;
@synthesize managedObjectContext=_managedObjectContext;
@synthesize managedObjectModel=_managedObjectModel;
@synthesize persistentStoreCoordinator=_persistentStoreCoordinator;

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{

    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleBlackOpaque];
    
    NSFetchRequest *req = [[NSFetchRequest alloc] init];
    req.entity = [NSEntityDescription entityForName:@"Currency" inManagedObjectContext: self.managedObjectContext];
    NSArray *currencies = [self.managedObjectContext executeFetchRequest:req error:nil];
    [req release];
    
    if (![currencies lastObject]) {
        
        NSLog(@"Initialising countries...");
        NSString *pathCountryPlist =[[NSBundle mainBundle] pathForResource:@"countries" ofType:@"plist"];
        NSDictionary* countryDict = [[NSDictionary alloc] initWithContentsOfFile:pathCountryPlist];
        NSArray *countries = [countryDict valueForKey:@"countries"];
        
        NSMutableDictionary *orderCountryDict = [[NSMutableDictionary alloc] init];
        
        for (NSDictionary *countryItem in countries) {
            Country *_country = [NSEntityDescription insertNewObjectForEntityForName:@"Country" inManagedObjectContext:self.managedObjectContext];
            _country.name = [countryItem valueForKey:@"name"];
            _country.image = [countryItem valueForKey:@"image"];
            
            NSString *countryId = [NSString stringWithFormat:@"%@", [countryItem valueForKey:@"id"]];
            [orderCountryDict setValue:_country forKey:countryId];
        }
        [countryDict release];
        
        NSLog(@"Initialising currencies...");
        NSString *pathCurrencyPlist =[[NSBundle mainBundle] pathForResource:@"currencies" ofType:@"plist"];
        NSDictionary* currencyDict = [[NSDictionary alloc] initWithContentsOfFile:pathCurrencyPlist];
        NSArray *currencies = [currencyDict valueForKey:@"currencies"];
        
        NSMutableDictionary *newCurrencies = [NSMutableDictionary dictionary];

        for (NSDictionary *currencyItem in currencies) {
            
            NSString *currencyIsoCode = [[currencyItem valueForKey:@"code"] uppercaseString];
            Currency *_currency = [newCurrencies objectForKey:currencyIsoCode];
            if (!_currency) {
                _currency = [NSEntityDescription insertNewObjectForEntityForName:@"Currency" inManagedObjectContext:self.managedObjectContext];
                [newCurrencies setObject:_currency forKey:currencyIsoCode];
            }
            _currency.code = currencyIsoCode;
            _currency.name = [[currencyItem valueForKey:@"name"] capitalizedString];
            _currency.digits = [currencyItem valueForKey:@"digits"];
            
            NSArray *countriesForCurrency = [currencyItem valueForKey:@"countries"];
            for (id countryItem in countriesForCurrency) {
                NSString *countryId = [NSString stringWithFormat:@"%@", countryItem];
                [_currency addCountriesObject:(Country *)[orderCountryDict objectForKey:countryId]];
            }
            
            NSDictionary *ratesForCurrency = [currencyItem valueForKey:@"rates"];
            NSEnumerator *ratesForCurrencyEnum = [ratesForCurrency keyEnumerator];
            for (NSString *ratesForCurrencyKey in [ratesForCurrencyEnum allObjects]) {
                
                ratesForCurrencyKey = [ratesForCurrencyKey uppercaseString];
                ExchangeRate *rate = [NSEntityDescription insertNewObjectForEntityForName:@"ExchangeRate" inManagedObjectContext:self.managedObjectContext];
                rate.counterCurrency = _currency;
                rate.rate = [ratesForCurrency valueForKey:ratesForCurrencyKey];
                
                Currency *baseCurrency = [newCurrencies objectForKey:ratesForCurrencyKey];
                if (!baseCurrency) {
                    baseCurrency = [NSEntityDescription insertNewObjectForEntityForName:@"Currency" inManagedObjectContext:self.managedObjectContext];
                    baseCurrency.code = ratesForCurrencyKey;
                    [newCurrencies setObject:baseCurrency forKey:ratesForCurrencyKey];
                }
                rate.baseCurrency = baseCurrency;
                
                [_currency addRatesWithCounterCurrencyObject:rate];
            }
        }
        [currencyDict release];
        [orderCountryDict release];
        
        [ReiseabrechnungAppDelegate saveContext:self.managedObjectContext];
    }
    
    NSFetchRequest *reqType = [[NSFetchRequest alloc] init];
    reqType.entity = [NSEntityDescription entityForName:@"Type" inManagedObjectContext: self.managedObjectContext];
    NSArray *types = [self.managedObjectContext executeFetchRequest:reqType error:nil];
    [reqType release];
    
    Type *_defaultType = nil;
    if (![types lastObject]) {
        
        NSLog(@"Initialising types...");
        
        NSString *typesPlistPath = [[NSBundle mainBundle] pathForResource:@"types" ofType:@"plist"];
        NSArray *staticTypeNames = [[NSDictionary dictionaryWithContentsOfFile:typesPlistPath] valueForKey:@"types"];
        
        for (NSString *staticTypeName in staticTypeNames) {
            Type *_type = [NSEntityDescription insertNewObjectForEntityForName:@"Type" inManagedObjectContext:self.managedObjectContext];
            _type.name = staticTypeName;
            
            if ([_type.name isEqualToString:@"None"]) {
                _defaultType = _type;
            }
        }
        
        [ReiseabrechnungAppDelegate saveContext:self.managedObjectContext];
    }
    
    AppDefaults *defaultObject = [ReiseabrechnungAppDelegate defaultsObject:self.managedObjectContext];
    
    if (!defaultObject.homeCurrency) {
        
        NSLog(@"Initialising defaults...");
        defaultObject.homeCurrency = [self defaultCurrency];
        defaultObject.defaultType = _defaultType;
        
        [ReiseabrechnungAppDelegate saveContext:self.managedObjectContext];
    }

    [self.window addSubview:[UIFactory createBackgroundViewWithFrame:self.window.frame]];
    
    //NSLog(@"Updating currencies...");
    CurrencyRefresh *currencyRefresh = [[CurrencyRefresh alloc] initInManagedContext:self.managedObjectContext];
    //[currencyRefresh refreshCurrencies:@"EUR"];
    [currencyRefresh release];
    
    RootViewController *rvc = [[RootViewController alloc] initInManagedObjectContext:self.managedObjectContext];
    self.navController = [[[ShadowNavigationController alloc] initWithRootViewController:rvc] autorelease];
    [rvc release];
    
    [self.window addSubview:self.navController.view];
    [self.window makeKeyAndVisible];
    
    return YES;
}

- (Currency *)defaultCurrency {
    
    NSLocale *theLocale = [NSLocale currentLocale];
    NSString *code = [theLocale objectForKey:NSLocaleCurrencyCode];
    
    NSFetchRequest *req = [[NSFetchRequest alloc] init];
    req.entity = [NSEntityDescription entityForName:@"Currency" inManagedObjectContext: self.managedObjectContext];
    req.predicate = [NSPredicate predicateWithFormat:@"code = %@", code];
    NSArray *curSet = [self.managedObjectContext executeFetchRequest:req error:nil];
    [req release];
    
    if ([curSet lastObject]) {
        return [curSet lastObject];
    } else {
        NSFetchRequest *req = [[NSFetchRequest alloc] init];
        req.entity = [NSEntityDescription entityForName:@"Travel" inManagedObjectContext: self.managedObjectContext];
        req.sortDescriptors = [NSArray arrayWithObject:[NSSortDescriptor sortDescriptorWithKey:@"date" ascending:YES]];
        NSArray *travelSet = [self.managedObjectContext executeFetchRequest:req error:nil];
        [req release];
        
        if ([travelSet lastObject]) {
            return [travelSet lastObject];
        }
    }
    
    return nil;
}

+ (AppDefaults *)defaultsObject:(NSManagedObjectContext *) context {
    
    NSFetchRequest *reqDefaults = [[NSFetchRequest alloc] init];
    reqDefaults.entity = [NSEntityDescription entityForName:@"AppDefaults" inManagedObjectContext: context];
    NSArray *defaults = [context executeFetchRequest:reqDefaults error:nil];
    [reqDefaults release];
    
    AppDefaults *defaultObj = [defaults lastObject];
    if (!defaultObj) {
        defaultObj = [NSEntityDescription insertNewObjectForEntityForName:@"AppDefaults" inManagedObjectContext:context];
        [ReiseabrechnungAppDelegate saveContext:context];
    }
    return defaultObj;
}

+ (void)saveContext:(NSManagedObjectContext *) context
{
    NSError *error = nil;
    if (context != nil)
    {
        if ([context hasChanges] && ![context save:&error])
        {
            NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
            abort();
        } 
    }
}

- (void)applicationWillResignActive:(UIApplication *)application
{
    /*
     Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
     Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
     */
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    /*
     Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
     If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
     */
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    /*
     Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
     */
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    /*
     Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
     */
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    /*
     Called when the application is about to terminate.
     Save data if appropriate.
     See also applicationDidEnterBackground:.
     */
}

- (NSManagedObjectContext *)managedObjectContext
{
    if (_managedObjectContext != nil)
    {
        return _managedObjectContext;
    }
    
    NSPersistentStoreCoordinator *coordinator = [self persistentStoreCoordinator];
    if (coordinator != nil)
    {
        _managedObjectContext = [[NSManagedObjectContext alloc] init];
        [_managedObjectContext setPersistentStoreCoordinator:coordinator];
    }
    return _managedObjectContext;
}

/**
 Returns the managed object model for the application.
 If the model doesn't already exist, it is created from the application's model.
 */
- (NSManagedObjectModel *)managedObjectModel
{
    if (_managedObjectModel != nil)
    {
        return _managedObjectModel;
    }
    NSURL *modelURL = [[NSBundle mainBundle] URLForResource:@"Model" withExtension:@"momd"];
    _managedObjectModel = [[NSManagedObjectModel alloc] initWithContentsOfURL:modelURL];    
    return _managedObjectModel;
}

/**
 Returns the persistent store coordinator for the application.
 If the coordinator doesn't already exist, it is created and the application's store added to it.
 */
- (NSPersistentStoreCoordinator *)persistentStoreCoordinator
{
    if (_persistentStoreCoordinator != nil)
    {
        return _persistentStoreCoordinator;
    }
    
    NSURL *storeURL = [[self applicationDocumentsDirectory] URLByAppendingPathComponent:@"database2.sqlite"];
    
    NSError *error = nil;
    _persistentStoreCoordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:[self managedObjectModel]];
    if (![_persistentStoreCoordinator addPersistentStoreWithType:NSSQLiteStoreType configuration:nil URL:storeURL options:nil error:&error])
    {
        NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
        abort();
    }    
    
    return _persistentStoreCoordinator;
}

#pragma mark - Application's Documents directory

/**
 Returns the URL to the application's Documents directory.
 */
- (NSURL *)applicationDocumentsDirectory
{
    return [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject];
}


- (void)dealloc
{
    [_window release];
	[_navController release];
    [_managedObjectContext release];
    [_managedObjectModel release];
    [_persistentStoreCoordinator release];
    [super dealloc];
}

@end
