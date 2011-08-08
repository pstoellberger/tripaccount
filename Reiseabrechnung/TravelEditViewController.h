//
//  TravelEditViewController.h
//  Reiseabrechnung
//
//  Created by Martin Maier on 29/06/2011.
//  Copyright 2011 Martin Maier. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TravelNotManaged.h"
#import <QuartzCore/QuartzCore.h>
#import "Locator.h"

@protocol TravelEditViewControllerDelegate
- (void)travelDidSave:(Travel *)travel;
@end

@interface TravelEditViewController : UITableViewController <UITextFieldDelegate, UITextViewDelegate, UITableViewDelegate, UITableViewDataSource, UINavigationControllerDelegate, LocatorDelegate> {

    NSManagedObjectContext *_context;
    
    NSMutableArray* _cellsToReloadAndFlash;

    BOOL _isFirstView;
    
    Locator *_locator;
}

@property (nonatomic, retain) NSString *name;
@property (nonatomic, retain) NSString *city;
@property (nonatomic, retain) Travel *travel;
@property (nonatomic, retain) Country *country;
@property (nonatomic, retain) NSArray *currencies;

@property (nonatomic, assign) id <TravelEditViewControllerDelegate> editDelegate;

- (IBAction)done:(UIBarButtonItem *)sender;
- (IBAction)cancel:(UIBarButtonItem *)sender;

- (id)initInManagedObjectContext:(NSManagedObjectContext *)context;
- (id)initInManagedObjectContext:(NSManagedObjectContext *)context withTravel:(Travel *)travel;

- (void)selectCurrencies:(NSArray *)currencies;
- (void)selectCountry:(Country *)country;
- (void)checkIfDoneIsPossible;

@end
