//
//  ParticipantSelectViewController.h
//  Reiseabrechnung
//
//  Created by Martin Maier on 01/07/2011.
//  Copyright 2011 Martin Maier. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Travel.h"
#import "CoreDataTableViewController.h"

#define ALL_BUTTON_INDEX 0
#define NONE_BUTTON_INDEX 1

@interface GenericSelectViewController : CoreDataTableViewController {
    
    SEL _selector;
    id _target;
    NSMutableArray *_selectedObjects;
    UISegmentedControl *_segControl;
    UIView *_segControlView;
    
}

@property (nonatomic, readonly) BOOL multiSelectionAllowed;
@property (nonatomic, retain) Class cellClass;
@property (nonatomic, retain) NSManagedObjectContext *context;

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

- (id)initInManagedObjectContext:(NSManagedObjectContext *)context 
                       withStyle:(UITableViewStyle)style
              withMultiSelection:(BOOL)multiSelection 
                withFetchRequest:(NSFetchRequest *)fetchRequest
                  withSectionKey:(NSString *)sectionKey
             withSelectedObjects:(NSArray *)selectedObjects
                          target:(id)target 
                          action:(SEL)selector;


@end