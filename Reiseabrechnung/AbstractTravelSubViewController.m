//
//  AbstractTravelSubViewController.m
//  Reiseabrechnung
//
//  Created by Martin Maier on 01/07/2011.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "AbstractTravelSubViewController.h"


@implementation AbstractTravelSubViewController

@synthesize containingViewController=_containingViewController;

- (void) updateBadgeValue {
    NSUInteger itemCount = [[[self.fetchedResultsController sections] lastObject] numberOfObjects];
    if (itemCount == 0) {
        self.tabBarItem.badgeValue = nil;
    } else {
        self.tabBarItem.badgeValue = [NSString stringWithFormat:@"%d", [self.fetchedResultsController.fetchedObjects count]];
    }
}

-(void) postConstructWithTravel:(Travel *) travel {
    
}

- (void)controllerDidChangeContent:(NSFetchedResultsController *)controller
{
    [super controllerDidChangeContent:controller];
    
    [self updateBadgeValue];
}

@end
