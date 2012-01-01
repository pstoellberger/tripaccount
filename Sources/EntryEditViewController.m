//
//  EntryEditViewController.m
//  Reiseabrechnung
//
//  Created by Martin Maier on 30/06/2011.
//  Copyright 2011 Martin Maier. All rights reserved.
//

#import "EntryEditViewController.h"
#import "EntryNotManaged.h"
#import "GenericSelectViewController.h"
#import "ReiseabrechnungAppDelegate.h"
#import "AlignedStyle2Cell.h"
#import "TextEditViewController.h"
#import "NumberEditViewController.h"
#import "DateSelectViewController.h"
#import "TypeViewController.h"
#import "ParticipantSelectViewController.h"
#import "ReceiverWeightNotManaged.h"
#import "ReceiverWeight.h"

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
@synthesize editDelegate=_editDelegate;

// designated initializer!
- (id)initWithTravel:(Travel *)travel andEntry:(Entry *)entryManaged {
    
    self = [super initWithStyle:UITableViewStyleGrouped];
    
    if (self) {
        
        [self initIndexPaths];
        
        _isFirstView = YES;
        
        _cellsToReloadAndFlash = [[[NSMutableArray alloc] init] retain];
        
        self.travel = travel;
        self.entryManaged = entryManaged;
        
        if (entryManaged) {
            self.nmEntry = [[[EntryNotManaged alloc] initWithEntry:entryManaged] autorelease];
            self.nmEntry.travel = travel;
            
            NSMutableSet *recWeightsNM = [NSMutableSet setWithCapacity:travel.participants.count];
            
            for (Participant *participant in travel.participants) {
                ReceiverWeightNotManaged *recWeightNM = [[ReceiverWeightNotManaged alloc] initWithParticiant:participant andWeight:participant.weight];
                recWeightNM.active = NO;
                
                for (ReceiverWeight *recWeight in entryManaged.receiverWeights) {
                    if ([recWeight.participant isEqual:participant]) {
                        recWeightNM.weight = recWeightNM.weight;
                        recWeightNM.active = YES;
                        break;
                    }
                }
                [recWeightsNM addObject:recWeightNM];
                [recWeightNM release];
            }
            self.nmEntry.receiverWeights = recWeightsNM;
        }
        
        self.tableView.backgroundColor = [UIColor clearColor];
        self.tableView.backgroundView = [UIFactory createBackgroundViewWithFrame:self.view.frame];
        
        self.navigationItem.backBarButtonItem = [[[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"Back",@"plain button")
                                          style:UIBarButtonItemStyleBordered
                                         target:nil
                                         action:nil] autorelease];

        
        [self checkIfDoneIsPossible];
    }
    return self;
}

- (id)initWithTravel: (Travel *)travel {
    
    self = [self initWithTravel:travel andEntry:nil];
    
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
                if ([travel.currencies count] == 1) {
                    self.nmEntry.currency = [travel.currencies anyObject];
                } else {
                    for (Currency *currency in travel.currencies) {
                        if (![currency isEqual:[ReiseabrechnungAppDelegate defaultCurrency:[travel managedObjectContext]]]) {
                            self.nmEntry.currency = currency;
                            break;
                        }
                    }
                }
            }
            
            // Create default ReceiverWeights
            NSMutableSet *recWeightNM = [NSMutableSet setWithCapacity:travel.participants.count];
            for (Participant *participant in travel.participants) {
                ReceiverWeightNotManaged *newRecWeight = [[ReceiverWeightNotManaged alloc] initWithParticiant:participant andWeight:participant.weight];
                [recWeightNM addObject:newRecWeight];
                [newRecWeight release];
            }
            self.nmEntry.receiverWeights = recWeightNM;
            
            self.nmEntry.date = [UIFactory createDateWithoutTimeFromDate:[NSDate date]];
        }
        
        [self checkIfDoneIsPossible];
    }
    return self;
}



