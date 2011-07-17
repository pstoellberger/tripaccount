//
//  CurrencySelectViewController.h
//  Reiseabrechnung
//
//  Created by Martin Maier on 01/07/2011.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "EntryEditViewController.h"
#import "Travel.h"
#import "Currency.h"

@interface CurrencySelectViewController : CoreDataTableViewController {
    SEL _selector;
    id _target;
    Currency *_selectedCurrency;
}

@property (nonatomic, retain) Currency *selectedCurrency;
@property (nonatomic, retain, readonly) Travel *travel;
@property (nonatomic, retain, readonly) EntryEditViewController *entryEditViewController;

- (id)initInManagedObjectContext:(NSManagedObjectContext *)context target:(id)target action:(SEL)selector;

@end
