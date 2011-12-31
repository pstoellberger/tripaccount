//
//  ReiseabrechnungAppDelegate.m
//  Reiseabrechnung
//
//  Created by Martin Maier on 28/06/2011.
//  Copyright 2011 Martin Maier. All rights reserved.
//

#import "ReiseabrechnungAppDelegate.h"
#import "RootViewController.h"
#import "Currency.h"
#import "Country.h"
#import "Type.h"
#import "UIFactory.h" 
#import "ShadowNavigationController.h"
#import "AppDefaults.h"
#import "CurrencyRefresh.h"
#import "ExchangeRate.h"
#import "City.h"
#import "Summary.h"
#import "Appirater.h"
#import "Crittercism.h"
#import "MTStatusBarOverlay.h"
#import "ReceiverWeight.h"
#import "Participant.h"

@implementation ReiseabrechnungAppDelegate

@synthesize helpBubbles=_helpBubbles;

@synthesize window=_window;
@synthesize navController=_navController;
@synthesize managedObjectContext=_managedObjectContext;
@synthesize managedObjectModel=_managedObjectModel;
@synthesize persistentStoreCoordinator=_persistentStoreCoordinator;
@synthesize locator=_locator;
@synthesize statusbarOverlay=_statusbarOverlay;

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOption {
    
    [self initUserDefaults];
    
    self.locator = [[[Locator alloc] initInManagedObjectContext:self.managedObjectContext] autorelease];
    
    self.helpBubbles = [NSMutableArray array];
    
    [self.window addSubview:[UIFactory createBackgroundViewWithFrame:self.window.frame]];
    
    UIActivityIndicatorView *actView = [[UIActivityIndicatorView alloc] initWithFrame:CGRectMake((self.window.frame.size.width - 40) / 2, (self.window.frame.size.height - 40) / 2, 40, 40)];
    actView.activityIndicatorViewStyle = UIActivityIndicatorViewStyleWhiteLarge;
    [self.window addSubview:actView];
    [self.window makeKeyAndVisible];
    
    self.statusbarOverlay = [MTStatusBarOverlay sharedInstance];
    self.statusbarOverlay.animation = MTStatusBarOverlayAnimationShrink;  // MTStatusBarOverlayAnimationShrink
    self.statusbarOverlay.detailViewMode = MTDetailViewModeCustom;         // enable automatic history-tracking and show in detail-view
    self.statusbarOverlay.delegate = self;

    [actView startAnimating];
    
    dispatch_queue_t updateQueue = dispatch_queue_create("InitQ", NULL);
    
    dispatch_async(updateQueue, ^{
        
        [self performInitialisations:self.window];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            [actView stopAnimating];
            [actView removeFromSuperview];
            
            RootViewController *rvc = [[RootViewController alloc] initInManagedObjectContext:self.managedObjectContext];
            self.navController = [[[ShadowNavigationController alloc] initWithRootViewController:rvc] autorelease];
            self.navController.delegate = rvc;
     
            
#if TARGET_IPHONE_SIMULATOR
            NSLog(@"Crittercism disabled in Simulator.");
#else
            [Crittercism initWithAppID: @"4ec2ddd83f5b31291100000e"
                                andKey:@"4ec2ddd83f5b31291100000ewufkre3p"
                             andSecret:@"0ilulrbcdkvhhn38o61neacyfgmgsdzu"
                 andMainViewController:self.navController];
#endif
            
            [rvc release];
            
            [self.window addSubview:self.navController.view];
            
            [Appirater appLaunched:YES];

        });
    });
    
    return YES;
    
}

#define INDIC_SIZE 40

- (void)performInitialisations:(UIWindow *)window {
    
    [self checkForResetOfHelpBubbles];
    
    [self initializeStartDatabase:[NSBundle mainBundle]];
    
    [self initializeSampleTrip];
    
    [self fixUsDollar];
    
    [self refreshCurrencyRatesIfOutDated];
    
    [self upgradeFromVersion1];
    
}

- (void)initUserDefaults {
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSDictionary *appDefaults = [NSDictionary dictionaryWithObject:@"NO" forKey:@"includeImages"];
    [defaults registerDefaults:appDefaults];
    [defaults synchronize];
    
}

