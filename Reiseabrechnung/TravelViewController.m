//
//  TravelViewController.m
//  Reiseabrechnung
//
//  Created by Martin Maier on 30/06/2011.
//  Copyright 2011 Martin Maier. All rights reserved.
//

#include <stdlib.h>
#import "TravelViewController.h"
#import "ParticipantViewController.h"
#import "EntryViewController.h"
#import "SummaryViewController.h"
#import "Participant.h"
#import "EntryEditViewController.h"
#import "ReiseabrechnungAppDelegate.h"
#import "ParticipantHelperCategory.h"
#import "UIFactory.h"
#import "EntrySortViewController.h"
#import "ShadowNavigationController.h"
#import "UIFactory.h"
#import "ExchangeRate.h"
#import "CurrencyRefresh.h"
#import "RateSelectViewController.h"
#import "ShadowNavigationController.h"
#import "MGTemplateEngine.h"
#import "ICUTemplateMatcher.h"

@interface TravelViewController ()

- (void)closeTravel;
- (void)openTravel:(BOOL)useLatestRates;
- (void)sendSummaryMail;

@end


@implementation TravelViewController

@synthesize travel=_travel, tabBarController=_tabBarController, addButton=_addButton, actionButton=_actionButton;
@synthesize participantViewController=_participantViewController, entrySortViewController=_entrySortViewController, summarySortViewController=_summarySortViewController;
@synthesize mailSendAlertView=_mailSendAlertView, rateRefreshAlertView=_rateRefreshAlertView;

- (id)initWithTravel:(Travel *) travel {
    
    self = [self init];
    if (self) {
        _travel = travel;
    }
    return self;    
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    return YES;
}

#pragma mark Open PopUps

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


- (void)openRateEditPopup {
    
    RateSelectViewController *rateSelectViewController = [[RateSelectViewController alloc] initWithTravel:self.travel];
    rateSelectViewController.closeDelegate = self;
    
    UINavigationController *navController = [[ShadowNavigationController alloc] initWithRootViewController:rateSelectViewController];
    navController.delegate = rateSelectViewController;
    [self.navigationController presentModalViewController:navController animated:YES];
    
    [navController release];
    [rateSelectViewController release];
    
}


- (void)openActionPopup {
    
    UIActionSheet *actionPopup;
    
    if ([self.travel.closed intValue] == 1) {
        
        actionPopup = [[UIActionSheet alloc] initWithTitle: @"Choose your action"
                                                  delegate:self
                                         cancelButtonTitle:@"Cancel"
                                    destructiveButtonTitle:nil
                                         otherButtonTitles:@"Send summary e-mail", @"Open this trip", nil];
    } else {
        
        actionPopup = [[UIActionSheet alloc] initWithTitle: @"Choose your action"
                                                  delegate:self
                                         cancelButtonTitle:@"Cancel"
                                    destructiveButtonTitle:nil
                                         otherButtonTitles:@"Send summary e-mail", @"Close this trip", @"Update exchange rates", @"Manually edit rates", nil];
    }
    

    actionPopup.actionSheetStyle = UIActionSheetStyleBlackTranslucent;
    [actionPopup showInView:self.view];
    [actionPopup release];
}

#pragma mark Travel logic

- (void)closeTravel {

    // close
    [self.travel close];
    
    [ReiseabrechnungAppDelegate saveContext:[self.travel managedObjectContext]];
}

- (void)openTravel:(BOOL)useLatestRates {
    
    // open
    [self.travel open:useLatestRates];

    [ReiseabrechnungAppDelegate saveContext:[self.travel managedObjectContext]];
    
    [_summarySortViewController.detailViewController.tableView reloadData];
    [_entrySortViewController.detailViewController.tableView reloadData];
    
    [self updateStateOfNavigationController:self.tabBarController.selectedViewController];    
}

- (void)askToRefreshRatesWhenOpening {
    [self.rateRefreshAlertView show];
}

