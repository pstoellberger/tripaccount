//
//  TravelEditViewController.m
//  Reiseabrechnung
//
//  Created by Martin Maier on 29/06/2011.
//  Copyright 2011 Martin Maier. All rights reserved.
//

#import "ParticipantEditViewController.h"
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

static NSIndexPath *_nameIndexPath;
static NSIndexPath *_emailIndexPath;

@interface ParticipantEditViewController ()
- (void)initIndexPaths;
- (void)updateAndFlash:(UIViewController *)viewController;
- (void)selectEmail:(NSString *)newEmail;
- (void)selectName:(NSString *)newName;
@end

@implementation ParticipantEditViewController

@synthesize name=_name, email=_email;
@synthesize travel=_travel, participant=_participant;
@synthesize editDelegate=_editDelegate;

- (id) initInManagedObjectContext:(NSManagedObjectContext *)context withTravel:(Travel *)travel withParticipant:(Participant *)participant {
    
    self = [super initWithStyle:UITableViewStyleGrouped];
    
    if (self) {
        
        [self initIndexPaths];
        
        _isFirstView = YES;
        
        _cellsToReloadAndFlash = [[[NSMutableArray alloc] init] retain];
        
        _context = context;
        
        [UIFactory initializeTableViewController:self.tableView];
        
        self.tableView.delegate = self;
        self.tableView.dataSource = self;
        
        self.travel = travel;
        self.participant = participant;
        
        self.navigationItem.leftBarButtonItem = [[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel target:self action:@selector(cancel:)] autorelease];
        
        if (self.participant) {
        
            self.navigationItem.rightBarButtonItem = [[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(done:)] autorelease];
            self.title = NSLocalizedString(@"Edit Person", @"controller person edit title");  
            
        } else {
            
            self.navigationItem.rightBarButtonItem = [[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemSave target:self action:@selector(done:)] autorelease];
            self.title = NSLocalizedString(@"Add Person", @"controller person add title");  
            
        }
        
        
        self.tableView.backgroundColor = [UIColor clearColor];
        self.tableView.backgroundView = [UIFactory createBackgroundViewWithFrame:self.view.frame];
        
        if (!participant) {
            
            self.name = @"";
            self.email = @"";
            
        } else {
            
            self.name = participant.name;
            self.email = participant.email;
        }
    }
    return self;
}

- (void)initIndexPaths {
    _nameIndexPath = [[NSIndexPath indexPathForRow:0 inSection:0] retain];
    _emailIndexPath = [[NSIndexPath indexPathForRow:1 inSection:0] retain];
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

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 2;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    return nil;    
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    UITableViewCell *cell = nil;
    
    if ([indexPath isEqual:_nameIndexPath]) {
        
        cell = [[[AlignedStyle2Cell alloc] initWithStyle:UITableViewCellStyleValue2 reuseIdentifier:nil] autorelease];
        cell.textLabel.text = NSLocalizedString(@"Name", @"cell caption name");
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        cell.detailTextLabel.text = self.name;
        
    } else if ([indexPath isEqual:_emailIndexPath]) {
        
        cell = [[[AlignedStyle2Cell alloc] initWithStyle:UITableViewCellStyleValue2 reuseIdentifier:nil] autorelease];
        cell.textLabel.text = NSLocalizedString(@"E-Mail", @"cell caption mail");
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        cell.detailTextLabel.text = self.email;
        
    } else {
        NSLog(@"no indexpath cell found for %@ ", indexPath);
    }
    
    return cell;
}

- (NSString *)tableView:(UITableView *)tableView titleForDeleteConfirmationButtonForRowAtIndexPath:(NSIndexPath *)indexPath {
    return NSLocalizedString(@"Clear", @"delete button title clear text cell");
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    return (indexPath == _nameIndexPath || indexPath == _emailIndexPath);  
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (indexPath == _nameIndexPath) {
        
        self.name = @"";
        [self.tableView reloadRowsAtIndexPaths:[NSArray arrayWithObject:_nameIndexPath] withRowAnimation:UITableViewRowAnimationNone];
        
        [self checkIfDoneIsPossible];
        
    } else if (indexPath == _emailIndexPath) {
        
        self.email = @"";
        [self.tableView reloadRowsAtIndexPaths:[NSArray arrayWithObject:_emailIndexPath] withRowAnimation:UITableViewRowAnimationNone];
    }
    
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if ([indexPath isEqual:_nameIndexPath]) {
        
        TextEditViewController *textEditViewController = [[TextEditViewController alloc] initWithText:self.name target:self selector:@selector(selectName:)]; 
        textEditViewController.title = NSLocalizedString(@"Name", @"controller title edit name");
        [self.navigationController pushViewController:textEditViewController animated:YES];
        [textEditViewController release];            
        
        
    } else if ([indexPath isEqual:_emailIndexPath]) {
        
        TextEditViewController *textEditViewController = [[TextEditViewController alloc] initWithText:self.email target:self selector:@selector(selectEmail:)]; 
        textEditViewController.title = NSLocalizedString(@"E-Mail", @"controller title edit mail");
        [textEditViewController setKeyBoardType:UIKeyboardTypeEmailAddress];
        [self.navigationController pushViewController:textEditViewController animated:YES];
        [textEditViewController release];            
        
    }
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

#pragma mark UINavigationControllerDelegate

- (void)navigationController:(UINavigationController *)navigationController didShowViewController:(UIViewController *)viewController animated:(BOOL)animated {
    [self updateAndFlash:self];
}

#pragma mark Select Items

- (void)selectName:(NSString *)newName {
    
    if (![newName isEqualToString:self.name]) {
        self.name = newName;
        [self.tableView reloadRowsAtIndexPaths:[NSArray arrayWithObject:_nameIndexPath] withRowAnimation:UITableViewRowAnimationFade];
        [_cellsToReloadAndFlash addObject:_nameIndexPath];
    }
}

- (void)selectEmail:(NSString *)newEmail {
    if (![newEmail isEqualToString:self.email]) {
        self.email = newEmail;
        [_cellsToReloadAndFlash addObject:_emailIndexPath];
    }
}

- (IBAction)done:(UIBarButtonItem *)sender {
    
    if (!self.participant) {
        self.participant = [NSEntityDescription insertNewObjectForEntityForName: @"Participant" inManagedObjectContext:_context];
        [self.travel addParticipantsObject:self.participant];
    }
    
    self.participant.name = self.name;
    self.participant.email = self.email;
    
    if (!self.participant.image) {
        self.participant.image = [NSData dataWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"noImage" ofType:@"png"]];
    }
    if (!self.participant.imageSmall) {
        self.participant.imageSmall = [Participant createThumbnail:self.participant.image];
    }
    
    [ReiseabrechnungAppDelegate saveContext:_context];
    
    [self dismissModalViewControllerAnimated:YES];
    
    [self.editDelegate participantEditFinished:self.participant wasSaved:YES];

}

- (IBAction)cancel:(UIBarButtonItem *)sender {
    
    self.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
    [self dismissModalViewControllerAnimated:YES];
    
    [self.editDelegate participantEditFinished:self.participant wasSaved:NO];
}

- (void)checkIfDoneIsPossible {
    
    if ([self.name length] > 0) {
        self.navigationItem.rightBarButtonItem.enabled = YES;
    } else {
        self.navigationItem.rightBarButtonItem.enabled = NO;
    }    
}

#pragma mark - View lifecycle

- (void)viewDidAppear:(BOOL)animated {
    
    _viewAppeared = YES;
    
    if (!self.participant && _isFirstView) {
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
