//
//  TravelViewController.m
//  Reiseabrechnung
//
//  Created by Martin Maier on 30/06/2011.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "TravelViewController.h"
#import "ParticipantViewController.h"
#import "EntryViewController.h"
#import "SummaryViewController.h"
#import "Participant.h"
#import "EntryEditViewController.h"


@implementation TravelViewController

@synthesize travel=_travel, tabBarController=_tabBarController, addButton=_addButton;
@synthesize participantViewController=_participantViewController, entryViewController=_entryViewController, summaryViewController=_summaryViewController;

- (id) initWithTravel:(Travel *) travel {
    self = [super init];
    if (self) {
        _travel = travel;
    }
    return self;    
}

- (void)dealloc
{
    [super dealloc];
}

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

- (BOOL)peoplePickerNavigationController:(ABPeoplePickerNavigationController *)peoplePicker shouldContinueAfterSelectingPerson:(ABRecordRef)person{
    
    NSString *firstName = (NSString *) ABRecordCopyValue(person, kABPersonFirstNameProperty);
    NSString *lastName = (NSString *) ABRecordCopyValue(person, kABPersonLastNameProperty);
    
    [self addPerson:[NSString stringWithFormat:@"%@ %@", firstName, lastName]];
    
    [firstName release];
    [lastName release];
    
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

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [_participantViewController postConstructWithTravel:_travel];
    [_entryViewController postConstructWithTravel:_travel];
    [_summaryViewController postConstructWithTravel:_travel];
    
    self.addButton = [[UIBarButtonItem alloc] initWithTitle:@"Add" style:UIBarButtonItemStylePlain target:self action:@selector(openAddPopup)]; 
    self.navigationItem.rightBarButtonItem = _addButton;
    
    if ([_travel.participants count] == 0) {
        self.tabBarController.selectedViewController = _participantViewController;
    } else {
        self.tabBarController.selectedViewController = _entryViewController;
    }
    
    [self.view addSubview:_tabBarController.view];

}

- (void)openAddPopup {
    if ([[[self tabBarController] selectedViewController] isEqual:_participantViewController]) {
        [self openParticipantAddPopup];
    } else if ([[[self tabBarController] selectedViewController] isEqual:_entryViewController]) {
        [self openEntryAddPopup];
    }
}

- (void)openEntryAddPopup {
    EntryEditViewController *detailViewController = [[EntryEditViewController alloc] initWithTravel:_travel];
    detailViewController.rootViewController = self;
    [self.navigationController presentModalViewController:detailViewController animated:YES];   
    [detailViewController release];
}

- (void)openParticipantAddPopup {
    ABPeoplePickerNavigationController *picker = [[ABPeoplePickerNavigationController alloc] init];
    picker.peoplePickerDelegate = self;
    [self presentModalViewController:picker animated:YES];
    [picker release];
}

- (void)addPerson:(NSString *)name {
    Participant *p = [NSEntityDescription insertNewObjectForEntityForName: @"Participant" inManagedObjectContext: [_travel managedObjectContext]];
    p.name = name;
    p.travel = _travel;
    [self saveContext];
}

- (void)addEntry:(NSString *)description withAmount:(NSNumber *)amount withCurrency:(NSString *)currency withDate:(NSDate *)date {
    Entry *_entry = [NSEntityDescription insertNewObjectForEntityForName: @"Entry" inManagedObjectContext: [_travel managedObjectContext]];
    _entry.text = description;
    _entry.amount = amount;
    _entry.currency = currency;
    _entry.date = date;
    _entry.currency = currency;
    _entry.travel = _travel;
    [self saveContext];
}

- (void)tabBarController:(UITabBarController *)tabBarController didSelectViewController:(UIViewController *)viewController {
    if ([viewController isEqual:_summaryViewController]) {
        self.navigationItem.rightBarButtonItem = nil;
    } else {
        self.navigationItem.rightBarButtonItem = _addButton;
    }
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
   }

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (void)saveContext
{
    NSError *error = nil;
    NSManagedObjectContext *managedObjectContext = [_travel managedObjectContext];
    if (managedObjectContext != nil)
    {
        if ([managedObjectContext hasChanges] && ![managedObjectContext save:&error])
        {
            NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
            abort();
        } 
    }
}

@end
