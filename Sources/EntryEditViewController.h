//
//  EntryEditViewController.h
//  Reiseabrechnung
//
//  Created by Martin Maier on 30/06/2011.
//  Copyright 2011 Martin Maier. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "EntryNotManaged.h"
#import "Entry.h"

@protocol EntryEditViewControllerDelegate 
- (void)addOrEditEntryWithParameters:(EntryNotManaged *)nmEntry andEntry:(Entry *)entry;
- (void)editWasCanceled:(Entry *)entry;
@end

@interface EntryEditViewController : UITableViewController <UITableViewDelegate, UITableViewDataSource, UINavigationControllerDelegate> {

    NSMutableArray* _cellsToReloadAndFlash;
    BOOL _isFirstView;
    NSDateFormatter *_formatter;
}

@property (nonatomic, retain, readonly) Travel *travel;

@property (nonatomic, assign) id <EntryEditViewControllerDelegate> editDelegate;

- (id)initWithTravel:(Travel *) travel;
- (id)initWithTravel:(Travel *) travel andEntry:(Entry *)entry;

- (IBAction)done:(UIBarButtonItem *)sender;
- (IBAction)cancel:(UIBarButtonItem *)sender;

- (void)updateAndFlash:(UIViewController *)viewController;

@end
