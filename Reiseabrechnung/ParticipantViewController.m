//
//  ParticipantViewController.m
//  Reiseabrechnung
//
//  Created by Martin Maier on 30/06/2011.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "ParticipantViewController.h"
#import "Participant.h"


@implementation ParticipantViewController

@synthesize travel=_travel;

-(void) postConstructWithTravel:(Travel *) travel {
    _travel = travel;
    
    NSManagedObjectContext *context = [travel managedObjectContext];
    
    NSFetchRequest *req = [[NSFetchRequest alloc] init];
    req.entity = [NSEntityDescription entityForName:@"Participant" inManagedObjectContext: context];
    req.sortDescriptors = [NSArray arrayWithObject:[NSSortDescriptor sortDescriptorWithKey:@"name" ascending:YES]];
    req.predicate = [NSPredicate predicateWithFormat:@"travel = %@", travel];
    
    [NSFetchedResultsController deleteCacheWithName:@"Participants"];
    self.fetchedResultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:req managedObjectContext:context sectionNameKeyPath:nil cacheName:@"Participants"];
    [req release];
    
    self.fetchedResultsController.delegate = self;
    
    self.titleKey = @"name";
    
    [self viewWillAppear:true];
    
}

- (void)deleteManagedObject:(NSManagedObject *)managedObject
{
    [_travel.managedObjectContext deleteObject:managedObject];
    [self saveContext:_travel.managedObjectContext];
}

- (BOOL)canDeleteManagedObject:(NSManagedObject *)managedObject
{
	return YES;
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

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

@end
