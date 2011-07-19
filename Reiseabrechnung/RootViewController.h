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
    NSManagedObjectContext *_managedObjectContext;
    UIBarButtonItem *_addButton;
    UIBarButtonItem *_editButton;
    UIBarButtonItem *_doneButton;
    UILabel *_tripLabel;
}

@property (nonatomic, retain, readonly) NSManagedObjectContext *managedObjectContext;

@property (nonatomic, retain, readonly) UIBarButtonItem *addButton;
@property (nonatomic, retain, readonly) UIBarButtonItem *editButton;
@property (nonatomic, retain, readonly) UIBarButtonItem *doneButton;

- (id)initInManagedObjectContext:(NSManagedObjectContext *)managedObjectContext;

- (void)addTravel:(NSString *)name withCurrency:(Currency *)currency;
- (void)updateNoTripLabel;

@end
