//
//  EntryViewController.h
//  Reiseabrechnung
//
//  Created by Martin Maier on 30/06/2011.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Travel.h"
#import "Entry.h"
#import "EntryCell.h"
#import "CoreDataTableViewController.h"
#import "EntryNotManaged.h"

@protocol EntryViewControllerDelegate
- (void)didItemCountChange:(NSUInteger)itemCount;
@end


@protocol EntryViewControllerEditDelegate
- (void)addOrEditEntryWithParameters:(EntryNotManaged *)nmEntry andEntry:(Entry *)entry;
- (void)openEditEntryPopup:(Entry *)entry;
@end

@interface EntryViewController : CoreDataTableViewController {
    int _sortIndex;
    NSArray *_sortKeyArray;
    NSArray *_sectionKeyArray;
    NSFetchRequest *_fetchRequest;
    EntryCell *_entryCell;
    
    id _delegate;
    id _editDelegate;
}

@property (nonatomic, retain) Travel *travel;
@property (nonatomic, retain) NSFetchRequest *fetchRequest;
@property (nonatomic, assign) id <EntryViewControllerDelegate> delegate;
@property (nonatomic, assign) id <EntryViewControllerEditDelegate> editDelegate;

@property (nonatomic, assign) IBOutlet EntryCell *entryCell;


- (id)initWithTravel:(Travel *) travel;
- (void)sortTable:(int)sortIndex;

@end
