//
//  EntrySortViewController.h
//  Reiseabrechnung
//
//  Created by Martin Maier on 25/07/2011.
//  Copyright 2011 Martin Maier. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Travel.h"
#import "EntryViewController.h"

@interface EntrySortViewController : UIViewController <EntryViewControllerDelegate>

@property (nonatomic, retain) Travel *travel;
@property (nonatomic, retain) EntryViewController *detailViewController;

@property (nonatomic, retain) UISegmentedControl *segControl;

- (id)initWithTravel:(Travel *) travel;

@end
