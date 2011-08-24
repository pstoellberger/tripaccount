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

@implementation ParticipantViewController

@synthesize travel=_travel, editDelegate=_editDelegate;

- (id)initWithTravel:(Travel *) travel {
    
    if (self = [super initWithStyle:UITableViewStylePlain]) {
        
        _travel = travel;
        
        self.tableView.delegate = self;
        self.tableView.dataSource = self;
        
        [UIFactory initializeTableViewController:self.tableView];
        
        self.tableView.scrollIndicatorInsets = UIEdgeInsetsMake(NAVIGATIONBAR_HEIGHT, 0, 0, 0);
        self.tableView.contentInset = self.tableView.scrollIndicatorInsets;
        
        self.title = @"People";
        self.tabBarItem.image = [UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"group" ofType:@"png"]];
        
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
        
        self.tableView.allowsSelection = NO;

        [self viewWillAppear:YES];
        
        [self updateBadgeValue];
    }
    
    return self;
}

- (UITableViewCellAccessoryType)accessoryTypeForManagedObject:(NSManagedObject *)managedObject {
    return UITableViewCellAccessoryNone;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForManagedObject:(NSManagedObject *)managedObject {
    
    UITableViewCell *cell = [super tableView:tableView cellForManagedObject:managedObject];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    cell.detailTextLabel.backgroundColor = [UIColor clearColor];
    cell.textLabel.backgroundColor = [UIColor clearColor];
    
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


#pragma mark - BadgeValue update 

- (void)updateBadgeValue {
    
    NSUInteger itemCount = [self.fetchedResultsController.fetchedObjects count];
    if (itemCount == 0) {
        self.tabBarItem.badgeValue = nil;
    } else {
        self.tabBarItem.badgeValue = [NSString stringWithFormat:@"%d", itemCount];
    }
}

- (void)controllerDidChangeContent:(NSFetchedResultsController *)controller {
    
    [super controllerDidChangeContent:controller];    
    [self updateBadgeValue];
}


#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];

}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

#pragma mark - Memory management

- (void)dealloc {
    [super dealloc];
}

@end
