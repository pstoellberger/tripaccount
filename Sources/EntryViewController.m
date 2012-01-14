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
    
    [Crittercism leaveBreadcrumb:@"EntryViewController: init"];
    
    if (self = [super initWithStyle:UITableViewStylePlain]) {
        
        _dateFormatter = [[NSDateFormatter alloc] init];
        _dateFormatter.dateStyle = NSDateFormatterMediumStyle;
        
        _headerDateFormatter = [[NSDateFormatter alloc] init];
        _headerDateFormatter.dateStyle = NSDateFormatterMediumStyle;
        
        self.travel = travel;
        _sortIndex = 0;
        _sortDesc = NO;
        
        _sectionKeyArray = [[NSArray alloc] initWithObjects:@"payer.name", @"typeSectionName", @"dateWithOutTime", nil];
        _sortKeyArray = [[NSArray alloc] initWithObjects:@"payer.name", [NSString stringWithFormat:@"type.%@", [Type sortAttributeI18N]], @"date", nil];

        self.tableView.delegate = self;
        self.tableView.dataSource = self;
        
        [UIFactory initializeTableViewController:self.tableView];
        
        UIEdgeInsets insets = self.tableView.contentInset;
        insets.top = self.navigationController.navigationBar.frame.size.height;
        self.tableView.contentInset = insets;
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

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
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
    
    cell.forLabel.text = NSLocalizedString(@"for", @"for label");
    
    // Set up the cell... 
    Entry *entry = (Entry *) managedObject;
    if (entry.text && [entry.text length] > 0) {
        if (!entry.type || _sortIndex == 1) {
            cell.top.text = [NSString stringWithFormat:@"%@", entry.text];
        } else {
            cell.top.text = [NSString stringWithFormat:@"%@ (%@)", entry.text, entry.type.nameI18N];
        }
    } else {
        cell.top.text = entry.type.nameI18N;
    }
    cell.right.text = [NSString stringWithFormat:@"%@ %@", [UIFactory formatNumber:entry.amount], entry.currency.code];
    
    cell.bottom.participants = entry.sortedReceivers;
    [cell.bottom setNeedsDisplay];
    cell.rightBottom.hidden = NO;
    cell.right.hidden = NO;
    
    cell.image.image = [[ImageCache instance] getImage:entry.payer.image];
    
    if ([UIFactory dateHasTime:entry.date]) {
        _dateFormatter.timeStyle = NSDateFormatterShortStyle;
    } else {
        _dateFormatter.timeStyle = NSDateFormatterNoStyle;
    }
    cell.rightBottom.text = [_dateFormatter stringFromDate:entry.date];
    
    cell.image.alpha = 1;
    cell.bottom.alpha = 1;
    cell.forLabel.alpha = 1;
    
    UIColor *textColor = [UIColor blackColor];
    if ([self.travel isClosed]) {
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
    
    [Crittercism leaveBreadcrumb:@"EntryViewController: managedObjectSelected"];
    
    if ([self.travel isOpen]) {
        
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
    
    [Crittercism leaveBreadcrumb:@"EntryViewController: deleteManagedObject"];
    
    [_travel.managedObjectContext deleteObject:managedObject];
    [ReiseabrechnungAppDelegate saveContext:_travel.managedObjectContext];
    
    [self.editDelegate entryWasDeleted:(Entry *)managedObject];
}

- (BOOL)canDeleteManagedObject:(NSManagedObject *)managedObject {
	return [self.travel isOpen];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {

    return YES;
}

- (void)initFetchResultsController:(NSFetchRequest *)req {
    
    [Crittercism leaveBreadcrumb:@"EntryViewController: initFetchResultsController"];
    
    req.sortDescriptors = [NSArray arrayWithObjects:[NSSortDescriptor sortDescriptorWithKey:[_sortKeyArray objectAtIndex:_sortIndex] ascending:!_sortDesc], [NSSortDescriptor sortDescriptorWithKey:@"date" ascending:YES], [NSSortDescriptor sortDescriptorWithKey:@"created" ascending:YES], nil];
    
    [NSFetchedResultsController deleteCacheWithName:@"Entries"];
    self.fetchedResultsController = [[[NSFetchedResultsController alloc] initWithFetchRequest:req managedObjectContext:self.travel.managedObjectContext sectionNameKeyPath:[_sectionKeyArray objectAtIndex:_sortIndex] cacheName:@"Entries"] autorelease];
    
    [super performFetchForTableView:self.tableView];
    
}

- (void)sortTable:(int)sortIndex desc:(BOOL)desc {
    
    [Crittercism leaveBreadcrumb:@"EntryViewController: sortTable"];
    
    _sortIndex = sortIndex;
    _sortDesc = desc;
    
    [self initFetchResultsController:self.fetchRequest];
    
    self.travel.displaySort = [NSNumber numberWithInt:sortIndex];
    self.travel.displaySortOrderDesc = [NSNumber numberWithBool:desc];
    
    [ReiseabrechnungAppDelegate saveContext:[self.travel managedObjectContext]];
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    
    NSString *sectionName = [super tableView:tableView titleForHeaderInSection:section];
    
    if (_sortIndex == 2) {
        Entry *entry = (Entry *)[((id <NSFetchedResultsSectionInfo>)[[[self fetchedResultsControllerForTableView:tableView] sections] objectAtIndex:section]).objects objectAtIndex:0];
        sectionName = [_headerDateFormatter stringFromDate:entry.date];
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
    self.tableView.allowsSelection = [self.travel isOpen];
}

#pragma mark - BadgeValue update 

- (void)controllerDidChangeContent:(NSFetchedResultsController *)controller {

    [Crittercism leaveBreadcrumb:@"EntryViewController: controllerDidChangeContent"];
    
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
    [_dateFormatter release];
    [_headerDateFormatter release];
    [_sortKeyArray release];
    [_sectionKeyArray release];
    [_travel release];
    
    [_fetchRequest release];
    
    [super dealloc];
}

@end
