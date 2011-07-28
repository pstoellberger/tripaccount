//
//  TravelAddWizard.h
//  Reiseabrechnung
//
//  Created by Martin Maier on 22/07/2011.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

#import "LocationViewController.h"

@interface TravelAddWizard : NSObject {
    
    UINavigationController *_navController;
    
    LocationViewController *_locationViewController;
    LocationViewController *_descriptionViewController;
    LocationViewController *_currencyViewController;
}

@property (nonatomic, retain) UINavigationController *navController;

@property (nonatomic, retain) LocationViewController *locationViewController;
@property (nonatomic, retain) LocationViewController *descriptionViewController;
@property (nonatomic, retain) LocationViewController *currencyViewController;

- (void)start:(UIViewController *)rootViewController;
- (void)descriptionStep;
- (void)currencyStep;
- (void)finish;

@end
