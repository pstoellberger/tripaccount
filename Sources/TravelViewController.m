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
#import "ParticipantEditViewController.h"
#import "NumberFilter.h"

@interface TravelViewController ()

- (void)closeTravel;
- (void)openTravel:(BOOL)useLatestRates;
- (void)sendSummaryMail;
- (void)updateTableViewInsets;
- (void)updateSummary;
- (void)openPersonChooseOrCreatePopup;
- (void)selectPerson:(ABRecordRef)abRecordRef withEmail:(NSString *)email;
- (NSString *)prettyPrintListOfStrings:(NSArray *)array;
- (void)initHelpBubbleForViewController:(UIViewController *)viewController;
@end


@implementation TravelViewController

@synthesize travel=_travel, tabBarController=_tabBarController, addButton=_addButton, actionButton=_actionButton;
@synthesize participantViewController=_participantViewController, entrySortViewController=_entrySortViewController, summarySortViewController=_summarySortViewController;
@synthesize mailSendAlertView=_mailSendAlertView, rateRefreshAlertView=_rateRefreshAlertView;

@synthesize actionSheetAddPerson=_actionSheetAddPerson, actionSheetOpenTravel=_actionSheetOpenTravel, actionSheetClosedTravel=_actionSheetClosedTravel;


- (id)initWithTravel:(Travel *) travel {
    
    self = [self init];
    
    if (self) {
        _travel = travel;
        
        self.actionSheetClosedTravel = [[[UIActionSheet alloc] initWithTitle: @"Choose your action"
                                                                    delegate:self
                                                           cancelButtonTitle:@"Cancel"
                                                      destructiveButtonTitle:nil
                                                           otherButtonTitles:@"Send summary e-mail", @"Open this trip", nil] autorelease];
        self.actionSheetClosedTravel.actionSheetStyle = UIActionSheetStyleBlackTranslucent;
        
        
        self.actionSheetOpenTravel = [[[UIActionSheet alloc] initWithTitle: @"Choose your action"
                                                                  delegate:self
                                                         cancelButtonTitle:@"Cancel"
                                                    destructiveButtonTitle:nil
                                                         otherButtonTitles:@"Send summary e-mail", @"Close this trip", @"Update exchange rates", @"Manually edit rates", nil] autorelease];
        self.actionSheetOpenTravel.actionSheetStyle = UIActionSheetStyleBlackTranslucent;        
        
        
        self.actionSheetAddPerson = [[[UIActionSheet alloc] initWithTitle: @"Where is the person?"
                                                                 delegate:self
                                                        cancelButtonTitle:@"Cancel"
                                                   destructiveButtonTitle:nil
                                                        otherButtonTitles:@"From Address Book", @"Create new person", nil] autorelease];
        self.actionSheetAddPerson.actionSheetStyle = UIActionSheetStyleBlackTranslucent;
    }
    return self;    
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    return YES;
}

#pragma mark Open PopUps

- (void)openAddPopup {
    
    if ([[[self tabBarController] selectedViewController] isEqual:self.participantViewController]) {
        [self openPersonChooseOrCreatePopup];
    } else if ([[[self tabBarController] selectedViewController] isEqual:self.entrySortViewController]) {
        [self openEntryAddPopup];
    }
}

- (void)openEntryAddPopup {
    
    EntryEditViewController *detailViewController = [[EntryEditViewController alloc] initWithTravel:_travel];
    detailViewController.editDelegate = self;
    UINavigationController *navController = [[ShadowNavigationController alloc] initWithRootViewController:detailViewController];
    navController.delegate = detailViewController;
    [self presentModalViewController:navController animated:YES];   
    [detailViewController release];
    [navController release];
}

- (void)openEditEntryPopup:(Entry *)entry {
    
    EntryEditViewController *detailViewController = [[EntryEditViewController alloc] initWithTravel:_travel andEntry:entry];
    detailViewController.editDelegate = self;
    UINavigationController *navController = [[ShadowNavigationController alloc] initWithRootViewController:detailViewController];
    navController.delegate = detailViewController;
    [self presentModalViewController:navController animated:YES];   
    [detailViewController release];
    [navController release];    
}

