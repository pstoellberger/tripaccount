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
#import "ReiseabrechnungAppDelegate.h"
#import "UIFactory.h"
#import "Country.h"
#import "GenericSelectViewController.h"

@interface TravelEditViewController ()
- (void)startLocating;
@end

@implementation TravelEditViewController

@synthesize name=_name, travel=_travel, currency=_currency, country=_country, foreignCurrencies=_foreignCurrencies, city=_city;

@synthesize locManager=_locManager;


- (id) initInManagedObjectContext:(NSManagedObjectContext *)context {
    
    self = [super initWithStyle:UITableViewStyleGrouped];
    
    if (self) {
        _context = context;
        
        self.currency = [self defaultCurrency];
        self.foreignCurrencies = [[NSArray alloc] init];
        self.name = nil;
        self.city = nil;
        self.country = nil;
        
        self.tableView.delegate = self;
        
        self.navigationItem.leftBarButtonItem = [[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel target:self action:@selector(cancel:)] autorelease];
        if (self.travel) {
            self.navigationItem.rightBarButtonItem = [[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(done:)] autorelease];
        } else {
            self.navigationItem.rightBarButtonItem = [[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemSave target:self action:@selector(done:)] autorelease];
        }
        
        // init location manager
        self.locManager = [[[CLLocationManager alloc] init] autorelease];
        if (![CLLocationManager locationServicesEnabled]) {
            NSLog(@"User has opted out of location services");
        }
        
        self.locManager.delegate = self;
        self.locManager.desiredAccuracy = kCLLocationAccuracyBest;
        
        self.locManager.distanceFilter = 5.0f; // in meters
        
        if (!self.country) {
            [self startLocating];
        }
        
    }
    return self;
}

- (id) initInManagedObjectContext:(NSManagedObjectContext *)context withTravel:(Travel *)travel {
    self = [self initInManagedObjectContext:context];
    if (self) {
        self.travel = travel;
        self.name = travel.name;
        self.city = travel.city;
        self.country = travel.country;
        self.currency = travel.homeCurrency;
        self.foreignCurrencies = [travel.foreignCurrencies allObjects];
    }
    return self;
}

//- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
//    
//    if (section == 0) {
//        UIView *containerView = [UIFactory createDefaultTableSectionHeader:self andTableView:tableView andSection:section];       
//        if(section == 0) {
//            UIButton *abutton = [UIButton buttonWithType:UIButtonTypeCustom];
//            UIImage *image = [UIImage imageNamed:@"74-location.png"];
//            
//            UISegmentedControl* sc = [[[UISegmentedControl alloc] initWithFrame:CGRectMake(270, 10 , 30, 30)] autorelease];
//            //UIBarButtonItem *barButton = [[UIBarButtonItem alloc] initWithImage:image style:UIBarButtonItemStyleBordered target:self action:@selector(startLocating)];
//            [sc insertSegmentWithImage:image atIndex:0 animated:NO];
//            //[sc inse:image atIndex:0 animated:NO];
//            sc.segmentedControlStyle = UISegmentedControlStyleBar;
//            sc.momentary = YES;
//            [self.view addSubview:sc];
//            //UIImage *strechableButtonImageNormal = [image stretchableImageWithLeftCapWidth:5 topCapHeight:5];
//            //[abutton setBackgroundImage:image forState:UIControlStateNormal];
//            abutton.frame = CGRectMake(270, 10 , 40, 40);
//            [abutton addTarget: self action: @selector(startLocating)forControlEvents: UIControlEventTouchUpInside];
//            [containerView addSubview:sc];
//        }
//        return containerView;
//    } else {
//        return nil;
//    }
//}
//
//- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
//	if(section == 0)
//		return 47;
//	else {
//		return 47-11;
//	}
//    
//}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    UITableViewCell *cell = nil;
    
    if (indexPath.section == 0) {
        switch (indexPath.row) {
            case 0:
                _countryCell = cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:@"CountryCell"] autorelease];
                _countryCell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
                _countryCell.textLabel.text = @"Country";
                if (self.country) {
                    _countryCell.textLabel.text = [NSString stringWithFormat:@"%@", self.country.name];
                    if (self.country.image) {
                        NSString *pathCountryPlist =[[NSBundle mainBundle] pathForResource:self.country.image ofType:@""];
                        _countryCell.imageView.image = [[UIImage alloc] initWithContentsOfFile:pathCountryPlist];                       
                    }
                }
                break;
            case 1:
                _cityCell = cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue2 reuseIdentifier:@"CityEditCell"] autorelease];
                _cityCell.textLabel.text = @"City";
                
                _cityCellField = [[UITextField alloc] initWithFrame:CGRectMake(85, 10, 200, 200)];
                _cityCellField.delegate = self;
                _cityCellField.placeholder = @"City (optional)";
                _cityCellField.text = self.city;
                
                [cell.contentView addSubview:_cityCellField];
                
                //cell.editing = YES;
                
                break;
            case 2:
                cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:@"CityDescCell"] autorelease];
                
                UIView *descriptionView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 300, 40)];
                //UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 300, 40)];
                //label.text = @"Use this button to use your current location";
                
                UIImage *image = [UIImage imageNamed:@"74-location.png"];
                UIButton *abutton = [UIButton buttonWithType:UIButtonTypeCustom];
                [abutton setBackgroundImage:image forState:UIControlStateNormal];
                [abutton setFrame:CGRectMake(250, 10, 20, 20)];
                //[abutton setTitle:@"Use current location" forState:UIControlStateNormal];
                [descriptionView addSubview:abutton];
                //[descriptionView addSubview:label];
                
                [cell addSubview:descriptionView];
                break;
        }
    } else if (indexPath.section == 1) {
        
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue2 reuseIdentifier:@"EditableTableViewCell"] autorelease];
        
        _descField = [[UITextField alloc] initWithFrame:CGRectMake(10, 10, 200, 200)];
        _descField.delegate = self;
        _descField.placeholder = @"Description (optional)";
        _descField.text = self.name;
        
        [cell.contentView addSubview:_descField];
        
        cell.editing = YES;
        
    } else if (indexPath.section == 2) {
        switch (indexPath.row) {
            case 0:
                cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue2 reuseIdentifier:@"Currency"] autorelease];
                cell.textLabel.text = @"Home";
                cell.detailTextLabel.text = [NSString stringWithFormat:@"%@", self.currency.name];
                cell.editing = NO;
                break;
            case 1:
                cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue2 reuseIdentifier:@"Currency"] autorelease];
                cell.textLabel.text = @"Foreign";
                cell.detailTextLabel.text = [NSString stringWithFormat:@"%d currencies", [self.foreignCurrencies count]];
                cell.editing = NO;
                break;
        };
    }
    
    return cell;
}

