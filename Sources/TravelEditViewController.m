//
//  TravelEditViewController.m
//  Reiseabrechnung
//
//  Created by Martin Maier on 29/06/2011.
//  Copyright 2011 Martin Maier. All rights reserved.
//

#import "TravelEditViewController.h"
#import "Currency.h"
#import "TravelNotManaged.h"
#import "ReiseabrechnungAppDelegate.h"
#import "UIFactory.h"
#import "Country.h"
#import "GenericSelectViewController.h"
#import "ParticipantHelperCategory.h"
#import "CountryCell.h"
#import "TextEditViewController.h"
#import "AlignedStyle2Cell.h"
#import "ExchangeRate.h"

static NSIndexPath *_countryIndexPath;
static NSIndexPath *_cityIndexPath;
static NSIndexPath *_descriptionIndexPath;
static NSIndexPath *_currenciesIndexPath;

@interface TravelEditViewController ()
- (void)initIndexPaths;
- (void)updateAndFlash:(UIViewController *)viewController;
- (void)selectCity:(NSString *)newCity;
- (void)selectName:(NSString *)newName;
@end

@implementation TravelEditViewController

@synthesize name=_name, travel=_travel, country=_country, currencies=_currencies, city=_city;
@synthesize editDelegate=_editDelegate;


- (id) initInManagedObjectContext:(NSManagedObjectContext *)context {
    
    self = [self initInManagedObjectContext:context withTravel:nil];
    return self;
}

- (id) initInManagedObjectContext:(NSManagedObjectContext *)context withTravel:(Travel *)travel {
    
    self = [super initWithStyle:UITableViewStyleGrouped];
    
    _autoFillCanBeDone = travel == nil;
    
    if (self) {
        
        [self initIndexPaths];
        
        _isFirstView = YES;
        _cityWasAutoFilled = NO;
        
        _cellsToReloadAndFlash = [[[NSMutableSet alloc] init] retain];
        
        _context = context;
        
        [UIFactory initializeTableViewController:self.tableView];
        
        self.tableView.delegate = self;
        self.tableView.dataSource = self;
        
        self.navigationItem.leftBarButtonItem = [[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel target:self action:@selector(cancel:)] autorelease];
        
        self.travel = travel;
        
        if (self.travel) {
            self.navigationItem.rightBarButtonItem = [[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(done:)] autorelease];
            
            self.title = NSLocalizedString(@"Edit Trip", @"trip edit title");  
            
        } else {
            self.navigationItem.rightBarButtonItem = [[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemSave target:self action:@selector(done:)] autorelease];
            
            self.title = NSLocalizedString(@"Add Trip", @"trip add title");  
            
        }
        
        self.tableView.backgroundColor = [UIColor clearColor];
        self.tableView.backgroundView = [UIFactory createBackgroundViewWithFrame:self.view.frame];
        
        if (!travel) {
            
            self.currencies = [NSArray arrayWithObject:[ReiseabrechnungAppDelegate defaultsObject:context].homeCurrency];
            [_cellsToReloadAndFlash addObject:_currenciesIndexPath];
            self.name = @"";
            self.city = @"";
            self.country = nil;
            
            // init location here
            Locator *locator = ((ReiseabrechnungAppDelegate *) [[UIApplication sharedApplication] delegate]).locator;
            locator.locationDelegate = self;
            [locator startLocating];
            
        } else {

            self.name = travel.name;
            self.city = travel.city;
            self.country = travel.country;
            self.currencies = [travel.currencies allObjects];
        }
    }
    return self;
}

- (void)initIndexPaths {
    _descriptionIndexPath = [[NSIndexPath indexPathForRow:0 inSection:0] retain];
    _countryIndexPath = [[NSIndexPath indexPathForRow:0 inSection:1] retain];
    _cityIndexPath = [[NSIndexPath indexPathForRow:1 inSection:1] retain];
    _currenciesIndexPath = [[NSIndexPath indexPathForRow:2 inSection:1] retain];
}


