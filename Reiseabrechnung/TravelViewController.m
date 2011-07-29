//
//  TravelViewController.m
//  Reiseabrechnung
//
//  Created by Martin Maier on 30/06/2011.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#include <stdlib.h>
#import "TravelViewController.h"
#import "ParticipantViewController.h"
#import "EntryViewController.h"
#import "SummaryViewController.h"
#import "Participant.h"
#import "EntryEditViewController.h"
#import "ReiseabrechnungAppDelegate.h"
#import "ParticipantHelper.h"
#import "UIFactory.h"
#import "EntrySortViewController.h"
#import "ShadowNavigationController.h"
#import "UIFactory.h"

@interface TravelViewController ()

- (void)closeTravel;
- (void)sendSummaryMail;

@end


@implementation TravelViewController

@synthesize travel=_travel, tabBarController=_tabBarController, addButton=_addButton, actionButton=_actionButton;
@synthesize participantViewController=_participantViewController, entrySortViewController=_entrySortViewController, summaryViewController=_summaryViewController;

- (id)initWithTravel:(Travel *) travel {
    self = [self init];
    if (self) {
        _travel = travel;
    }
    return self;    
}

- (void)openAddPopup {
    if ([[[self tabBarController] selectedViewController] isEqual:self.participantViewController]) {
        [self openParticipantAddPopup];
    } else if ([[[self tabBarController] selectedViewController] isEqual:self.entrySortViewController]) {
        [self openEntryAddPopup];
    }
}

- (void)openEntryAddPopup {
    
    EntryEditViewController *detailViewController = [[EntryEditViewController alloc] initWithTravel:_travel target:self action:@selector(addOrEditEntryWithParameters:andEntry:)];
    UINavigationController *navController = [[ShadowNavigationController alloc] initWithRootViewController:detailViewController];
    navController.delegate = detailViewController;
    [self presentModalViewController:navController animated:YES];   
    [detailViewController release];
    [navController release];
}

- (void)openEditEntryPopup:(Entry *)entry {
    
    EntryEditViewController *detailViewController = [[EntryEditViewController alloc] initWithTravel:_travel andEntry:entry target:self action:@selector(addOrEditEntryWithParameters:andEntry:)];
    UINavigationController *navController = [[ShadowNavigationController alloc] initWithRootViewController:detailViewController];
    navController.delegate = detailViewController;
    [self presentModalViewController:navController animated:YES];   
    [detailViewController release];
    [navController release];    
}

- (void)openParticipantAddPopup {
    
    ABPeoplePickerNavigationController *picker = [[ABPeoplePickerNavigationController alloc] init];
    picker.peoplePickerDelegate = self;
    picker.navigationBar.barStyle = UIBarStyleBlack;
    picker.navigationBar.tintColor = [UIFactory defaultTintColor];
    [self presentModalViewController:picker animated:YES];
    
    [UIFactory setColorOfSearchBarInABPicker:picker color:[UIFactory defaultTintColor]];
    
    [picker release];
}

- (void)openActionPopup {
    UIActionSheet *actionPopup = [[UIActionSheet alloc] initWithTitle: @"Choose your action"
                                                        delegate:self
                                               cancelButtonTitle:@"Cancel"
                                          destructiveButtonTitle:nil
                                               otherButtonTitles:@"Send summary e-mail", @"Close this trip", nil];
    actionPopup.actionSheetStyle = UIActionSheetStyleBlackTranslucent;
    [actionPopup showInView:self.view];
    [actionPopup release];
}

- (void)closeTravel {
    self.travel.closed = [NSNumber numberWithInt:1];
    [ReiseabrechnungAppDelegate saveContext:[self.travel managedObjectContext]];
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)sendSummaryMail {
    
    MFMailComposeViewController* controller = [[MFMailComposeViewController alloc] init];
    
    controller.navigationBar.tintColor = [UIFactory defaultTintColor];
    
    controller.mailComposeDelegate = self;
    [controller setSubject:@"My Subject"];
    [controller setMessageBody:@"Hello there." isHTML:NO];

    if (controller)  {
        [self presentModalViewController:controller animated:YES];
    }
    [controller release];
    
}

- (void)addOrEditEntryWithParameters:(EntryNotManaged *)nmEntry andEntry:(Entry *)entry {
    
    [self.entrySortViewController.detailViewController.tableView beginUpdates];
    
    Entry *_entry = nil;
    if (!entry) {
        _entry = [NSEntityDescription insertNewObjectForEntityForName: @"Entry" inManagedObjectContext: [_travel managedObjectContext]];
    } else {
        _entry = entry;
    }
    _entry.text = nmEntry.text;
    _entry.amount = nmEntry.amount;
    _entry.currency = nmEntry.currency;
    _entry.date = nmEntry.date;
    _entry.payer= nmEntry.payer;
    _entry.receivers= nmEntry.receivers;
    _entry.type = nmEntry.type;
    _entry.travel = _travel;
    
    
    [ReiseabrechnungAppDelegate saveContext:[_travel managedObjectContext]];
    
    [self.entrySortViewController.detailViewController.tableView endUpdates];
}

