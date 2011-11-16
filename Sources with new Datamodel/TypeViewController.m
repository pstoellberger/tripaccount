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

@implementation TypeViewController

- (id)initInManagedObjectContext:(NSManagedObjectContext *)context withMultiSelection:(BOOL)multiSelection withSelectedObjects:(NSArray *)selectedObjects target:(id)target action:(SEL)selector {
    
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    fetchRequest.entity = [NSEntityDescription entityForName:@"Type" inManagedObjectContext:context];
    fetchRequest.sortDescriptors = [NSArray arrayWithObject:[NSSortDescriptor sortDescriptorWithKey:[Type sortAttributeI18N] ascending:YES selector:@selector(caseInsensitiveCompare:)]]; 
    
    if (self = [super initInManagedObjectContext:context withMultiSelection:multiSelection withAllNoneButtons:NO withFetchRequest:fetchRequest withSectionKey:nil withSelectedObjects:selectedObjects target:target action:selector]) {
        
        
        _editButton = [[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemEdit target:self action:@selector(toggleEditing)] retain];
        _addButton = [[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(openAddPopup)] retain];
        _doneButton = [[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(toggleEditing)] retain];
        
        self.navigationItem.rightBarButtonItem = _editButton;
        
        self.title = NSLocalizedString(@"Type", "controller title");
        
        self.tableView.allowsSelectionDuringEditing = YES;
        
    }
    
    [fetchRequest release];
    
    return self;
}

- (void)openAddPopup {
    
    TextEditViewController *tevc = [[TextEditViewController alloc] initWithText:@"" target:self selector:@selector(addType:)];
    tevc.title = NSLocalizedString(@"Add type", @"title new type");
    [self.navigationController pushViewController:tevc animated:YES];
    [tevc release];
}

- (void)editType:(Type *)type {
    
    _editedType = type;
    
    TextEditViewController *tevc = [[TextEditViewController alloc] initWithText:type.name target:self selector:@selector(updateType:)];
    [self.navigationController pushViewController:tevc animated:YES];
    [tevc release];
}

- (void)updateType:(NSString *)typeName {

    if (_editedType) {
        
        [self.tableView beginUpdates];
        
        _editedType.name = typeName;
        
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
    
    [self.tableView setEditing:!self.tableView.editing animated:YES];
    
    if (self.tableView.editing) {
        [self.navigationItem setRightBarButtonItem:_addButton animated:YES];
        [self.navigationItem setLeftBarButtonItem:_doneButton animated:YES];
    } else {
        [self.navigationItem setRightBarButtonItem:_editButton animated:YES];
        [self.navigationItem setLeftBarButtonItem:nil animated:YES];
    }
}


- (UITableViewCellAccessoryType)accessoryTypeForManagedObject:(NSManagedObject *)managedObject {
    return UITableViewCellAccessoryNone;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForManagedObject:(NSManagedObject *)managedObject {
    
    static NSString *reuseIdentifier = @"TypeCell";
    
    Type *type = (Type *)managedObject;
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:reuseIdentifier];
    if (cell == nil) {
        cell = [[[self newUIViewCell] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:reuseIdentifier] autorelease];
    }
    
    if ([type.builtIn intValue] == 1) {
        cell.detailTextLabel.text = NSLocalizedString(@"(built-in)", @"built-in type mark");
    } else {
        cell.detailTextLabel.text = nil;
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
    
    Type *type = (Type *)managedObject;
    if ([type.builtIn intValue] == 1) {
        return NO;
    } else {
        return YES;
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
    
    [super dealloc];
}


@end
