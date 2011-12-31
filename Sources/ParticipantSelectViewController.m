//
//  ParticipantSelectViewController.m
//  Reiseabrechnung
//
//  Created by Martin Maier on 08/09/2011.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "ParticipantSelectViewController.h"
#import "Entry.h"
#import "Currency.h"
#import "I18NSortCategory.h"
#import "UIFactory.h"
#import "AlignedStyle2Cell.h"
#import "ImageCache.h"
#import "NumberEditViewController.h"
#import "ReceiverWeightNotManaged.h"
#import "Travel.h"
#import "TravelCategory.h"

@interface ParticipantSelectViewController () {
    Participant *_accessorySelectedParticipant;
    BOOL _flash;
}

- (void)updateCellWithSplitAmount:(UILabel *)label selected:(BOOL)selected selectedParticipant:(Participant *)selectedParticipant;
- (void)updateAllSplitAmountsForTableView:(UITableView *)tableView;
- (void)selectWeight:(id)sender;
- (ReceiverWeightNotManaged *)receiverWeightForParticipant:(Participant *)participant;
- (void)resetWeights;
- (BOOL)shouldResetButtonAppear;

@end

@implementation ParticipantSelectViewController

@synthesize entry=_entry, footerView=_footerView;


#define RESET_WEIGHT_BUTTON_GAP 10
#define RESET_WEIGHT_BUTTON_HEIGHT 40

- (id)initInManagedObjectContext:(NSManagedObjectContext *)context
                       withEntry:(EntryNotManaged *)entry
                withFetchRequest:(NSFetchRequest *)fetchRequest
        withSelectedParticipants:(NSArray *)newSelectedObjects
                          target:(id)target 
                          action:(SEL)selector {
    
    if (self = [super initInManagedObjectContext:context 
                              withMultiSelection:YES 
                                withFetchRequest:fetchRequest 
                             withSelectedObjects:newSelectedObjects 
                                          target:target 
                                          action:selector]) {
        
        _flash = NO;
        self.entry = entry;
        _amountCells = [[NSMutableDictionary alloc] init];
        
        UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.tableView.bounds.size.width, RESET_WEIGHT_BUTTON_HEIGHT + (RESET_WEIGHT_BUTTON_GAP*2)) ];
        view.autoresizingMask = UIViewAutoresizingFlexibleWidth;
        self.footerView = view;
        [view release];
        
        UIButton *resetWeightButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
        [resetWeightButton setTitle:NSLocalizedString(@"Reset Weight",@"button label") forState:UIControlStateNormal];                        
        resetWeightButton.frame = CGRectMake(RESET_WEIGHT_BUTTON_GAP, RESET_WEIGHT_BUTTON_GAP, self.tableView.bounds.size.width - (RESET_WEIGHT_BUTTON_GAP*2), RESET_WEIGHT_BUTTON_HEIGHT);
        [resetWeightButton addTarget:self action:@selector(resetWeights) forControlEvents:UIControlEventTouchUpInside];
        resetWeightButton.autoresizingMask = UIViewAutoresizingFlexibleWidth;
        resetWeightButton.titleLabel.font = [UIFont boldSystemFontOfSize:16];
        [view addSubview:resetWeightButton];

        if ([self shouldResetButtonAppear]) {
            self.tableView.tableFooterView = self.footerView;
        }
        
    }
    
    return self;
}

