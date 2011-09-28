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
@synthesize participantSortViewController=_participantSortViewController, entrySortViewController=_entrySortViewController, summarySortViewController=_summarySortViewController;
@synthesize mailSendAlertView=_mailSendAlertView, rateRefreshAlertView=_rateRefreshAlertView;

@synthesize actionSheetAddPerson=_actionSheetAddPerson, actionSheetOpenTravel=_actionSheetOpenTravel, actionSheetClosedTravel=_actionSheetClosedTravel, actionSheetOpenTravelNoCurrency=_actionSheetOpenTravelNoCurrency;


- (id)initWithTravel:(Travel *) travel {
    
    self = [self init];
    
    if (self) {
        _travel = travel;
        
        self.actionSheetClosedTravel = [[[UIActionSheet alloc] initWithTitle:NSLocalizedString(@"Choose your action", @"close travel action sheet title")
                                                                    delegate:self
                                                           cancelButtonTitle:NSLocalizedString(@"Cancel", @"Cancel")
                                                      destructiveButtonTitle:nil
                                                           otherButtonTitles:NSLocalizedString(@"Send summary e-mail", @"alert item mail"), NSLocalizedString(@"Open this trip", @"alert item open trip"), nil] autorelease];
        self.actionSheetClosedTravel.actionSheetStyle = UIActionSheetStyleBlackTranslucent;
        
        
        self.actionSheetOpenTravel = [[[UIActionSheet alloc] initWithTitle:NSLocalizedString(@"Choose your action", @"open travel action sheet title")
                                                                  delegate:self
                                                         cancelButtonTitle:NSLocalizedString(@"Cancel", @"Cancel")
                                                    destructiveButtonTitle:nil
                                                         otherButtonTitles:NSLocalizedString(@"Send summary e-mail", @"alert item mail"), NSLocalizedString(@"Close this trip", @"alert item close trip"), NSLocalizedString(@"Update exchange rates", @"alert item update rates"), NSLocalizedString(@"Manually edit rates", @"alert title edit rate"), nil] autorelease];
        self.actionSheetOpenTravel.actionSheetStyle = UIActionSheetStyleBlackTranslucent;        
        
        
        self.actionSheetOpenTravelNoCurrency = [[[UIActionSheet alloc] initWithTitle:NSLocalizedString(@"Choose your action", @"open travel action sheet title")
                                                                  delegate:self
                                                         cancelButtonTitle:NSLocalizedString(@"Cancel", @"Cancel")
                                                    destructiveButtonTitle:nil
                                                         otherButtonTitles:NSLocalizedString(@"Send summary e-mail", @"alert item mail"), NSLocalizedString(@"Close this trip", @"alert item close trip"), nil] autorelease];
        self.actionSheetOpenTravelNoCurrency.actionSheetStyle = UIActionSheetStyleBlackTranslucent;   
        
        self.actionSheetAddPerson = [[[UIActionSheet alloc] initWithTitle:NSLocalizedString(@"Where is the person?", @"add person action sheet title")
                                                                 delegate:self
                                                        cancelButtonTitle:NSLocalizedString(@"Cancel", @"Cancel")
                                                   destructiveButtonTitle:nil
                                                        otherButtonTitles:NSLocalizedString(@"From Address Book", @"alert item address book"), NSLocalizedString(@"Create new person", @"alert item new person"), nil] autorelease];
        self.actionSheetAddPerson.actionSheetStyle = UIActionSheetStyleBlackTranslucent;
    }
    return self;    
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    return YES;
}

#pragma mark Open PopUps

