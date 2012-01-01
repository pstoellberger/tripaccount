//
//  TypeViewController.m
//  Reiseabrechnung
//
//  Created by Martin Maier on 01/08/2011.
//  Copyright 2011 Martin Maier. All rights reserved.
//

#import "TypeViewController.h"
#import "UIFactory.h"
#import "ReiseabrechnungAppDelegate.h"
#import "Type.h"
#import "TextEditViewController.h"
#import "ReiseabrechnungAppDelegate.h"
#import "UIFactory.h"
#import "CustomImageStyle2Cell.h"

@implementation TypeViewController

- (id)initInManagedObjectContext:(NSManagedObjectContext *)context withMultiSelection:(BOOL)multiSelection withSelectedObjects:(NSArray *)selectedObjects target:(id)target action:(SEL)selector {
    
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    request.entity = [NSEntityDescription entityForName:@"Type" inManagedObjectContext:context];
    request.predicate = [NSPredicate predicateWithFormat:@"hidden == 0"];
    request.sortDescriptors = [NSArray arrayWithObject:[NSSortDescriptor sortDescriptorWithKey:[Type sortAttributeI18N] ascending:YES selector:@selector(caseInsensitiveCompare:)]];
    
    if (self = [super initInManagedObjectContext:context withMultiSelection:multiSelection withAllNoneButtons:NO withFetchRequest:request withSectionKey:nil withSelectedObjects:selectedObjects target:target action:selector]) {
        
        
        _editButton = [[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemEdit target:self action:@selector(toggleEditing)] retain];
        _addButton = [[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(openAddPopup)] retain];
        _doneButton = [[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(toggleEditing)] retain];
        
        self.navigationItem.rightBarButtonItem = _editButton;
        
        self.title = NSLocalizedString(@"Type", "controller title");
        
        self.tableView.allowsSelectionDuringEditing = YES;
        
        _builtInImage = [[UIImage imageNamed:@"component_green.png"] retain];
        _customImage = [[UIImage imageNamed:@"component_edit.png"] retain];
        
    }
    
    [request release];
    
    return self;
}

- (void)openAddPopup {
    
    TextEditViewController *tevc = [[TextEditViewController alloc] initWithText:@"" target:self selector:@selector(addType:)];
    tevc.title = NSLocalizedString(@"Add Type", @"title new type");
    [self.navigationController pushViewController:tevc animated:YES];
    [tevc release];
}

- (void)editType:(Type *)type {
    
    _editedType = type;
    
    TextEditViewController *tevc = [[TextEditViewController alloc] initWithText:type.name target:self selector:@selector(updateType:) andNamedImage:@"component_edit.png"];
    [self.navigationController pushViewController:tevc animated:YES];
    [tevc release];
}

- (void)updateType:(NSString *)typeName {

    if (_editedType) {
        
        [self.tableView beginUpdates];
        
        _editedType.name = typeName;
        _editedType.name_de = typeName;
        
        [ReiseabrechnungAppDelegate saveContext:self.context];
        
        [self.tableView endUpdates];
    }
}

- (void)addType:(NSString *)typeName {
    
    [self.tableView beginUpdates];
    
    Type *type = [NSEntityDescription insertNewObjectForEntityForName:@"Type" inManagedObjectContext: self.context];
    type.name = typeName;
    type.name_de = typeName;
    type.builtIn = [NSNumber numberWithInt:0];    
    
    [ReiseabrechnungAppDelegate saveContext:self.context];
    
    [self.tableView endUpdates];    
}

- (void)toggleEditing {
        
    NSFetchedResultsController *resultsController = [self fetchedResultsControllerForTableView:self.tableView];
    
    if (!self.tableView.editing) {
        
        resultsController.fetchRequest.predicate = nil;
        
        [self.navigationItem setRightBarButtonItem:_addButton animated:YES];
        [self.navigationItem setLeftBarButtonItem:_doneButton animated:YES];
        
    } else {
        
        resultsController.fetchRequest.predicate = [NSPredicate predicateWithFormat:@"hidden == 0"];
        
        [self.navigationItem setRightBarButtonItem:_editButton animated:YES];
        [self.navigationItem setLeftBarButtonItem:nil animated:YES];
    }
    
    NSError *error = nil;
    if (![resultsController performFetch:&error]) {
        NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
    }
    
    [self.tableView reloadData];
    
    [self.tableView setEditing:!self.tableView.editing animated:YES];

}


- (UITableViewCellAccessoryType)accessoryTypeForManagedObject:(NSManagedObject *)managedObject {
    return UITableViewCellAccessoryNone;
}

#define IMAGE_TAG 4242

