//
//  RootViewController.m
//  Reiseabrechnung
//
//  Created by Martin Maier on 28/06/2011.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "RootViewController.h"
#import "TravelViewController.h"
#import "TravelEditViewController.h"
#import "Currency.h"
#import "ReiseabrechnungAppDelegate.h"

@implementation RootViewController

@synthesize managedObjectContext=_managedObjectContext, fetchedResultsController=_fetchedResultsController;
@synthesize addButton=_addButton, editButton=_editButton, doneButton=_doneButton;


- (id) initInManagedObjectContext:(NSManagedObjectContext *) context {
    
    self = [super initWithStyle:UITableViewStyleGrouped];
    if (self) {
        
        _managedObjectContext = context;
    
        NSFetchRequest *req = [[NSFetchRequest alloc] init];
        req.entity = [NSEntityDescription entityForName:@"Travel" inManagedObjectContext: self.managedObjectContext];
        req.sortDescriptors = [NSArray arrayWithObject:[NSSortDescriptor sortDescriptorWithKey:@"created" ascending:YES]];
    
        self.fetchedResultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:req managedObjectContext:self.managedObjectContext sectionNameKeyPath:nil cacheName:@"Travel"];
        [req release];
        
        self.fetchedResultsController.delegate = self;
        [self.fetchedResultsController performFetch:nil];
        
        self.titleKey = @"name";
        self.subtitleKey = @"country.name";
        self.imageKey = @"country.image";
        
        self.tableView.separatorStyle = UITableViewCellSeparatorStyleSingleLine;
        
    }
    return self;
}

- (void)managedObjectSelected:(NSManagedObject *)managedObject {
    
    if (self.tableView.editing) {
        
        TravelEditViewController *detailViewController = [[TravelEditViewController alloc] initInManagedObjectContext:self.managedObjectContext withTravel:(Travel *)managedObject];
        UINavigationController *navController = [[UINavigationController alloc] initWithRootViewController:detailViewController];
        [self.navigationController presentModalViewController:navController animated:YES];   
        [detailViewController release];
        [navController release];
        
    } else {
        Travel *travel = (Travel *) managedObject;
        
        TravelViewController *detailViewController = [[TravelViewController alloc] initWithTravel:travel];
        detailViewController.title = travel.name;
        
        [self.navigationController pushViewController:detailViewController animated:YES];
        [detailViewController release]; 
    }
    
}

- (void)deleteManagedObject:(NSManagedObject *)managedObject
{
    [self.managedObjectContext deleteObject:managedObject];
    [ReiseabrechnungAppDelegate saveContext:self.managedObjectContext];
}

- (BOOL)canDeleteManagedObject:(NSManagedObject *)managedObject
{
	return YES;
}

- (void)viewDidLoad {
    [super viewDidLoad];

    self.title = @"Reiseabrechnungen";
    
    self.navigationItem.rightBarButtonItem = self.addButton;
    self.navigationItem.leftBarButtonItem = self.editButton;
    
    self.tableView.allowsSelectionDuringEditing = YES;
    
    [_tripLabel release];
    _tripLabel= [[UILabel alloc] initWithFrame:CGRectMake(0, 0, self.view.bounds.size.width, self.view.bounds.size.height - 46)];
    _tripLabel.text = @"No existing trips. \n Click on the \"+\" button to add a trip.";
    _tripLabel.backgroundColor = [UIColor clearColor];
    _tripLabel.numberOfLines = 0;
    _tripLabel.textAlignment = UITextAlignmentCenter;
    _tripLabel.textColor = [UIColor whiteColor];
    [self.view addSubview:_tripLabel];
    
    UIColor *background = [[UIColor alloc] initWithPatternImage:[UIImage imageNamed:@"background.png"]];
    self.view.backgroundColor = background;
    [background release];
    
    [self updateNoTripLabel];
}

- (void)controllerDidChangeContent:(NSFetchedResultsController *)controller {
    [super controllerDidChangeContent:controller];
    [self updateNoTripLabel];
}

- (void) updateNoTripLabel {
    if ([self.fetchedResultsController. fetchedObjects count] == 0) {
        _tripLabel.hidden = NO;
    } else {
        _tripLabel.hidden = YES;
    }
}

- (UIBarButtonItem *) addButton {
    if (!_addButton) {
        _addButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(openTravelPopup)];   
    }
    return [_addButton retain];    
}

- (UIBarButtonItem *) editButton {
    if (!_editButton) {
        _editButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemEdit target:self action:@selector(changeToEditMode)]; 
    }
    return [_editButton retain];    
}

- (UIBarButtonItem *) doneButton {
    if (!_doneButton) {
        _doneButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(doneEditing)];
    }
    return [_doneButton retain];       
}

- (void)viewDidUnload {
    [super viewDidUnload];
    
    [ReiseabrechnungAppDelegate saveContext:self.managedObjectContext];
}

- (void)openTravelPopup {
    TravelEditViewController *detailViewController = [[TravelEditViewController alloc] initInManagedObjectContext:self.managedObjectContext];
    UINavigationController *navController = [[UINavigationController alloc] initWithRootViewController:detailViewController];
    [self.navigationController presentModalViewController:navController animated:YES];   
    [detailViewController release];
    [navController release];
}

- (void)changeToEditMode {
    [self.navigationItem setRightBarButtonItem:self.doneButton animated:YES];
    [self.navigationItem setLeftBarButtonItem:nil animated:YES];
    [self.tableView setEditing:YES animated:YES];
}

- (void)doneEditing {
    [self.navigationItem setRightBarButtonItem:self.addButton animated:YES];
    [self.navigationItem setLeftBarButtonItem:self.editButton animated:YES];
    [self.tableView setEditing:NO animated:YES];
}

- (void)addTravel:(NSString *)name withCurrency:(Currency *)newCurrency {
    
    NSLog(@"%@", self.managedObjectContext);
    
    Travel *_travel = [NSEntityDescription insertNewObjectForEntityForName: @"Travel" inManagedObjectContext: self.managedObjectContext];
    _travel.name = name;
    _travel.created = [NSDate date];
    _travel.homeCurrency = newCurrency;
    
    [ReiseabrechnungAppDelegate saveContext:self.managedObjectContext];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return YES;
}

- (void)dealloc {
    [_tripLabel release];
    [_managedObjectContext release];
    [_addButton release];
    [_editButton release];
    [_doneButton release];
    
    [super dealloc];
}

@end