- (void)openAddPopup {
    
    if ([[[self tabBarController] selectedViewController] isEqual:self.participantSortViewController]) {
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
        if ([self.travel.currencies count] == 1) {
            [self.actionSheetOpenTravelNoCurrency showInView:self.view];
        } else {
            [self.actionSheetOpenTravel showInView:self.view];
        }
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
    [self.participantSortViewController.detailViewController.tableView reloadData];
    
    [self.participantSortViewController.detailViewController updateTravelOpenOrClosed];
    [self.entrySortViewController.detailViewController updateTravelOpenOrClosed];
    [self.summarySortViewController updateRateLabel:YES];
    
    [self initHelpBubbleForViewController:self.summarySortViewController];
}

- (void)openTravel:(BOOL)useLatestRates {
    
    // open
    [self.travel open:useLatestRates];
    
    [ReiseabrechnungAppDelegate saveContext:[self.travel managedObjectContext]];
    
    [self.summarySortViewController.detailViewController.tableView reloadData];
    [self.entrySortViewController.detailViewController.tableView reloadData];
    [self.participantSortViewController.detailViewController.tableView reloadData];
    
    [self updateStateOfNavigationController:self.tabBarController.selectedViewController]; 
    
    [self.participantSortViewController.detailViewController updateTravelOpenOrClosed];
    [self.entrySortViewController.detailViewController updateTravelOpenOrClosed];
    [self.summarySortViewController updateRateLabel:YES];
    
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
        NSString *message = [NSString stringWithFormat:NSLocalizedString(@"There are no email addresses available for the participant%@ %@", @"alert no mail addresses"), ([noMailParticipants count]==1)?@"":NSLocalizedString(@"plural character",@"plural character"), [self prettyPrintListOfStrings:noMailParticipants]];
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
        
        returnValue = [NSString stringWithFormat:NSLocalizedString(@"%@ and %@", @"param1 'and' param2 count:2"), [array objectAtIndex:0], [array objectAtIndex:1]];
        
    } else {
        
        for (int i=0; i < [array count]; i++) {
            if (i == 0) {
                returnValue = [array objectAtIndex:i];
            } else if (i == [array count] - 1) {
                returnValue = [returnValue stringByAppendingFormat:NSLocalizedString(@", and %@",  @"param1 'and' param2 count:>2"), [array objectAtIndex:i]];
            } else {
                returnValue = [returnValue stringByAppendingFormat:@", %@", [array objectAtIndex:i]];
            }
        }
    }
    
    return returnValue;
}

- (void)sendSummaryMail {
    
    MFMailComposeViewController* controller = [[MFMailComposeViewController alloc] init];
    controller.navigationBar.barStyle = UIBarStyleBlack;
    
    NSMutableDictionary *dictionary = [NSMutableDictionary dictionaryWithObject:self.travel forKey:@"travel"];
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    
    if ([userDefaults boolForKey:@"includeImages"]) {
        [dictionary setValue:@"Yes" forKey:@"includeImages"];
        
        for (Participant *p in self.travel.participants) {
            //UIImage * image = [UIImage imageWithData:p.image];
            //[controller addAttachmentData:UIImageJPEGRepresentation(image, 1) mimeType:@"image/jpg" fileName:[NSString stringWithFormat:@"%@.jpg", p.name]];
        }
    }
    if ([self.travel.name length] > 0) {
        [dictionary setValue:@"Yes" forKey:@"tripHasName"];
    }
    
    [dictionary setValue:NSLocalizedString(@"Expenses of trip", @"mail label") forKey:@"labelExpenses"];
    [dictionary setValue:NSLocalizedString(@"to", @"mail label") forKey:@"labelTo"];
    [dictionary setValue:NSLocalizedString(@"Payer", @"mail label") forKey:@"labelPayer"];
    [dictionary setValue:NSLocalizedString(@"Type", @"mail label") forKey:@"labelType"];
    [dictionary setValue:NSLocalizedString(@"Description", @"mail label") forKey:@"labelText"];
    [dictionary setValue:NSLocalizedString(@"Amount", @"mail label") forKey:@"labelAmount"];
    [dictionary setValue:NSLocalizedString(@"Date", @"mail label") forKey:@"labelDate"];
    [dictionary setValue:NSLocalizedString(@"Receivers", @"mail label") forKey:@"labelReceivers"];
    [dictionary setValue:NSLocalizedString(@"total costs", @"mail label") forKey:@"labelTotal"];
    [dictionary setValue:NSLocalizedString(@"Summary", @"mail label") forKey:@"labelSummary"];
    [dictionary setValue:NSLocalizedString(@"who owes", @"mail label") forKey:@"labelWhoOwes"];
    [dictionary setValue:NSLocalizedString(@"how much", @"mail label") forKey:@"labelHowMuch"];
    [dictionary setValue:NSLocalizedString(@"to whom", @"mail label") forKey:@"labelToWhom"];
    [dictionary setValue:NSLocalizedString(@"already paid", @"mail label") forKey:@"labelAlreadyPaid"];
    [dictionary setValue:NSLocalizedString(@"Yes", @"mail label") forKey:@"labelYes"];
    [dictionary setValue:NSLocalizedString(@"No", @"mail label") forKey:@"labelNo"];
    [dictionary setValue:NSLocalizedString(@"Currencies used for this trip:", @"mail label") forKey:@"labelCurrenciesUsed"];
    
    MGTemplateEngine *engine = [[MGTemplateEngine alloc] init];
    engine.matcher = [[[ICUTemplateMatcher alloc] initWithTemplateEngine:engine] autorelease];
    NSString *mailBody = [engine processTemplateInFileAtPath:[[NSBundle mainBundle] pathForResource:@"mailTemplate" ofType:@"html"] withVariables:dictionary];
    [engine release];
    
    controller.mailComposeDelegate = self;
    
    NSString *subjectLine = [NSString stringWithFormat:NSLocalizedString(@"Expenses summary report for trip '%@'", @"mail subject"), self.travel.name];
    if (!self.travel.name || [self.travel.name length] == 0) {
        subjectLine = [NSString stringWithFormat:NSLocalizedString(@"Expenses summary report for trip to %@", @"mail subject with no travel name"), self.travel.location];
    }
    [controller setSubject:subjectLine];
    [controller setMessageBody:mailBody isHTML:YES];

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
            _summarySortViewController.lastUpdatedLabel.text = NSLocalizedString(@"Updating currency exchange rates...", @"status text of update toolbar");
            [_summarySortViewController centerRateLabel];
            [_summarySortViewController.updateIndicator startAnimating];
        });
        
        CurrencyRefresh *currencyRefresh = [[CurrencyRefresh alloc] initInManagedContext:[self.travel managedObjectContext]];
        NSLog(@"Updating currencies...");
        BOOL updated = [currencyRefresh refreshCurrencies];
        [currencyRefresh release];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            [_summarySortViewController updateRateLabel:YES];
            [_summarySortViewController.updateIndicator stopAnimating];
            
            if (updated) {
                [self updateSummary];
            }
        });
        
    });
}

