//
//  EntryViewController.h
//  Reiseabrechnung
//
//  Created by Martin Maier on 30/06/2011.
//  Copyright 2011 Martin Maier. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Travel.h"
#import "Entry.h"
#import "EntryCell.h"
#import "CoreDataTableViewController.h"
#import "EntryNotManaged.h"
#import "ImageCache.h"

@protocol EntryViewControllerDelegate
- (void)didItemCountChange:(NSUInteger)itemCount;
@end


@protocol EntryViewControllerEditDelegate
- (void)addOrEditEntryWithParameters:(EntryNotManaged *)nmEntry andEntry:(Entry *)entry;
- (void)openEditEntryPopup:(Entry *)entry;
- (void)entryWasDeleted:(Entry *)entry;
@end

@interface EntryViewController : CoreDataTableViewController {
    int _sortIndex;
    BOOL _sortDesc;
    NSArray *_sortKeyArray;
    NSArray *_sectionKeyArray;
    NSDateFormatter *_dateFormatter;
    NSDateFormatter *_headerDateFormatter;
}

@property (nonatomic, retain) Travel *travel;
@property (nonatomic, retain) NSFetchRequest *fetchRequest;
@property (nonatomic, assign) id <EntryViewControllerDelegate> delegate;
@property (nonatomic, assign) id <EntryViewControllerEditDelegate> editDelegate;

@property (nonatomic, assign) IBOutlet EntryCell *entryCell;


- (id)initWithTravel:(Travel *) travel;
- (void)sortTable:(int)sortIndex desc:(BOOL)desc;

- (void)updateTravelOpenOrClosed;

@end
