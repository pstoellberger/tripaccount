//
//  RootViewController.m
//  Reiseabrechnung
//
//  Created by Martin Maier on 28/06/2011.
//  Copyright 2011 Martin Maier. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>
#import "TravelListViewController.h"
#import "TravelViewController.h"
#import "TravelEditViewController.h"
#import "Currency.h"
#import "ReiseabrechnungAppDelegate.h"
#import "UIFactory.h"
#import "LocationViewController.h"
#import "ShadowNavigationController.h"
#import "HelpView.h"

@implementation TravelListViewController

@synthesize managedObjectContext=_managedObjectContext, fetchedResultsController=_fetchedResultsController, rootViewController=_rootViewController;
@synthesize openTripAlert=_openTripAlert, refreshRatesAlert=_refreshRatesAlert;

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
        
        [self.tableView scrollRectToVisible:CGRectMake(0, 0, 1, 1) animated:NO];
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
            
        } else {
            
            [self.openTripAlert show];
            
        }
        
    } else {
        
        self.reloadDisabled = YES;
        
        Travel *travel = (Travel *) managedObject;
        TravelViewController *detailViewController = [[TravelViewController alloc] initWithTravel:travel];
        if ([travel.name length] > 0) {
            detailViewController.title = travel.name;
        } else {
            detailViewController.title = travel.country.name;
        }
        [self.rootViewController.navigationController pushViewController:detailViewController animated:YES];
        [detailViewController release]; 
        
    }

}

- (void)deleteManagedObject:(NSManagedObject *)managedObject {
    
    [self.managedObjectContext deleteObject:managedObject];
    [ReiseabrechnungAppDelegate saveContext:self.managedObjectContext];
}

- (BOOL)canDeleteManagedObject:(NSManagedObject *)managedObject {
	return YES;
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
    
    if ([travel.closed intValue] == 0) {
        cell.textLabel.font = [UIFont boldSystemFontOfSize:16];
        cell.detailTextLabel.font = [UIFont systemFontOfSize:14];
    } else {
        cell.textLabel.font = [UIFont italicSystemFontOfSize:16];
        cell.detailTextLabel.font = [UIFont italicSystemFontOfSize:14];
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

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    return YES;
}

#pragma mark UIAlertViewDelegate

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    
    if (alertView == self.openTripAlert) {
        
        if (buttonIndex != self.openTripAlert.cancelButtonIndex) {
            [self.refreshRatesAlert show];
        } else {
            [self.tableView deselectRowAtIndexPath:[self.tableView indexPathForSelectedRow] animated:YES];
        }
        
    } else if (alertView == self.refreshRatesAlert) {
        
        [self.tableView beginUpdates];
        
        Travel *travel = [[self fetchedResultsControllerForTableView:self.tableView]  objectAtIndexPath:[self.tableView indexPathForSelectedRow]];
        [travel open:(buttonIndex != self.refreshRatesAlert.cancelButtonIndex)];
        
        [self.tableView endUpdates];
        
        [self managedObjectSelected:travel];
    }
}

#pragma mark View lifecycle

- (void)loadView {
    
    [super loadView];
    
    self.openTripAlert = [[[UIAlertView alloc] initWithTitle:@"Trip is closed." message:@"Closed trips can not be edited. Do you want to open the trip now?" delegate:self cancelButtonTitle:@"No" otherButtonTitles:@"Yes", nil] autorelease];
    
    self.refreshRatesAlert = [UIFactory createAlterViewForRefreshingRatesOnOpeningTravel:self];
    
}

- (void)viewDidUnload {
    [super viewDidUnload];
    
    [ReiseabrechnungAppDelegate saveContext:self.managedObjectContext];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.tableView.allowsSelectionDuringEditing = YES;
}

#pragma mark Memory management

- (void)dealloc {
    [_managedObjectContext release];

    [super dealloc];
}

@end
