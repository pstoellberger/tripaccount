//
//  TravelViewController.h
//  Reiseabrechnung
//
//  Created by Martin Maier on 30/06/2011.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Travel.h"


@interface TravelViewController : UIViewController {
    IBOutlet Travel *travel;
}

@property (nonatomic, retain) IBOutlet Travel *travel;
@property (nonatomic, retain) IBOutlet UITabBarController *tabBarController;

@end
