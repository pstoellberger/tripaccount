//
//  EntryEditViewController.h
//  Reiseabrechnung
//
//  Created by Martin Maier on 30/06/2011.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TravelViewController.h"
#import "EditableTableViewCell.h"
#import "EntryNotManaged.h"


@interface EntryEditViewController : UITableViewController <UITableViewDelegate, UITableViewDataSource, UINavigationControllerDelegate> {
    id _target;
    SEL _selector;
    
    EntryNotManaged *_entry;
    Entry *_entryManaged;
    Travel *_travel;

    NSMutableArray* _cellsToReloadAndFlash;
}

@property (nonatomic, retain, readonly) Travel *travel;

- (id)initWithTravel: (Travel *) travel target:(id)target action:(SEL)selector;
- (id)initWithTravel: (Travel *) travel andEntry:(Entry *)entry target:(id)target action:(SEL)selector;

- (IBAction)done:(UIBarButtonItem *)sender;
- (IBAction)cancel:(UIBarButtonItem *)sender;

@end
