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
#import "TransferCategory.h"
#import "I18NSortCategory.h"

#import "UIFactory.h"
#import "Currency.h"
#import "AppDefaults.h"
#import "Locator.h"
#import "MTStatusBarOverlay.h"
#import "Appirater.h"

extern NSString *const ITUNES_STORE_LINK;
extern NSString *const ITUNES_STORE_RATE_LINK;

#define TRIP_ACCOUNT_ID APPIRATER_APP_ID

@interface ReiseabrechnungAppDelegate : NSObject <UIApplicationDelegate, MTStatusBarOverlayDelegate>

@property (nonatomic, retain) IBOutlet UINavigationController *navController;
@property (nonatomic, retain) IBOutlet UIWindow *window;

@property (nonatomic, retain) NSManagedObjectContext *managedObjectContext;
@property (nonatomic, retain, readonly) NSManagedObjectModel *managedObjectModel;
@property (nonatomic, retain, readonly) NSPersistentStoreCoordinator *persistentStoreCoordinator;

@property (nonatomic, retain) Locator *locator;

@property (nonatomic, retain) NSMutableArray *helpBubbles;

@property (nonatomic, retain) MTStatusBarOverlay *statusbarOverlay;


- (NSURL *)applicationDocumentsDirectory;

+ (void)saveContext:(NSManagedObjectContext *) context;
+ (Currency *)defaultCurrency:(NSManagedObjectContext *) context;
+ (AppDefaults *)defaultsObject:(NSManagedObjectContext *) context;
- (void)refreshCurrencyRatesIfOutDated;
- (void)checkForResetOfHelpBubbles;
- (void)registerHelpBubble:(HelpView *)helpView;
- (void)initUserDefaults;
- (NSManagedObjectContext *)createNewManagedObjectContext;
- (void)userdefaults:(NSUserDefaults *)defaults setIfDoesNotExist:(BOOL)value forKey:(NSString *)key;
- (BOOL)isFullVersion;

@end
