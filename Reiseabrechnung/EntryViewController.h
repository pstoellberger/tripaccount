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
#import "AbstractTravelSubViewController.h"


@interface EntryViewController : AbstractTravelSubViewController {
}

@property (nonatomic, retain) Travel *travel;

@end
