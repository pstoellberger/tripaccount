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

@interface ParticipantSelectViewController ()

- (void)updateCellWithSplitAmount:(UILabel *)label selected:(BOOL)selected;
- (void)updateAllSplitAmountsForTableView:(UITableView *)tableView;

@end

@implementation ParticipantSelectViewController

@synthesize entry=_entry;

- (id)initInManagedObjectContext:(NSManagedObjectContext *)context
                      withEntry:(EntryNotManaged *)entry
              withMultiSelection:(BOOL)multiSelection 
                withFetchRequest:(NSFetchRequest *)fetchRequest
             withSelectedObjects:(NSArray *)newSelectedObjects
                          target:(id)target 
                          action:(SEL)selector {

    if (self = [super initInManagedObjectContext:context withMultiSelection:multiSelection withFetchRequest:fetchRequest withSelectedObjects:newSelectedObjects target:target action:selector]) {
        
        self.entry = entry;
        _amountCells = [[NSMutableDictionary alloc] init];
        
    }
    
    return self;
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
    cell.accessoryType = [self accessoryTypeForManagedObject:managedObject];
    cell.imageView.image = [[ImageCache instance] getImage:p.image];
    
    if (self.entry.amount && [self.entry.amount doubleValue] != 0 && cell.detailTextLabel) {
        [_amountCells setObject:cell.detailTextLabel forKey:p.name];
    }
    
    [self updateCellWithSplitAmount:cell.detailTextLabel selected:[self.selectedObjects containsObject:managedObject]];
    
    return cell;
        
}

- (void)updateCellWithSplitAmount:(UILabel *)label selected:(BOOL)selected {
    
    if ([self.selectedObjects count] != 0 && selected && [self.entry.amount doubleValue] > 0) {
        
        label.text = [NSString stringWithFormat:@"%@ %@", [UIFactory formatNumber:[NSNumber numberWithDouble:([self.entry.amount doubleValue] / [self.selectedObjects count])]], self.entry.currency.code]; 
        
    } else {
        
        label.text = @"";
    }
}

- (void)updateAllSplitAmountsForTableView:(UITableView *)tableView {
    
    if (self.entry.amount && [self.entry.amount doubleValue] != 0) {
        
        if ([self.selectedObjects count] != 0) {
            
            for (NSString *name in [_amountCells keyEnumerator]) {
                
                UILabel *amountLabel = [_amountCells objectForKey:name];
                NSManagedObject *managedObject = nil;
                for (Participant *p in [self fetchedResultsControllerForTableView:tableView].fetchedObjects) {
                    if ([name isEqualToString:p.name]) {
                        managedObject = p;
                        break;
                    }
                }
                [self updateCellWithSplitAmount:amountLabel selected:[self.selectedObjects containsObject:managedObject]];
                
            }
        } else {
            
        }
    }    
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    [super tableView:tableView didSelectRowAtIndexPath:indexPath];
    [self updateAllSplitAmountsForTableView:tableView];
}

- (void)selectAll:(id)sender {
    [super selectAll:sender];
    [self updateAllSplitAmountsForTableView:self.tableView];
}

- (void)selectNone:(id)sender {
    [super selectNone:sender];
    [self updateAllSplitAmountsForTableView:self.tableView];
}

- (void)dealloc {
    [_amountCells release];
    [super dealloc];
}

@end
