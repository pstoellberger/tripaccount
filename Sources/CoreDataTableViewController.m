//
//  CoreDataTableViewController.m
//
//  Created for Stanford CS193p Spring 2010
//

#import "CoreDataTableViewController.h"
#import "UIFactory.h"
#import "GradientCell.h"

@interface CoreDataTableViewController () 
- (UIImage *)imageWithImage:(UIImage *)image scaledToSize:(CGSize)newSize;
@end

@implementation CoreDataTableViewController

@synthesize fetchedResultsController=_fetchedResultsController, dataSearchController=_dataSearchController;
@synthesize titleKey, subtitleKey, searchKey, imageKey, searchKeyAlternative;
@synthesize reloadDisabled=_reloadDisabled;

- (void)createSearchBar {
    
    if (self.tableView) {
        
        if (self.searchKey.length) {
            
			UISearchBar *searchBar = [[[UISearchBar alloc] init] autorelease];
            searchBar.autoresizingMask = UIViewAutoresizingFlexibleWidth;
            searchBar.frame = CGRectMake(0, 0, [[UIScreen mainScreen] bounds].size.width, 38);
            searchBar.tintColor = [UIFactory defaultTintColor];
            searchBar.delegate = self;
            
			self.dataSearchController = [[[UISearchDisplayController alloc] initWithSearchBar:searchBar contentsController:self] autorelease];
			self.dataSearchController.searchResultsDelegate = self;
			self.dataSearchController.searchResultsDataSource = self;
			self.dataSearchController.delegate = self;
            
            UIView *subView = [self createTableHeaderSubView];
            
            if (subView) {
                UIView *comboView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, searchBar.bounds.size.width, searchBar.bounds.size.height + subView.bounds.size.height)];
                subView.frame = CGRectMake(0, searchBar.bounds.size.height, subView.bounds.size.width, subView.bounds.size.height);
                [comboView addSubview:subView];
                [comboView addSubview:searchBar];
                self.tableView.tableHeaderView = comboView;
                [comboView release];
            } else {
                self.tableView.tableHeaderView = self.dataSearchController.searchBar;
            }
        } else {
            UIView *subView = [self createTableHeaderSubView];
            self.tableView.tableHeaderView = subView;
        }
    }
}

- (void)setSearchKey:(NSString *)aKey {
	[searchKey release];
	searchKey = [aKey copy];
	[self createSearchBar];
}

- (NSString *) titleKey {
	if (!titleKey) {
		NSArray *sortDescriptors = [self.fetchedResultsController.fetchRequest sortDescriptors];
		if (sortDescriptors.count) {
			return [[sortDescriptors objectAtIndex:0] key];
		} else {
			return nil;
		}
	} else {
		return titleKey;
	}
}

- (void)performFetchForTableView:(UITableView *)tableView {
	NSError *error = nil;
    
    @try {
        [self.fetchedResultsController performFetch:&error];
    }
    @catch (NSException *exception) {
        
        if([[exception name] isEqualToString:NSInternalInconsistencyException]) {
                                                                        
            NSLog(@"NSInternalInconsistencyException caught, clearing cache and performing retry.");
            // clear cache and retry
            [NSFetchedResultsController deleteCacheWithName:self.fetchedResultsController.cacheName];
            [self.fetchedResultsController performFetch:&error];
        }
        else {
            @throw exception;
        }
    }

	if (error) {
		NSLog(@"[CoreDataTableViewController performFetchForTableView:] %@ (%@)", [error localizedDescription], [error localizedFailureReason]);
	}
	[tableView reloadData];
}

- (NSFetchedResultsController *)fetchedResultsControllerForTableView:(UITableView *)tableView
{
	if (tableView == self.tableView) {
        
		if (self.fetchedResultsController.fetchRequest.predicate != normalPredicate && self.searchKey.length) {
            // reset predicate after search is over
			[NSFetchedResultsController deleteCacheWithName:self.fetchedResultsController.cacheName];
			self.fetchedResultsController.fetchRequest.predicate = normalPredicate;
			[self performFetchForTableView:tableView];
		}
		[currentSearchText release];
		currentSearchText = nil;
        
	} else if ((tableView == self.searchDisplayController.searchResultsTableView) && self.searchKey && ![currentSearchText isEqual:self.searchDisplayController.searchBar.text]) {
        
		[currentSearchText release];
		currentSearchText = [self.searchDisplayController.searchBar.text copy];
        
		NSString *searchPredicateFormat = [NSString stringWithFormat:@"%@ contains[c] %@", self.searchKey, @"%@"];
        NSPredicate *searchPredicate = [NSPredicate predicateWithFormat:searchPredicateFormat, self.searchDisplayController.searchBar.text];
        
        if (searchKeyAlternative) {
            searchPredicateFormat = [NSString stringWithFormat:@"%@ contains[c] %@ OR %@ contains[c] %@", self.searchKey, @"%@", self.searchKeyAlternative, @"%@"];
            searchPredicate = [NSPredicate predicateWithFormat:searchPredicateFormat, self.searchDisplayController.searchBar.text, self.searchDisplayController.searchBar.text];
        }
		
		[NSFetchedResultsController deleteCacheWithName:self.fetchedResultsController.cacheName];
		self.fetchedResultsController.fetchRequest.predicate = [NSCompoundPredicate andPredicateWithSubpredicates:[NSArray arrayWithObjects:searchPredicate, normalPredicate , nil]];
		[self performFetchForTableView:tableView];
	}

	return self.fetchedResultsController;
}

