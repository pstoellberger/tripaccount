//
//  TravelAddWizard.m
//  Reiseabrechnung
//
//  Created by Martin Maier on 22/07/2011.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

#import "TravelAddWizard.h"
#import "LocationViewController.h"


@implementation TravelAddWizard

@synthesize navController=_navController;

@synthesize locationViewController=_locationViewController, descriptionViewController=_descriptionViewController, currencyViewController=_currencyViewController;

- (id)init
{
    self = [super init];
    if (self) {
        // Initialization code here.
    }
    
    return self;
}

- (void)start:(UIViewController *)rootViewController {
    
    self.locationViewController = [[[LocationViewController alloc] initWithTravel:nil target:self selector:nil] autorelease];
    self.navController = [[[UINavigationController alloc] initWithRootViewController:self.locationViewController] autorelease];
    
    self.locationViewController.navigationItem.rightBarButtonItem = [[[UIBarButtonItem alloc] initWithTitle:@"Next" style:UIBarButtonItemStylePlain target:self action:@selector(descriptionStep)] autorelease];
    
    [rootViewController presentModalViewController:self.navController animated:YES];   
    
}

- (void)descriptionStep {
    self.descriptionViewController = [[[LocationViewController alloc] initWithTravel:nil target:self selector:nil] autorelease];
    [self.navController pushViewController:self.descriptionViewController animated:YES];
    
    self.descriptionViewController.navigationItem.rightBarButtonItem = [[[UIBarButtonItem alloc] initWithTitle:@"Next" style:UIBarButtonItemStylePlain target:self action:@selector(descriptionStep)] autorelease];
}

- (void)currencyStep {
    self.currencyViewController = [[[LocationViewController alloc] initWithTravel:nil target:self selector:nil] autorelease];
    [self.navController pushViewController:self.currencyViewController animated:YES];
    
    self.currencyViewController.navigationItem.rightBarButtonItem = [[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemSave target:self action:@selector(finish)] autorelease];
}

- (void)finish {
    
}

@end
