//
//  TravelViewController.h
//  Reiseabrechnung
//
//  Created by Martin Maier on 30/06/2011.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AddressBook/AddressBook.h>
#import <AddressBookUI/AddressBookUI.h>
#import "Travel.h"
#import "ParticipantViewController.h"
#import "EntryViewController.h"
#import "SummaryViewController.h"

 
@interface TravelViewController : UIViewController <ABPeoplePickerNavigationControllerDelegate, UITabBarControllerDelegate> {
    IBOutlet Travel *_travel;
    UIBarButtonItem *_addButton;
}

@property (nonatomic, retain, readonly) IBOutlet Travel *travel;
@property (nonatomic, retain) IBOutlet UITabBarController *tabBarController;
@property (nonatomic, retain) IBOutlet ParticipantViewController *participantViewController;
@property (nonatomic, retain) IBOutlet EntryViewController *entryViewController;
@property (nonatomic, retain) IBOutlet SummaryViewController *summaryViewController;

@property (nonatomic, retain) UIBarButtonItem *addButton;

- (id) initWithTravel:(Travel *) travel;

- (void)openParticipantAddPopup;
- (void)openEntryAddPopup;
- (void)addEntry:(NSString *)description withAmount:(NSNumber *)amount withCurrency:(NSString *)currency withDate:(NSDate *)date;
- (void)addPerson:(NSString *)name;

- (void)saveContext;


@end
