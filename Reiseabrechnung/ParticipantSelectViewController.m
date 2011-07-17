//
//  ParticipantSelectViewController.m
//  Reiseabrechnung
//
//  Created by Martin Maier on 01/07/2011.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "ParticipantSelectViewController.h"

@interface ParticipantSelectViewController(hidden) 

@property (retain, readonly) NSMutableArray *selectedParticipants;
- (void)done;

@end

@implementation ParticipantSelectViewController

@synthesize multiSelectionAllowed=_multiSelectionAllowed;

- (id)initInManagedObjectContext:(NSManagedObjectContext *)context withTravel:(Travel *)travel target:(id)target action:(SEL)selector {

    self = [super initWithNibName:nil bundle:nil];
    if (self) {
        _selector = selector;
        _target = target;
        
        self.multiSelectionAllowed = NO;
        
        NSFetchRequest *req = [[NSFetchRequest alloc] init];
        req.entity = [NSEntityDescription entityForName:@"Participant" inManagedObjectContext: context];
        req.sortDescriptors = [NSArray arrayWithObject:[NSSortDescriptor sortDescriptorWithKey:@"name" ascending:YES]];
        req.predicate = [NSPredicate predicateWithFormat:@"travel = %@", travel];
        
        [NSFetchedResultsController deleteCacheWithName:@"Participants"];
        self.fetchedResultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:req managedObjectContext:context sectionNameKeyPath:nil cacheName:@"Participants"];
        [req release];
        
        self.fetchedResultsController.delegate = self;
        
        [self.navigationItem setHidesBackButton:YES animated:NO];
        
        self.titleKey = @"name";
        
        [self viewWillAppear:true];
    }
    return self;
}

- (void)managedObjectSelected:(NSManagedObject *)managedObject {
    
    if (!self.multiSelectionAllowed) {
        [self.selectedParticipants removeAllObjects];
        [self.selectedParticipants addObject:managedObject];
        [self done];
    } else {
        if (![self.selectedParticipants containsObject:managedObject]) {
            [self.selectedParticipants addObject:managedObject];
        } else {
            [self.selectedParticipants removeObject:managedObject];
        }
    }
    
    [self.tableView reloadData];
}

- (void)addSelectedParticipants:(NSSet *)newArray {
    for (id obj in newArray) {
        [self.selectedParticipants addObject:obj];
    }
}

- (NSMutableArray *)selectedParticipants {
    if (!_selectedParticipants) {
        _selectedParticipants = [[NSMutableArray alloc] init];
        [_selectedParticipants retain];
    }
    return _selectedParticipants;
}

- (void)done {
    if ([_target respondsToSelector:_selector]) {
        if (!self.multiSelectionAllowed) {
            [_target performSelector:_selector withObject:[self.selectedParticipants lastObject]];
        } else {
            [_target performSelector:_selector withObject:self.selectedParticipants];
        }
    }    
    
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)setMultiSelectionAllowed:(BOOL)newValue {
    _multiSelectionAllowed = newValue;
    if (newValue) {
        if (!self.navigationItem.rightBarButtonItem) {
            self.navigationItem.rightBarButtonItem = [[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(done)] autorelease];
            [self.navigationController.view setNeedsDisplay];
        }
    } else {
        self.navigationItem.rightBarButtonItem = nil;
        self.navigationItem.backBarButtonItem = nil;
    }
}

- (UITableViewCellAccessoryType)accessoryTypeForManagedObject:(NSManagedObject *)managedObject {
    if ([self.selectedParticipants containsObject:managedObject]) {
        return UITableViewCellAccessoryCheckmark;
    } else {
        return UITableViewCellAccessoryNone;
    }
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