- (void)updateAndFlash:(UIViewController *)viewController {
    
    if (viewController == self && _viewAppeared) {
        
        [self.tableView beginUpdates];
        for (id indexPath in _cellsToReloadAndFlash) {
            [self.tableView reloadRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationNone];
        }
        [self.tableView endUpdates];
        
        for (id indexPath in _cellsToReloadAndFlash) {
            [self.tableView selectRowAtIndexPath:indexPath animated:YES scrollPosition:UITableViewScrollPositionNone];
            [self.tableView deselectRowAtIndexPath:indexPath animated:YES];                  
        }
        [_cellsToReloadAndFlash removeAllObjects];
    }
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    return YES;
}

#pragma mark UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    switch (section) {
        case 0: return 1;
        case 1: return 3;
    }
    return 0;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    return nil;    
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    UITableViewCell *cell = nil;
    
    if ([indexPath isEqual:_countryIndexPath]) {
        
        cell = [[[AlignedStyle2Cell alloc] initWithStyle:UITableViewCellStyleValue2 reuseIdentifier:nil] autorelease];
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        cell.textLabel.text = NSLocalizedString(@"Country", @"country cell caption");
        if (self.country) {
            cell.detailTextLabel.text = [NSString stringWithFormat:@"%@", self.country.nameI18N];
            if (self.country.image) {
                NSString *pathCountryPlist =[[NSBundle mainBundle] pathForResource:self.country.image ofType:@""];
                cell.imageView.image = [UIImage imageWithContentsOfFile:pathCountryPlist];                       
            }
        }
        
    } else if ([indexPath isEqual:_cityIndexPath]) {
                
        cell = [[[AlignedStyle2Cell alloc] initWithStyle:UITableViewCellStyleValue2 reuseIdentifier:nil] autorelease];
        cell.textLabel.text = NSLocalizedString(@"City/State", @"city cell caption");
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        cell.detailTextLabel.text = self.city;
        
    } else if ([indexPath isEqual:_descriptionIndexPath]) {
        
        cell = [[[AlignedStyle2Cell alloc] initWithStyle:UITableViewCellStyleValue2 reuseIdentifier:nil] autorelease];
        cell.textLabel.text = NSLocalizedString(@"Description", @"description cell caption");
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        cell.detailTextLabel.text = self.name;

    } else if ([indexPath isEqual:_currenciesIndexPath]) {
        
        cell = [[[AlignedStyle2Cell alloc] initWithStyle:UITableViewCellStyleValue2 reuseIdentifier:nil] autorelease];
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        cell.textLabel.text = NSLocalizedString(@"Currencies", @"currencies cell caption");
        
        NSString *currenciesString = @"";
        const unichar cr = '\n';
        NSString *singleCR = [NSString stringWithCharacters:&cr length:1];
        for (Currency *currency in self.currencies) {
            currenciesString = [[currenciesString stringByAppendingString:currency.nameI18N] stringByAppendingString:singleCR];
        }
        
        cell.detailTextLabel.text = [NSString stringWithFormat:@"%@\n", [currenciesString stringByTrimmingCharactersInSet:[NSCharacterSet newlineCharacterSet]]];
        cell.detailTextLabel.numberOfLines = 0;

    } else {
        NSLog(@"no indexpath cell found for %@ ", indexPath);
    }
    
    return cell;
}