- (void)fixUsDollar {
    
    NSFetchRequest *req = [[NSFetchRequest alloc] init];
    req.entity = [NSEntityDescription entityForName:@"Currency" inManagedObjectContext: self.managedObjectContext];
    req.predicate = [NSPredicate predicateWithFormat:@"name_de == 'Us-Dollar'"];
    NSArray *currencies = [self.managedObjectContext executeFetchRequest:req error:nil];    
    if (currencies && [currencies count] == 1) {
        Currency *currency = [currencies lastObject];
        currency.name_de = @"US-Dollar";
        [ReiseabrechnungAppDelegate saveContext:self.managedObjectContext];
    }
    [req release];
}

- (void)initializeStartDatabase:(NSBundle *)bundle {        
    
    NSFetchRequest *req = [[NSFetchRequest alloc] init];
    req.entity = [NSEntityDescription entityForName:@"Currency" inManagedObjectContext: self.managedObjectContext];
    NSArray *currencies = [self.managedObjectContext executeFetchRequest:req error:nil];
    
    if (![currencies lastObject]) {
        
        [self.statusbarOverlay postMessage:@"Initialising..." duration:1];
        
        NSLog(@"Initialising countries...");
        NSString *pathCountryPlist =[bundle pathForResource:@"countries" ofType:@"plist"];
        NSDictionary* countryDict = [[NSDictionary alloc] initWithContentsOfFile:pathCountryPlist];
        NSArray *countries = [countryDict valueForKey:@"countries"];
        
        NSMutableDictionary *orderCountryDict = [[NSMutableDictionary alloc] init];
        
        for (NSDictionary *countryItem in countries) {
            Country *_country = [NSEntityDescription insertNewObjectForEntityForName:@"Country" inManagedObjectContext:self.managedObjectContext];
            _country.name = [countryItem valueForKey:@"name"];
            _country.name_de = [countryItem valueForKey:@"name_de"];
            _country.image = [countryItem valueForKey:@"image"];
            
            NSString *countryId = [NSString stringWithFormat:@"%@", [countryItem valueForKey:@"id"]];
            [orderCountryDict setValue:_country forKey:countryId];
            
            NSDictionary *cities = [countryItem valueForKey:@"cities"];
            for (NSDictionary *cityItem in cities) {
                City *_city = [NSEntityDescription insertNewObjectForEntityForName:@"City" inManagedObjectContext:self.managedObjectContext];
                _city.name = [cityItem valueForKey:@"name"];
                _city.latitude = [cityItem valueForKey:@"latitude"];
                _city.longitude = [cityItem valueForKey:@"longitude"];
                _city.country = _country;
            }
        }
        [countryDict release];
        
        NSLog(@"Initialising currencies...");
        NSString *pathCurrencyPlist =[bundle pathForResource:@"currencies" ofType:@"plist"];
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
            _currency.name_de = [[currencyItem valueForKey:@"name_de"] capitalizedString];
            _currency.digits = [currencyItem valueForKey:@"digits"];
            
            NSArray *countriesForCurrency = [currencyItem valueForKey:@"countries"];
            for (id countryItem in countriesForCurrency) {
                NSString *countryId = [NSString stringWithFormat:@"%@", countryItem];
                [_currency addCountriesObject:(Country *)[orderCountryDict objectForKey:countryId]];
            }
            
            NSDictionary *ratesForCurrency = [currencyItem valueForKey:@"rates"];
            NSEnumerator *ratesForCurrencyEnum = [ratesForCurrency keyEnumerator];
            for (NSString *ratesForCurrencyKey in [ratesForCurrencyEnum allObjects]) {
                
                if ([ratesForCurrencyKey isEqualToString:@"EUR"]) {
                    ratesForCurrencyKey = [ratesForCurrencyKey uppercaseString];
                    ExchangeRate *rate = [NSEntityDescription insertNewObjectForEntityForName:@"ExchangeRate" inManagedObjectContext:self.managedObjectContext];
                    
                    rate.counterCurrency = _currency;
                    rate.rate = [ratesForCurrency valueForKey:ratesForCurrencyKey];
                    rate.defaultRate = [NSNumber numberWithInt:1];
                    
                    Currency *baseCurrency = [newCurrencies objectForKey:ratesForCurrencyKey];
                    if (!baseCurrency) {
                        baseCurrency = [NSEntityDescription insertNewObjectForEntityForName:@"Currency" inManagedObjectContext:self.managedObjectContext];
                        baseCurrency.code = ratesForCurrencyKey;
                        [newCurrencies setObject:baseCurrency forKey:ratesForCurrencyKey];
                    }
                    rate.baseCurrency = baseCurrency;
                    
                    //[_currency addRatesObject:rate];
                }
            }
        }
        
        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
        if (![defaults objectForKey:[CurrencyRefresh lastUpdatedKey]]) {
            [defaults setObject:[currencyDict valueForKey:@"lastUpdated"] forKey:[CurrencyRefresh lastUpdatedKey]];
            [defaults synchronize];                
        }
        
        [currencyDict release];
        [orderCountryDict release];
        
        [ReiseabrechnungAppDelegate saveContext:self.managedObjectContext];
        
    }
    
    currencies = [self.managedObjectContext executeFetchRequest:req error:nil];
    [req release];
    
    for (Currency *c in currencies) {
        if ([c.rates count] == 0){
            NSLog(@"no rate for currency %@", c.name);
        }
    }
    
    NSFetchRequest *reqType = [[NSFetchRequest alloc] init];
    reqType.entity = [NSEntityDescription entityForName:@"Type" inManagedObjectContext: self.managedObjectContext];
    NSArray *types = [self.managedObjectContext executeFetchRequest:reqType error:nil];
    [reqType release];
    
    Type *_defaultType = nil;
    if (![types lastObject]) {
        
        NSLog(@"Initialising types...");
        
        NSString *typesPlistPath = [bundle pathForResource:@"types" ofType:@"plist"];
        NSArray *staticTypeNames = [[NSDictionary dictionaryWithContentsOfFile:typesPlistPath] valueForKey:@"types"];
        
        for (NSDictionary *staticTypeNameDict in staticTypeNames) {
            Type *_type = [NSEntityDescription insertNewObjectForEntityForName:@"Type" inManagedObjectContext:self.managedObjectContext];
            
            for (NSString *key in [staticTypeNameDict keyEnumerator]) {
                SEL setter = NSSelectorFromString([NSString stringWithFormat:@"set%@%@:", [[key substringToIndex:1] uppercaseString], [key substringFromIndex:1], nil]);
                if ([_type respondsToSelector:setter]) {
                    [_type performSelector:setter withObject:[staticTypeNameDict objectForKey:key]];
                }
            }
            
            if ([_type.name isEqualToString:@"Other"]) {
                _defaultType = _type;
            }
        }
        
        [ReiseabrechnungAppDelegate saveContext:self.managedObjectContext];
    }
    
    AppDefaults *defaultObject = [ReiseabrechnungAppDelegate defaultsObject:self.managedObjectContext];
    
    if (!defaultObject.homeCurrency) {
        
        NSLog(@"Initialising defaults...");
        defaultObject.homeCurrency = [ReiseabrechnungAppDelegate defaultCurrency:self.managedObjectContext];
        defaultObject.defaultType = _defaultType;
        
        [ReiseabrechnungAppDelegate saveContext:self.managedObjectContext];
    }
}

