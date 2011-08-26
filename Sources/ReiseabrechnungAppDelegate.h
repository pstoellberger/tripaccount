//
//  ReiseabrechnungAppDelegate.h
//  Reiseabrechnung
//
//  Created by Martin Maier on 28/06/2011.
//  Copyright 2011 Martin Maier. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreData/CoreData.h>

#import "FirstLetterCategory.h"
#import "DateSortCategory.h"
#import "CurrencyHelperCategory.h"
#import "ParticipantHelperCategory.h"
#import "ParticipantCategory.h"
#import "TravelCategory.h"
#import "EntryCategory.h"

#import "UIFactory.h"
#import "Currency.h"
#import "AppDefaults.h"
#import "Locator.h"

@interface ReiseabrechnungAppDelegate : NSObject <UIApplicationDelegate>

@property (nonatomic, retain) IBOutlet UINavigationController *navController;
@property (nonatomic, retain) IBOutlet UIWindow *window;

@property (nonatomic, retain) NSManagedObjectContext *managedObjectContext;
@property (nonatomic, retain, readonly) NSManagedObjectModel *managedObjectModel;
@property (nonatomic, retain, readonly) NSPersistentStoreCoordinator *persistentStoreCoordinator;

@property (nonatomic, retain) Locator *locator;

@property (nonatomic, retain) NSMutableArray *helpBubbles;


- (NSURL *)applicationDocumentsDirectory;

+ (void)saveContext:(NSManagedObjectContext *) context;
+ (Currency *)defaultCurrency:(NSManagedObjectContext *) context;
+ (AppDefaults *)defaultsObject:(NSManagedObjectContext *) context;
- (void)initializeStartDatabase:(NSBundle *)bundle;
- (void)refreshCurrencyRatesIfOutDated;
- (void)checkForResetOfHelpBubbles;

- (void)registerHelpBubble:(HelpView *)helpView;

@end
