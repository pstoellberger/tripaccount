//
//  RootViewController.h
//  Reiseabrechnung
//
//  Created by Martin Maier on 28/06/2011.
//  Copyright 2011 Martin Maier. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Travel.h"
#import "AlertPrompt.h"
#import "Entry.h"
#import "AlertPrompt.h"
#import "Participant.h"
#import "CoreDataTableViewController.h"
#import "TravelEditViewController.h"
#import "InfoViewController.h"

@interface RootViewController : UIViewController <TravelEditViewControllerDelegate> {
    NSManagedObjectContext *_managedObjectContext;
    UITableViewController *_tableViewController;
    UIView *_helpView;
}

@property (nonatomic, retain, readonly) UIBarButtonItem *addButton;
@property (nonatomic, retain, readonly) UIBarButtonItem *editButton;
@property (nonatomic, retain, readonly) UIBarButtonItem *doneButton;

@property (nonatomic, retain) UITableViewController *tableViewController;
@property (nonatomic, retain, readonly) NSManagedObjectContext *managedObjectContext;

@property (nonatomic, retain) InfoViewController *infoViewController;

- (id)initInManagedObjectContext:(NSManagedObjectContext *)managedObjectContext;

- (void)openTravelEditViewController;

@end
