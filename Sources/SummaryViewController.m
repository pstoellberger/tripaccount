//
//  SummaryViewController.m
//  Reiseabrechnung
//
//  Created by Martin Maier on 30/06/2011.
//  Copyright 2011 Martin Maier. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>
#import "SummaryViewController.h"
#import "Summary.h"
#import "Participant.h"
#import "SummaryCell.h"
#import "UIFactory.h"
#import "CurrencyHelperCategory.h"
#import "Transfer.h"
#import "ReiseabrechnungAppDelegate.h"

@implementation SummaryViewController

@synthesize travel=_travel, summaryCell=_summaryCell ;

- (id)initWithTravel:(Travel *) travel andDisplayedCurrency:(Currency *)currency {

    if (self = [super initWithStyle:UITableViewStylePlain]) {
    
        _travel = travel;
        _displayCurrency = currency;

        self.tableView.delegate = self;
        self.tableView.dataSource = self;
        
        [UIFactory initializeTableViewController:self.tableView];
        
        self.title = @"Summary";
        self.tabBarItem.image = [UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"138-scales" ofType:@"png"]];
        
        NSFetchRequest *req = [[NSFetchRequest alloc] init];
        req.entity = [NSEntityDescription entityForName:@"Transfer" inManagedObjectContext:[travel managedObjectContext]];
        req.sortDescriptors = [NSArray arrayWithObjects:[NSSortDescriptor sortDescriptorWithKey:@"debtor.name" ascending:YES selector:@selector(caseInsensitiveCompare:)], nil];
        req.predicate = [NSPredicate predicateWithFormat:@"travel = %@", travel];
        
        self.fetchedResultsController = [[[NSFetchedResultsController alloc] initWithFetchRequest:req managedObjectContext:[travel managedObjectContext] sectionNameKeyPath:nil cacheName:nil] autorelease];
        [req release];
        
        self.fetchedResultsController.delegate = self;
        [self performFetchForTableView:self.tableView];
       
        [self viewWillAppear:YES];
    }
    return self;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForManagedObject:(NSManagedObject *)managedObject {
    
    static NSString *ReuseIdentifier = @"SummaryCell";
    
    SummaryCell *cell = (SummaryCell *) [tableView dequeueReusableCellWithIdentifier:ReuseIdentifier];
    if (cell == nil) {
        [[NSBundle mainBundle] loadNibNamed:@"SummaryCell" owner:self options:nil];
        
        cell = self.summaryCell;
        [UIFactory initializeCell:cell];
        
        cell.paid.transform = CGAffineTransformMakeRotation( -M_PI/6 ); // = 45 degrees
        cell.paid.layer.cornerRadius = 4;
        cell.paid.layer.masksToBounds = YES;
        [UIFactory addGradientToView:cell.paid color1:[UIColor colorWithRed:1 green:0.2 blue:0.2 alpha:1] color2:[UIColor colorWithRed:0.5 green:0 blue:0 alpha:1]];
        [UIFactory addShadowToView:cell.paid];
        cell.paid.alpha = 0.5;
        cell.paidLabel.text = @"BEZAHLT";
    }
    
    Transfer *transfer = (Transfer *)managedObject;

    cell.debtor.text = transfer.debtor.name;
    cell.leftImage.image = [UIImage imageWithData:transfer.debtor.image];
    cell.debtee.text = transfer.debtee.name;
    cell.rightImage.image = [UIImage imageWithData:transfer.debtee.image];
    cell.amount.text = [NSString stringWithFormat:@"%@ %@", [UIFactory formatNumber:[NSNumber numberWithDouble:[self.travel.transferBaseCurrency convertTravelAmount:self.travel currency:_displayCurrency amount:[transfer.amount doubleValue]]]], _displayCurrency.code];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    cell.paid.hidden = YES;
    
    cell.rightImage.alpha = 1;
    cell.leftImage.alpha = 1;
    
    UIColor *textColor = [UIColor blackColor];
    if ([self.travel.closed intValue] == 1) {
        textColor = [UIColor grayColor];
        cell.rightImage.alpha = 0.6;
        cell.leftImage.alpha = 0.6;
    }
    
    if ([transfer.paid intValue] == 1) {
       cell.paid.hidden = NO; 
    }

    cell.debtor.textColor = textColor;
    cell.debtee.textColor = textColor;
    cell.amount.textColor = textColor;
    cell.owes.textColor = textColor;
    cell.to.textColor = textColor;
    
    
    return cell;    
}

- (void)managedObjectSelected:(NSManagedObject *)managedObject {
   
    Transfer *transfer = (Transfer *)managedObject;
    
    if ([self.travel.closed intValue] == 1) {
        
        if ([transfer.paid intValue] == 1) {
            transfer.paid = [NSNumber numberWithInt:0];
            [self.tableView reloadRowsAtIndexPaths:[NSArray arrayWithObject:[[self fetchedResultsControllerForTableView:self.tableView] indexPathForObject:managedObject]] withRowAnimation:UITableViewRowAnimationLeft];
        } else {
            transfer.paid = [NSNumber numberWithInt:1];
            [self.tableView reloadRowsAtIndexPaths:[NSArray arrayWithObject:[[self fetchedResultsControllerForTableView:self.tableView] indexPathForObject:managedObject]] withRowAnimation:UITableViewRowAnimationRight];
        }
        
        [ReiseabrechnungAppDelegate saveContext:[self.travel managedObjectContext]];
    }
    
    [self.tableView deselectRowAtIndexPath:[[self fetchedResultsControllerForTableView:self.tableView] indexPathForObject:managedObject]  animated:YES];
}

- (void)changeDisplayedCurrency:(Currency *)currency {
    _displayCurrency = currency;
    [self.tableView reloadData];
    
    self.travel.displayCurrency = currency;
    [ReiseabrechnungAppDelegate saveContext:[self.travel managedObjectContext]];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 64;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    return YES;
}

#pragma mark Business Logic

- (void)recalculateSummary {
    
    NSLog(@"recalculate summary.");

    if ([self.travel.closed intValue] != 1) {
        
        Summary *summary = [Summary createSummary:self.travel];
        NSMutableDictionary *dic = summary.accounts;
        
        [self.travel removeTransfers:self.travel.transfers];
        
        self.travel.transferBaseCurrency = summary.baseCurrency;
        
        for (NSString* key in [dic keyEnumerator]) {
            ParticipantKey *participantKey = (ParticipantKey *)key;
            
            Transfer *transfer = [NSEntityDescription insertNewObjectForEntityForName: @"Transfer" inManagedObjectContext: [_travel managedObjectContext]];
            transfer.debtor = participantKey.payer;
            transfer.debtee = participantKey.receiver;
            transfer.amount = [dic objectForKey:key];
            transfer.travel = self.travel;
            [self.travel addTransfersObject:transfer];
        }
        
        [ReiseabrechnungAppDelegate saveContext:[self.travel managedObjectContext]];
    }
}


#pragma mark - View lifecycle

- (void)viewDidLoad {
    
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
}

- (void)viewDidUnload {
    
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

#pragma mark - Memory management

- (void)dealloc {
    [super dealloc];
}

@end
