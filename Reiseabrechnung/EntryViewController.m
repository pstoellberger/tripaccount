//
//  EntryViewController.m
//  Reiseabrechnung
//
//  Created by Martin Maier on 30/06/2011.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "EntryViewController.h"
#import "EntryCell.h"


@implementation EntryViewController

@synthesize travel=_travel;

-(void) postConstructWithTravel:(Travel *) travel {
    _travel = travel;
    
    NSManagedObjectContext *context = [travel managedObjectContext];
    
    NSFetchRequest *req = [[NSFetchRequest alloc] init];
    req.entity = [NSEntityDescription entityForName:@"Entry" inManagedObjectContext: context];
    req.sortDescriptors = [NSArray arrayWithObject:[NSSortDescriptor sortDescriptorWithKey:@"date" ascending:YES]];
    req.predicate = [NSPredicate predicateWithFormat:@"travel = %@", travel];
    
    [NSFetchedResultsController deleteCacheWithName:@"Entries"];
    self.fetchedResultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:req managedObjectContext:context sectionNameKeyPath:nil cacheName:@"Entries"];
    [req release];
    
    self.fetchedResultsController.delegate = self;
    
    self.titleKey = @"text";
    self.subtitleKey = @"amount";
    
    [self viewWillAppear:true];
    
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForManagedObject:(NSManagedObject *)managedObject {
    
    static NSString *CellIdentifier = @"EntryCell";
    
    EntryCell *cell = (EntryCell *) [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        NSArray *tlo = [[NSBundle mainBundle] loadNibNamed:@"EntryCell" owner:self options:nil];
        cell = [tlo objectAtIndex:0];
    }
    
    // Set up the cell... 
    Entry *entry = (Entry *) managedObject;
    cell.top.text = entry.text;
    cell.bottom.text = @"someone";
    cell.right.text = [NSString stringWithFormat:@"%@ %@", entry.amount, entry.currency];
    
    return cell;
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
    // Do any additional setup after loading the view from its nib.
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
