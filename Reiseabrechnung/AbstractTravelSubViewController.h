//
//  AbstractTravelSubViewController.h
//  Reiseabrechnung
//
//  Created by Martin Maier on 01/07/2011.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Travel.h"
#import "CoreDataTableViewController.h"


@interface AbstractTravelSubViewController : CoreDataTableViewController {
    
}

-(void) postConstructWithTravel:(Travel *) travel;
-(void) updateBadgeValue;

@end
