//
//  RootViewController.m
//  Reiseabrechnung
//
//  Created by Martin Maier on 28/06/2011.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>
#import "TravelListViewController.h"
#import "TravelViewController.h"
#import "TravelEditViewController.h"
#import "Currency.h"
#import "ReiseabrechnungAppDelegate.h"
#import "UIFactory.h"
#import "LocationViewController.h"
#import "TravelAddWizard.h"
#import "ShadowNavigationController.h"
#import "HelpView.h"

@implementation TravelListViewController

@synthesize managedObjectContext=_managedObjectContext, fetchedResultsController=_fetchedResultsController, rootViewController=_rootViewController;

- (id)initInManagedObjectContext:(NSManagedObjectContext *)managedObjectContext withRootViewController:(UIViewController <TravelEditViewControllerDelegate> *)rootViewController {
    
    self = [super initWithStyle:UITableViewStylePlain];
    if (self) {
        
        [UIFactory initializeTableViewController:self.tableView];
        
        _managedObjectContext = managedObjectContext;
        _rootViewController = rootViewController;
        
        NSFetchRequest *req = [[NSFetchRequest alloc] init];
        req.entity = [NSEntityDescription entityForName:@"Travel" inManagedObjectContext: self.managedObjectContext];
        req.sortDescriptors = [NSArray arrayWithObjects:[NSSortDescriptor sortDescriptorWithKey:@"closed" ascending:YES], [NSSortDescriptor sortDescriptorWithKey:@"created" ascending:YES], nil];
        
        self.fetchedResultsController = [[[NSFetchedResultsController alloc] initWithFetchRequest:req managedObjectContext:self.managedObjectContext sectionNameKeyPath:@"closed" cacheName:nil] autorelease];
        [req release];
        
        self.fetchedResultsController.delegate = self;
        [self performFetchForTableView:self.tableView];
        
        self.titleKey = @"name";
        self.subtitleKey = @"country.name";
        self.imageKey = @"country.image";

        self.clearsSelectionOnViewWillAppear = YES;
        
    }
    return self;
}

- (void)managedObjectSelected:(NSManagedObject *)managedObject {
    
    if (self.tableView.editing) {
        
        if ([((Travel *)managedObject).closed intValue] != 1) {
            TravelEditViewController *detailViewController = [[TravelEditViewController alloc] initInManagedObjectContext:self.managedObjectContext withTravel:(Travel *)managedObject];
            detailViewController.editDelegate = self.rootViewController;
            UINavigationController *navController = [[ShadowNavigationController alloc] initWithRootViewController:detailViewController];
            navController.delegate = detailViewController;
            [self.rootViewController.navigationController presentModalViewController:navController animated:YES];   
            [detailViewController release];
            [navController release];
        }
        
    } else {
        
        Travel *travel = (Travel *) managedObject;
        TravelViewController *detailViewController = [[TravelViewController alloc] initWithTravel:travel];
        detailViewController.title = travel.name;
        [self.rootViewController.navigationController pushViewController:detailViewController animated:YES];
        [detailViewController release]; 
    }
    
    [self.tableView deselectRowAtIndexPath:[self.tableView indexPathForSelectedRow] animated:YES];
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
    
    self.tableView.allowsSelectionDuringEditing = YES;
    
}

- (void)controllerDidChangeContent:(NSFetchedResultsController *)controller {
    [super controllerDidChangeContent:controller];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForManagedObject:(NSManagedObject *)managedObject {
    
    UITableViewCell *cell = [super tableView:tableView cellForManagedObject:managedObject];
    
    Travel *travel = (Travel *) managedObject;
    
    if ([travel.name length] != 0) {
        // travel text
        cell.textLabel.text = travel.name;
        if ([travel.city length] > 0) {
            cell.detailTextLabel.text = [NSString stringWithFormat:@"%@, %@", travel.city, travel.country.name];
        } else {
            cell.detailTextLabel.text = travel.country.name;
        }
    } else {
        // travel country
        cell.textLabel.text = travel.country.name;
        if ([travel.city length] > 0) {
            cell.detailTextLabel.text = travel.city;
        } else {
            cell.detailTextLabel.text = @"";
        }
    }

    return cell;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    if ([[super tableView:tableView titleForHeaderInSection:section] isEqualToString:@"0"]) {
        return @"Open Trips";
    } else if ([[super tableView:tableView titleForHeaderInSection:section] isEqualToString:@"1"]) {
        return @"Closed Trips";
    } else {
        return @"";
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    if (section == 0) {
        return [UIFactory defaultSectionHeaderCellHeight] + 8;
    } else {
        return [UIFactory defaultSectionHeaderCellHeight] + 5;
    }
}

- (NSArray *)sectionIndexTitlesForTableView:(UITableView *)tableView {
    return nil;
}

- (void)closeTravel:(Travel *)travel {
    
    // perform operation
    if ([travel.closed isEqualToNumber:[NSNumber numberWithInt:0]]) {
        travel.closed = [NSNumber numberWithInt:1];
    } else {
        travel.closed = [NSNumber numberWithInt:0];
    }
    [ReiseabrechnungAppDelegate saveContext:[travel managedObjectContext]];

    [self.tableView beginUpdates];
    [self.tableView endUpdates];
}

- (void)viewDidUnload {
    [super viewDidUnload];
    
    [ReiseabrechnungAppDelegate saveContext:self.managedObjectContext];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return YES;
}

- (void)dealloc {
    [_managedObjectContext release];
    [_addButton release];
    [_editButton release];
    [_doneButton release];
    
    [_wizard release];
    
    [super dealloc];
}

@end
