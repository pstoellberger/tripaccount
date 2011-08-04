//
//  EntryEditViewController.m
//  Reiseabrechnung
//
//  Created by Martin Maier on 30/06/2011.
//  Copyright 2011 Martin Maier. All rights reserved.
//

#import "EntryEditViewController.h"
#import "EditableTableViewCell.h"
#import "EntryNotManaged.h"
#import "GenericSelectViewController.h"
#import "ReiseabrechnungAppDelegate.h"
#import "AlignedStyle2Cell.h"
#import "TextEditViewController.h"
#import "NumberEditViewController.h"
#import "DateSelectViewController.h"
#import "TypeViewController.h"

static NSIndexPath *_payerIndexPath;
static NSIndexPath *_amountIndexPath;
static NSIndexPath *_currencyIndexPath;
static NSIndexPath *_receiverIndexPath;
static NSIndexPath *_descriptionIndexPath;
static NSIndexPath *_typeIndexPath;
static NSIndexPath *_dateIndexPath;

@interface EntryEditViewController () 

@property (nonatomic, retain) Entry *entryManaged;
@property (nonatomic, retain) EntryNotManaged *nmEntry;
@property (nonatomic, retain) Travel *travel;

- (void)selectPayer:(Participant *)payer;
- (void)selectCurrency:(Currency *)currency;
- (void)selectReceivers:(NSArray *)receivers;
- (void)checkIfDoneIsPossible;
- (void)initIndexPaths;

@end

@implementation EntryEditViewController

@synthesize entryManaged=_entryManaged, travel=_travel, nmEntry=_nmEntry;

// designated initializer!
- (id)initWithTravel: (Travel *)travel andEntry:(Entry *)entryManaged target:(id)target action:(SEL)selector {
    
    self = [super initWithStyle:UITableViewStyleGrouped];
    
    if (self) {
        
        [self initIndexPaths];
        
        _isFirstView = YES;
        
        _target = target;
        _selector = selector;
        
        _cellsToReloadAndFlash = [[[NSMutableArray alloc] init] retain];
        
        self.travel = travel;
        self.entryManaged = entryManaged;
        
        if (entryManaged) {
            self.nmEntry = [[[EntryNotManaged alloc] initWithEntry:entryManaged] autorelease];
        }
        
        self.tableView.backgroundColor = [UIColor clearColor];
        self.tableView.backgroundView = [UIFactory createBackgroundViewWithFrame:self.view.frame];
        
        [self checkIfDoneIsPossible];
    }
    return self;
}

- (id)initWithTravel: (Travel *)travel target:(id)target action:(SEL)selector {
    
    self = [self initWithTravel:travel andEntry:nil target:target action:selector];
    
    if (self) {
        
        if (!self.nmEntry) {
            
            self.nmEntry = [[[EntryNotManaged alloc] init] autorelease];
            
            if (travel.lastParticipantUsed) {
                self.nmEntry.payer = travel.lastParticipantUsed;
            } else {
                self.nmEntry.payer = [travel.participants anyObject];
            }
            
            if (travel.lastCurrencyUsed) {
                self.nmEntry.currency = travel.lastCurrencyUsed;
            } else {
                self.nmEntry.currency = [ReiseabrechnungAppDelegate defaultsObject:[travel managedObjectContext]].homeCurrency;
            }
            
            self.nmEntry.receivers = travel.participants;
            self.nmEntry.date = [UIFactory createDateWithoutTimeFromDate:[NSDate date]];
            self.nmEntry.type = [ReiseabrechnungAppDelegate defaultsObject:[travel managedObjectContext]].defaultType;
        }
        
        [self checkIfDoneIsPossible];
    }
    return self;
}



