//
//  EntryEditViewController.h
//  Reiseabrechnung
//
//  Created by Martin Maier on 30/06/2011.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TravelViewController.h"


@interface EntryEditViewController : UIViewController {
    
}

@property (nonatomic, retain, readonly) Travel *travel;

@property (nonatomic, retain) IBOutlet UITextField *descriptionField;
@property (nonatomic, retain) IBOutlet UITextField *amountField;
@property (nonatomic, retain) IBOutlet UITextField *currencyField;
@property (nonatomic, retain) IBOutlet UISwitch *dateToggle;
@property (nonatomic, retain) IBOutlet UIDatePicker *datePicker;

@property (nonatomic, retain) TravelViewController *rootViewController;

- (id) initWithTravel: (Travel *) travel;

- (IBAction)done:(UIBarButtonItem *)sender;
- (IBAction)cancel:(UIBarButtonItem *)sender;

@end