- (NSIndexPath *)tableView:(UITableView *)tableView willSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    switch (indexPath.section) {
        case 0: 
            switch(indexPath.row) {
                case 0: return indexPath;
                case 1:
                    [_cityCellField becomeFirstResponder];
                    return nil;
            }
        case 1: 
            switch(indexPath.row) {
                case 0: return indexPath;
                case 1: return indexPath;
            }
        case 2:
            switch(indexPath.row) {
                case 0: return indexPath;
                case 1: return indexPath;
            }
    }
    return indexPath;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	if (indexPath.section == 2) {
        if (indexPath.row == 0) {
            NSFetchRequest *_fetchRequest = [[[NSFetchRequest alloc] init] autorelease];
            _fetchRequest.entity = [NSEntityDescription entityForName:@"Currency" inManagedObjectContext: _context];
            _fetchRequest.sortDescriptors = [NSArray arrayWithObject:[NSSortDescriptor sortDescriptorWithKey:@"name" ascending:YES]]; 
            
            GenericSelectViewController *csvc = [[GenericSelectViewController alloc] initInManagedObjectContext:_context
                                                                                             withMultiSelection:NO
                                                                                               withFetchRequest:_fetchRequest 
                                                                                            withSelectedObjects:[NSArray arrayWithObjects:self.currency, nil] 
                                                                                                         target:self
                                                                                                         action:@selector(selectHomeCurrency:)];
            [self.navigationController pushViewController:csvc animated:YES];
            [csvc release];
        } else {
            NSFetchRequest *_fetchRequest = [[[NSFetchRequest alloc] init] autorelease];
            _fetchRequest.entity = [NSEntityDescription entityForName:@"Currency" inManagedObjectContext: _context];
            _fetchRequest.sortDescriptors = [NSArray arrayWithObject:[NSSortDescriptor sortDescriptorWithKey:@"name" ascending:YES]]; 
            
            GenericSelectViewController *csvc = [[GenericSelectViewController alloc] initInManagedObjectContext:_context
                                                                                             withMultiSelection:YES
                                                                                               withFetchRequest:_fetchRequest 
                                                                                            withSelectedObjects:self.foreignCurrencies
                                                                                                         target:self
                                                                                                         action:@selector(selectForeignCurrencies:)];
            [self.navigationController pushViewController:csvc animated:YES];
            [csvc release];
        }
    } else if (indexPath.section == 0 && indexPath.row == 0) {
        
        NSFetchRequest *_fetchRequest = [[[NSFetchRequest alloc] init] autorelease];
        _fetchRequest.entity = [NSEntityDescription entityForName:@"Country" inManagedObjectContext: _context];
        _fetchRequest.sortDescriptors = [NSArray arrayWithObject:[NSSortDescriptor sortDescriptorWithKey:@"name" ascending:YES]]; 
        
        GenericSelectViewController *selectViewController = [[GenericSelectViewController alloc] initInManagedObjectContext:_context
                                                                                                         withMultiSelection:NO
                                                                                                           withFetchRequest:_fetchRequest 
                                                                                                        withSelectedObjects:[NSArray arrayWithObjects:self.country, nil]
                                                                                                                     target:self
                                                                                                                     action:@selector(selectCountry:)];
        [self.navigationController pushViewController:selectViewController animated:YES];
        [selectViewController release];
    }
}

