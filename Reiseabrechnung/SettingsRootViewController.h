//
//  SettingsRootViewController.h
//  Reiseabrechnung
//
//  Created by Martin Maier on 01/08/2011.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CoreDataTableViewController.h"

@interface SettingsRootViewController : UIViewController <UITabBarControllerDelegate>

@property (nonatomic, retain) UITabBarController *settingsTabBarController;

- (id)initInManagedObjectContext:(NSManagedObjectContext *)context;

- (void)cancel;
- (void)add;

@end
