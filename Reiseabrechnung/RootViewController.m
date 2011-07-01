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

@implementation RootViewController

@synthesize managedObjectContext=_managedObjectContext, fetchedResultsController=_fetchedResultsController;;
@synthesize addButton;


- (id) initInManagedObjectContext:(NSManagedObjectContext *) context {
    
    self = [super initWithStyle:UITableViewStylePlain];
    if (self) {
        
        self.managedObjectContext = context;
    
        NSFetchRequest *req = [[NSFetchRequest alloc] init];
        req.entity = [NSEntityDescription entityForName:@"Travel" inManagedObjectContext: self.managedObjectContext];
        req.sortDescriptors = [NSArray arrayWithObject:[NSSortDescriptor sortDescriptorWithKey:@"created" ascending:YES]];
    
        self.fetchedResultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:req managedObjectContext:self.managedObjectContext sectionNameKeyPath:nil cacheName:@"Travel"];
        [req release];
        
        self.fetchedResultsController.delegate = self;
        
        self.titleKey = @"name";
        self.subtitleKey = @"name";
        
    }
    return self;
}

- (void)managedObjectSelected:(NSManagedObject *)managedObject {
    
    Travel *travel = (Travel *) managedObject;
    
    TravelViewController *detailViewController = [[TravelViewController alloc] initWithTravel:travel];
    detailViewController.title = travel.name;

    [self.navigationController pushViewController:detailViewController animated:YES];
    [detailViewController release];    
    
}

- (void)deleteManagedObject:(NSManagedObject *)managedObject
{
    [self.managedObjectContext deleteObject:managedObject];
    [self saveContext:_managedObjectContext];
}

- (BOOL)canDeleteManagedObject:(NSManagedObject *)managedObject
{
	return YES;
}

- (void)viewDidLoad {
    [super viewDidLoad];

    self.title = @"Reiseabrechnungen";
    
    UIBarButtonItem *anotherButton = [[UIBarButtonItem alloc] initWithTitle:@"Add" style:UIBarButtonItemStylePlain target:self action:@selector(openTravelPopup)];          
    self.navigationItem.rightBarButtonItem = anotherButton;
    [anotherButton release];
}

- (void)viewDidUnload {
    [super viewDidUnload];
    
    [self saveContext:_managedObjectContext];
}

- (void)openTravelPopup {
    TravelEditViewController *detailViewController = [[TravelEditViewController alloc] init];
    detailViewController.rootViewController = self;
    [self.navigationController presentModalViewController:detailViewController animated:YES];   
    [detailViewController release];   
}

- (void)addTravel:(NSString *)name withCurrency:(NSString *)currency {
    
    Travel *_travel = [NSEntityDescription insertNewObjectForEntityForName: @"Travel" inManagedObjectContext: _managedObjectContext];
    _travel.name = name;
    _travel.created = [NSDate date];
    _travel.currency = currency;
    
    [self saveContext:_managedObjectContext];
}

- (void)dealloc {
    [super dealloc];
}

@end