- (Currency *)defaultCurrency {
    
    NSLocale *theLocale = [NSLocale currentLocale];
    NSString *code = [theLocale objectForKey:NSLocaleCurrencyCode];
    
    NSFetchRequest *req = [[NSFetchRequest alloc] init];
    req.entity = [NSEntityDescription entityForName:@"Currency" inManagedObjectContext: _context];
    req.predicate = [NSPredicate predicateWithFormat:@"code = %@", code];
    NSArray *curSet = [_context executeFetchRequest:req error:nil];
    [req release];
    
    if ([curSet lastObject]) {
        return [curSet lastObject];
    } else {
        NSFetchRequest *req = [[NSFetchRequest alloc] init];
        req.entity = [NSEntityDescription entityForName:@"Travel" inManagedObjectContext: _context];
        req.sortDescriptors = [NSArray arrayWithObject:[NSSortDescriptor sortDescriptorWithKey:@"date" ascending:YES]];
        NSArray *travelSet = [_context executeFetchRequest:req error:nil];
        [req release];
        
        if ([travelSet lastObject]) {
            return [travelSet lastObject];
        }
    }
    
    return nil;
}

- (void)selectForeignCurrencies:(NSArray *)newCurrencies {
    self.foreignCurrencies = newCurrencies;
    [self.tableView reloadData];
}

- (void)selectHomeCurrency:(Currency *)currency {
    self.currency = currency;
    [self.tableView reloadData];
}

- (void)selectCountry:(Country *)country {
    self.country = country;
    self.foreignCurrencies = [country.currencies allObjects];

    [self.tableView reloadData];
}

- (IBAction)done:(UIBarButtonItem *)sender {
    
    if (!self.travel) {
        self.travel = [NSEntityDescription insertNewObjectForEntityForName: @"Travel" inManagedObjectContext:_context];
    }
    
    self.travel.name = _descField.text;
    self.travel.homeCurrency = self.currency;
    self.travel.country = self.country;
    self.travel.city = _cityCellField.text;
    self.travel.foreignCurrencies = [[[NSSet alloc] initWithArray:self.foreignCurrencies] autorelease];
    
    [ReiseabrechnungAppDelegate saveContext:_context];
    
    [self dismissModalViewControllerAnimated:YES];
}

- (IBAction)cancel:(UIBarButtonItem *)sender {
    self.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
    [self dismissModalViewControllerAnimated:YES];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 3;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    switch (section) {
        case 0: return 2;
        case 1: return 1;
        case 2: return 2;
    }
    return 0;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    switch (section) {
        case 0: return @"Location";
        case 1: return @"Description";
        case 2: return @"Currencies";
    }
    return nil;    
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
    if (_countryCell.textLabel.text) {
        self.navigationItem.rightBarButtonItem.enabled = YES;
    } else if ([[newString  stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]] length] > 0) {
        self.navigationItem.rightBarButtonItem.enabled = YES;
    } else {
        self.navigationItem.rightBarButtonItem.enabled = NO;
    }    
}

#pragma mark - View lifecycle

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
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
    [_currency release];
    
    [_geocoder release];
    
    [super dealloc];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
}

#pragma mark - Localisation

-(void) startLocating {
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
        self.city = [placemark locality];
    }
    
    if ([placemark country]) {
        NSFetchRequest *_fetchRequest = [[NSFetchRequest alloc] init];
        _fetchRequest.entity = [NSEntityDescription entityForName:@"Country" inManagedObjectContext: _context];
        _fetchRequest.predicate = [NSPredicate predicateWithFormat:@"name = %@", [placemark country]];
        NSArray *countries = [_context executeFetchRequest:_fetchRequest error:nil];
        [_fetchRequest release];
        
        if ([countries lastObject]) {
            [self selectCountry:[countries lastObject]];
        }
    }
    
    [self.tableView reloadData];

    [self checkIfDoneIsPossible:_descField.text];
    
    [self.locManager stopUpdatingLocation];
    [geocoder cancel];
}

@end