- (void)initIndexPaths {
    _payerIndexPath = [[NSIndexPath indexPathForRow:0 inSection:0] retain];
    _dateIndexPath = [[NSIndexPath indexPathForRow:0 inSection:1] retain];
    _descriptionIndexPath = [[NSIndexPath indexPathForRow:1 inSection:2] retain];
    _typeIndexPath = [[NSIndexPath indexPathForRow:0 inSection:2] retain];
    _amountIndexPath = [[NSIndexPath indexPathForRow:0 inSection:3] retain];
    _currencyIndexPath = [[NSIndexPath indexPathForRow:1 inSection:3] retain];
    _receiverIndexPath = [[NSIndexPath indexPathForRow:0 inSection:4] retain];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 5;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    switch(section) {
        case 0: return 1;
        case 1: return 1;
        case 2: return 2;
        case 3: return 2;
        case 4: return 1;
    }
    return 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    UITableViewCell *cell = nil;
    
    if ([indexPath isEqual:_payerIndexPath]) {
        
        cell = [[[AlignedStyle2Cell alloc] initWithStyle:UITableViewCellStyleValue2 reuseIdentifier:@"AlignedStyle2Cell"] autorelease];
        cell.textLabel.text = @"Payer";
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        cell.detailTextLabel.text = nil;
        if (self.nmEntry.payer) {
            cell.detailTextLabel.text = [NSString stringWithFormat:@"%@", self.nmEntry.payer.name];
        }
        
    } else if ([indexPath isEqual:_amountIndexPath]) {

        cell = [[[AlignedStyle2Cell alloc] initWithStyle:UITableViewCellStyleValue2 reuseIdentifier:@"AlignedStyle2Cell"] autorelease];
        cell.textLabel.text = @"Amount";
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        cell.detailTextLabel.text = nil;
        
        if (self.nmEntry.amount) {
            if (self.nmEntry.currency) {
                cell.detailTextLabel.text = [NSString stringWithFormat:@"%.2f %@", [self.nmEntry.amount doubleValue], self.nmEntry.currency.code];
            } else {
                cell.detailTextLabel.text = [NSString stringWithFormat:@"%.2f", [self.nmEntry.amount doubleValue]];
            }
        }
        
    } else if ([indexPath isEqual:_dateIndexPath]) {
        
        cell = [[[AlignedStyle2Cell alloc] initWithStyle:UITableViewCellStyleValue2 reuseIdentifier:@"AlignedStyle2Cell"] autorelease];
        cell.textLabel.text = @"Date";
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        cell.detailTextLabel.text = nil;
        
        if (self.nmEntry.date) {
            NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
            formatter.dateStyle = NSDateFormatterMediumStyle;
            if ([UIFactory dateHasTime:self.nmEntry.date]) {
                formatter.timeStyle = NSDateFormatterShortStyle;
            }
            cell.detailTextLabel.text = [formatter stringFromDate:self.nmEntry.date];
            [formatter release];
        }
    } else if ([indexPath isEqual:_currencyIndexPath]) {
        
        cell = [[[AlignedStyle2Cell alloc] initWithStyle:UITableViewCellStyleValue2 reuseIdentifier:@"AlignedStyle2Cell"] autorelease];
        cell.textLabel.text = @"Currency";
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        cell.detailTextLabel.text = nil;
        if (self.nmEntry.currency) {
            cell.detailTextLabel.text = [NSString stringWithFormat:@"%@ (%@)", self.nmEntry.currency.name, self.nmEntry.currency.code];
        }
        
    } else if ([indexPath isEqual:_descriptionIndexPath]) {        

        cell = [[[AlignedStyle2Cell alloc] initWithStyle:UITableViewCellStyleValue2 reuseIdentifier:@"AlignedStyle2Cell"] autorelease];
        cell.textLabel.text = @"Description";
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        cell.detailTextLabel.text = self.nmEntry.text;
        
    } else if ([indexPath isEqual:_typeIndexPath]) {
        
        cell = [[[AlignedStyle2Cell alloc] initWithStyle:UITableViewCellStyleValue2 reuseIdentifier:@"AlignedStyle2Cell"] autorelease];
        cell.textLabel.text = @"Type";
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        cell.detailTextLabel.text = nil;
        if (self.nmEntry.type.name) {
            cell.detailTextLabel.text = [NSString stringWithFormat:@"%@", self.nmEntry.type.name];
        }

    } else if ([indexPath isEqual:_receiverIndexPath]) {
        
        cell = [[[AlignedStyle2Cell alloc] initWithStyle:UITableViewCellStyleValue2 reuseIdentifier:@"AlignedStyle2Cell"] autorelease];
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        cell.textLabel.text = @"Receiver";
        
        NSString *receiverString = @"";
        const unichar cr = '\n';
        NSString *singleCR = [NSString stringWithCharacters:&cr length:1];
        for (Participant *receiver in self.nmEntry.receivers) {
            receiverString = [[receiverString stringByAppendingString:receiver.name] stringByAppendingString:singleCR];
        }
        
        cell.detailTextLabel.text = [NSString stringWithFormat:@"%@\n", [receiverString stringByTrimmingCharactersInSet:[NSCharacterSet newlineCharacterSet]]];
        cell.detailTextLabel.numberOfLines = 0;
    }
    
    if (indexPath.row == [self tableView:tableView numberOfRowsInSection:indexPath.section] -1 ) {
        //[UIFactory addShadowToView:cell];
    }
    
    return cell;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if ([indexPath isEqual:_receiverIndexPath] && [self.nmEntry.receivers count] > 1) {
        return 40 + (([self.nmEntry.receivers count]-1) * 19.5);
    } else {
        return [UIFactory defaultCellHeight];
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if ([indexPath isEqual:_payerIndexPath]) {
        
        NSFetchRequest *_fetchRequest = [[[NSFetchRequest alloc] init] autorelease];
        _fetchRequest.entity = [NSEntityDescription entityForName:@"Participant" inManagedObjectContext:[self.travel managedObjectContext]];
        _fetchRequest.sortDescriptors = [NSArray arrayWithObject:[NSSortDescriptor sortDescriptorWithKey:@"name" ascending:YES selector:@selector(caseInsensitiveCompare:)]];
        _fetchRequest.predicate = [NSPredicate predicateWithFormat:@"travel = %@", self.travel];
        
        GenericSelectViewController *selectViewController = [[GenericSelectViewController alloc] initInManagedObjectContext:[self.travel managedObjectContext]
                                                                                                         withMultiSelection:NO
                                                                                                           withFetchRequest:_fetchRequest
                                                                                                        withSelectedObjects:[NSArray arrayWithObjects: self.nmEntry.payer, nil] 
                                                                                                                     target:self
                                                                                                                     action:@selector(selectPayer:)];
        selectViewController.imageKey = @"image";
        selectViewController.title = @"Payer";
        
        [self.navigationController pushViewController:selectViewController animated:YES];
        [selectViewController release];
        
    } else if ([indexPath isEqual:_amountIndexPath]) {
        
        NumberEditViewController *numberEditViewController = [[NumberEditViewController alloc] initWithNumber:self.nmEntry.amount currency:self.nmEntry.currency travel:self.travel target:self selector:@selector(selectAmount:)]; 
        numberEditViewController.title = @"Amount";
        [self.navigationController pushViewController:numberEditViewController animated:YES];
        [numberEditViewController release]; 
        
    } else if ([indexPath isEqual:_dateIndexPath]) {
        
        DateSelectViewController *dateSelectViewController = [[DateSelectViewController alloc] initWithDate:self.nmEntry.date target:self selector:@selector(selectDate:)]; 
        dateSelectViewController.title = @"Date";
        [self.navigationController pushViewController:dateSelectViewController animated:YES];
        [dateSelectViewController release]; 
        
    } else if ([indexPath isEqual:_currencyIndexPath]) {

        NSFetchRequest *_fetchRequest = [[[NSFetchRequest alloc] init] autorelease];
        _fetchRequest.entity = [NSEntityDescription entityForName:@"Currency" inManagedObjectContext: [self.travel managedObjectContext]];
        _fetchRequest.sortDescriptors = [NSArray arrayWithObject:[NSSortDescriptor sortDescriptorWithKey:@"name" ascending:YES selector:@selector(caseInsensitiveCompare:)]];
        _fetchRequest.predicate = [NSPredicate predicateWithFormat:@"travels contains %@", self.travel];
        
        GenericSelectViewController *selectViewController = [[GenericSelectViewController alloc] initInManagedObjectContext:[self.travel managedObjectContext]
                                                                                                         withMultiSelection:NO
                                                                                                           withFetchRequest:_fetchRequest 
                                                                                                        withSelectedObjects:[NSArray arrayWithObjects: self.nmEntry.currency, nil] 
                                                                                                                     target:self
                                                                                                                     action:@selector(selectCurrency:)];
        [self.navigationController pushViewController:selectViewController animated:YES];
        [selectViewController release];
        
    } else if ([indexPath isEqual:_descriptionIndexPath]) {
        
        TextEditViewController *textEditViewController = [[TextEditViewController alloc] initWithText:self.nmEntry.text target:self selector:@selector(selectText:)]; 
        textEditViewController.title = @"Description";
        [self.navigationController pushViewController:textEditViewController animated:YES];
        [textEditViewController release];    

    } else if ([indexPath isEqual:_typeIndexPath]) {
        
        NSFetchRequest *_fetchRequest = [[[NSFetchRequest alloc] init] autorelease];
        _fetchRequest.entity = [NSEntityDescription entityForName:@"Type" inManagedObjectContext: [self.travel managedObjectContext]];
        _fetchRequest.sortDescriptors = [NSArray arrayWithObject:[NSSortDescriptor sortDescriptorWithKey:@"name" ascending:YES selector:@selector(caseInsensitiveCompare:)]]; 
        
        TypeViewController *selectViewController = [[TypeViewController alloc] initInManagedObjectContext:[self.travel managedObjectContext]
                                                                                       withMultiSelection:NO
                                                                                         withFetchRequest:_fetchRequest 
                                                                                      withSelectedObjects:[NSArray arrayWithObjects: self.nmEntry.type ,nil] 
                                                                                                   target:self
                                                                                                   action:@selector(selectType:)];
        [self.navigationController pushViewController:selectViewController animated:YES];
        [selectViewController release];

    } else if ([indexPath isEqual:_receiverIndexPath]) {
        
        NSFetchRequest *_fetchRequest = [[[NSFetchRequest alloc] init] autorelease];
        _fetchRequest.entity = [NSEntityDescription entityForName:@"Participant" inManagedObjectContext:[self.travel managedObjectContext]];
        _fetchRequest.sortDescriptors = [NSArray arrayWithObject:[NSSortDescriptor sortDescriptorWithKey:@"name" ascending:YES selector:@selector(caseInsensitiveCompare:)]];
        _fetchRequest.predicate = [NSPredicate predicateWithFormat:@"travel = %@", self.travel];
        
        GenericSelectViewController *selectViewController = [[GenericSelectViewController alloc] initInManagedObjectContext:[self.travel managedObjectContext]
                                                                                                         withMultiSelection:YES
                                                                                                           withFetchRequest:_fetchRequest 
                                                                                                        withSelectedObjects:[self.nmEntry.receivers allObjects] 
                                                                                                                     target:self
                                                                                                                     action:@selector(selectReceivers:)];
        
        selectViewController.imageKey = @"image";
        selectViewController.title = @"Receivers";
        
        [self.navigationController pushViewController:selectViewController animated:YES];
        [selectViewController release];
    }
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

- (void)selectType:(Type *)type {
    self.nmEntry.type = type;
    [self checkIfDoneIsPossible];
    [_cellsToReloadAndFlash addObject:_typeIndexPath];
    
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)selectPayer:(Participant *)payer {
    self.nmEntry.payer = payer;
    [_cellsToReloadAndFlash addObject:_payerIndexPath];
    
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)selectAmount:(NSNumber *)amount {
    self.nmEntry.amount = amount;
    [_cellsToReloadAndFlash addObject:_amountIndexPath];
}

- (void)selectText:(NSString *)text {
    self.nmEntry.text = text;
    [_cellsToReloadAndFlash addObject:_descriptionIndexPath];
}

- (void)selectDate:(NSDate *)date {
    self.nmEntry.date = date;
    [_cellsToReloadAndFlash addObject:_dateIndexPath];
}

- (void)selectCurrency:(Currency *)currency {
    self.nmEntry.currency = currency;
    
    if (self.nmEntry.amount) {
        [_cellsToReloadAndFlash addObject:_amountIndexPath];
    }
    [_cellsToReloadAndFlash addObject:_currencyIndexPath];
    
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)selectReceivers:(NSArray *)receivers {
    self.nmEntry.receivers = [[[NSSet alloc] initWithArray:receivers] autorelease];
    [_cellsToReloadAndFlash addObject:_receiverIndexPath];
    
    [self.navigationController popViewControllerAnimated:YES];
}

- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath {
    return UITableViewCellEditingStyleInsert;
}

- (void)checkIfDoneIsPossible {
    if (self.nmEntry.amount <= 0) {
        self.navigationItem.rightBarButtonItem.enabled = NO;
    } else if (self.nmEntry.type) {
        self.navigationItem.rightBarButtonItem.enabled = YES;
    } else if ([[self.nmEntry.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]] length] > 0) {
        self.navigationItem.rightBarButtonItem.enabled = YES;
    } else {
        self.navigationItem.rightBarButtonItem.enabled = NO;
    }    
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

- (void)updateAndFlash:(UIViewController *)viewController {
    
    if (viewController == self) {
        
        [self checkIfDoneIsPossible];
        
        [self.tableView beginUpdates];
        for (id indexPath in _cellsToReloadAndFlash) {
            [self.tableView reloadRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
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

- (void)viewDidAppear:(BOOL)animated {
    
    if (!self.entryManaged && _isFirstView) {
        
        [_cellsToReloadAndFlash addObject:_payerIndexPath];
        [_cellsToReloadAndFlash addObject:_dateIndexPath];
        [_cellsToReloadAndFlash addObject:_typeIndexPath];
        [_cellsToReloadAndFlash addObject:_currencyIndexPath];
        [_cellsToReloadAndFlash addObject:_receiverIndexPath];
        
        [self updateAndFlash:self];
        _isFirstView = NO;
    }
}

#pragma mark - UINavigationControllerDelegate

- (void)navigationController:(UINavigationController *)navigationController didShowViewController:(UIViewController *)viewController animated:(BOOL)animated {
    [self updateAndFlash:viewController];
}

#pragma mark - View load/unload

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    self.navigationItem.leftBarButtonItem = [[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel target:self action:@selector(cancel:)] autorelease];
    if (self.entryManaged) {
        self.navigationItem.rightBarButtonItem = [[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(done:)] autorelease];
    } else {
        self.navigationItem.rightBarButtonItem = [[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemSave target:self action:@selector(done:)] autorelease];
    }
    
    [self checkIfDoneIsPossible];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}


#pragma mark - memory management

- (void)dealloc
{
    [_cellsToReloadAndFlash release];
    
    [super dealloc];
}

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

@end