#pragma mark - UIActionSheetDelegate

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
    
    if (buttonIndex == 0) {
        [self sendSummaryMail];
    } else if (buttonIndex == 1) {
        [self closeTravel];
    }
}

#pragma mark - ABPeoplePickerNavigationControllerDelegate

- (BOOL)peoplePickerNavigationController:(ABPeoplePickerNavigationController *)peoplePicker shouldContinueAfterSelectingPerson:(ABRecordRef)abRecordRef{
    
    Participant *newPerson = [NSEntityDescription insertNewObjectForEntityForName: @"Participant" inManagedObjectContext: [_travel managedObjectContext]];
    [ParticipantHelper addParticipant:newPerson toTravel:_travel withABRecord:abRecordRef];
    [ReiseabrechnungAppDelegate saveContext:[_travel managedObjectContext]];
    
    [[self navigationController] dismissModalViewControllerAnimated:YES];
    
	return NO;
}

- (BOOL)peoplePickerNavigationController:(ABPeoplePickerNavigationController *)peoplePicker shouldContinueAfterSelectingPerson:(ABRecordRef)person 
								property:(ABPropertyID)property identifier:(ABMultiValueIdentifier)identifier {
    
    // no property selection allowed
	return NO;
}

- (void)peoplePickerNavigationControllerDidCancel:(ABPeoplePickerNavigationController *)peoplePicker; {
    peoplePicker.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
	[self dismissModalViewControllerAnimated:YES];
}

#pragma mark - UITabBarControllerDelegate

- (void)tabBarController:(UITabBarController *)tabBarController didSelectViewController:(UIViewController *)viewController {
    if ([viewController isEqual:_summaryViewController]) {
        self.navigationItem.rightBarButtonItem = self.actionButton;
    } else {
        self.navigationItem.rightBarButtonItem = self.addButton;
    }
}

- (BOOL)tabBarController:(UITabBarController *)tabBarController shouldSelectViewController:(UIViewController *)viewController {
    [_summaryViewController recalculateSummary];
    return YES;
}

#pragma mark - MFMailComposeViewControllerDelegate

- (void)mailComposeController:(MFMailComposeViewController*)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError*)error {
    if (result == MFMailComposeResultSent) {
        NSLog(@"It's away!");
    }
    [self dismissModalViewControllerAnimated:YES];
}

#pragma mark - View lifecycle

- (void)loadView
{
    [super loadView];
    
    self.view.frame = CGRectMake(0, 0, [[UIScreen mainScreen] applicationFrame].size.width, [[UIScreen mainScreen] applicationFrame].size.height - NAVIGATIONBAR_HEIGHT);    
    self.view.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    
    self.participantViewController = [[[ParticipantViewController alloc] initWithTravel:_travel] autorelease];
    
    self.entrySortViewController = [[[EntrySortViewController alloc] initWithTravel:_travel] autorelease];
    self.entrySortViewController.detailViewController.editDelegate = self;
    
    self.summaryViewController = [[[SummaryViewController alloc] initWithTravel:_travel] autorelease];
    
    self.tabBarController = [[[UITabBarController alloc] init] autorelease];
    self.tabBarController.delegate = self;
    [self.tabBarController setViewControllers:[NSArray arrayWithObjects:self.participantViewController, self.entrySortViewController, self.summaryViewController, nil] animated:NO];
    self.tabBarController.view.frame = CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height);
    
    self.tabBarController.tabBar.frame = CGRectMake(0, self.tabBarController.view.frame.size.height - TABBAR_HEIGHT, self.view.frame.size.width, TABBAR_HEIGHT);
    
    self.addButton = [[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(openAddPopup)] autorelease]; 
    self.navigationItem.rightBarButtonItem = self.addButton;
    
    self.actionButton = [[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAction target:self action:@selector(openActionPopup)] autorelease]; 
    
    if ([_travel.participants count] <= 1) {
        self.tabBarController.selectedViewController = self.participantViewController;
    } else {
        self.tabBarController.selectedViewController = self.entrySortViewController;
    }
    
    [self.view addSubview:_tabBarController.view];

}

- (void)dealloc
{
    [super dealloc];
}

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
}

- (void)viewDidUnload {
    [super viewDidUnload];

    self.tabBarController = nil;
    self.participantViewController = nil;
    self.entrySortViewController = nil;
    self.summaryViewController = nil;
    self.addButton = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return YES;
}

@end