- (void)initializeSampleTrip {
    
    if (![[ReiseabrechnungAppDelegate defaultsObject:self.managedObjectContext].sampleTravelCreated isEqual:[NSNumber numberWithInt:1]]) {
        
        NSLog(@"Initialising sample travel...");
        
        Travel *travel = [NSEntityDescription insertNewObjectForEntityForName:@"Travel" inManagedObjectContext:self.managedObjectContext];
        travel.name = NSLocalizedString(@"Sample Trip", @"sample trip name");
        travel.city = NSLocalizedString(@"Vienna", @"sampe trip Stadt");
        travel.closed = [NSNumber numberWithInt:0];
               
        NSFetchRequest *req = [[NSFetchRequest alloc] init];
        req.entity = [NSEntityDescription entityForName:@"Country" inManagedObjectContext: self.managedObjectContext];
        req.predicate = [NSPredicate predicateWithFormat:@"name = 'Austria'"];
        
        travel.country = [[self.managedObjectContext executeFetchRequest:req error:nil] lastObject];
        [req release];
        
        // currencies
        req = [[NSFetchRequest alloc] init];
        req.entity = [NSEntityDescription entityForName:@"Currency" inManagedObjectContext: self.managedObjectContext];
        req.predicate = [NSPredicate predicateWithFormat:@"code = 'USD'"];
        Currency *usdCurrency = [[self.managedObjectContext executeFetchRequest:req error:nil] lastObject];
        [travel addCurrenciesObject:usdCurrency];
        [req release];
        
        req = [[NSFetchRequest alloc] init];
        req.entity = [NSEntityDescription entityForName:@"Currency" inManagedObjectContext: self.managedObjectContext];
        req.predicate = [NSPredicate predicateWithFormat:@"code = 'EUR'"];
        Currency *eurCurrency = [[self.managedObjectContext executeFetchRequest:req error:nil] lastObject];
        [travel addCurrenciesObject:eurCurrency];
        [req release];
        
        // rates
        [travel addRatesObject:usdCurrency.defaultRate];
        [travel addRatesObject:eurCurrency.defaultRate];
        
        travel.displayCurrency = eurCurrency;
        travel.displaySort = [NSNumber numberWithInt:1];
        
        Participant *p1 = [NSEntityDescription insertNewObjectForEntityForName:@"Participant" inManagedObjectContext:self.managedObjectContext];
        p1.name =  @"Leonardo";
        p1.email = @"leonardo@tmnt.com";
        p1.image = [NSData dataWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"leo" ofType:@"png"]];
        p1.imageSmall = UIImagePNGRepresentation([UIFactory imageWithImage:[UIImage imageWithData:p1.image] scaledToSize:CGSizeMake(32, 32)]);
        
        Participant *p2 = [NSEntityDescription insertNewObjectForEntityForName:@"Participant" inManagedObjectContext:self.managedObjectContext];
        p2.name =  @"Raphael";
        p2.email = @"raphael@tmnt.com";
        p2.image = [NSData dataWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"raphael" ofType:@"png"]];
        p2.imageSmall = UIImagePNGRepresentation([UIFactory imageWithImage:[UIImage imageWithData:p2.image] scaledToSize:CGSizeMake(32, 32)]);
        
        Participant *p3 = [NSEntityDescription insertNewObjectForEntityForName:@"Participant" inManagedObjectContext:self.managedObjectContext];
        p3.name =  @"Donatello";
        p3.email = @"donatello@tmnt.com";
        p3.image = [NSData dataWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"donatello" ofType:@"png"]];
        p3.imageSmall = UIImagePNGRepresentation([UIFactory imageWithImage:[UIImage imageWithData:p3.image] scaledToSize:CGSizeMake(32, 32)]);
        
        Participant *p4 = [NSEntityDescription insertNewObjectForEntityForName:@"Participant" inManagedObjectContext:self.managedObjectContext];
        p4.name =  @"Michelangelo";
        p4.email = @"michelangelo@tmnt.com";
        p4.image = [NSData dataWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"michelangelo" ofType:@"png"]];
        p4.imageSmall = UIImagePNGRepresentation([UIFactory imageWithImage:[UIImage imageWithData:p4.image] scaledToSize:CGSizeMake(32, 32)]);
        
        [travel addParticipantsObject:p1];
        [travel addParticipantsObject:p2];
        [travel addParticipantsObject:p3];
        [travel addParticipantsObject:p4];
        
        NSArray *participantArray = [NSArray arrayWithObjects:p1, p2, p3, p4, nil];
        
        NSString *sampleTripPlist =[[NSBundle mainBundle] pathForResource:@"sampleTrip" ofType:@"plist"];
        NSDictionary *sampleTripDict = [[NSDictionary alloc] initWithContentsOfFile:sampleTripPlist];
        
        NSArray *entriesArray = [sampleTripDict objectForKey:@"entries"];
        for (NSDictionary *entryDict in entriesArray) {
            
            Entry *entry = [NSEntityDescription insertNewObjectForEntityForName:@"Entry" inManagedObjectContext:self.managedObjectContext];
            entry.travel = travel;
            
            entry.created = [NSDate date];
            entry.lastUpdated = [NSDate date];
            
            entry.payer = [participantArray objectAtIndex:[[entryDict objectForKey:@"payer"] intValue]];
            entry.text = [entryDict objectForKey:@"description"];
            entry.amount = [entryDict objectForKey:@"amount"];

            NSDate *date = [[UIFactory createDateWithoutTimeFromDate:[NSDate date]] dateByAddingTimeInterval:-7 * 60 * 60 * 24];
            entry.date = [date dateByAddingTimeInterval:([[entryDict objectForKey:@"date"] intValue] * 60 * 60 * 24)];
            
            NSArray *receiverArray = [entryDict objectForKey:@"receivers"];
            for (NSNumber *receiverNumber in receiverArray) {
                ReceiverWeight *recWeight = [NSEntityDescription insertNewObjectForEntityForName:@"ReceiverWeight" inManagedObjectContext:self.managedObjectContext];
                recWeight.weight = [NSNumber numberWithDouble:1.0];
                recWeight.participant = [participantArray objectAtIndex:[receiverNumber intValue]];
                [entry addReceiverWeightsObject:recWeight];
            }
        
            if ([[entryDict objectForKey:@"currency"] isEqualToString:@"USD"]) {
                entry.currency = usdCurrency;
            } else if ([[entryDict objectForKey:@"currency"] isEqualToString:@"EUR"]) {
                entry.currency = eurCurrency;
            }
            
            req = [[NSFetchRequest alloc] init];
            req.entity = [NSEntityDescription entityForName:@"Type" inManagedObjectContext: self.managedObjectContext];
            req.predicate = [NSPredicate predicateWithFormat:@"name = %@", [entryDict objectForKey:@"type"]];
            entry.type = [[self.managedObjectContext executeFetchRequest:req error:nil] lastObject];
            [req release];
        }
        [sampleTripDict release];
        
        [Summary updateSummaryOfTravel:travel];
        
        [ReiseabrechnungAppDelegate defaultsObject:self.managedObjectContext].sampleTravelCreated = [NSNumber numberWithInt:1];
        [ReiseabrechnungAppDelegate saveContext:self.managedObjectContext];
    }
    
}