- (NSString *)tableView:(UITableView *)tableView titleForDeleteConfirmationButtonForRowAtIndexPath:(NSIndexPath *)indexPath {
    return NSLocalizedString(@"Clear", @"caption of red delete button to clear");
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    return (indexPath == _cityIndexPath || indexPath == _descriptionIndexPath);  
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (indexPath == _cityIndexPath) {
        
        self.city = @"";
        [self.tableView reloadRowsAtIndexPaths:[NSArray arrayWithObject:_cityIndexPath] withRowAnimation:UITableViewRowAnimationNone];
        
    } else if (indexPath == _descriptionIndexPath) {
        
        self.name = @"";
        [self.tableView reloadRowsAtIndexPaths:[NSArray arrayWithObject:_descriptionIndexPath] withRowAnimation:UITableViewRowAnimationNone];
    }
    
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if ([indexPath isEqual:_currenciesIndexPath] && [self.currencies count] > 1) {
        return 40 + (([self.currencies count]-1) * 19.5);
    } else {
        return [UIFactory defaultCellHeight];
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    _autoFillCanBeDone = NO;
    
    if ([indexPath isEqual:_countryIndexPath]) {
        
        NSFetchRequest *_fetchRequest = [[[NSFetchRequest alloc] init] autorelease];
        _fetchRequest.entity = [NSEntityDescription entityForName:@"Country" inManagedObjectContext: _context];
        _fetchRequest.sortDescriptors = [NSArray arrayWithObject:[NSSortDescriptor sortDescriptorWithKey:[Country sortAttributeI18N] ascending:YES]];
        
        GenericSelectViewController *selectViewController = [[GenericSelectViewController alloc] initInManagedObjectContext:_context
                                                                                                         withMultiSelection:NO
                                                                                                         withAllNoneButtons:NO
                                                                                                           withFetchRequest:_fetchRequest 
                                                                                                             withSectionKey:@"uppercaseFirstLetterOfName"
                                                                                                        withSelectedObjects:[NSArray arrayWithObjects:self.country, nil]
                                                                                                                     target:self
                                                                                                                     action:@selector(selectCountry:)];
        selectViewController.imageKey = @"image";
        selectViewController.titleKey = [Country sortAttributeI18N];
        selectViewController.searchKey = [Country sortAttributeI18N];
        selectViewController.title = NSLocalizedString(@"Country", "controller title");
        
        [self.navigationController pushViewController:selectViewController animated:YES];
        [selectViewController release];
        
    } else if ([indexPath isEqual:_cityIndexPath]) {
        
        TextEditViewController *textEditViewController = [[TextEditViewController alloc] initWithText:self.city target:self selector:@selector(selectCity:)]; 
        textEditViewController.title = NSLocalizedString(@"City/State", @"edit city title");
        [self.navigationController pushViewController:textEditViewController animated:YES];
        [textEditViewController release];            
        
        
    } else if ([indexPath isEqual:_descriptionIndexPath]) {
        
        TextEditViewController *textEditViewController = [[TextEditViewController alloc] initWithText:self.name target:self selector:@selector(selectName:)]; 
        textEditViewController.title = NSLocalizedString(@"Description", @"edit description title");
        [self.navigationController pushViewController:textEditViewController animated:YES];
        [textEditViewController release];
        
    } else if ([indexPath isEqual:_currenciesIndexPath]) {
        
        NSFetchRequest *_fetchRequest = [[[NSFetchRequest alloc] init] autorelease];
        _fetchRequest.entity = [NSEntityDescription entityForName:@"Currency" inManagedObjectContext: _context];
        _fetchRequest.sortDescriptors = [NSArray arrayWithObject:[NSSortDescriptor sortDescriptorWithKey:[Currency sortAttributeI18N] ascending:YES]]; 
        
        GenericSelectViewController *selectViewController = [[GenericSelectViewController alloc] initInManagedObjectContext:_context
                                                                                                         withMultiSelection:YES
                                                                                                         withAllNoneButtons:NO
                                                                                                           withFetchRequest:_fetchRequest
                                                                                                             withSectionKey:@"uppercaseFirstLetterOfName"
                                                                                                        withSelectedObjects:self.currencies
                                                                                                                     target:self
                                                                                                                     action:@selector(selectCurrencies:)];
        selectViewController.searchKey = [Currency sortAttributeI18N];
        selectViewController.searchKeyAlternative = @"code";
        selectViewController.titleKey = @"fullName";
        selectViewController.title = NSLocalizedString(@"Currencies", "controller title");
        [self.navigationController pushViewController:selectViewController animated:YES];
        [selectViewController release];
    }
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

#pragma mark UINavigationControllerDelegate

- (void)navigationController:(UINavigationController *)navigationController didShowViewController:(UIViewController *)viewController animated:(BOOL)animated {
    [self updateAndFlash:self];
}

#pragma mark Select Items

- (void)selectCurrencies:(NSArray *)newCurrencies {
    
    NSMutableSet *addCurrArray = [NSMutableSet set];
    for (Entry *entry in self.travel.entries) {
        if (![newCurrencies containsObject:entry.currency]) {
            [addCurrArray addObject:entry.currency];
        }
    }
    
    if ([addCurrArray count] > 0) {
        
        NSString *message = NSLocalizedString(@"currency can be removed", @"alert when when chaning travel");
        UIAlertView *alertView = [[[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Warning", @"alert title") message:message delegate:self cancelButtonTitle:NSLocalizedString(@"Cancel", @"alert item") otherButtonTitles:NSLocalizedString(@"OK", @"alert item"), nil] autorelease];
        [alertView show];
        
        newCurrencies = [newCurrencies arrayByAddingObjectsFromArray:[addCurrArray allObjects]];
    }
    
    if (![newCurrencies isEqual:self.currencies]) {
        self.currencies = [Currency sortCurrencies:newCurrencies inManagedObjectContext:_context];
        [_cellsToReloadAndFlash addObject:_currenciesIndexPath];
    }
    
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)selectCountry:(Country *)newCountry {
    
    if (![newCountry isEqual:self.country]) {
        
        NSMutableArray *newCurrencies = [NSMutableArray arrayWithArray:self.currencies];
        
        if (self.country) {
            // remove old currencies
            for (Currency *currency in [self.country.currencies allObjects]) {
                if (![newCountry.currencies containsObject:currency] && [newCurrencies containsObject:currency] && ![currency isEqual:[ReiseabrechnungAppDelegate defaultCurrency:_context]]) {
                    [newCurrencies removeObject:currency];
                }
            }
        }
        
        // add new
        for (Currency *currency in [newCountry.currencies allObjects]) {
            if (![newCurrencies containsObject:currency]) {
                [newCurrencies addObject:currency];
            }
        }
        
        self.country = newCountry;
        [_cellsToReloadAndFlash addObject:_countryIndexPath];
        
        if (![newCurrencies isEqualToArray:self.currencies]) {
            self.currencies = newCurrencies;
            [_cellsToReloadAndFlash addObject:_currenciesIndexPath];
        }
        
        if (_cityWasAutoFilled) {
            [self selectCity:@""];
        }
    }
    
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)selectName:(NSString *)newName {
    
    if (![newName isEqualToString:self.name]) {
        self.name = newName;
        [self.tableView reloadRowsAtIndexPaths:[NSArray arrayWithObject:_descriptionIndexPath] withRowAnimation:UITableViewRowAnimationFade];
        
        if (!self.country && [newName length] > 0) {
            NSFetchRequest *req = [[NSFetchRequest alloc] init];
            req.entity = [NSEntityDescription entityForName:@"Country" inManagedObjectContext: _context];
            req.sortDescriptors = [NSArray arrayWithObject:[NSSortDescriptor sortDescriptorWithKey:[Country sortAttributeI18N] ascending:YES]];
            NSArray *countrySet = [_context executeFetchRequest:req error:nil];
            [req release];
            
            NSArray *nameComponents = [[[newName lowercaseString] componentsSeparatedByString:@" "] arrayByAddingObject:[newName lowercaseString]];
            for (NSString* nameComponent in nameComponents) {
                if ([nameComponent length] >= 3) {
                    for (Country* country in countrySet) {
                        if ([nameComponent isEqual:[country.name lowercaseString]]) {
                            [self selectCountry:country];
                            return;
                        }
                    }
                }
            }
        }
        [_cellsToReloadAndFlash addObject:_descriptionIndexPath];
    }
}

- (void)selectCity:(NSString *)newCity {
    
    if (![newCity isEqualToString:self.city]) {
        
        self.city = newCity;
        
        _cityWasAutoFilled = NO;
        
        [_cellsToReloadAndFlash addObject:_cityIndexPath];
    }
}

- (IBAction)done:(UIBarButtonItem *)sender {
    
    BOOL newTravel = !self.travel;
    
    if (newTravel) {
        self.travel = [NSEntityDescription insertNewObjectForEntityForName: @"Travel" inManagedObjectContext:_context];
        self.travel.displayCurrency = [self.currencies objectAtIndex:0];
    }
    
    self.travel.name = self.name;
    self.travel.country = self.country;
    self.travel.city = self.city;
    self.travel.closed = [NSNumber numberWithInt:0];
    self.travel.currencies = [[[NSSet alloc] initWithArray:self.currencies] autorelease];
    
    if ([self.travel.currencies containsObject:self.travel.lastCurrencyUsed]) {
        self.travel.lastCurrencyUsed = [self.currencies objectAtIndex:0]; 
    }
    if ([self.travel.currencies containsObject:self.travel.displayCurrency]) {
        self.travel.displayCurrency = [self.currencies objectAtIndex:0]; 
    }
    

    
    NSMutableArray *ratesToDelete = [NSMutableArray arrayWithArray:[self.travel.rates allObjects]];
    for (Currency *currency in self.currencies) {
        BOOL rateFound = NO;
        for (ExchangeRate *rate in self.travel.rates) {
            if (rate.counterCurrency == currency) {
                [ratesToDelete removeObject:rate];
                rateFound = YES;
                break;
            }
        }
        if (!rateFound) {
            [self.travel addRatesObject:currency.defaultRate];
        }
    }
    [self.travel removeRates:[NSSet setWithArray:ratesToDelete]];
    
    if (newTravel) {
        ABAddressBookRef addressBook = ABAddressBookCreate();
        
        if (addressBook) {
            
            NSString *deviceName = [[UIDevice currentDevice] name];
            NSRange range = [deviceName rangeOfString:@"s iPhone"];
            
            NSString *userName = nil;
            if (range.location > 1 && range.length > 0) {
                userName = [deviceName substringToIndex:range.location - 1];
            }
            
            // to honour my first customer
            if ([deviceName isEqualToString:@"black pussy"]) {
                userName = @"Simon Pucher";
            } 
            
            if (userName) {
                NSArray *martinPerson = (NSArray *) ABAddressBookCopyPeopleWithName(addressBook, (CFStringRef) userName);
                if ([martinPerson lastObject]) {
                    Participant *newPerson = [NSEntityDescription insertNewObjectForEntityForName: @"Participant" inManagedObjectContext: [_travel managedObjectContext]];
                    newPerson.yourself = [NSNumber numberWithInt:1];
                    [Participant addParticipant:newPerson toTravel:_travel withABRecord:[martinPerson lastObject]];
                }
                [martinPerson release];
            }
            
            CFRelease(addressBook);
        }
    }
    
    [ReiseabrechnungAppDelegate saveContext:_context];
    
    [self dismissModalViewControllerAnimated:YES];
    
    [self.editDelegate travelEditFinished:self.travel wasSaved:YES];
}

- (IBAction)cancel:(UIBarButtonItem *)sender {
    self.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
    [self dismissModalViewControllerAnimated:YES];
    
    [self.editDelegate travelEditFinished:self.travel wasSaved:NO];
}

- (void)checkIfDoneIsPossible {
    
    if ([self.currencies count] > 0 && (self.country || [self.name length] > 0)) {
        self.navigationItem.rightBarButtonItem.enabled = YES;
    } else {
        self.navigationItem.rightBarButtonItem.enabled = NO;
    }    
}

#pragma mark LocatorDelegate

- (void)locationAquired:(Country *)country city:(NSString *)city {
    
    if (_autoFillCanBeDone) {
        
        int cellsToFlash = [_cellsToReloadAndFlash count];
        
        [self selectCountry:country];
        
        if (![city isEqualToString:country.name]) {
            [self selectCity:city];
            _cityWasAutoFilled = YES;  
        }
        
        // trigger flash only if the new cells are the only ones
        // if there are cell to be flashed, updateAndFlash will be called anyway
        if (cellsToFlash == 0) {
            [self updateAndFlash:self];
        }
        
        [self checkIfDoneIsPossible];
    }
    
}

#pragma mark - View lifecycle

- (void)viewDidAppear:(BOOL)animated {
    
    _viewAppeared = YES;
    
    NSString *text = NSLocalizedString(@"help currencies", @"help bubble currencies enter");
    HelpView *helpView = [[HelpView alloc] initWithFrame:CGRectMake(240, 192, 50, 50) text:text arrowPosition:ARROWPOSITION_TOP_RIGHT enterStage:ENTER_STAGE_FROM_BOTTOM uniqueIdentifier:@"trip currency edit"];
    [UIFactory addHelpViewToView:helpView toView:self.view];
    [helpView release];
    
    if (!self.travel && _isFirstView) {
        [self updateAndFlash:self];
        _isFirstView = NO;
    }
}

- (void)viewWillAppear:(BOOL)animated {
    
    [self checkIfDoneIsPossible];
}

#pragma mark - Memory Management

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (void)dealloc {
    
    [_cellsToReloadAndFlash release];
    
    [super dealloc];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
}

@end