- (void)askToSendEmail {
    
    NSString *noMailParticipants = nil;
    for (Participant *participant in self.travel.participants) {
        if (participant.email == nil || [participant.email length] == 0) {
            if (noMailParticipants == nil) {
                noMailParticipants = participant.name;
            } else {
                noMailParticipants = [noMailParticipants stringByAppendingFormat:@", ", participant.email];
            }
        }
    }
    
    if (noMailParticipants) {
        NSString *message = [NSString stringWithFormat:@"There are no email addresses available for the participant(s) %@", noMailParticipants];
        self.mailSendAlertView.message = message;
        [self.mailSendAlertView show];
    } else {
        [self sendSummaryMail];
    }
}

- (void)sendSummaryMail {
    
    MFMailComposeViewController* controller = [[MFMailComposeViewController alloc] init];
    
    controller.navigationBar.tintColor = [UIFactory defaultTintColor];
    
    NSDictionary *dictionary = [NSDictionary dictionaryWithObject:self.travel forKey:@"travel"];
    
    NSLog(@"%@", [[self.travel.participants anyObject] base64]);
    
    MGTemplateEngine *engine = [[MGTemplateEngine alloc] init];
    engine.matcher = [[ICUTemplateMatcher alloc] initWithTemplateEngine:engine];
    NSString *mailBody = [engine processTemplateInFileAtPath:[[NSBundle mainBundle] pathForResource:@"mailTemplate" ofType:@"html"] withVariables:dictionary];
    
    controller.mailComposeDelegate = self;
    
    NSString *subjectLine = [NSString stringWithFormat:@"Summary email for trip '%@'", self.travel.name];
    if (!self.travel.name || [self.travel.name length] == 0) {
        subjectLine = [NSString stringWithFormat:@"Summary email for trip to %@", self.travel.country.name];
    }
    [controller setSubject:subjectLine];
    [controller setMessageBody:mailBody isHTML:YES];

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
        _travel.lastParticipantUsed = nmEntry.payer;
        _travel.lastCurrencyUsed = nmEntry.currency;
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

- (void)updateStateOfNavigationController:(UIViewController *)selectedViewController {
    
    if ([selectedViewController isEqual:_summarySortViewController]) {
        self.navigationItem.rightBarButtonItem = self.actionButton;
    } else {
        self.navigationItem.rightBarButtonItem = self.addButton;
    }
    
    self.addButton.enabled = [self.travel.closed intValue] != 1;

}

- (void)refreshExchangeRates {
    
    dispatch_queue_t updateQueue = dispatch_queue_create("UpdateQueue", NULL);
    dispatch_async(updateQueue, ^{
        
        dispatch_async(dispatch_get_main_queue(), ^{
            [_summarySortViewController.updateIndicator startAnimating];
            _summarySortViewController.lastUpdatedLabel.text = @"Updating currency exchange rates...";
        });
        
        CurrencyRefresh *currencyRefresh = [[CurrencyRefresh alloc] initInManagedContext:[self.travel managedObjectContext]];
        NSLog(@"Updating currencies...");
        [currencyRefresh refreshCurrencies];
        [currencyRefresh release];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            [_summarySortViewController updateRateLabel];
            [_summarySortViewController.updateIndicator stopAnimating];
        });
    });
}

#pragma mark - UIAlertViewDelegate

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    
    if (alertView == self.rateRefreshAlertView) {
        
        [self openTravel:(buttonIndex != [alertView cancelButtonIndex])];
        
    } else if (alertView == self.mailSendAlertView) {
        
        [self sendSummaryMail];
        
    }
}

#pragma mark - UIActionSheetDelegate

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
    
    if (buttonIndex == 0) {
        
        [self askToSendEmail];
        
    } else if (buttonIndex == 1) {
        
        if ([self.travel.closed intValue] == 1) {
            [self askToRefreshRatesWhenOpening];
        } else {
            [self closeTravel];
        }
    } else if (buttonIndex == 2) {
        
        [self refreshExchangeRates];
        
    } else if (buttonIndex == 3) {
        
        [self openRateEditPopup];
    }
}
#pragma mark - RateSelectViewControllerDelegate

