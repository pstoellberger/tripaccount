//
//  EntryEditViewController.m
//  Reiseabrechnung
//
//  Created by Martin Maier on 30/06/2011.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "EntryEditViewController.h"
#import "EditableTableViewCell.h"
#import "EntryNotManaged.h"
#import "GenericSelectViewController.h"


@interface EntryEditViewController () 

@property (nonatomic, retain) Entry *entryManaged;
@property (nonatomic, retain) EntryNotManaged *nmEntry;
@property (nonatomic, retain) Travel *travel;

- (void)selectPayer:(Participant *)payer;
- (void)selectCurrency:(Currency *)currency;
- (void)selectReceivers:(NSArray *)receivers;

@end

@implementation EntryEditViewController

@synthesize entryManaged=_entryManaged, travel=_travel, nmEntry=_nmEntry;

- (id)initWithTravel: (Travel *)travel target:(id)target action:(SEL)selector {
    self = [self initWithTravel:travel andEntry:nil target:target action:selector];
    if (self) {
        if (!self.nmEntry) {
            self.nmEntry = [[EntryNotManaged alloc] init];
            self.nmEntry.currency = (Currency *) travel.homeCurrency;
            self.nmEntry.payer = [travel.participants anyObject];
        }
    }
    return self;
}

- (id)initWithTravel: (Travel *)travel andEntry:(Entry *)entryManaged target:(id)target action:(SEL)selector {
    self = [super initWithStyle:UITableViewStyleGrouped];
    if (self) {
        _target = target;
        _selector = selector;
        self.travel = travel;
        self.entryManaged = entryManaged;
        
        if (entryManaged) {
            self.nmEntry = [[EntryNotManaged alloc] initWithEntry:entryManaged];
        }
    }
    return self;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 4;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    switch(section) {
        case 0: return 1;
        case 1: return 2;
        case 2: return 2;
        case 3: return 1;
    }
    return 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    UITableViewCell *cell = nil;
    
    if (indexPath.section == 0) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue2 reuseIdentifier:@"Payer"] autorelease];
        cell.textLabel.text = @"Payer";
        cell.detailTextLabel.text = [NSString stringWithFormat:@"%@", self.nmEntry.payer.name];
    } else if (indexPath.section == 1) {
        switch (indexPath.row) {
            case 0:
                cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue2 reuseIdentifier:@"AmountCell"] autorelease];
                
                _amountField = [[[UITextField alloc] initWithFrame:CGRectMake(80, 10, self.tableView.bounds.size.width - 110, 50)] autorelease];
                _descField.autoresizingMask = UIViewAutoresizingFlexibleWidth;
                _amountField.delegate = self;
                _amountField.placeholder = @"Amount";
                if (self.nmEntry.amount) {
                    _amountField.text = [NSString stringWithFormat:@"%@", self.nmEntry.amount];
                }
                _amountField.keyboardType = UIKeyboardTypeDecimalPad;
                _amountField.keyboardAppearance = UIKeyboardAppearanceAlert;
                _amountField.textAlignment = UITextAlignmentRight;
                
                [cell.contentView addSubview:_amountField];
                
                cell.editing = YES;
                cell.textLabel.text = @"Amount";
                
                break;
            case 1:
                cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue2 reuseIdentifier:@"amount"] autorelease];
                cell.textLabel.text = @"Currency";
                cell.detailTextLabel.text = [NSString stringWithFormat:@"%@", self.nmEntry.currency.code];
                break;
        };
    } else if (indexPath.section == 2) {
        switch (indexPath.row) {
            case 0:
                cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue2 reuseIdentifier:@"DescriptionCell"] autorelease];
                
                
                NSLog(@"%@", cell.detailTextLabel.bounds);
                
                _descField = [[[UITextField alloc] initWithFrame:CGRectMake(80, 10, self.tableView.bounds.size.width - 110, 50)] autorelease];
                _descField.autoresizingMask = UIViewAutoresizingFlexibleWidth;
                _descField.delegate = self;
                _descField.placeholder = @"Description";
                _descField.text =  self.nmEntry.text;
                
                [cell.contentView addSubview:_descField];
                
                cell.editing = YES;
                cell.textLabel.text = @"Description";
                break;        
            case 1:
                cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue2 reuseIdentifier:@"type"] autorelease];
                cell.textLabel.text = @"Type";
                if (self.nmEntry.type.name) {
                    cell.detailTextLabel.text = [NSString stringWithFormat:@"%@", self.nmEntry.type.name];
                } else {
                    cell.detailTextLabel.text = @"Type (optional)";
                }
                break;
        }
    } else if (indexPath.section == 3) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue2 reuseIdentifier:@"Payer"] autorelease];
        cell.textLabel.text = @"Receiver";
        cell.detailTextLabel.text = [NSString stringWithFormat:@"%d people", [self.nmEntry.receivers count]];
        cell.editing = YES;          
    }
    
    return cell;
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)repString {
    if([repString isEqualToString:@"\n"]) {
        [textField resignFirstResponder];
        return NO;
    }
    
    if (textField == _descField) {
        self.nmEntry.text = [textField.text stringByReplacingCharactersInRange:range withString:repString];
    } else if (textField == _amountField) {
        self.nmEntry.amount = [[NSNumber alloc] initWithDouble:[[textField.text stringByReplacingCharactersInRange:range withString:repString] doubleValue]];
    }
    return YES;
}

- (void)selectType:(Type *)type {
    self.nmEntry.type = type;
    [self.tableView reloadData];
}

- (void)selectPayer:(Participant *)payer {
    self.nmEntry.payer = payer;
    [self.tableView reloadData];
}