- (void)upgradeFromVersion1 {
    
    NSFetchRequest *req = [[NSFetchRequest alloc] init];
    req.entity = [NSEntityDescription entityForName:@"Travel" inManagedObjectContext: self.managedObjectContext];
    NSArray *travels = [self.managedObjectContext executeFetchRequest:req error:nil];
    [req release];
    
    for (Travel* travel in travels) {
        for (Entry *entry in travel.entries) {
            if (entry.receivers) {
                for (Participant *participant in entry.receivers) {
                    ReceiverWeight *recWeight = [NSEntityDescription insertNewObjectForEntityForName:@"ReceiverWeight" inManagedObjectContext:self.managedObjectContext];
                    recWeight.participant = participant;
                    [entry addReceiverWeightsObject:recWeight];
                }
                [entry removeReceivers:entry.receivers];
            }
        }
    }
    
    [ReiseabrechnungAppDelegate saveContext:self.managedObjectContext];
}

- (void)checkForResetOfHelpBubbles {
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults synchronize];
    BOOL resetBubbles = [defaults boolForKey:@"resetBubbles"];
    
    if (resetBubbles) {
        NSLog(@"Resetting help bubbles...");
        [defaults removeObjectForKey:[HelpView DICTIONARY_KEY]];
        [defaults setBool:NO forKey:@"resetBubbles"];
        [defaults synchronize];
        
        for (HelpView *view in self.helpBubbles) {
            if (view.hidden) {
                view.hidden = false;
                [view enterStage];
            }
        }
    }
    
}