- (void)initHelpBubbleForViewController:(UIViewController *)viewController {
    
    double navBarHeight = self.navigationController.navigationBar.frame.size.height;
    double entrySortHeight = self.entrySortViewController.detailViewController.tableView.tableHeaderView.frame.size.height;
    double windowWidth = self.view.frame.size.width;
    double windowHeight = self.view.frame.size.height;
    
    if (viewController == self.participantSortViewController && ![self.travel.closed isEqualToNumber:[NSNumber numberWithInt:1]]) {
        
        NSString *text = NSLocalizedString(@"help add people", @"help bubble add travelers");
        HelpView *helpView = [[HelpView alloc] initWithFrame:CGRectMake(windowWidth - 102, navBarHeight, 100, 100) text:text arrowPosition:ARROWPOSITION_TOP_RIGHT enterStage:ENTER_STAGE_FROM_TOP uniqueIdentifier:@"traveler add"];
        [UIFactory addHelpViewToView:helpView toView:viewController.view];
        [helpView release];
        
    } else if (viewController == self.entrySortViewController) {
        
        if (![self.travel.closed isEqualToNumber:[NSNumber numberWithInt:1]]) {
            NSString *text = NSLocalizedString(@"help add entries", @"help bubble add expenses");
            HelpView *helpView = [[HelpView alloc] initWithFrame:CGRectMake(windowWidth - 102, navBarHeight, 100, 100) text:text arrowPosition:ARROWPOSITION_TOP_RIGHT enterStage:ENTER_STAGE_FROM_TOP uniqueIdentifier:@"entry add"];
            [UIFactory addHelpViewToView:helpView toView:viewController.view];
            [helpView release];
        }
        
        NSString *text = NSLocalizedString(@"help sort", @"help bubble sort buttons");
        HelpView *helpView = [[HelpView alloc] initWithFrame:CGRectMake(10, navBarHeight + entrySortHeight - 5, 100, 100) text:text arrowPosition:ARROWPOSITION_TOP_LEFT enterStage:ENTER_STAGE_FROM_TOP uniqueIdentifier:@"sort button entry"];
        [UIFactory addHelpViewToView:helpView toView:viewController.view];
        [helpView release];
        
    } else if (viewController == self.summarySortViewController) {
        
        NSString *text = NSLocalizedString(@"help action", @"help bubble action button");
        HelpView *helpView = [[HelpView alloc] initWithFrame:CGRectMake(windowWidth - 102, navBarHeight, 100, 100) text:text arrowPosition:ARROWPOSITION_TOP_RIGHT enterStage:ENTER_STAGE_FROM_TOP uniqueIdentifier:@"action button"];
        [UIFactory addHelpViewToView:helpView toView:viewController.view];
        [helpView release];
        
        text = NSLocalizedString(@"help rate updated", @"help bubble last updated toolbar");
        HelpView *openHelpView = [[HelpView alloc] initWithFrame:CGRectMake(110, windowHeight - 180, 100, 100) text:text arrowPosition:ARROWPOSITION_BOTTOM_RIGHT enterStage:ENTER_STAGE_FROM_BOTTOM uniqueIdentifier:@"rateLabel"];
        
        text = NSLocalizedString(@"help closed travel", @"help bubble close travel");
        HelpView *closedHelpView = [[HelpView alloc] initWithFrame:CGRectMake(110, windowHeight - 180, 100, 100) text:text arrowPosition:ARROWPOSITION_BOTTOM_RIGHT enterStage:ENTER_STAGE_FROM_BOTTOM uniqueIdentifier:@"travelClosedLabel"];
        
        if (![self.travel.closed isEqualToNumber:[NSNumber numberWithInt:1]]) { // is open
            if (self.summarySortViewController.segControl.numberOfSegments > 1) {
                [UIFactory replaceHelpViewInView:closedHelpView.uniqueIdentifier withView:openHelpView toView:viewController.view];
            }
        } else {
            [UIFactory replaceHelpViewInView:openHelpView.uniqueIdentifier withView:closedHelpView toView:viewController.view];
        }
        
        [openHelpView release];
        [closedHelpView release];
    }
}

