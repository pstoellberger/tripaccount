//
//  RootViewController.h
//  Reiseabrechnung
//
//  Created by Martin Maier on 28/06/2011.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Travel.h"
#import "AlertPrompt.h"
#import "Entry.h"
#import "AlertPrompt.h"
#import "Participant.h"
#import "CoreDataTableViewController.h"

@interface RootViewController : CoreDataTableViewController {

}

@property (nonatomic, retain) NSManagedObjectContext *managedObjectContext;

@property (nonatomic, retain) IBOutlet UIButton *addButton;

- (id) initInManagedObjectContext:(NSManagedObjectContext *) context;

- (void)addTravel:(NSString *)name withCurrency:(NSString *)currency;

@end
