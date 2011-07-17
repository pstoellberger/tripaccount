//
//  TravelEditViewController.m
//  Reiseabrechnung
//
//  Created by Martin Maier on 29/06/2011.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "TravelEditViewController.h"
#import "Currency.h"
#import "TravelNotManaged.h"
#import "EditableTableViewCell.h"
#import "CurrencySelectViewController.h"
#import "ReiseabrechnungAppDelegate.h"

@implementation TravelEditViewController

@synthesize descField=_descField;
@synthesize locManager=_locManager;
@synthesize name=_name, travel=_travel, currency=_currency;

- (id) initInManagedObjectContext:(NSManagedObjectContext *)context {
    
    self = [super initWithNibName:@"TravelEditViewController" bundle:nil];
    if (self) {
        NSFetchRequest *req = [[NSFetchRequest alloc] init];
        req.entity = [NSEntityDescription entityForName:@"Currency" inManagedObjectContext: context];
        currencies = [context executeFetchRequest:req error:nil];
        [req release];
        [currencies retain];
        
        _context = context;
        self.currency = [self defaultCurrency];
        self.name = nil;
        
    }
    return self;
}

- (id) initInManagedObjectContext:(NSManagedObjectContext *)context withTravel:(Travel *)travel {
    self = [self initInManagedObjectContext:context];
    if (self) {
        self.currency = travel.currency;
        self.name = travel.name;
        self.travel = travel;
    }
    return self;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    UITableViewCell *cell = nil;
    
    if (indexPath.section == 0) {
        _locationCell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:@"LocationCell"] autorelease];
        cell = _locationCell;
      
    } else {
        switch (indexPath.row) {
            case 0:
                cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue2 reuseIdentifier:@"EditableTableViewCell"] autorelease];
                
                _descField = [[[UITextField alloc] initWithFrame:CGRectMake(10, 12, 200, 200)] autorelease];
                _descField.delegate = self;
                _descField.placeholder = @"Description (optional)";
                _descField.text = self.name;
                
                [cell.contentView addSubview:_descField];
                
                cell.editing = YES;
                
                [_descField becomeFirstResponder];
                
                break;
            case 1:
                cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue2 reuseIdentifier:@"Currency"] autorelease];
                cell.textLabel.text = @"Currency";
                cell.detailTextLabel.text = [NSString stringWithFormat:@"%@", self.currency.name];
                cell.editing = NO;
                break;
                
        };       
    }
    
    return cell;
}

- (NSIndexPath *)tableView:(UITableView *)tableView willSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	if (indexPath.row == 1) {
        return indexPath;
    } else {
        return nil;
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	if (indexPath.row == 1) {
        CurrencySelectViewController *csvc = [[CurrencySelectViewController alloc] initInManagedObjectContext:_context target:self action:@selector(selectCurrency:)];
        csvc.selectedCurrency = self.currency;
        [self.navigationController pushViewController:csvc animated:YES];
        [csvc release];
    }
}

- (Currency *)defaultCurrency {
    return [currencies lastObject];
}

- (void)selectCurrency:(Currency *)currency {
    self.currency = currency;
    [self.tableView reloadData];
}

- (IBAction)done:(UIBarButtonItem *)sender {
    
    if (!self.travel) {
        self.travel = [NSEntityDescription insertNewObjectForEntityForName: @"Travel" inManagedObjectContext:_context];
        if ([currencies lastObject]) {
            self.travel.currency = [currencies objectAtIndex:0];
        }
    }
    
    self.travel.name = _descField.text;
    self.travel.currency = self.currency; 
    
    [ReiseabrechnungAppDelegate saveContext:_context];
    
    [self dismissModalViewControllerAnimated:YES];
}

- (IBAction)cancel:(UIBarButtonItem *)sender {
    self.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
    [self dismissModalViewControllerAnimated:YES];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (section == 0) {
        return 1;
    } else {
        return 2;
    }
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    if (section == 0) {
        return @"Location";
    } else {
        return nil;
    }    
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)repString {
    if([repString isEqualToString:@"\n"]) {
        [textField resignFirstResponder];
        return NO;
    }
    
    [self checkIfDoneIsPossible:repString];
    
    self.name = [textField.text stringByReplacingCharactersInRange:range withString:repString];
   
	return YES;
}

- (void)checkIfDoneIsPossible:(NSString *)newString {
    if (_locationCell.textLabel.text) {
        self.navigationItem.rightBarButtonItem.enabled = YES;
    } else if ([[newString  stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]] length] > 0) {
        self.navigationItem.rightBarButtonItem.enabled = YES;
    } else {
        self.navigationItem.rightBarButtonItem.enabled = NO;
    }    
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

    self.navigationItem.leftBarButtonItem = [[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel target:self action:@selector(cancel:)] autorelease];
    if (self.travel) {
        self.navigationItem.rightBarButtonItem = [[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(done:)] autorelease];
    } else {
        self.navigationItem.rightBarButtonItem = [[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemSave target:self action:@selector(done:)] autorelease];
    }
    
	self.locManager = [[[CLLocationManager alloc] init] autorelease];
	if (![CLLocationManager locationServicesEnabled])
	{
		NSLog(@"User has opted out of location services");
		return;
	}
    
	self.locManager.delegate = self;
	self.locManager.desiredAccuracy = kCLLocationAccuracyBest;
    
	self.locManager.distanceFilter = 5.0f; // in meters
	[self.locManager startUpdatingLocation];
}

- (void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error
{
	NSLog(@"Location manager error: %@", [error description]);
}

- (void)reverseGeocoder:(MKReverseGeocoder *)geocoder didFailWithError:(NSError *)error
{
	NSLog(@"Reverse geocoder error: %@", [error description]);
}

- (void)locationManager:(CLLocationManager *)manager didUpdateToLocation:(CLLocation *)newLocation fromLocation:(CLLocation *)oldLocation
{
    if (!_geocoder) {
        _geocoder = [[MKReverseGeocoder alloc] initWithCoordinate:newLocation.coordinate];
        _geocoder.delegate = self;
        [_geocoder start];
        [_geocoder retain];
    }
}

- (void)reverseGeocoder:(MKReverseGeocoder *)geocoder didFindPlacemark:(MKPlacemark *)placemark
{
	NSLog(@"%@",[placemark.addressDictionary description]);
	
    if ([placemark locality]) {
        _locationCell.textLabel.text = [NSString stringWithFormat:@"%@, %@",  [placemark locality], [placemark country]];
    } else {
        _locationCell.textLabel.text = [placemark country];
    }
    [_locationCell setNeedsLayout];

    [self checkIfDoneIsPossible:_descField.text];
    
    [geocoder cancel];
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

- (void)dealloc {
    [currencies release];
    [_currency release];
    
    [_geocoder release];
    
    [super dealloc];
}

@end