- (void)searchDisplayControllerWillEndSearch:(UISearchDisplayController *)controller {
	// reset the fetch controller for the main (non-searching) table view
	[self fetchedResultsControllerForTableView:self.tableView];
}

- (void)searchDisplayControllerDidEndSearch:(UISearchDisplayController *)controller {
    [self.tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0] atScrollPosition:UITableViewScrollPositionBottom animated:YES];
}

- (void)setFetchedResultsController:(NSFetchedResultsController *)controller {
  
	_fetchedResultsController.delegate = nil;
	[_fetchedResultsController release];
	_fetchedResultsController = [controller retain];
	controller.delegate = self;
	normalPredicate = [self.fetchedResultsController.fetchRequest.predicate retain];
    
	if (!self.title) self.title = controller.fetchRequest.entity.name;
	if (self.view.window) [self performFetchForTableView:self.tableView];
}

- (UITableViewCellAccessoryType)accessoryTypeForManagedObject:(NSManagedObject *)managedObject {
	return UITableViewCellAccessoryDisclosureIndicator;
}

- (UIImage *)thumbnailImageForManagedObject:(NSManagedObject *)managedObject {
	return nil;
}

- (void)configureCell:(UITableViewCell *)cell forManagedObject:(NSManagedObject *)managedObject {
}
             
- (UIView *)createTableHeaderSubView {
    return nil;
}

- (UITableViewCell *)newUIViewCell {
    return [GradientCell alloc];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForManagedObject:(NSManagedObject *)managedObject {
    
    static NSString *ReuseIdentifier = @"CoreDataTableViewCell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:ReuseIdentifier];
    if (cell == nil) {
		UITableViewCellStyle cellStyle = self.subtitleKey ? UITableViewCellStyleSubtitle : UITableViewCellStyleDefault;
        UITableViewCell *newCell = [self newUIViewCell];
        cell = [[newCell initWithStyle:cellStyle reuseIdentifier:ReuseIdentifier] autorelease];
        // get a class name like this: NSStringFromClass([newCell class])
        
        if (tableView.style == UITableViewStylePlain) {
            [UIFactory initializeCell:cell];
        }
    }
	
	if (self.titleKey) cell.textLabel.text = [self cascadedObject:managedObject withKey:self.titleKey];
	if (self.subtitleKey) cell.detailTextLabel.text = [self cascadedObject:managedObject withKey:self.subtitleKey];
    if (self.imageKey) {
        id image = [self cascadedObject:managedObject withKey:self.imageKey];
        if (image) {
            if ([image isKindOfClass:[NSData class]]) {
                cell.imageView.image = [[[UIImage alloc] initWithData:image] autorelease];
            } else {
                NSString *pathCountryPlist =[[NSBundle mainBundle] pathForResource:image ofType:@""];
                cell.imageView.image = [UIImage imageWithContentsOfFile:pathCountryPlist];
            }
        }
    }
	cell.accessoryType = [self accessoryTypeForManagedObject:managedObject];
	UIImage *thumbnail = [self thumbnailImageForManagedObject:managedObject];
	if (thumbnail) cell.imageView.image = thumbnail;

	return cell;
}

- (UIImage *)imageWithImage:(UIImage *)image scaledToSize:(CGSize)newSize {
    UIGraphicsBeginImageContext(newSize);
    [image drawInRect:CGRectMake(0, 0, newSize.width, newSize.height)];
    UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();    
    UIGraphicsEndImageContext();
    return newImage;
}

- (id) cascadedObject:(NSManagedObject *)managedObject withKey:(NSString *)key {
    NSArray *components = [key componentsSeparatedByString:@"."];
    id returnValue = managedObject;
    for (NSString *component in components) {
        returnValue = [returnValue valueForKey:component];
    }
    return returnValue;
}

- (void)managedObjectSelected:(NSManagedObject *)managedObject
{
    // Navigation logic may go here. Create and push another view controller.
    // AnotherViewController *anotherViewController = [[AnotherViewController alloc] initWithNibName:@"AnotherView" bundle:nil];
    // [self.navigationController pushViewController:anotherViewController];
    // [anotherViewController release];
}

- (void)deleteManagedObject:(NSManagedObject *)managedObject
{
    // implement in subclass
}

- (BOOL)canDeleteManagedObject:(NSManagedObject *)managedObject
{
	return NO;
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
	NSManagedObject *managedObject = [[self fetchedResultsControllerForTableView:tableView] objectAtIndexPath:indexPath];
	return [self canDeleteManagedObject:managedObject];
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
	NSManagedObject *managedObject = [[self fetchedResultsControllerForTableView:tableView] objectAtIndexPath:indexPath];
	[self deleteManagedObject:managedObject];
}

#pragma mark UIViewController methods

- (void)viewDidLoad
{
	[self createSearchBar];
}

- (void)viewWillAppear:(BOOL)animated
{
	[super viewWillAppear:animated];
	[self performFetchForTableView:self.tableView];
}

#pragma mark UITableViewDataSource methods

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return [[[self fetchedResultsControllerForTableView:tableView] sections] count];
}

