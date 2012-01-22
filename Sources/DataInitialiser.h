//
//  DataInitialiser.h
//  Reiseabrechnung
//
//  Created by Martin Maier on 21/01/2012.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>
#import "Currency.h"
#import "Country.h"
#import "Participant.h"
#import "ReceiverWeight.h"
#import "Travel.h"
#import "Country.h"
#import "City.h"
#import "ExchangeRate.h"
#import "Type.h"
#import "AppDefaults.h"
#import "MTStatusBarOverlay.h"
#import "Appirater.h"
#import "CurrencyRefresh.h"
#import "UIFactory.h"
#import "Entry.h"
#import "ReiseabrechnungAppDelegate.h"
#import "Summary.h"

@interface DataInitialiser : NSObject {
    NSManagedObjectContext *_context;
}

- (void)performDataInitialisations:(UIWindow *)window inContext:(NSManagedObjectContext *)context;

@end
