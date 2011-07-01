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


@interface EntryViewController : CoreDataTableViewController {
}

@property (nonatomic, retain) Travel *travel;

-(void) postConstructWithTravel:(Travel *) travel;

@end