- (void)openPersonAddPopup {
    
    ABPeoplePickerNavigationController *picker = [[ABPeoplePickerNavigationController alloc] init];
    picker.peoplePickerDelegate = self;
    picker.navigationBar.barStyle = UIBarStyleBlack;
    picker.navigationBar.tintColor = [UIFactory defaultTintColor];
    picker.displayedProperties = [NSArray arrayWithObject:[NSNumber numberWithInt:kABPersonEmailProperty]];
    
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
    
    if ([self.travel.closed intValue] == 1) {
        [self.actionSheetClosedTravel showInView:self.view];
    } else {
        [self.actionSheetOpenTravel showInView:self.view];
    }
}

- (void)openPersonChooseOrCreatePopup {
    
    [self.actionSheetAddPerson showInView:self.view];
    
}

#pragma mark Travel logic

- (void)closeTravel {
    
    // close
    [self.travel close];
    
    [ReiseabrechnungAppDelegate saveContext:[self.travel managedObjectContext]];
    
    [self.summarySortViewController.detailViewController.tableView reloadData];
    [self.entrySortViewController.detailViewController.tableView reloadData];
    [self.participantViewController.tableView reloadData];
    
    [self.participantViewController updateTravelOpenOrClosed];
    [self.entrySortViewController.detailViewController updateTravelOpenOrClosed];
    [self.summarySortViewController updateRateLabel];
    
    [self initHelpBubbleForViewController:self.summarySortViewController];
}

- (void)openTravel:(BOOL)useLatestRates {
    
    // open
    [self.travel open:useLatestRates];
    
    [ReiseabrechnungAppDelegate saveContext:[self.travel managedObjectContext]];
    
    [self.summarySortViewController.detailViewController.tableView reloadData];
    [self.entrySortViewController.detailViewController.tableView reloadData];
    [self.participantViewController.tableView reloadData];
    
    [self updateStateOfNavigationController:self.tabBarController.selectedViewController]; 
    
    [self.participantViewController updateTravelOpenOrClosed];
    [self.entrySortViewController.detailViewController updateTravelOpenOrClosed];
    [self.summarySortViewController updateRateLabel];
    
    [self initHelpBubbleForViewController:self.summarySortViewController];
    [UIFactory replaceHelpViewInView:@"travelClosedLabel" withView:nil toView:self.summarySortViewController.view];
}

- (void)askToRefreshRatesWhenOpening {
    [self.rateRefreshAlertView show];
}

- (void)askToSendEmail {
    
    NSMutableArray *noMailParticipants = [NSMutableArray array];
    for (Participant *participant in self.travel.participants) {
        if (participant.email == nil || [participant.email length] == 0) {
            [noMailParticipants addObject:participant.name];
        }
    }
    
    if ([noMailParticipants count] > 0) {
        NSString *message = [NSString stringWithFormat:@"There are no email addresses available for the participant%@ %@", ([noMailParticipants count]==1)?@"":@"s", [self prettyPrintListOfStrings:noMailParticipants]];
        self.mailSendAlertView.message = message;
        [self.mailSendAlertView show];
    } else {
        [self sendSummaryMail];
    }
}

- (NSString *)prettyPrintListOfStrings:(NSArray *)array {
    
    NSString *returnValue = nil;
    
    if ([array count] == 0) {
        
        returnValue = @"";
        
    } else if ([array count] == 1) {
        
        returnValue = [array objectAtIndex:0];
        
    } else if ([array count] == 2) {
        
        returnValue = [NSString stringWithFormat:@"%@ and %@", [array objectAtIndex:0], [array objectAtIndex:1]];
        
    } else {
        
        for (int i=0; i < [array count]; i++) {
            if (i == 0) {
                returnValue = [array objectAtIndex:i];
            } else if (i == [array count] - 1) {
                returnValue = [returnValue stringByAppendingFormat:@" and %@", [array objectAtIndex:i]];
            } else {
                returnValue = [returnValue stringByAppendingFormat:@", %@", [array objectAtIndex:i]];
            }
        }
    }
    
    return returnValue;
}

