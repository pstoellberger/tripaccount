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

#import "UIFactory.h"
#import "Currency.h"
#import "AppDefaults.h"

@interface ReiseabrechnungAppDelegate : NSObject <UIApplicationDelegate>

@property (nonatomic, retain) IBOutlet UINavigationController *navController;
@property (nonatomic, retain) IBOutlet UIWindow *window;

@property (nonatomic, retain) NSManagedObjectContext *managedObjectContext;
@property (nonatomic, retain, readonly) NSManagedObjectModel *managedObjectModel;
@property (nonatomic, retain, readonly) NSPersistentStoreCoordinator *persistentStoreCoordinator;

- (NSURL *)applicationDocumentsDirectory;

+ (void)saveContext:(NSManagedObjectContext *) context;
- (Currency *)defaultCurrency;
+ (AppDefaults *)defaultsObject:(NSManagedObjectContext *) context;
- (void)initializeStartDatabase:(NSBundle *)bundle;
- (void)refreshCurrencyRatesIfOutDated;

@end
