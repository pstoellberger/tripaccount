//
//  ParticipantViewController.m
//  Reiseabrechnung
//
//  Created by Martin Maier on 30/06/2011.
//  Copyright 2011 Martin Maier. All rights reserved.
//

#import "ParticipantViewController.h"
#import "Participant.h"
#import "ReiseabrechnungAppDelegate.h"
#import "ParticipantEditViewController.h"
#import "ShadowNavigationController.h"

@implementation ParticipantViewController

@synthesize travel=_travel, editDelegate=_editDelegate, delegate=_delegate;

- (id)initWithTravel:(Travel *) travel {
    
    if (self = [super initWithStyle:UITableViewStylePlain]) {
        
        _travel = travel;
        
        self.tableView.delegate = self;
        self.tableView.dataSource = self;
        
        [UIFactory initializeTableViewController:self.tableView];
       
        NSManagedObjectContext *context = [travel managedObjectContext];
        
        NSFetchRequest *req = [[NSFetchRequest alloc] init];
        req.entity = [NSEntityDescription entityForName:@"Participant" inManagedObjectContext: context];
        req.sortDescriptors = [NSArray arrayWithObject:[NSSortDescriptor sortDescriptorWithKey:@"name" ascending:YES]];
        req.predicate = [NSPredicate predicateWithFormat:@"travel = %@", travel];
        
        [NSFetchedResultsController deleteCacheWithName:@"Participants"];
        self.fetchedResultsController = [[[NSFetchedResultsController alloc] initWithFetchRequest:req managedObjectContext:context sectionNameKeyPath:nil cacheName:@"Participants"] autorelease];
        [req release];
        
        self.fetchedResultsController.delegate = self;
        
        self.titleKey = @"name";
        self.imageKey = @"image";
        self.subtitleKey = @"email";
        
        [self viewWillAppear:YES];
        
        [self updateTravelOpenOrClosed];
    }
    
    return self;
}

- (UITableViewCellAccessoryType)accessoryTypeForManagedObject:(NSManagedObject *)managedObject {
    return UITableViewCellAccessoryNone;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForManagedObject:(NSManagedObject *)managedObject {
    
    UITableViewCell *cell = [super tableView:tableView cellForManagedObject:managedObject];
    cell.detailTextLabel.backgroundColor = [UIColor clearColor];
    cell.textLabel.backgroundColor = [UIColor clearColor];
    
    cell.textLabel.alpha = 1;
    cell.detailTextLabel.alpha = 1;
    cell.imageView.alpha = 1;
    
    if ([self.travel.closed intValue] == 1) {
        cell.textLabel.alpha = 0.6;
        cell.detailTextLabel.alpha = 0.6;
        cell.imageView.alpha = 0.6;
    }
    
    return cell;
}

- (void)deleteManagedObject:(NSManagedObject *)managedObject {
    
    Participant *participant = (Participant *)managedObject;
    
    if ([participant.pays count] > 0) {
        
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Can not delete traveler" message:@"This traveler has expensens on this trip. Please delete those expenses first." delegate:nil cancelButtonTitle:nil otherButtonTitles:@"OK" , nil];
        [alertView show];
        [alertView release];
        
    } else {
    
        [_travel.managedObjectContext deleteObject:managedObject];
        [ReiseabrechnungAppDelegate saveContext:_travel.managedObjectContext];

        [self.editDelegate participantWasDeleted:participant];
    }
}

- (BOOL)canDeleteManagedObject:(NSManagedObject *)managedObject {
	return [self.travel.closed intValue] != 1;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    return YES;
}

- (void)managedObjectSelected:(NSManagedObject *)managedObject {
    
    [self.editDelegate openParticipantPopup:(Participant *)managedObject];
}

- (void)updateTravelOpenOrClosed {
    self.tableView.allowsSelection = ![self.travel.closed isEqualToNumber:[NSNumber numberWithInt:1]];
}

- (void)controllerDidChangeContent:(NSFetchedResultsController *)controller {
    
    [super controllerDidChangeContent:controller];    
    [self.delegate didItemCountChange:[controller.fetchedObjects count]];
}


#pragma mark - View lifecycle

- (void)viewDidLoad {
    [super viewDidLoad];

}

- (void)viewDidUnload {
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

#pragma mark - Memory management

- (void)dealloc {
    [super dealloc];
}

@end
