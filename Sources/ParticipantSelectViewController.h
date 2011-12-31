//
//  ParticipantSelectViewController.h
//  Reiseabrechnung
//
//  Created by Martin Maier on 08/09/2011.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "GenericSelectViewController.h"
#import "EntryNotManaged.h"

@interface ParticipantSelectViewController : GenericSelectViewController {
    NSMutableDictionary *_amountCells;
}

@property (nonatomic, retain) EntryNotManaged *entry;
@property (nonatomic, retain) UIView *footerView;

- (id)initInManagedObjectContext:(NSManagedObjectContext *)context
                       withEntry:(EntryNotManaged *)entry
                withFetchRequest:(NSFetchRequest *)fetchRequest
        withSelectedParticipants:(NSArray *)selectedParticipants
                          target:(id)target 
                          action:(SEL)selector;

@end