- (void)sendSummaryMail {
    
    MFMailComposeViewController* controller = [[MFMailComposeViewController alloc] init];
    
    controller.navigationBar.tintColor = [UIFactory defaultTintColor];
    
    NSMutableDictionary *dictionary = [NSMutableDictionary dictionaryWithObject:self.travel forKey:@"travel"];
    if ([[NSUserDefaults standardUserDefaults] boolForKey:@"includeImages"]) {
        [dictionary setValue:@"Yes" forKey:@"includeImages"];
    }
    
    MGTemplateEngine *engine = [[MGTemplateEngine alloc] init];
    engine.matcher = [[[ICUTemplateMatcher alloc] initWithTemplateEngine:engine] autorelease];
    NSString *mailBody = [engine processTemplateInFileAtPath:[[NSBundle mainBundle] pathForResource:@"mailTemplate" ofType:@"html"] withVariables:dictionary];
    [engine release];
    
    controller.mailComposeDelegate = self;
    
    NSString *subjectLine = [NSString stringWithFormat:@"Expenses summary report for trip '%@'", self.travel.name];
    if (!self.travel.name || [self.travel.name length] == 0) {
        subjectLine = [NSString stringWithFormat:@"Expenses summary report for trip to %@", self.travel.location];
    }
    [controller setSubject:subjectLine];
    [controller setMessageBody:mailBody isHTML:YES];
    
    NSLog(@"%@", mailBody);
    
    NSMutableArray *toArray = [NSMutableArray array];
    for (Participant *p in self.travel.participants) {
        if (![p.yourself isEqual:[NSNumber numberWithInt:1]]) {
            if (p.email != nil && [p.email length] > 0) {
                [toArray addObject:p.email];
            } 
        } else {
            [controller setCcRecipients:[NSArray arrayWithObject:p.email]];
        }
        
    }
    [controller setToRecipients:toArray];
    
    
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
        _entry.created = [NSDate date];
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
    _entry.lastUpdated = [NSDate date];
    
    [ReiseabrechnungAppDelegate saveContext:[_travel managedObjectContext]];
    
    [self.entrySortViewController.detailViewController.tableView endUpdates];
    
    [self updateSummary];
}

- (void)selectPerson:(ABRecordRef)abRecordRef withEmail:(NSString *)email {
    
    Participant *newPerson = [NSEntityDescription insertNewObjectForEntityForName: @"Participant" inManagedObjectContext: [_travel managedObjectContext]];
    [Participant addParticipant:newPerson toTravel:_travel withABRecord:abRecordRef andEmail:email];
    [ReiseabrechnungAppDelegate saveContext:[_travel managedObjectContext]];    
}

- (void)entryWasDeleted:(Entry *)entry {
    
    [self updateSummary];
}

- (void)updateSummary {
    
    //    dispatch_queue_t updateQueue = dispatch_queue_create("UpdateSummary", NULL);
    //    dispatch_async(updateQueue, ^{
    //        
    //        [self.summarySortViewController.detailViewController recalculateSummary];
    //        
    //        dispatch_async(dispatch_get_main_queue(), ^{
    //            [self.summarySortViewController.detailViewController.tableView reloadData];     
    //        });
    //    });
    
    [self.summarySortViewController.detailViewController recalculateSummary];
    [self.summarySortViewController.detailViewController.tableView reloadData]; 
}

- (void)editWasCanceled:(Entry *)entry {
    
    if (entry) {
        [self.entrySortViewController.detailViewController.tableView deselectRowAtIndexPath:[[self.entrySortViewController.detailViewController fetchedResultsControllerForTableView:self.entrySortViewController.detailViewController.tableView] indexPathForObject:entry] animated:YES];
    }
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
        
        [self updateSummary];
    });
}

