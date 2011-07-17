//
//  SummaryViewController.h
//  Reiseabrechnung
//
//  Created by Martin Maier on 30/06/2011.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Travel.h"
#import "AbstractTravelSubViewController.h"


@interface SummaryViewController : UIViewController {
}

@property (nonatomic, retain) Travel *travel;

-(void) postConstructWithTravel:(Travel *) travel;

@end
