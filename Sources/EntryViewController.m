//
//  EntryViewController.m
//  Reiseabrechnung
//
//  Created by Martin Maier on 30/06/2011.
//  Copyright 2011 Martin Maier. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>
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
        
        self.tableView.scrollIndicatorInsets = UIEdgeInsetsMake(NAVIGATIONBAR_HEIGHT, 0, 0, 0);
        self.tableView.contentInset = self.tableView.scrollIndicatorInsets;

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
        
        [self updateTravelOpenOrClosed];
        
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
    
    static NSString *reuseIdentifier = @"EntryCell";
    
    EntryCell *cell = (EntryCell *) [tableView dequeueReusableCellWithIdentifier:reuseIdentifier];
    if (cell == nil) {
        [[NSBundle mainBundle] loadNibNamed:@"EntryCell" owner:self options:nil];
        cell = self.entryCell;
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
    cell.bottom.participants = entry.sortedReceivers;
    cell.image.image = [UIImage imageWithData:entry.payer.image];
    
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    formatter.dateStyle = NSDateFormatterMediumStyle;
    if ([UIFactory dateHasTime:entry.date]) {
        formatter.timeStyle = NSDateFormatterShortStyle;
    }
    cell.rightBottom.text = [formatter stringFromDate:entry.date];
    [formatter release];
    
    cell.image.alpha = 1;
    cell.bottom.alpha = 1;
    cell.forLabel.alpha = 1;
    
    UIColor *textColor = [UIColor blackColor];
    if ([self.travel.closed intValue] == 1) {
        textColor = [UIColor grayColor];
        cell.image.alpha = 0.6;
        cell.bottom.alpha = 0.6;
        cell.forLabel.alpha = 0.6;
    }
    
    cell.right.textColor = textColor;
    cell.rightBottom.textColor = textColor;
    cell.top.textColor = textColor;
    
    return cell;
}


- (void)managedObjectSelected:(NSManagedObject *)managedObject {
    
    if ([self.travel.closed intValue] != 1) {
        
        [self.editDelegate openEditEntryPopup:(Entry *)managedObject];
        
    } else {
        
        Entry *entry = (Entry *) managedObject;

        if ([entry.checked intValue] != 1) {
            entry.checked = [NSNumber numberWithInt:1];
            [self.tableView reloadRowsAtIndexPaths:[NSArray arrayWithObject:[[self fetchedResultsControllerForTableView:self.tableView] indexPathForObject:managedObject]] withRowAnimation:UITableViewRowAnimationLeft];
        } else {
            entry.checked = [NSNumber numberWithInt:0];
            [self.tableView reloadRowsAtIndexPaths:[NSArray arrayWithObject:[[self fetchedResultsControllerForTableView:self.tableView] indexPathForObject:managedObject]] withRowAnimation:UITableViewRowAnimationRight];
        }
        
        [ReiseabrechnungAppDelegate saveContext:[self.travel managedObjectContext]];
    }
}

- (void)deleteManagedObject:(NSManagedObject *)managedObject {
    
    [_travel.managedObjectContext deleteObject:managedObject];
    [ReiseabrechnungAppDelegate saveContext:_travel.managedObjectContext];
    
    [self.editDelegate entryWasDeleted:(Entry *)managedObject];
}

- (BOOL)canDeleteManagedObject:(NSManagedObject *)managedObject {
	return [self.travel.closed intValue] != 1;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {

    return YES;
}

- (void)initFetchResultsController:(NSFetchRequest *)req {
    
    req.sortDescriptors = [NSArray arrayWithObjects:[NSSortDescriptor sortDescriptorWithKey:[_sortKeyArray objectAtIndex:_sortIndex] ascending:YES], [NSSortDescriptor sortDescriptorWithKey:@"date" ascending:YES], nil];
    
    [NSFetchedResultsController deleteCacheWithName:@"Entries"];
    self.fetchedResultsController = [[[NSFetchedResultsController alloc] initWithFetchRequest:req managedObjectContext:self.travel.managedObjectContext sectionNameKeyPath:[_sectionKeyArray objectAtIndex:_sortIndex] cacheName:@"Entries"] autorelease];
    
    [super performFetchForTableView:self.tableView];
    
}

- (void)sortTable:(int)sortIndex {
    
    _sortIndex = sortIndex;
    [self initFetchResultsController:self.fetchRequest];
    
    self.travel.displaySort = [NSNumber numberWithInt:sortIndex];
    [ReiseabrechnungAppDelegate saveContext:[self.travel managedObjectContext]];
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    
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
    [(NSObject *)_delegate release];
    _delegate = delegate;
    [self.delegate didItemCountChange:[self.fetchedResultsController.fetchedObjects count]];
}

- (void)updateTravelOpenOrClosed {
    self.tableView.allowsSelection = ![self.travel.closed isEqualToNumber:[NSNumber numberWithInt:1]];
}

#pragma mark - BadgeValue update 

- (void)controllerDidChangeContent:(NSFetchedResultsController *)controller {
    [super controllerDidChangeContent:controller];    
    [self.delegate didItemCountChange:[self.fetchedResultsController.fetchedObjects count]];
}

#pragma mark - View lifecycle

- (void)viewDidLoad {
    
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
}

- (void)viewDidUnload {
    
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

#pragma mark - Memory management

- (void)dealloc {
    
    [_sortKeyArray release];
    [_sectionKeyArray release];
    [super dealloc];
}

@end
