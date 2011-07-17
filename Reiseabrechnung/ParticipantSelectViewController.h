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

@interface ParticipantSelectViewController : CoreDataTableViewController {
    SEL _selector;
    id _target;
    NSMutableArray *_selectedParticipants;
    BOOL _multiSelectionAllowed;
}

@property (nonatomic) BOOL multiSelectionAllowed;

- (id)initInManagedObjectContext:(NSManagedObjectContext *)context withTravel:(Travel *)travel target:(id)target action:(SEL)selector;
- (void)addSelectedParticipants:(NSSet *)newArray;

@end
