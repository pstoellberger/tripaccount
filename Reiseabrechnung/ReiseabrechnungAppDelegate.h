//
//  ReiseabrechnungAppDelegate.h
//  Reiseabrechnung
//
//  Created by Martin Maier on 28/06/2011.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreData/CoreData.h>
#import "UIFactory.h"
#import "Currency.h"
#import "AppDefaults.h"

@interface ReiseabrechnungAppDelegate : NSObject <UIApplicationDelegate> {
    UINavigationController *_navController;
}

@property (nonatomic, retain) IBOutlet UINavigationController *navController;
@property (nonatomic, retain) IBOutlet UIWindow *window;

@property (nonatomic, retain, readonly) NSManagedObjectContext *managedObjectContext;
@property (nonatomic, retain, readonly) NSManagedObjectModel *managedObjectModel;
@property (nonatomic, retain, readonly) NSPersistentStoreCoordinator *persistentStoreCoordinator;

- (NSURL *)applicationDocumentsDirectory;

+ (void)saveContext:(NSManagedObjectContext *) context;
- (Currency *)defaultCurrency;
+ (AppDefaults *)defaultsObject:(NSManagedObjectContext *) context;

@end
