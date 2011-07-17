//
//  EntryEditViewController.m
//  Reiseabrechnung
//
//  Created by Martin Maier on 30/06/2011.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "EntryEditViewController.h"
#import "ParticipantSelectViewController.h"
#import "EditableTableViewCell.h"
#import "EntryNotManaged.h"
#import "CurrencySelectViewController.h"


@interface EntryEditViewController () 

- (void)selectPayer:(Participant *)payer;
- (void)selectCurrency:(Currency *)currency;
- (void)selectReceivers:(NSArray *)receivers;

@end

@implementation EntryEditViewController

@synthesize rootViewController=_rootViewController, travel=_travel;
@synthesize descriptionField=_descriptionField, amountField=_amountField, currencyField=_currencyField, datePicker=_datePicker, dateToggle=_dateToggle;
@synthesize toolbarView=_toolbarView;

- (id)initWithTravel: (Travel *) travel {
    self = [super initWithNibName:@"EntryEditViewController" bundle:nil];
    if (self) {
        _travel = travel;
        _entry = [[EntryNotManaged alloc] init];
        _entry.currency = (Currency *) _travel.currency;
        _entry.payer = [_travel.participants anyObject];
    }
    return self;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 3;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    switch(section) {
        case 0: return 1;
        case 1: return 3;
        case 2: return 1;
    }
    return 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *tagCellIdentifier = @"EditableTableViewCell";
    
    UITableViewCell *cell = nil;
    
    if (indexPath.section == 0) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue2 reuseIdentifier:@"Payer"] autorelease];
        cell.textLabel.text = @"Payer";
        cell.detailTextLabel.text = [NSString stringWithFormat:@"%@", _entry.payer.name];
    } else if (indexPath.section == 1) {
        EditableTableViewCell *editCell = nil;
        switch (indexPath.row) {
            case 0:
                editCell = (EditableTableViewCell *) [tableView dequeueReusableCellWithIdentifier:tagCellIdentifier];
                if (editCell == nil) {
                    editCell = [[EditableTableViewCell alloc] initWithStyle:UITableViewCellStyleValue2 reuseIdentifier:@"Text"];
                    //NSArray *compArray = [[NSBundle mainBundle] loadNibNamed:@"EditableTableViewCell" owner:editCell options:nil];
                    //editCell = [compArray lastObject];
                }
                editCell.textLabel.text = @"Description";
                editCell.textField.placeholder = @"enter text here";
                editCell.editing = YES;
                cell = editCell;
                break;
            case 1:
                cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue2 reuseIdentifier:@"amount"] autorelease];
                cell.textLabel.text = @"Amount";
                cell.detailTextLabel.text = [NSString stringWithFormat:@"%@", _entry.amount];
                break;
            case 2:
                cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue2 reuseIdentifier:@"amount"] autorelease];
                cell.textLabel.text = @"Currency";
                cell.detailTextLabel.text = [NSString stringWithFormat:@"%@", _entry.currency.code];
                break;
        };        
    } else if (indexPath.section == 2) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue2 reuseIdentifier:@"Payer"] autorelease];
        cell.textLabel.text = @"Receiver";
        cell.detailTextLabel.text = [NSString stringWithFormat:@"%d people", [_entry.receivers count]];
        cell.editing = YES;          
    }
    
    return cell;
}

- (void)selectPayer:(Participant *)payer {
    _entry.payer = payer;
    [self.tableView reloadData];
}

- (void)selectCurrency:(Currency *)currency {
    _entry.currency = currency;
    [self.tableView reloadData];
}

- (void)selectReceivers:(NSArray *)receivers {
    _entry.receivers = [[[NSSet alloc] initWithArray:receivers] autorelease];
    [self.tableView reloadData];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == 0 && indexPath.row == 0) {
        ParticipantSelectViewController *psc = [[ParticipantSelectViewController alloc] initInManagedObjectContext:[self.travel managedObjectContext] withTravel:_travel target:self action:@selector(selectPayer:)];
        [psc addSelectedParticipants:[NSArray arrayWithObject:_entry.payer]];
        [self.navigationController pushViewController:psc animated:YES];
        [psc release];
    } else if (indexPath.section == 1 && indexPath.row == 2) {
        CurrencySelectViewController *csvc = [[CurrencySelectViewController alloc] initInManagedObjectContext:[self.travel managedObjectContext] target:self action:@selector(selectCurrency:)];
        csvc.selectedCurrency = _entry.currency;
        [self.navigationController pushViewController:csvc animated:YES];
        [csvc release];
    } else if (indexPath.section == 2 && indexPath.row == 0) {
        ParticipantSelectViewController *psc = [[ParticipantSelectViewController alloc] initInManagedObjectContext:[self.travel managedObjectContext] withTravel:_travel target:self action:@selector(selectReceivers:)];
        [psc addSelectedParticipants:_entry.receivers];
        psc.multiSelectionAllowed = YES;
        
        [self.navigationController pushViewController:psc animated:YES];
        [psc release];
    }
}

- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath {
    return UITableViewCellEditingStyleInsert;
}

- (IBAction)done:(UIBarButtonItem *)sender {
    
    //NSNumberFormatter * f = [[NSNumberFormatter alloc] init];
    //[f setNumberStyle:NSNumberFormatterDecimalStyle];
    //NSNumber * myNumber = [f numberFromString:_amountField.text];
    //[f release];
    
    [_rootViewController addEntry:_entry];
    
    [self dismissModalViewControllerAnimated:YES];
}

- (IBAction)cancel:(UIBarButtonItem *)sender {
    self.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
    [self dismissModalViewControllerAnimated:YES];
}

- (void)dealloc
{
    [super dealloc];
    [_entry release];
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
    
    self.tableView.tableHeaderView = _toolbarView;
    
    self.navigationItem.leftBarButtonItem = [[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel target:self action:@selector(cancel:)] autorelease];
    if (self.travel) {
        self.navigationItem.rightBarButtonItem = [[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(done:)] autorelease];
    } else {
        self.navigationItem.rightBarButtonItem = [[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemSave target:self action:@selector(done:)] autorelease];
    }

    [_descriptionField becomeFirstResponder];
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
