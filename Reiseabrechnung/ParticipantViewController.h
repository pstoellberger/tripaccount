//
//  ParticipantViewController.h
//  Reiseabrechnung
//
//  Created by Martin Maier on 30/06/2011.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Travel.h"
#import "CoreDataTableViewController.h"

@interface ParticipantViewController : CoreDataTableViewController {
}

@property (nonatomic, retain, readonly) Travel *travel;

-(void) postConstructWithTravel:(Travel *) travel;

@end