- (void)willDisappearWithChanges {
    [_summarySortViewController.detailViewController recalculateSummary];
    [_summarySortViewController.detailViewController.tableView reloadData];
}

#pragma mark - ABPeoplePickerNavigationControllerDelegate

- (BOOL)peoplePickerNavigationController:(ABPeoplePickerNavigationController *)peoplePicker shouldContinueAfterSelectingPerson:(ABRecordRef)abRecordRef{
    
    Participant *newPerson = [NSEntityDescription insertNewObjectForEntityForName: @"Participant" inManagedObjectContext: [_travel managedObjectContext]];
    [Participant addParticipant:newPerson toTravel:_travel withABRecord:abRecordRef];
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
    
    [self updateStateOfNavigationController:viewController];
    
    self.travel.selectedTab = [NSNumber numberWithInt:[tabBarController.viewControllers indexOfObject:viewController]];
    [ReiseabrechnungAppDelegate saveContext:[self.travel managedObjectContext]];
    
}

- (BOOL)tabBarController:(UITabBarController *)tabBarController shouldSelectViewController:(UIViewController *)viewController {
    
    if ([_summarySortViewController isEqual:viewController]) {
        [_summarySortViewController.detailViewController recalculateSummary];
        [_summarySortViewController.detailViewController.tableView reloadData];
    }
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

- (void)loadView {
    
    [super loadView];
    
    self.addButton = [[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(openAddPopup)] autorelease]; 
    self.navigationItem.rightBarButtonItem = self.addButton;
    
    self.actionButton = [[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAction target:self action:@selector(openActionPopup)] autorelease]; 
    
    self.view.frame = CGRectMake(0, 0, [[UIScreen mainScreen] applicationFrame].size.width, [[UIScreen mainScreen] applicationFrame].size.height - NAVIGATIONBAR_HEIGHT);    
    self.view.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    
    self.participantViewController = [[[ParticipantViewController alloc] initWithTravel:_travel] autorelease];
    
    self.entrySortViewController = [[[EntrySortViewController alloc] initWithTravel:_travel] autorelease];
    self.entrySortViewController.detailViewController.editDelegate = self;
    
    self.summarySortViewController = [[[SummarySortViewController alloc] initWithTravel:_travel] autorelease];
    
    self.tabBarController = [[[UITabBarController alloc] init] autorelease];
    self.tabBarController.delegate = self;
    [self.tabBarController setViewControllers:[NSArray arrayWithObjects:self.participantViewController, self.entrySortViewController, self.summarySortViewController, nil] animated:NO];
    self.tabBarController.view.frame = CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height);
    self.tabBarController.tabBar.frame = CGRectMake(0, self.tabBarController.view.frame.size.height - TABBAR_HEIGHT, self.view.frame.size.width, TABBAR_HEIGHT);
    
    self.tabBarController.selectedIndex = [self.travel.selectedTab intValue];
    [self updateStateOfNavigationController:self.tabBarController.selectedViewController];
    
    [self.view addSubview:_tabBarController.view];
    
    self.mailSendAlertView = [[[UIAlertView alloc] initWithTitle:@"Warning" message:nil delegate:self cancelButtonTitle:nil otherButtonTitles:@"OK", nil] autorelease];
    
    self.rateRefreshAlertView = [UIFactory createAlterViewForRefreshingRatesOnOpeningTravel:self];

}

#pragma mark View lifecycle


- (void)viewDidUnload {
    [super viewDidUnload];
    
    self.tabBarController = nil;
    self.participantViewController = nil;
    self.entrySortViewController = nil;
    self.summarySortViewController = nil;
    self.addButton = nil;
}

#pragma mark Memory Management

- (void)dealloc {
    [super dealloc];
}

@end
