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
#import "ImageCache.h"
#import "ParticipantView.h"
#import "DataInitialiser.h"

@implementation ReiseabrechnungAppDelegate

NSString *const ITUNES_STORE_LINK = @"itms-apps://itunes.apple.com/us/app/trip-account/id%d?mt=8&uo=4";
NSString *const ITUNES_STORE_RATE_LINK = @"itms-apps://ax.itunes.apple.com/WebObjects/MZStore.woa/wa/viewContentsUserReviews?type=Purple+Software&id=%d";

@synthesize helpBubbles=_helpBubbles;

@synthesize window=_window;
@synthesize navController=_navController;
@synthesize managedObjectContext=_managedObjectContext;
@synthesize managedObjectModel=_managedObjectModel;
@synthesize persistentStoreCoordinator=_persistentStoreCoordinator;
@synthesize locator=_locator;
@synthesize statusbarOverlay=_statusbarOverlay;

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOption {
    
    
#if TARGET_IPHONE_SIMULATOR
    NSLog(@"Crittercism disabled in Simulator.");
#else
    [Crittercism initWithAppID: @"4ec2ddd83f5b31291100000e"
                        andKey:@"4ec2ddd83f5b31291100000ewufkre3p"
                     andSecret:@"0ilulrbcdkvhhn38o61neacyfgmgsdzu"];
#endif
    
    [Crittercism leaveBreadcrumb:[NSString stringWithFormat:@"%@: %@ ", self.class, @"didFinishLaunchingWithOptions"]];
    
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
    
    [Crittercism leaveBreadcrumb:[NSString stringWithFormat:@"%@: %@ ", self.class, @"ActivityIndicator start animate"]];
    
    dispatch_queue_t updateQueue = dispatch_queue_create("InitQ", NULL);
    
    dispatch_async(updateQueue, ^{
        
        [self checkForResetOfHelpBubbles];
        
        DataInitialiser *dataInit = [[DataInitialiser alloc] init];
        [dataInit performDataInitialisations:self.window inContext:[self createNewManagedObjectContext]];
        [dataInit release];
        
        [self refreshCurrencyRatesIfOutDated];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            
            [actView stopAnimating];
            [actView removeFromSuperview];
            
            RootViewController *rvc = [[RootViewController alloc] initInManagedObjectContext:self.managedObjectContext];
            self.navController = [[[ShadowNavigationController alloc] initWithRootViewController:rvc] autorelease];
            self.navController.delegate = rvc;
            rvc.animationOngoing = YES;
            
            [self.window addSubview:self.navController.view];
            self.navController.view.transform = CGAffineTransformTranslate(CGAffineTransformIdentity, 320, 0);
            [UIView animateWithDuration:0.5
                                  delay:0 
                                options:(UIViewAnimationOptionAllowUserInteraction | UIViewAnimationOptionBeginFromCurrentState)
                             animations:^{
                                 self.navController.view.transform = CGAffineTransformTranslate(CGAffineTransformIdentity, -10, 0);
                             } 
                             completion:^(BOOL finished){
                                 if (finished) {
                                     [UIView animateWithDuration:0.2
                                                           delay:0 
                                                         options:(UIViewAnimationOptionAllowUserInteraction | UIViewAnimationOptionBeginFromCurrentState)
                                                      animations:^{
                                                          self.navController.view.transform = CGAffineTransformTranslate(CGAffineTransformIdentity, 5, 0);
                                                      } 
                                                      completion:^(BOOL finished){
                                                          if (finished) {
                                                              [UIView animateWithDuration:0.2
                                                                                    delay:0 
                                                                                  options:(UIViewAnimationOptionAllowUserInteraction | UIViewAnimationOptionBeginFromCurrentState)
                                                                               animations:^{
                                                                                   self.navController.view.transform = CGAffineTransformIdentity;
                                                                               }
                                                                               completion:^(BOOL finished){
                                                                                   rvc.animationOngoing = NO;
                                                                               }];
                                                          }
                                                      }]; 
                                 }
                             }];
                             
            
            [Appirater appLaunched:YES];
            
            [rvc release];

        });
    });
    
    return YES;
    
}

#define INDIC_SIZE 40

- (void)initUserDefaults {
    
    NSUserDefaults *appDefaults = [NSUserDefaults standardUserDefaults];
    [self userdefaults:appDefaults setIfDoesNotExist:NO forKey:@"includeImages"];
    [self userdefaults:appDefaults setIfDoesNotExist:YES forKey:@"showTotals"];
    [self userdefaults:appDefaults setIfDoesNotExist:YES forKey:@"includePersons"];
    [self userdefaults:appDefaults setIfDoesNotExist:YES forKey:@"includeEntries"];
    [self userdefaults:appDefaults setIfDoesNotExist:NO forKey:@"resetBubbles"];
    [self userdefaults:appDefaults setIfDoesNotExist:NO forKey:@"travelInitialised"];
    [self userdefaults:appDefaults setIfDoesNotExist:YES forKey:@"updateRates"];
    [self userdefaults:appDefaults setIfDoesNotExist:NO forKey:@"retryUpdateOnFailure"];
    [appDefaults synchronize];
}

- (void)userdefaults:(NSUserDefaults *)defaults setIfDoesNotExist:(BOOL)value forKey:(NSString *)key {
    if (![defaults.dictionaryRepresentation.allKeys containsObject:key]) {
        [defaults setBool:value forKey:key];
    }
}



- (void)checkForResetOfHelpBubbles {
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults synchronize];
    BOOL resetBubbles = [defaults boolForKey:@"resetBubbles"];
    
    if (resetBubbles) {
        NSLog(@"Resetting help bubbles...");
        [defaults setBool:NO forKey:@"resetBubbles"];
        [defaults removeObjectForKey:[HelpView DICTIONARY_KEY]];
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
    
    [Crittercism leaveBreadcrumb:@"ReiseabrechungAppDelegate: refreshCurrencyRatesIfOutDated"];

    dispatch_queue_t updateQueue = dispatch_queue_create("UpdateQueue", NULL);
    
    dispatch_async(updateQueue, ^{
        
        CurrencyRefresh *currencyRefresh = [[CurrencyRefresh alloc] initInManagedContext:[self createNewManagedObjectContext]];
        
        NSLog(@"Checking if currency rates are outdated.");
        
        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
        [defaults synchronize];
        BOOL updateRates = [defaults boolForKey:@"updateRates"];
        BOOL retryUpdateOnFailure = [defaults boolForKey:@"retryUpdateOnFailure"];
        
        if (updateRates && [currencyRefresh areRatesOutdated] && [currencyRefresh shouldRetry:retryUpdateOnFailure]) {
            
            NSLog(@"Refreshing currency rates...");
            
            [NSThread sleepForTimeInterval:1];
            
            [currencyRefresh refreshCurrencies];
            [currencyRefresh release];
            
            NSLog(@"Refresh finished.");
            
        } else {
            
            [currencyRefresh release];
        }
        
    });
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

- (void)applicationDidReceiveMemoryWarning:(UIApplication *)application {
    
    [ImageCache evictCache];
    [ParticipantView evictCache];
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
- (NSURL *)applicationDocumentsDirectory {
    return [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject];
}


- (void)dealloc {
    
    [_locator release];
    [_helpBubbles release];
    [_statusbarOverlay release];
    
    [_window release];
	[_navController release];
    [_managedObjectContext release];
    [_managedObjectModel release];
    [_persistentStoreCoordinator release];
    [super dealloc];
}

@end
