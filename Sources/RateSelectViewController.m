//
//  RateSelectViewController.m
//  Reiseabrechnung
//
//  Created by Martin Maier on 8/3/11.
//  Copyright 2011 Martin Maier. All rights reserved.
//

#import "RateSelectViewController.h"
#import "NumberEditViewController.h"
#import "ExchangeRate.h"
#import "UIFactory.h"
#import "AlignedStyle2Cell.h"
#import "ReiseabrechnungAppDelegate.h"
#import "RateCell.h"

@implementation RateSelectViewController

@synthesize rateToEdit=_rateToEdit, travel=_travel;
@synthesize closeDelegate=_closeDelegate;
@synthesize rateCell=_rateCell;

- (id)initWithTravel:(Travel *)travel {
    
    NSFetchRequest *fetchRequest = [[[NSFetchRequest alloc] init] autorelease];
    fetchRequest.entity = [NSEntityDescription entityForName:@"ExchangeRate" inManagedObjectContext:[travel managedObjectContext]];
    fetchRequest.sortDescriptors = [NSArray arrayWithObject:[NSSortDescriptor sortDescriptorWithKey:@"counterCurrency.code" ascending:YES selector:@selector(caseInsensitiveCompare:)]];
    fetchRequest.predicate = [NSPredicate predicateWithFormat:@"travels contains %@ && baseCurrency != counterCurrency", travel];
    
    if (self = [super initInManagedObjectContext:[travel managedObjectContext] withStyle:UITableViewStyleGrouped withMultiSelection:NO withFetchRequest:fetchRequest withSectionKey:nil withSelectedObjects:nil target:self action:@selector(selectRate:)]) {
        
        _cellsToReloadAndFlash = [[[NSMutableArray alloc] init] retain];
        
        self.travel = travel;
        
        self.navigationItem.rightBarButtonItem = [[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(doneWithEditing)] autorelease];
        
        self.tableView.backgroundColor = [UIColor clearColor];
        self.tableView.backgroundView = [UIFactory createBackgroundViewWithFrame:self.view.frame];
        
    }
    return self;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForManagedObject:(NSManagedObject *)managedObject {
    
    static NSString *reuseIdentifier = @"RateCell";
    
    ExchangeRate *rate = (ExchangeRate *)managedObject;
    
    RateCell *cell = (RateCell *) [tableView dequeueReusableCellWithIdentifier:reuseIdentifier];
    if (cell == nil) {
        [[NSBundle mainBundle] loadNibNamed:@"RateCell" owner:self options:nil];
        cell = self.rateCell;
    }
    
    cell.rateLabel.text = [NSString stringWithFormat:@"1 %@ = %@ %@", rate.baseCurrency.code, [UIFactory formatNumber:rate.rate], rate.counterCurrency.code];
    cell.nameLabel.text = rate.counterCurrency.name;
    
    NSLog(@"%@", cell.subTextLabel);
    
    if ([rate.edited intValue] == 1) {
        cell.subTextLabel.hidden = NO;
        cell.subTextLabel.font = [UIFont italicSystemFontOfSize:cell.subTextLabel.font.pointSize];
        cell.rateLabel.font = [UIFont italicSystemFontOfSize:cell.rateLabel.font.pointSize];
    } else {
        cell.subTextLabel.hidden = YES;
        cell.subTextLabel.font = [UIFont systemFontOfSize:cell.subTextLabel.font.pointSize];
        cell.rateLabel.font = [UIFont systemFontOfSize:cell.rateLabel.font.pointSize];      
    }
    
    return cell;
    
}

- (void)deleteManagedObject:(NSManagedObject *)managedObject {
    
    ExchangeRate *rate = (ExchangeRate *)managedObject;
    [self.travel addRatesObject:rate.counterCurrency.defaultRate];
    [self.context deleteObject:managedObject];
    
    [ReiseabrechnungAppDelegate saveContext:self.context];
}

- (BOOL)canDeleteManagedObject:(NSManagedObject *)managedObject {
    
    ExchangeRate *rate = (ExchangeRate *)managedObject;
	return [rate.edited intValue] == 1;
}

- (NSString *)tableView:(UITableView *)tableView titleForDeleteConfirmationButtonForRowAtIndexPath:(NSIndexPath *)indexPath {
    return NSLocalizedString(@"Reset rate", @"red button title clear rate");
}

- (void)doneWithEditing {
    
    [self.closeDelegate willDisappearWithChanges];
    
    [self.navigationController dismissModalViewControllerAnimated:YES];
}

- (void)selectRate:(ExchangeRate *)rate {
    
    NumberEditViewController *controller = [[NumberEditViewController alloc] initWithNumber:rate.rate currency:nil travel:nil target:self selector:@selector(selectNewRateValue:)];
    self.rateToEdit = rate;
    
    [self.navigationController pushViewController:controller animated:YES];
    [controller release];
}

- (void)selectNewRateValue:(NSNumber *)newRateValue {
    
    if ([self.rateToEdit.edited intValue] != 1) {
        // create copy of rate
        [self.travel removeRatesObject:self.rateToEdit];
        
        ExchangeRate *newRate = [NSEntityDescription insertNewObjectForEntityForName: @"ExchangeRate" inManagedObjectContext:self.context];
        newRate.rate = newRateValue;
        newRate.baseCurrency = self.rateToEdit.baseCurrency;
        newRate.counterCurrency = self.rateToEdit.counterCurrency;
        newRate.edited = [NSNumber numberWithInt:1];
        
        [self.travel addRatesObject:newRate];
        
    } else {
        
        self.rateToEdit.rate = newRateValue;
    }
    
    [_cellsToReloadAndFlash addObject:[self.fetchedResultsController indexPathForObject:self.rateToEdit]];
    
    [ReiseabrechnungAppDelegate saveContext:self.context];
}

- (void)navigationController:(UINavigationController *)navigationController didShowViewController:(UIViewController *)viewController animated:(BOOL)animated {
    
    if (viewController == self) {
        
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

#pragma mark Memory management

- (void)dealloc {
    [_cellsToReloadAndFlash release];
    [super dealloc];
}

@end
