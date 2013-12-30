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
#import "ReceiverWeight.h"

@implementation ParticipantViewController

@synthesize travel=_travel, editDelegate=_editDelegate, delegate=_delegate;

- (id)initWithTravel:(Travel *) travel {
    
    [Crittercism leaveBreadcrumb:@"ParticipantViewController: init"];
    
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

#define WEIGHT_LABEL_TAG 42
#define WEIGHT_LABEL_WIDTH 50

- (UITableViewCell *)tableView:(UITableView *)tableView cellForManagedObject:(NSManagedObject *)managedObject {
    
    static NSString *ReuseIdentifier = @"ParticipantCell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:ReuseIdentifier];
    
    UILabel *right = nil;
    if (cell == nil) {
        
        cell = [super tableView:tableView cellForManagedObject:managedObject];
        cell.textLabel.backgroundColor = [UIColor clearColor];
        
        right = (UILabel *) [cell viewWithTag:WEIGHT_LABEL_TAG];
        if (!right) {
            right = [[[UILabel alloc] initWithFrame:CGRectMake(cell.frame.size.width - WEIGHT_LABEL_WIDTH - 3, 10, WEIGHT_LABEL_WIDTH, cell.frame.size.height)] autorelease];
            right.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin;
            right.backgroundColor = [UIColor clearColor];
            right.textAlignment = NSTextAlignmentRight;
            right.font = [UIFont italicSystemFontOfSize:12];
            right.textColor = [UIColor colorWithRed:0 green:0 blue:0.8 alpha:1];
            right.textColor = [UIColor grayColor];
            right.tag = WEIGHT_LABEL_TAG;
            
            [cell.contentView addSubview:right];
        }
    }
    
    Participant *p = (Participant *)managedObject;
    
    if ([self.travel isWeightInUse]) {
        if (!right) {
            right = (UILabel *) [cell viewWithTag:WEIGHT_LABEL_TAG];
        }
        right.text = [NSString stringWithFormat:@"%@", [p.weight stringValue]];
    } else {
        right.text = @"";
    }
    
    cell.textLabel.alpha = 1;
    cell.detailTextLabel.alpha = 1;
    cell.imageView.alpha = 1;
    
    if ([self.travel isClosed]) {
        cell.textLabel.alpha = 0.6;
        cell.detailTextLabel.alpha = 0.6;
        cell.imageView.alpha = 0.6;
    }
    
    return cell;
}

- (void)deleteManagedObject:(NSManagedObject *)managedObject {
    
    [Crittercism leaveBreadcrumb:@"ParticipantViewController: deleteManagedObject"];
    
    Participant *participant = (Participant *)managedObject;
    
    if ([participant.pays count] > 0) {
        
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Can not delete traveler", @"alert view can not delete") message:NSLocalizedString(@"This traveler has expensens on this trip. Please delete those expenses first.", @"alert view explain why can not delete") delegate:nil cancelButtonTitle:nil otherButtonTitles:NSLocalizedString(@"OK", @"alert view ok") , nil];
        [alertView show];
        [alertView release];
        
    } else {
        
        NSManagedObjectContext *context = [_travel managedObjectContext];
        
        for (ReceiverWeight *recWeight in participant.receiverWeights) {
            [context deleteObject:recWeight];
        }
        
        [context deleteObject:managedObject];
        [ReiseabrechnungAppDelegate saveContext:context];

        [self.editDelegate participantWasDeleted:participant];
    }
}

- (BOOL)canDeleteManagedObject:(NSManagedObject *)managedObject {
	return [self.travel isOpen];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    return YES;
}

- (void)managedObjectSelected:(NSManagedObject *)managedObject {
    
    [Crittercism leaveBreadcrumb:@"ParticipantViewController: managedObjectSelected"];
    
    [self.editDelegate openParticipantPopup:(Participant *)managedObject];
}

- (void)updateTravelOpenOrClosed {
    self.tableView.allowsSelection = [self.travel isOpen];
}

- (void)controllerDidChangeContent:(NSFetchedResultsController *)controller {
    
    [Crittercism leaveBreadcrumb:@"ParticipantViewController: controllerDidChangeContent"];
    
    [super controllerDidChangeContent:controller];  
    
    [self.delegate didItemCountChange:[controller.fetchedObjects count]];
}

- (void)setDelegate:(id<ParticipantViewControllerDelegate>)delegate {
    [(NSObject *)_delegate release];
    _delegate = delegate;
    [self.delegate didItemCountChange:[self.fetchedResultsController.fetchedObjects count]];
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