- (BOOL)shouldResetButtonAppear {
    return [self.entry receiverWeightsDifferFromDefault];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForManagedObject:(NSManagedObject *)managedObject {
    
    static NSString *ReuseIdentifier = @"ParticipantCell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:ReuseIdentifier];
    if (cell == nil) {
        cell = [[[GradientCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:ReuseIdentifier] autorelease];
        
        if (tableView.style == UITableViewStylePlain) {
            [UIFactory initializeCell:cell];
        }
    };
    
    Participant *p = (Participant *)managedObject;
    
    cell.textLabel.text = p.name;
    cell.imageView.image = [[ImageCache instance] getImage:p.image];    
    
    if ([self.selectedObjects containsObject:managedObject]) {
        cell.accessoryType = UITableViewCellAccessoryDetailDisclosureButton;
    } else {
        cell.accessoryType = UITableViewCellAccessoryNone;
    }
    
    if (self.entry.amount && [self.entry.amount doubleValue] != 0 && cell.detailTextLabel) {
        [_amountCells setObject:cell.detailTextLabel forKey:p.name];
    }
    
    [self updateCellWithSplitAmount:cell.detailTextLabel selected:[self.selectedObjects containsObject:managedObject] selectedParticipant:p];
    
    return cell;
    
}

- (void)updateCellWithSplitAmount:(UILabel *)label selected:(BOOL)selected selectedParticipant:(Participant *)selectedParticipant {
    
    if ([self.selectedObjects count] != 0 && selected && [self.entry.amount doubleValue] > 0 && [self.selectedObjects containsObject:selectedParticipant]) {
        
        double weightOfSelectedParticipants = 0;
        for (ReceiverWeightNotManaged *recWeight in self.entry.receiverWeights) {
            if (recWeight.active) {
                weightOfSelectedParticipants += [recWeight.weight doubleValue];
            }
        }
        
        double amount = [self.entry.amount doubleValue] / weightOfSelectedParticipants;
        amount *= [[self receiverWeightForParticipant:selectedParticipant].weight doubleValue];
        
        label.text = [NSString stringWithFormat:@"%@ %@", [UIFactory formatNumber:[NSNumber numberWithDouble:amount]], self.entry.currency.code]; 
        
    } else {
        
        label.text = @"";
    }
}

- (void)updateAllSplitAmountsForTableView:(UITableView *)tableView {
    
    if (self.entry.amount && [self.entry.amount doubleValue] != 0) {
        
        if ([self.selectedObjects count] != 0) {
            
            for (NSString *name in [_amountCells keyEnumerator]) {
                
                UILabel *amountLabel = [_amountCells objectForKey:name];
                Participant *managedObject = nil;
                for (Participant *p in [self fetchedResultsControllerForTableView:tableView].fetchedObjects) {
                    if ([name isEqualToString:p.name]) {
                        managedObject = p;
                        break;
                    }
                }
                [self updateCellWithSplitAmount:amountLabel selected:[self.selectedObjects containsObject:managedObject] selectedParticipant:managedObject];
                
            }
        } else {
            
        }
    }    
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    [super tableView:tableView didSelectRowAtIndexPath:indexPath];
    
    Participant *selectedParticipant = [self.fetchedResultsController objectAtIndexPath:indexPath];
    ReceiverWeightNotManaged *recWeight = [self receiverWeightForParticipant:selectedParticipant];
    
    if ([self.selectedObjects containsObject:selectedParticipant]) {
        // jetzt selektiert
        if (!recWeight) {
            recWeight = [[[ReceiverWeightNotManaged alloc] initWithParticiant:selectedParticipant andWeight:selectedParticipant.weight] autorelease];
            [self.entry.receiverWeights addObject:recWeight];
        } else {
            recWeight.active = YES;
        }
    } else {
        // jetzt deselektiert
        recWeight.active = NO;
    } 
    
    [self updateAllSplitAmountsForTableView:tableView];
}

- (void)tableView:(UITableView *)tableView accessoryButtonTappedForRowWithIndexPath:(NSIndexPath *)indexPath {
    
    Participant *participant = (Participant *) [self.fetchedResultsController objectAtIndexPath:indexPath];
    _accessorySelectedParticipant = participant;
    
    NumberEditViewController *numberEditViewController = [[NumberEditViewController alloc] initWithNumber:[self receiverWeightForParticipant:participant].weight withDecimals:YES andNamedImage:@"weight.png" target:self selector:@selector(selectWeight:)]; 
    numberEditViewController.title = NSLocalizedString(@"Weight", @"controller title edit weight");
    numberEditViewController.allowZero = NO;
    numberEditViewController.allowNull = NO;
    [self.navigationController pushViewController:numberEditViewController animated:YES];
    [numberEditViewController release];
    
}

- (ReceiverWeightNotManaged *)receiverWeightForParticipant:(Participant *)participant {
    
    for (ReceiverWeightNotManaged *recWeight in self.entry.receiverWeights) {
        if ([recWeight.participant isEqual:participant]) {
            return recWeight;
        }
    }
    return nil;
}

- (void)selectWeight:(NSNumber *)number {
    
    ReceiverWeightNotManaged *recWeight = [self receiverWeightForParticipant:_accessorySelectedParticipant];
    
    if (![recWeight.weight isEqualToNumber:number]) {
        
        recWeight.weight = number;
        
        if ([self shouldResetButtonAppear]) {
            self.tableView.tableFooterView = self.footerView;
        } else {
            self.tableView.tableFooterView = nil;
        }
        
        [self updateAllSplitAmountsForTableView:self.tableView];
        
        _flash = YES;
    }
    
}

- (void)viewDidAppear:(BOOL)animated {
    
    // flash
    if (_flash) {
        for (Participant *p in self.selectedObjects) {
            NSIndexPath *indexPath = [self.fetchedResultsController indexPathForObject:p];
            [self.tableView selectRowAtIndexPath:indexPath animated:YES scrollPosition:UITableViewScrollPositionNone];
            [self.tableView deselectRowAtIndexPath:indexPath animated:YES]; 
            _flash = NO;
        }
    }
}

- (void)resetWeights {
    
    for (ReceiverWeightNotManaged *recWeight in self.entry.receiverWeights) {
        recWeight.weight = recWeight.participant.weight;
    }
    [self updateAllSplitAmountsForTableView:self.tableView];
    
    self.tableView.tableFooterView = nil;
    
}

- (void)selectAll:(id)sender {
    [super selectAll:sender];
    for (ReceiverWeightNotManaged *recWeight in self.entry.receiverWeights) {
        recWeight.active = YES;
    }
    [self updateAllSplitAmountsForTableView:self.tableView];
}

- (void)selectNone:(id)sender {
    [super selectNone:sender];
    for (ReceiverWeightNotManaged *recWeight in self.entry.receiverWeights) {
        recWeight.active = NO;
    }
    [self updateAllSplitAmountsForTableView:self.tableView];
}

- (void)dealloc {
    [_amountCells release];
    [_footerView release];
    [super dealloc];
}

@end