- (void)initIndexPaths {
    _payerIndexPath = [[NSIndexPath indexPathForRow:0 inSection:0] retain];
    _dateIndexPath = [[NSIndexPath indexPathForRow:1 inSection:0] retain];
    _descriptionIndexPath = [[NSIndexPath indexPathForRow:2 inSection:0] retain];
    _typeIndexPath = [[NSIndexPath indexPathForRow:3 inSection:0] retain];
    _amountIndexPath = [[NSIndexPath indexPathForRow:4 inSection:0] retain];
    _currencyIndexPath = [[NSIndexPath indexPathForRow:5 inSection:0] retain];
    _receiverIndexPath = [[NSIndexPath indexPathForRow:6 inSection:0] retain];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 7;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    UITableViewCell *cell = nil;
    
    if ([indexPath isEqual:_payerIndexPath]) {
        
        cell = [[[AlignedStyle2Cell alloc] initWithStyle:UITableViewCellStyleValue2 reuseIdentifier:@"AlignedStyle2Cell" andNamedImage:@"user1.png"] autorelease];
        cell.textLabel.text = NSLocalizedString(@"Payer", @"cell title payer");
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        cell.detailTextLabel.text = nil;
        if (self.nmEntry.payer) {
            cell.detailTextLabel.text = [NSString stringWithFormat:@"%@", self.nmEntry.payer.name];
        }
        
    } else if ([indexPath isEqual:_amountIndexPath]) {

        cell = [[[AlignedStyle2Cell alloc] initWithStyle:UITableViewCellStyleValue2 reuseIdentifier:@"AlignedStyle2Cell" andNamedImage:@"wallet_open.png"] autorelease];
        cell.textLabel.text = NSLocalizedString(@"Amount", @"cell title amount");
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        cell.detailTextLabel.text = nil;
        
        if (self.nmEntry.amount) {
            if (self.nmEntry.currency) {
                cell.detailTextLabel.text = [NSString stringWithFormat:@"%@ %@", [UIFactory formatNumber:self.nmEntry.amount], self.nmEntry.currency.code];
            } else {
                cell.detailTextLabel.text = [UIFactory formatNumber:self.nmEntry.amount];
            }
        }
        
    } else if ([indexPath isEqual:_dateIndexPath]) {
        
        cell = [[[AlignedStyle2Cell alloc] initWithStyle:UITableViewCellStyleValue2 reuseIdentifier:@"AlignedStyle2Cell" andNamedImage:@"date-time.png"] autorelease];
        cell.textLabel.text = NSLocalizedString(@"Date", @"cell title date");
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
        
        cell = [[[AlignedStyle2Cell alloc] initWithStyle:UITableViewCellStyleValue2 reuseIdentifier:@"AlignedStyle2Cell" andNamedImage:@"money2.png"] autorelease];
        cell.textLabel.text = NSLocalizedString(@"Currency", @"cell title currency");
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        cell.detailTextLabel.text = nil;
        if (self.nmEntry.currency) {
            cell.detailTextLabel.text = [NSString stringWithFormat:@"%@ (%@)", self.nmEntry.currency.nameI18N, self.nmEntry.currency.code];
        }
        
    } else if ([indexPath isEqual:_descriptionIndexPath]) {        

        cell = [[[AlignedStyle2Cell alloc] initWithStyle:UITableViewCellStyleValue2 reuseIdentifier:@"AlignedStyle2Cell" andNamedImage:@"pencil.png"] autorelease];
        cell.textLabel.text = NSLocalizedString(@"Description", @"cell title description");
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        cell.detailTextLabel.text = self.nmEntry.text;
        
    } else if ([indexPath isEqual:_typeIndexPath]) {
        
        cell = [[[AlignedStyle2Cell alloc] initWithStyle:UITableViewCellStyleValue2 reuseIdentifier:@"AlignedStyle2Cell" andNamedImage:@"components.png"] autorelease];
        cell.textLabel.text = NSLocalizedString(@"Type", @"cell title type");
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        cell.detailTextLabel.text = nil;
        if (self.nmEntry.type) {
            cell.detailTextLabel.text = [NSString stringWithFormat:@"%@", self.nmEntry.type.nameI18N];
        }

    } else if ([indexPath isEqual:_receiverIndexPath]) {
        
        cell = [[[AlignedStyle2Cell alloc] initWithStyle:UITableViewCellStyleValue2 reuseIdentifier:@"AlignedStyle2Cell" andNamedImage:@"users_into.png"] autorelease];
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        cell.textLabel.text = NSLocalizedString(@"Receiver", @"cell title receiver");
        
        NSString *receiverString = @"";
        const unichar cr = '\n';
        NSString *singleCR = [NSString stringWithCharacters:&cr length:1];
        for (ReceiverWeightNotManaged *recWeights in self.nmEntry.receiverWeights) {
            if (recWeights.active) {
                receiverString = [[receiverString stringByAppendingString:recWeights.participant.name] stringByAppendingString:singleCR];
            }
        }
        
        cell.detailTextLabel.text = [NSString stringWithFormat:@"%@\n", [receiverString stringByTrimmingCharactersInSet:[NSCharacterSet newlineCharacterSet]]];
        cell.detailTextLabel.numberOfLines = 0;
    }
    
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSArray *activeReceiverWeights = [self.nmEntry activeReceiverWeights];
    if ([indexPath isEqual:_receiverIndexPath] && [activeReceiverWeights count] > 1) {
        return 40 + (([activeReceiverWeights count]-1) * 19.5);
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
        selectViewController.title = NSLocalizedString(@"Payer", @"controller title payer");
        
        [self.navigationController pushViewController:selectViewController animated:YES];
        [selectViewController release];
        
    } else if ([indexPath isEqual:_amountIndexPath]) {
        
        NumberEditViewController *numberEditViewController = [[NumberEditViewController alloc] initWithNumber:self.nmEntry.amount withDecimals:2 currency:self.nmEntry.currency travel:self.travel andNamedImage:@"wallet_open.png" description:nil target:self selector:@selector(selectAmount:)]; 
        numberEditViewController.title = NSLocalizedString(@"Amount", @"controller title amount");
        [self.navigationController pushViewController:numberEditViewController animated:YES];
        [numberEditViewController release]; 
        
    } else if ([indexPath isEqual:_dateIndexPath]) {
        
        DateSelectViewController *dateSelectViewController = [[DateSelectViewController alloc] initWithDate:self.nmEntry.date target:self selector:@selector(selectDate:)]; 
        dateSelectViewController.title = NSLocalizedString(@"Date", @"controller title date");
        [self.navigationController pushViewController:dateSelectViewController animated:YES];
        [dateSelectViewController release]; 
        
    } else if ([indexPath isEqual:_currencyIndexPath]) {

        NSFetchRequest *_fetchRequest = [[[NSFetchRequest alloc] init] autorelease];
        _fetchRequest.entity = [NSEntityDescription entityForName:@"Currency" inManagedObjectContext: [self.travel managedObjectContext]];
        _fetchRequest.sortDescriptors = [NSArray arrayWithObject:[NSSortDescriptor sortDescriptorWithKey:[Currency sortAttributeI18N] ascending:YES selector:@selector(caseInsensitiveCompare:)]];
        _fetchRequest.predicate = [NSPredicate predicateWithFormat:@"travels contains %@", self.travel];
        
        GenericSelectViewController *selectViewController = [[GenericSelectViewController alloc] initInManagedObjectContext:[self.travel managedObjectContext]
                                                                                                         withMultiSelection:NO
                                                                                                           withFetchRequest:_fetchRequest 
                                                                                                        withSelectedObjects:[NSArray arrayWithObjects: self.nmEntry.currency, nil] 
                                                                                                                     target:self
                                                                                                                     action:@selector(selectCurrency:)];
        selectViewController.title = NSLocalizedString(@"Currency", @"controller title");
        [self.navigationController pushViewController:selectViewController animated:YES];
        [selectViewController release];
        
    } else if ([indexPath isEqual:_descriptionIndexPath]) {
        
        TextEditViewController *textEditViewController = [[TextEditViewController alloc] initWithText:self.nmEntry.text target:self selector:@selector(selectText:)]; 
        textEditViewController.title = NSLocalizedString(@"Description", @"controller title description");
        [self.navigationController pushViewController:textEditViewController animated:YES];
        [textEditViewController release];    

    } else if ([indexPath isEqual:_typeIndexPath]) {
        
        TypeViewController *selectViewController = [[TypeViewController alloc] initInManagedObjectContext:[self.travel managedObjectContext]
                                                                                       withMultiSelection:NO
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
        
        NSMutableArray *selectedParticipants = [NSMutableArray arrayWithCapacity:self.nmEntry.receiverWeights.count];
        for (ReceiverWeightNotManaged *recWeightNM in self.nmEntry.receiverWeights) {
            if (recWeightNM.active) {
                [selectedParticipants addObject:recWeightNM.participant];
            }
        }
        
        ParticipantSelectViewController *selectViewController = [[ParticipantSelectViewController alloc] initInManagedObjectContext:[self.travel managedObjectContext] 
                                                                                                                          withEntry:self.nmEntry
                                                                                                                   withFetchRequest:_fetchRequest 
                                                                                                           withSelectedParticipants:selectedParticipants
                                                                                                                             target:self
                                                                                                                             action:@selector(selectReceivers:)];
        
        selectViewController.imageKey = @"image";
        selectViewController.title = NSLocalizedString(@"Receivers", @"controller title receivers");
        
        [self.navigationController pushViewController:selectViewController animated:YES];
        [selectViewController release];
    }
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

- (NSString *)tableView:(UITableView *)tableView titleForDeleteConfirmationButtonForRowAtIndexPath:(NSIndexPath *)indexPath {
    return NSLocalizedString(@"Clear", @"remove button clear cell");
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    return [indexPath isEqual:_descriptionIndexPath];  
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if ([indexPath isEqual:_descriptionIndexPath]) {
        self.nmEntry.text = @"";
        [self.tableView reloadRowsAtIndexPaths:[NSArray arrayWithObject:_descriptionIndexPath] withRowAnimation:[UIFactory commitEditingStyleRowAnimation]];
    }
}

- (void)checkIfDoneIsPossible {
    
    if (self.nmEntry.amount <= 0 || !self.nmEntry.payer) {
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
    
    [self.editDelegate addOrEditEntryWithParameters:self.nmEntry andEntry:self.entryManaged];
    [self dismissModalViewControllerAnimated:YES];
}

- (IBAction)cancel:(UIBarButtonItem *)sender {
    
    self.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
    [self dismissModalViewControllerAnimated:YES];
    
    NSLog(@"%@",self.entryManaged);
    [self.editDelegate editWasCanceled:self.entryManaged];
}

- (void)updateAndFlash:(UIViewController *)viewController {
    
    if (viewController == self) {
        
        [self checkIfDoneIsPossible];
        
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

- (void)viewDidAppear:(BOOL)animated {
    
    if (!self.entryManaged && _isFirstView) {
        
        [_cellsToReloadAndFlash addObject:_payerIndexPath];
        [_cellsToReloadAndFlash addObject:_dateIndexPath];
        [_cellsToReloadAndFlash addObject:_currencyIndexPath];
        [_cellsToReloadAndFlash addObject:_receiverIndexPath];
        
        [self updateAndFlash:self];
        _isFirstView = NO;
    }
}

#pragma mark Select methods

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

- (void)selectReceivers:(NSArray *)receiverWeights {
    
    [_cellsToReloadAndFlash addObject:_receiverIndexPath];
    
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark - UINavigationControllerDelegate

- (void)navigationController:(UINavigationController *)navigationController didShowViewController:(UIViewController *)viewController animated:(BOOL)animated {
    [self updateAndFlash:viewController];
}

#pragma mark - View load/unload

- (void)viewDidLoad {
    
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    self.navigationItem.leftBarButtonItem = [[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel target:self action:@selector(cancel:)] autorelease];
    if (self.entryManaged) {
        self.navigationItem.rightBarButtonItem = [[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(done:)] autorelease];
        self.title = NSLocalizedString(@"Edit Expense", @"entry edit title");  
        
    } else {
        self.navigationItem.rightBarButtonItem = [[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemSave target:self action:@selector(done:)] autorelease];
        self.title = NSLocalizedString(@"Add Expense", @"entry add title"); 
        
    }
    
    [self checkIfDoneIsPossible];
}

- (void)viewDidUnload {
    
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}


#pragma mark - Memory management

- (void)dealloc {
    [_cellsToReloadAndFlash release];
    [_travel release];
    
    [super dealloc];
}


@end