- (UITableViewCell *)tableView:(UITableView *)tableView cellForManagedObject:(NSManagedObject *)managedObject {
    
    static NSString *reuseIdentifierCustom = @"CustTypeCell";
    static NSString *reuseIdentifierBuiltIn = @"BITypeCell";
    
    Type *type = (Type *)managedObject;
    
    UITableViewCell *cell = nil;
    
    if ([type.builtIn intValue] == 1) {
        cell = [tableView dequeueReusableCellWithIdentifier:reuseIdentifierBuiltIn];
        if (cell == nil) {
            cell = [[[CustomImageStyle2Cell alloc] initWithImage:_builtInImage reuseIdentifier:reuseIdentifierBuiltIn] autorelease];
        }
    } else {
        cell = [tableView dequeueReusableCellWithIdentifier:reuseIdentifierCustom];
        if (cell == nil) {
            cell = [[[CustomImageStyle2Cell alloc] initWithImage:_customImage reuseIdentifier:reuseIdentifierCustom] autorelease];
        }        
    }
    
    UIImageView *uiImageView = (UIImageView *) [cell viewWithTag:IMAGE_TAG];
    if ([type.builtIn intValue] == 1) {
        uiImageView.image = [UIImage imageNamed:@"component_green.png"];
        if ([type.hidden intValue] == 0) {
            cell.detailTextLabel.text = NSLocalizedString(@"(built-in)", @"built-in type mark");
        } else {
            cell.detailTextLabel.text = NSLocalizedString(@"(hidden)", @"built-in type mark");
        }
    } else {
        uiImageView.image = [UIImage imageNamed:@"component_edit.png"];
        cell.detailTextLabel.text = nil;
    }
    
    if ([type.hidden intValue] == 1) {
        cell.textLabel.textColor = [UIColor lightGrayColor];
        cell.detailTextLabel.textColor = [UIColor lightGrayColor];
    } else {
        cell.textLabel.textColor = [UIColor blackColor];
        cell.detailTextLabel.textColor = [UIColor colorWithRed:0.22 green:0.33 blue:0.53 alpha:1];
    }
    
    cell.textLabel.text = type.nameI18N;
    
    return cell;
}

- (void)managedObjectSelected:(NSManagedObject *)managedObject {
    
    if (!self.tableView.editing) {
        
        [super managedObjectSelected:managedObject];
        
    } else {
        
        Type *type = (Type *)managedObject;
        if ([type.builtIn intValue] == 1) {
            if ([type.hidden intValue] == 1) {
                type.hidden = [NSNumber numberWithInt:0];
                [ReiseabrechnungAppDelegate saveContext:self.context];
                [self.tableView reloadRowsAtIndexPaths:[NSArray arrayWithObject:[self.fetchedResultsController indexPathForObject:type]] withRowAnimation:UITableViewRowAnimationNone];
            } else {
                type.hidden = [NSNumber numberWithInt:1];
                [ReiseabrechnungAppDelegate saveContext:self.context];
                [self.tableView reloadRowsAtIndexPaths:[NSArray arrayWithObject:[self.fetchedResultsController indexPathForObject:type]] withRowAnimation:UITableViewRowAnimationNone];
            }
            [self.tableView deselectRowAtIndexPath:[self.tableView indexPathForSelectedRow] animated:YES];   
        } else {
            [self editType:type];
        }    
    }
}

- (void)deleteManagedObject:(NSManagedObject *)managedObject {
    
    Type *type = (Type *)managedObject;
   
    for (Entry *entry in type.entries) {
        entry.type = [ReiseabrechnungAppDelegate defaultsObject:self.context].defaultType;
    }
    
    [self.context deleteObject:managedObject];

    [ReiseabrechnungAppDelegate saveContext:self.context];
}

- (BOOL)canDeleteManagedObject:(NSManagedObject *)managedObject {
    Type *type = (Type *) managedObject;
    return [type.builtIn intValue] == 0;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {

    Type *type = (Type *) [self.fetchedResultsController objectAtIndexPath:indexPath];
    
    if ([type.builtIn intValue] == 0) {
        
        [super tableView:tableView commitEditingStyle:editingStyle forRowAtIndexPath:indexPath];
    
    } else {
        
        type.hidden = [NSNumber numberWithInt:1];
        [ReiseabrechnungAppDelegate saveContext:self.context];
        
        [tableView reloadRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:[UIFactory commitEditingStyleRowAnimation]];
    }
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    return YES;
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
    
    [_addButton release];
    [_editButton release];
    [_doneButton release];
    
    [_builtInImage release];
    [_customImage release];
    
    [super dealloc];
}


@end
