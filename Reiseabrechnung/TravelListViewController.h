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
#import "TravelAddWizard.h"
#import "TravelEditViewController.h"

@interface TravelListViewController : CoreDataTableViewController {
    
    NSManagedObjectContext *_managedObjectContext;

    UIBarButtonItem *_addButton;
    UIBarButtonItem *_editButton;
    UIBarButtonItem *_doneButton;
    
    TravelAddWizard *_wizard;
}

@property (nonatomic, retain, readonly) NSManagedObjectContext *managedObjectContext;
@property (nonatomic, retain, readonly) UIViewController <TravelEditViewControllerDelegate> *rootViewController;

- (id)initInManagedObjectContext:(NSManagedObjectContext *)managedObjectContext withRootViewController:(UIViewController *)rootViewController;

- (void)closeTravel:(Travel *)travel;

@end
