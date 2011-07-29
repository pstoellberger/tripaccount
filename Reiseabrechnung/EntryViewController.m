//
//  EntryViewController.m
//  Reiseabrechnung
//
//  Created by Martin Maier on 30/06/2011.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "EntryViewController.h"
#import "EntryCell.h"
#import "ReiseabrechnungAppDelegate.h"
#import "Currency.h"
#import "Participant.h"
#import "EntryEditViewController.h"
#import "ShadowNavigationController.h"
#import "DateSortCategory.h"

@interface EntryViewController ()
- (void)initFetchResultsController:(NSFetchRequest *)req;    
@end

@implementation EntryViewController

@synthesize entryCell=_entryCell;
@synthesize travel=_travel, fetchRequest=_fetchRequest;
@synthesize delegate=_delegate, editDelegate=_editDelegate;

- (id)initWithTravel:(Travel *) travel {
    
    if (self = [super initWithStyle:UITableViewStylePlain]) {
        
        _travel = travel;
        _sortIndex = 0;
        
        _sectionKeyArray = [[NSArray alloc] initWithObjects:@"payer.name", @"type.name", @"dateWithOutTime", nil];
        _sortKeyArray = [[NSArray alloc] initWithObjects:@"payer.name", @"type.name", @"date", nil];

        self.tableView.delegate = self;
        self.tableView.dataSource = self;
        
        [UIFactory initializeTableViewController:self.tableView];

        NSManagedObjectContext *context = [travel managedObjectContext];
        
        NSFetchRequest *req = [[NSFetchRequest alloc] init];
        req.entity = [NSEntityDescription entityForName:@"Entry" inManagedObjectContext: context];
        req.predicate = [NSPredicate predicateWithFormat:@"travel = %@", travel];
        self.fetchRequest = req;
        [req release];
        
        [self initFetchResultsController:self.fetchRequest];
        
        self.fetchedResultsController.delegate = self;
        
        self.titleKey = @"text";
        self.subtitleKey = @"amount";
        
        [self viewWillAppear:YES];
    }
    
    return self;
}

- (UITableViewCellAccessoryType)accessoryTypeForManagedObject:(NSManagedObject *)managedObject {
    return UITableViewCellAccessoryNone;
}

-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    if (section == 0) {
        return [UIFactory defaultSectionHeaderCellHeight] + 8;
    } else {
        return [UIFactory defaultSectionHeaderCellHeight] + 5;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForManagedObject:(NSManagedObject *)managedObject {
    
    static NSString *CellIdentifier = @"EntryCell";
    
    EntryCell *cell = (EntryCell *) [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        NSArray *tlo = [[NSBundle mainBundle] loadNibNamed:@"EntryCell" owner:self options:nil];
        cell = [tlo objectAtIndex:0];
        [UIFactory initializeCell:cell];
    }
    
    // Set up the cell... 
    Entry *entry = (Entry *) managedObject;
    if (entry.text && [entry.text length] > 0) {
        cell.top.text = entry.text;
    } else {
        cell.top.text = entry.type.name;
    }
    cell.right.text = [NSString stringWithFormat:@"%@ %@", entry.amount, entry.currency.code];
    cell.bottom.participants = [entry.receivers allObjects];
    cell.image.image = [UIImage imageWithData:entry.payer.image];
    
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    formatter.dateStyle = NSDateFormatterMediumStyle;
    if ([UIFactory dateHasTime:entry.date]) {
        formatter.timeStyle = NSDateFormatterShortStyle;
    }
    cell.rightBottom.text = [formatter stringFromDate:entry.date];
    [formatter release];
    
    return cell;
}


- (void)managedObjectSelected:(NSManagedObject *)managedObject {
    
    [self.editDelegate openEditEntryPopup:(Entry *)managedObject];
    [self.tableView deselectRowAtIndexPath:[[self fetchedResultsControllerForTableView:self.tableView] indexPathForObject:managedObject]  animated:YES];
}

- (void)deleteManagedObject:(NSManagedObject *)managedObject
{
    [_travel.managedObjectContext deleteObject:managedObject];
    [ReiseabrechnungAppDelegate saveContext:_travel.managedObjectContext];
}

- (BOOL)canDeleteManagedObject:(NSManagedObject *)managedObject
{
	return YES;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return YES;
}

- (void)initFetchResultsController:(NSFetchRequest *)req {
    
    req.sortDescriptors = [NSArray arrayWithObjects:[NSSortDescriptor sortDescriptorWithKey:[_sortKeyArray objectAtIndex:_sortIndex] ascending:YES], [NSSortDescriptor sortDescriptorWithKey:@"date" ascending:YES], nil];
    
    [NSFetchedResultsController deleteCacheWithName:@"Entries"];
    self.fetchedResultsController = [[[NSFetchedResultsController alloc] initWithFetchRequest:req managedObjectContext:self.travel.managedObjectContext sectionNameKeyPath:[_sectionKeyArray objectAtIndex:_sortIndex] cacheName:@"Entries"] autorelease];
}

- (void)sortTable:(int)sortIndex {
    _sortIndex = sortIndex;
    [self initFetchResultsController:self.fetchRequest];
    
    [self.tableView beginUpdates];
    [self.tableView endUpdates];
}

-(NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    
    NSString *sectionName = [super tableView:tableView titleForHeaderInSection:section];
    
    if (_sortIndex == 2) {
        Entry *entry = (Entry *)[((id <NSFetchedResultsSectionInfo>)[[[self fetchedResultsControllerForTableView:tableView] sections] objectAtIndex:section]).objects objectAtIndex:0];
        NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
        formatter.dateStyle = NSDateFormatterMediumStyle;
        sectionName = [formatter stringFromDate:entry.date];
        [formatter release];
    }
    return sectionName;
   
    
    }

- (NSArray *)sectionIndexTitlesForTableView:(UITableView *)tableView {
    return nil;
}

- (void)setDelegate:(id<EntryViewControllerDelegate>)delegate {
    [_delegate release];
    _delegate = delegate;
    [self.delegate didItemCountChange:[self.fetchedResultsController.fetchedObjects count]];
}

#pragma mark - BadgeValue update 

- (void)controllerDidChangeContent:(NSFetchedResultsController *)controller {
    [super controllerDidChangeContent:controller];    
    [self.delegate didItemCountChange:[self.fetchedResultsController.fetchedObjects count]];
}

#pragma mark - View lifecycle

- (void)dealloc
{
    [_sortKeyArray release];
    [_sectionKeyArray release];
    [super dealloc];
}

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

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

@end