- (void)initHelpBubbleForViewController:(UIViewController *)viewController {
    
    if (viewController == self.participantViewController && ![self.travel.closed isEqualToNumber:[NSNumber numberWithInt:1]]) {
        
        NSString *text = @"Add travelers on this trip here.";
        HelpView *helpView = [[HelpView alloc] initWithFrame:CGRectMake(218, 0, 100, 100) text:text arrowPosition:ARROWPOSITION_TOP_RIGHT enterStage:ENTER_STAGE_FROM_TOP uniqueIdentifier:@"traveler add"];
        [UIFactory addHelpViewToView:helpView toView:viewController.view];
        [helpView release];
        
    } else if (viewController == self.entrySortViewController) {
        
        if (![self.travel.closed isEqualToNumber:[NSNumber numberWithInt:1]]) {
            NSString *text = @"Add new expense entries here.";
            HelpView *helpView = [[HelpView alloc] initWithFrame:CGRectMake(218, NAVIGATIONBAR_HEIGHT, 100, 100) text:text arrowPosition:ARROWPOSITION_TOP_RIGHT enterStage:ENTER_STAGE_FROM_TOP uniqueIdentifier:@"entry add"];
            [UIFactory addHelpViewToView:helpView toView:viewController.view];
            [helpView release];
        }
        
        NSString *text = @"Use these button to sort the expense entries.";
        HelpView *helpView = [[HelpView alloc] initWithFrame:CGRectMake(110, 270, 100, 100) text:text arrowPosition:ARROWPOSITION_BOTTOM_LEFT enterStage:ENTER_STAGE_FROM_BOTTOM uniqueIdentifier:@"sort button entry"];
        [UIFactory addHelpViewToView:helpView toView:viewController.view];
        [helpView release];
        
    } else if (viewController == self.summarySortViewController) {
        
        NSString *text = @"This button offers you action like sending the summary report email to the travelers. You can also fix or edit currency exchange rates here.";
        HelpView *helpView = [[HelpView alloc] initWithFrame:CGRectMake(218, NAVIGATIONBAR_HEIGHT, 100, 100) text:text arrowPosition:ARROWPOSITION_TOP_RIGHT enterStage:ENTER_STAGE_FROM_TOP uniqueIdentifier:@"action button"];
        [UIFactory addHelpViewToView:helpView toView:viewController.view];
        [helpView release];
        
        text = @"Find here the date of the last update of the currency exchange rates. Use the action above to update them now.";
        HelpView *openHelpView = [[HelpView alloc] initWithFrame:CGRectMake(110, 280, 100, 100) text:text arrowPosition:ARROWPOSITION_BOTTOM_RIGHT enterStage:ENTER_STAGE_FROM_BOTTOM uniqueIdentifier:@"rateLabel"];
        
        text = @"The travel was closed and can not be changed any more. Exchange rates used of this travel are fixed.";
        HelpView *closedHelpView = [[HelpView alloc] initWithFrame:CGRectMake(110, 280, 100, 100) text:text arrowPosition:ARROWPOSITION_BOTTOM_RIGHT enterStage:ENTER_STAGE_FROM_BOTTOM uniqueIdentifier:@"travelClosedLabel"];
        
        if (![self.travel.closed isEqualToNumber:[NSNumber numberWithInt:1]]) { // is open
            if (!self.summarySortViewController.ratesToolBar.hidden) {
                [UIFactory replaceHelpViewInView:closedHelpView.uniqueIdentifier withView:openHelpView toView:viewController.view];
            }
        } else {
            [UIFactory replaceHelpViewInView:openHelpView.uniqueIdentifier withView:closedHelpView toView:viewController.view];
        }
        
        [openHelpView release];
        [closedHelpView release];
    }
}

- (void) updateTableViewInsets {
    
    self.participantViewController.tableView.contentInset = UIEdgeInsetsMake(self.navigationController.navigationBar.frame.size.height, 0, 0, 0);
    self.participantViewController.tableView.scrollIndicatorInsets = self.participantViewController.tableView.contentInset;
    
    self.entrySortViewController.detailViewController.tableView.contentInset = UIEdgeInsetsMake(self.navigationController.navigationBar.frame.size.height, 0, 0, 0);
    self.entrySortViewController.detailViewController.tableView.scrollIndicatorInsets = self.entrySortViewController.detailViewController.tableView.contentInset;
    
    self.summarySortViewController.detailViewController.tableView.contentInset = UIEdgeInsetsMake(self.navigationController.navigationBar.frame.size.height, 0, self.summarySortViewController.ratesToolBar.frame.size.height, 0);
    self.summarySortViewController.detailViewController.tableView.scrollIndicatorInsets = self.summarySortViewController.detailViewController.tableView.contentInset;
    
}


#pragma mark - ParticipantViewControllerEditDelegate

- (void)participantEditFinished:(Participant *)participant wasSaved:(BOOL)wasSaved {
    
    [self.participantViewController.tableView deselectRowAtIndexPath:[self.participantViewController.tableView indexPathForSelectedRow] animated:YES];
    
}