- (NSArray *)sectionIndexTitlesForTableView:(UITableView *)tableView
{
	return [[self fetchedResultsControllerForTableView:tableView] sectionIndexTitles];
}

#pragma mark UITableViewDelegate methods

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [[[[self fetchedResultsControllerForTableView:tableView] sections] objectAtIndex:section] numberOfObjects];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{    
	return [self tableView:tableView cellForManagedObject:[[self fetchedResultsControllerForTableView:tableView] objectAtIndexPath:indexPath]];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
	[self managedObjectSelected:[[self fetchedResultsControllerForTableView:tableView] objectAtIndexPath:indexPath]];
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
	return [[[[self fetchedResultsControllerForTableView:tableView] sections] objectAtIndex:section] name];
}

- (NSInteger)tableView:(UITableView *)tableView sectionForSectionIndexTitle:(NSString *)title atIndex:(NSInteger)index
{
    return [[self fetchedResultsControllerForTableView:tableView] sectionForSectionIndexTitle:title atIndex:index];
}

- (NSString *)controller:(NSFetchedResultsController *)controller sectionIndexTitleForSectionName:(NSString *)sectionName {
    return sectionName;}

#pragma mark NSFetchedResultsControllerDelegate methods

- (void)controllerWillChangeContent:(NSFetchedResultsController *)controller
{
    [self.tableView beginUpdates];
}

- (void)controller:(NSFetchedResultsController *)controller
  didChangeSection:(id <NSFetchedResultsSectionInfo>)sectionInfo
		   atIndex:(NSUInteger)sectionIndex
	 forChangeType:(NSFetchedResultsChangeType)type
{	
    switch(type)
	{
        case NSFetchedResultsChangeInsert:
            [self.tableView insertSections:[NSIndexSet indexSetWithIndex:sectionIndex] withRowAnimation:UITableViewRowAnimationFade];
            break;
			
        case NSFetchedResultsChangeDelete:
            [self.tableView deleteSections:[NSIndexSet indexSetWithIndex:sectionIndex] withRowAnimation:UITableViewRowAnimationFade];
            break;
    }
}


- (void)controller:(NSFetchedResultsController *)controller
   didChangeObject:(id)anObject
	   atIndexPath:(NSIndexPath *)indexPath
	 forChangeType:(NSFetchedResultsChangeType)type
	  newIndexPath:(NSIndexPath *)newIndexPath
{	
    UITableView *tableView = self.tableView;
	
    switch(type)
	{
        case NSFetchedResultsChangeInsert:
            [tableView insertRowsAtIndexPaths:[NSArray arrayWithObject:newIndexPath] withRowAnimation:UITableViewRowAnimationFade];
            break;
			
        case NSFetchedResultsChangeDelete:
            [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
            break;
			
        case NSFetchedResultsChangeUpdate:
            if (!self.reloadDisabled) {
                [tableView reloadRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
            }
            break;
			
        case NSFetchedResultsChangeMove:
            [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
            [tableView insertRowsAtIndexPaths:[NSArray arrayWithObject:newIndexPath] withRowAnimation:UITableViewRowAnimationFade];
            break;
    }
}


- (void)controllerDidChangeContent:(NSFetchedResultsController *)controller
{
    [self.tableView endUpdates];
}

#pragma mark dealloc

- (void)dealloc {
    
    [NSFetchedResultsController deleteCacheWithName:_fetchedResultsController.cacheName];
    
	_fetchedResultsController.delegate = nil;
	[_fetchedResultsController release];
    
	[searchKey release];
	[titleKey release];
	[currentSearchText release];
	[normalPredicate release];
    [super dealloc];
}

@end