- (void)registerHelpBubble:(HelpView *)helpView {
    
    if (![self.helpBubbles containsObject:helpView]) {
        [self.helpBubbles addObject:helpView];
    }
    
}

- (void)refreshCurrencyRatesIfOutDated {
    
    CurrencyRefresh *currencyRefresh = [[CurrencyRefresh alloc] initInManagedContext:[self createNewManagedObjectContext]];
    
    NSLog(@"Checking if currency rates are outdated.");
    
    if ([currencyRefresh areRatesOutdated]) {
        
        NSLog(@"Refreshing currency rates...");
        
        dispatch_queue_t updateQueue = dispatch_queue_create("UpdateQueue", NULL);
        
        dispatch_async(updateQueue, ^{
            
            [NSThread sleepForTimeInterval:1];
            
            [currencyRefresh refreshCurrencies];
            [currencyRefresh release];
            
            NSLog(@"Refresh finished.");
        });
        
    } else {
        
        [currencyRefresh release];
    }
    
}

+ (Currency *)defaultCurrency:(NSManagedObjectContext *) context {
    
    NSLocale *theLocale = [NSLocale currentLocale];
    NSString *code = [theLocale objectForKey:NSLocaleCurrencyCode];
    
    NSFetchRequest *req = [[NSFetchRequest alloc] init];
    req.entity = [NSEntityDescription entityForName:@"Currency" inManagedObjectContext:context];
    req.predicate = [NSPredicate predicateWithFormat:@"code = %@", code];
    NSArray *curSet = [context executeFetchRequest:req error:nil];
    [req release];
    
    if ([curSet lastObject]) {
        return [curSet lastObject];
    } else {
        NSFetchRequest *req = [[NSFetchRequest alloc] init];
        req.entity = [NSEntityDescription entityForName:@"Travel" inManagedObjectContext:context];
        req.sortDescriptors = [NSArray arrayWithObject:[NSSortDescriptor sortDescriptorWithKey:@"closedDate" ascending:YES]];
        NSArray *travelSet = [context executeFetchRequest:req error:nil];
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

- (void)onCrash {
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Crash"
                                                    message:@"The App has crashed and will attempt to send a crash report"
                                                   delegate:nil
                                          cancelButtonTitle:@"OK"
                                          otherButtonTitles:nil];
    [alert show];
    [alert release];
}

+ (void)saveContext:(NSManagedObjectContext *) context {
    
    NSError *error = nil;
    
    if (context != nil) {
        
        if ([[context persistentStoreCoordinator].persistentStores count] > 0) {
            
            if ([context hasChanges] && ![context save:&error]) {
                
                NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
                abort();
            } 
        } else {
            NSLog(@"No persistent store, saving will be skipped");
        }
    }
}

- (void)applicationWillResignActive:(UIApplication *)application {
    /*
     Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
     Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
     */
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    /*
     Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
     If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
     */
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
    /*
     Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
     */
    [self refreshCurrencyRatesIfOutDated];
    [self checkForResetOfHelpBubbles];
    
    [Appirater appEnteredForeground:YES];
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    /*
     Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
     */
}

- (void)applicationWillTerminate:(UIApplication *)application {
    /*
     Called when the application is about to terminate.
     Save data if appropriate.
     See also applicationDidEnterBackground:.
     */
    [ReiseabrechnungAppDelegate saveContext:[self managedObjectContext]];
}
                                        
                                        
- (NSManagedObjectContext *)createNewManagedObjectContext {
    
    @synchronized(self) {
        NSPersistentStoreCoordinator *coordinator = [self persistentStoreCoordinator];
        NSManagedObjectContext *managedObjectContext = nil;
        if (coordinator != nil) {
            managedObjectContext = [[[NSManagedObjectContext alloc] init] autorelease];
            [managedObjectContext setPersistentStoreCoordinator:coordinator];
            [managedObjectContext setMergePolicy:NSOverwriteMergePolicy];
        }
        return managedObjectContext;   
    }
}

- (NSManagedObjectContext *)managedObjectContext {
    
    if (_managedObjectContext != nil) {
        return _managedObjectContext;
    }
    
    _managedObjectContext = [self createNewManagedObjectContext];
    
    return _managedObjectContext;
}

/**
 Returns the managed object model for the application.
 If the model doesn't already exist, it is created from the application's model.
 */
- (NSManagedObjectModel *)managedObjectModel {
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
- (NSPersistentStoreCoordinator *)persistentStoreCoordinator {
    
    if (_persistentStoreCoordinator != nil) {
        return _persistentStoreCoordinator;
    }
    
    NSURL *storeURL = [[self applicationDocumentsDirectory] URLByAppendingPathComponent:@"database.sqlite"];
    
    NSError *error = nil;
    _persistentStoreCoordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:[self managedObjectModel]];
    
    NSDictionary *options = [NSDictionary dictionaryWithObjectsAndKeys:
                             [NSNumber numberWithBool:YES], NSMigratePersistentStoresAutomaticallyOption,
                             [NSNumber numberWithBool:YES], NSInferMappingModelAutomaticallyOption, nil];
    
    if (![_persistentStoreCoordinator addPersistentStoreWithType:NSSQLiteStoreType configuration:nil URL:storeURL options:options error:&error]) {
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
