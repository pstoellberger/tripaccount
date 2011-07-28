//
//  ParticipantSelectViewController.h
//  Reiseabrechnung
//
//  Created by Martin Maier on 01/07/2011.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Travel.h"
#import "CoreDataTableViewController.h"
#import "EntryEditViewController.h"

#define ALL_BUTTON_INDEX 0
#define NONE_BUTTON_INDEX 1

@interface GenericSelectViewController : CoreDataTableViewController {
    
    SEL _selector;
    id _target;
    NSMutableArray *_selectedObjects;
    BOOL _multiSelectionAllowed;
    UISegmentedControl *_segControl;
    UIView *_segControlView;
    Class _cellClass;
    
}

@property (nonatomic, readonly) BOOL multiSelectionAllowed;
@property (nonatomic, retain) Class cellClass;

- (void)selectAll:(id)sender;
- (void)selectNone:(id)sender;

- (id)initInManagedObjectContext:(NSManagedObjectContext *)context 
              withMultiSelection:(BOOL)multiSelection 
                withFetchRequest:(NSFetchRequest *)fetchRequest
             withSelectedObjects:(NSArray *)selectedObjects
                          target:(id)target 
                          action:(SEL)selector;

- (id)initInManagedObjectContext:(NSManagedObjectContext *)context 
              withMultiSelection:(BOOL)multiSelection 
                withFetchRequest:(NSFetchRequest *)fetchRequest
                  withSectionKey:(NSString *)sectionKey
             withSelectedObjects:(NSArray *)selectedObjects
                          target:(id)target 
                          action:(SEL)selector;


@end