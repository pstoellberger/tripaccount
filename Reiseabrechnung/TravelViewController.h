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
#import <MessageUI/MFMailComposeViewController.h>

#import "Travel.h"
#import "ParticipantViewController.h"
#import "EntryViewController.h"
#import "SummaryViewController.h"
#import "EntryNotManaged.h"
#import "EntrySortViewController.h"
#import "SummarySortViewController.h"
 
@interface TravelViewController : UIViewController <ABPeoplePickerNavigationControllerDelegate, UITabBarControllerDelegate, UIActionSheetDelegate, EntryViewControllerEditDelegate, MFMailComposeViewControllerDelegate> {
    Travel *_travel;
    UIBarButtonItem *_addButton;
    UIBarButtonItem *_actionButton;
}

@property (nonatomic, retain, readonly) IBOutlet Travel *travel;
@property (nonatomic, retain) IBOutlet UITabBarController *tabBarController;
@property (nonatomic, retain) IBOutlet ParticipantViewController *participantViewController;
@property (nonatomic, retain) IBOutlet EntrySortViewController *entrySortViewController;
@property (nonatomic, retain) IBOutlet SummarySortViewController *summarySortViewController;

@property (nonatomic, retain) UIBarButtonItem *addButton;
@property (nonatomic, retain) UIBarButtonItem *actionButton;

- (id)initWithTravel:(Travel *) travel;

- (void)openParticipantAddPopup;
- (void)openEntryAddPopup;
- (void)addOrEditEntryWithParameters:(EntryNotManaged *)nmEntry andEntry:(Entry *)entry;


@end