- (void)updateTableViewInsets {
    
    self.participantSortViewController.detailViewController.tableView.contentInset = UIEdgeInsetsMake(self.navigationController.navigationBar.frame.size.height, 0, 0, 0);
    self.participantSortViewController.detailViewController.tableView.scrollIndicatorInsets = self.participantSortViewController.detailViewController.tableView.contentInset;
    
    self.entrySortViewController.detailViewController.tableView.contentInset = UIEdgeInsetsMake(self.navigationController.navigationBar.frame.size.height, 0, 0, 0);
    self.entrySortViewController.detailViewController.tableView.scrollIndicatorInsets = self.entrySortViewController.detailViewController.tableView.contentInset;
    
    self.summarySortViewController.detailViewController.tableView.contentInset = UIEdgeInsetsMake(self.navigationController.navigationBar.frame.size.height, 0, 0, 0);
    self.summarySortViewController.detailViewController.tableView.scrollIndicatorInsets = self.summarySortViewController.detailViewController.tableView.contentInset;
    
}


#pragma mark - ParticipantViewControllerEditDelegate

- (void)participantEditFinished:(Participant *)participant wasSaved:(BOOL)wasSaved {
    
    [self.participantSortViewController.detailViewController.tableView deselectRowAtIndexPath:[self.participantSortViewController.detailViewController.tableView indexPathForSelectedRow] animated:YES];
    
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
    
    if (buttonIndex != actionSheet.cancelButtonIndex) {
        
        if ([actionSheet isEqual:self.actionSheetOpenTravel] || [actionSheet isEqual:self.actionSheetOpenTravelNoCurrency] || [actionSheet isEqual:self.actionSheetClosedTravel]) {
            
            if (buttonIndex == 0) {
                
                [self askToSendEmail];
                
            } else if (buttonIndex == 1) {
                
                if ([self.travel.closed intValue] == 1) {
                    
                    if ([self.travel.currencies count] == 1) {
                        [self openTravel:YES];
                    } else {
                        [self askToRefreshRatesWhenOpening];
                    }
                        
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
    
    self.participantSortViewController = [[[ParticipantSortViewController alloc] initWithTravel:_travel] autorelease];
    self.participantSortViewController.detailViewController.editDelegate = self;
    
    self.entrySortViewController = [[[EntrySortViewController alloc] initWithTravel:_travel] autorelease];
    self.entrySortViewController.detailViewController.editDelegate = self;
    
    self.summarySortViewController = [[[SummarySortViewController alloc] initWithTravel:_travel] autorelease];
    
    self.tabBarController = [[[UITabBarController alloc] init] autorelease];
    self.tabBarController.delegate = self;
    [self.tabBarController setViewControllers:[NSArray arrayWithObjects:self.participantSortViewController, self.entrySortViewController, self.summarySortViewController, nil] animated:NO];
    self.tabBarController.view.frame = CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height);
    self.tabBarController.tabBar.frame = CGRectMake(0, self.tabBarController.view.frame.size.height - TABBAR_HEIGHT, self.view.frame.size.width, TABBAR_HEIGHT);
    
    self.tabBarController.selectedIndex = [self.travel.selectedTab intValue];
    [self updateStateOfNavigationController:self.tabBarController.selectedViewController];
    
    [self.view addSubview:_tabBarController.view];
    
    self.mailSendAlertView = [[[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Warning", @"alert title") message:nil delegate:self cancelButtonTitle:NSLocalizedString(@"Cancel", @"alert item") otherButtonTitles:NSLocalizedString(@"OK", @"alert item"), nil] autorelease];
    
    self.rateRefreshAlertView = [UIFactory createAlterViewForRefreshingRatesOnOpeningTravel:self];
    
}

- (void)viewDidAppear:(BOOL)animated {
    [self.participantSortViewController viewDidAppear:animated];
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
    self.participantSortViewController = nil;
    self.entrySortViewController = nil;
    self.summarySortViewController = nil;
    self.addButton = nil;
}

#pragma mark Memory Management

- (void)dealloc {
    [super dealloc];
}

@end