- (void)selectCurrency:(Currency *)currency {
    self.nmEntry.currency = currency;
    [self.tableView reloadData];
}

- (void)selectReceivers:(NSArray *)receivers {
    self.nmEntry.receivers = [[[NSSet alloc] initWithArray:receivers] autorelease];
    [self.tableView reloadData];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (indexPath.section == 0 && indexPath.row == 0) {
        
        NSFetchRequest *_fetchRequest = [[[NSFetchRequest alloc] init] autorelease];
        _fetchRequest.entity = [NSEntityDescription entityForName:@"Participant" inManagedObjectContext:[self.travel managedObjectContext]];
        _fetchRequest.sortDescriptors = [NSArray arrayWithObject:[NSSortDescriptor sortDescriptorWithKey:@"name" ascending:YES]];
        _fetchRequest.predicate = [NSPredicate predicateWithFormat:@"travel = %@", self.travel];
        
        GenericSelectViewController *selectViewController = [[GenericSelectViewController alloc] initInManagedObjectContext:[self.travel managedObjectContext]
                                                                                                         withMultiSelection:NO
                                                                                                           withFetchRequest:_fetchRequest
                                                                                                        withSelectedObjects:[NSArray arrayWithObjects: self.nmEntry.payer, nil] 
                                                                                                                     target:self
                                                                                                                     action:@selector(selectPayer:)];        

        selectViewController.title = @"Payer";
        [self.navigationController pushViewController:selectViewController animated:YES];
        [selectViewController release];
        
    } else if (indexPath.section == 1 && indexPath.row == 1) {

        NSFetchRequest *_fetchRequest = [[[NSFetchRequest alloc] init] autorelease];
        _fetchRequest.entity = [NSEntityDescription entityForName:@"Currency" inManagedObjectContext: [self.travel managedObjectContext]];
        _fetchRequest.sortDescriptors = [NSArray arrayWithObject:[NSSortDescriptor sortDescriptorWithKey:@"name" ascending:YES]];
        _fetchRequest.predicate = [NSPredicate predicateWithFormat:@"travels contains %@ OR origins contains %@", self.travel, self.travel];
        
        GenericSelectViewController *selectViewController = [[GenericSelectViewController alloc] initInManagedObjectContext:[self.travel managedObjectContext]
                                                                                                         withMultiSelection:NO
                                                                                                           withFetchRequest:_fetchRequest 
                                                                                                        withSelectedObjects:[NSArray arrayWithObjects: self.nmEntry.currency, nil] 
                                                                                                                     target:self
                                                                                                                     action:@selector(selectCurrency:)];
        [self.navigationController pushViewController:selectViewController animated:YES];
        [selectViewController release];
        
    } else if (indexPath.section == 2 && indexPath.row == 1) {
        
        NSFetchRequest *_fetchRequest = [[[NSFetchRequest alloc] init] autorelease];
        _fetchRequest.entity = [NSEntityDescription entityForName:@"Type" inManagedObjectContext: [self.travel managedObjectContext]];
        _fetchRequest.sortDescriptors = [NSArray arrayWithObject:[NSSortDescriptor sortDescriptorWithKey:@"name" ascending:YES]]; 
        
        GenericSelectViewController *selectViewController = [[GenericSelectViewController alloc] initInManagedObjectContext:[self.travel managedObjectContext]
                                                                                                         withMultiSelection:NO
                                                                                                           withFetchRequest:_fetchRequest 
                                                                                                        withSelectedObjects:[NSArray arrayWithObjects: self.nmEntry.type ,nil] 
                                                                                                                     target:self
                                                                                                                     action:@selector(selectType:)];
        [self.navigationController pushViewController:selectViewController animated:YES];
        [selectViewController release];

    } else if (indexPath.section == 3 && indexPath.row == 0) {
        
        NSFetchRequest *_fetchRequest = [[[NSFetchRequest alloc] init] autorelease];
        _fetchRequest.entity = [NSEntityDescription entityForName:@"Participant" inManagedObjectContext:[self.travel managedObjectContext]];
        _fetchRequest.sortDescriptors = [NSArray arrayWithObject:[NSSortDescriptor sortDescriptorWithKey:@"name" ascending:YES]];
        _fetchRequest.predicate = [NSPredicate predicateWithFormat:@"travel = %@", self.travel];
        
        GenericSelectViewController *selectViewController = [[GenericSelectViewController alloc] initInManagedObjectContext:[self.travel managedObjectContext]
                                                                                                         withMultiSelection:YES
                                                                                                           withFetchRequest:_fetchRequest 
                                                                                                        withSelectedObjects:[self.nmEntry.receivers allObjects] 
                                                                                                                     target:self
                                                                                                                     action:@selector(selectReceivers:)];        
        
        selectViewController.title = @"Receivers";
        [self.navigationController pushViewController:selectViewController animated:YES];
        [selectViewController release];
    }
}

- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath {
    return UITableViewCellEditingStyleInsert;
}

- (IBAction)done:(UIBarButtonItem *)sender {
    
    if ([_target respondsToSelector:_selector]) {
        [_target performSelector:_selector withObject:self.nmEntry withObject:self.entryManaged];
    }
    
    [self dismissModalViewControllerAnimated:YES];
}

- (IBAction)cancel:(UIBarButtonItem *)sender {
    self.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
    [self dismissModalViewControllerAnimated:YES];
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

    self.navigationItem.leftBarButtonItem = [[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel target:self action:@selector(cancel:)] autorelease];
    if (self.travel) {
        self.navigationItem.rightBarButtonItem = [[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(done:)] autorelease];
    } else {
        self.navigationItem.rightBarButtonItem = [[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemSave target:self action:@selector(done:)] autorelease];
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
