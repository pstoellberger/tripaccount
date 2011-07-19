//
//  ParticipantSelectViewController.m
//  Reiseabrechnung
//
//  Created by Martin Maier on 01/07/2011.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "GenericSelectViewController.h"

@interface GenericSelectViewController () 

@property (retain, readonly) NSMutableArray *selectedObjects;
- (void)done;
- (void)updateSegmentedControl;
@end

@implementation GenericSelectViewController

@synthesize multiSelectionAllowed=_multiSelectionAllowed;

- (id)initInManagedObjectContext:(NSManagedObjectContext *)context 
              withMultiSelection:(BOOL)multiSelection 
                withFetchRequest:(NSFetchRequest *)fetchRequest
             withSelectedObjects:(NSArray *)newSelectedObjects
                          target:(id)target 
                          action:(SEL)selector; {
    
    self = [super initWithStyle:UITableViewStyleGrouped];
    if (self) {
        _selector = selector;
        _target = target;
        _multiSelectionAllowed = multiSelection;
        
        for (id obj in newSelectedObjects) {
            [self.selectedObjects addObject:obj];
        }        

        self.titleKey = @"name";
        
        if (multiSelection) {
            self.navigationItem.rightBarButtonItem = [[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(done)] autorelease];
            [self.navigationController.view setNeedsDisplay];
            [self.navigationItem setHidesBackButton:YES animated:NO];
        }
        
        if (fetchRequest.predicate) {
            [NSFetchedResultsController deleteCacheWithName:[[fetchRequest entity] name]];
        }
        self.fetchedResultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:fetchRequest managedObjectContext:context sectionNameKeyPath:nil cacheName:(fetchRequest.predicate)?nil:[[fetchRequest entity] name]];
        self.fetchedResultsController.delegate = self;
        
        [self viewWillAppear:true];
    }
    return self;
}

- (void)managedObjectSelected:(NSManagedObject *)managedObject {
    
    if (!self.multiSelectionAllowed) {
        [self.selectedObjects removeAllObjects];
        [self.selectedObjects addObject:managedObject];
        [self done];
    } else {
        if (![self.selectedObjects containsObject:managedObject]) {
            [self.selectedObjects addObject:managedObject];
        } else {
            [self.selectedObjects removeObject:managedObject];
        }
    }
    [self updateSegmentedControl];    
    
    [self.tableView reloadData];
}

- (void) updateSegmentedControl {
    if (_segControl) {
        _segControl.momentary = YES;
        [self.fetchedResultsController performFetch:nil];
        if ([self.selectedObjects count] == [self.fetchedResultsController.fetchedObjects count]) {
            _segControl.selectedSegmentIndex = ALL_BUTTON_INDEX;
        } else if ([self.selectedObjects count] == 0) {
            _segControl.selectedSegmentIndex = NONE_BUTTON_INDEX;
        } else {
            _segControl.selectedSegmentIndex = UISegmentedControlNoSegment;
        }
        _segControl.momentary = NO;
    }           
}

- (NSMutableArray *)selectedObjects {
    if (!_selectedObjects) {
        _selectedObjects = [[[NSMutableArray alloc] init] retain];
    }
    return _selectedObjects;
}

- (void)done {
    if ([_target respondsToSelector:_selector]) {
        if (!self.multiSelectionAllowed) {
            [_target performSelector:_selector withObject:[self.selectedObjects lastObject]];
        } else {
            [_target performSelector:_selector withObject:self.selectedObjects];
        }
    }    
    
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)selectAll:(id)sender {
    
    [self.selectedObjects removeAllObjects];
    for (id obj in self.fetchedResultsController.fetchedObjects) {
        [self.selectedObjects addObject:obj];
    }
    
    [self updateSegmentedControl];
    [self.tableView reloadData];
}

- (void)selectNone:(id)sender {
    [self.selectedObjects removeAllObjects];
    [self updateSegmentedControl];
    [self.tableView reloadData];
}

- (UITableViewCellAccessoryType)accessoryTypeForManagedObject:(NSManagedObject *)managedObject {
    if ([self.selectedObjects containsObject:managedObject]) {
        return UITableViewCellAccessoryCheckmark;
    } else {
        return UITableViewCellAccessoryNone;
    }
}

- (void)dealloc
{
    [_segControl release];
    
    [super dealloc];
}

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

- (void)selectParticipants:(UISegmentedControl *) sender {
    if ([sender selectedSegmentIndex] == ALL_BUTTON_INDEX) {
        [self selectAll:sender];
    } else if ([sender selectedSegmentIndex] == NONE_BUTTON_INDEX) {
        [self selectNone:sender];
    }
}

#pragma mark - View lifecycle                   

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    if (self.multiSelectionAllowed) {
        NSString *selectAllButton = @"All";
        NSString *selectNoneButton = @"None";
        
        [_segControl release];
        _segControl = [[UISegmentedControl alloc] initWithItems:[NSArray arrayWithObjects:selectAllButton, selectNoneButton, nil]];
        _segControl.frame = CGRectMake(10, 10, self.tableView.bounds.size.width - 20, 40);
        _segControl.autoresizingMask = UIViewAutoresizingFlexibleWidth;
        [_segControl addTarget:self action:@selector(selectParticipants:) forControlEvents:UIControlEventValueChanged];
        _segControl.selectedSegmentIndex = UISegmentedControlNoSegment;
        [self updateSegmentedControl];
        
        UIView *segView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.tableView.bounds.size.width, 50)];
        segView.autoresizingMask = UIViewAutoresizingFlexibleWidth;
        [segView addSubview:_segControl];
        self.tableView.tableHeaderView = segView;
        [segView release];

    }
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return YES;
}

@end