- (void)openParticipantPopup:(Participant *)participant {
    
    ParticipantEditViewController *detailViewController = [[ParticipantEditViewController alloc] initInManagedObjectContext:[self.travel managedObjectContext] withTravel:self.travel withParticipant:participant];
    detailViewController.editDelegate = self;
    UINavigationController *navController = [[ShadowNavigationController alloc] initWithRootViewController:detailViewController];
    navController.delegate = detailViewController;
    [self presentModalViewController:navController animated:YES];   
    [detailViewController release];
    [navController release];    
}

#pragma mark - ParticipantViewControllerEditDelegate

- (void)participantWasDeleted:(Participant *)participant {
    
    [self updateSummary];   
}

#pragma mark - UIAlertViewDelegate

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    
    if (alertView == self.rateRefreshAlertView) {
        
        [self openTravel:(buttonIndex != [alertView cancelButtonIndex])];
        
    } else if (alertView == self.mailSendAlertView && buttonIndex != self.mailSendAlertView.cancelButtonIndex) {
        
        [self sendSummaryMail];
        
    }
}

#pragma mark - UIActionSheetDelegate

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
    
    if ([actionSheet isEqual:self.actionSheetOpenTravel] || [actionSheet isEqual:self.actionSheetClosedTravel]) {
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
    } else {
        
        if (buttonIndex == 0) {
            
            [self openPersonAddPopup];
            
        } else if (buttonIndex == 1) {
            
            [self openParticipantPopup:nil];
            
        }
    }
}
#pragma mark - RateSelectViewControllerDelegate

- (void)willDisappearWithChanges {
    [self updateSummary];
}

#pragma mark - ABPeoplePickerNavigationControllerDelegate

- (BOOL)peoplePickerNavigationController:(ABPeoplePickerNavigationController *)peoplePicker shouldContinueAfterSelectingPerson:(ABRecordRef)person {
    
    BOOL returnValue = YES;
    
    ABMultiValueRef *multiValue = (ABMultiValueRef *) ABRecordCopyValue(person, kABPersonEmailProperty);
    NSArray *emailList = (NSArray *) ABMultiValueCopyArrayOfAllValues(multiValue);
    
    if ([emailList count] <= 1) {
        
        NSString *email = nil;
        if ([emailList count] > 0) {
            email = [emailList objectAtIndex:0];
        }
        
        [self selectPerson:person withEmail:email];
        [[self navigationController] dismissModalViewControllerAnimated:YES];
        
        returnValue = NO;
    }
    
    CFRelease(multiValue);
    
    if (emailList) {
        CFRelease(emailList);
    }
    
    return returnValue;
}

- (BOOL)peoplePickerNavigationController:(ABPeoplePickerNavigationController *)peoplePicker shouldContinueAfterSelectingPerson:(ABRecordRef)person 
								property:(ABPropertyID)property identifier:(ABMultiValueIdentifier)identifier {
    
    ABMultiValueRef *multiValue = (ABMultiValueRef *) ABRecordCopyValue(person, property);
    CFIndex index = (CFIndex) ABMultiValueGetIndexForIdentifier(multiValue, identifier);
    NSString *email = (NSString *) ABMultiValueCopyValueAtIndex(multiValue, index);
    
    [self selectPerson:person withEmail:email];
    [[self navigationController] dismissModalViewControllerAnimated:YES];
    
    CFRelease(multiValue);
    CFRelease(email);
    
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
    
    [self initHelpBubbleForViewController:viewController];
}



- (BOOL)tabBarController:(UITabBarController *)tabBarController shouldSelectViewController:(UIViewController *)viewController {
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
    self.participantViewController.editDelegate = self;
    
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
    
    self.mailSendAlertView = [[[UIAlertView alloc] initWithTitle:@"Warning" message:nil delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"OK", nil] autorelease];
    
    self.rateRefreshAlertView = [UIFactory createAlterViewForRefreshingRatesOnOpeningTravel:self];
    
}

- (void)viewDidAppear:(BOOL)animated {
    [self.participantViewController viewDidAppear:animated];
    [self.entrySortViewController viewDidAppear:animated];
    [self.summarySortViewController viewDidAppear:animated];
    
    
    [self initHelpBubbleForViewController:self.tabBarController.selectedViewController];
}

- (void)viewWillAppear:(BOOL)animated {
    [self updateTableViewInsets];
}

- (void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation {
    [self updateTableViewInsets];
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
