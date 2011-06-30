//
//  RootViewController.m
//  Reiseabrechnung
//
//  Created by Martin Maier on 28/06/2011.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "RootViewController.h"
#import "TravelViewController.h"
#import "TravelEditViewController.h"
#import "AlertPrompt.h"
#import "Participant.h"

@implementation RootViewController

@synthesize travelArray, addButton, tableView=_tableView;

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [travelArray count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *CellIdentifier = @"Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithFrame:CGRectZero reuseIdentifier:CellIdentifier] autorelease];
    }
    
    // Set up the cell...
    Travel *travel = [travelArray objectAtIndex:indexPath.row];
    cell.textLabel.text = travel.name;

    return cell;
}

-(void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    Travel *travel = [travelArray objectAtIndex:indexPath.row];
    
    TravelViewController *detailViewController = [[TravelViewController alloc] init];
    detailViewController.title = travel.name;
    detailViewController.travel = travel;
    
    [self.navigationController pushViewController:detailViewController animated:YES];
    [detailViewController release];    
    
}

- (void)viewDidLoad {
    [super viewDidLoad];

    self.title = @"Reiseabrechnungen";
    
    self.travelArray = [NSMutableArray array];
    for (int i=0; i<2; i++) {
        Travel *_travel = [[Travel alloc] init];
        _travel.name = [@"Travel " stringByAppendingFormat: @"%d", i];
        _travel.created = [NSDate date];
        
        for (int j=0; j<2; j++) {
            Participant *p = [[Participant alloc] init];
            p.name = [@"Participant " stringByAppendingFormat: @"%d", j];
            [_travel.participants addObject:p];
            [p release];
        }
        
        [travelArray addObject:_travel];
        [_travel release];
    }
    
    UIBarButtonItem *anotherButton = [[UIBarButtonItem alloc] initWithTitle:@"Add" style:UIBarButtonItemStylePlain target:self action:@selector(openTravelPopup)];          
    self.navigationItem.rightBarButtonItem = anotherButton;
    [anotherButton release];
}

- (void)viewDidUnload {
    [super viewDidUnload];
}

- (void)openTravelPopup {
    TravelEditViewController *detailViewController = [[TravelEditViewController alloc] init];
    detailViewController.rootViewController = self;
    [self.navigationController presentModalViewController:detailViewController animated:YES];   
    [detailViewController release];   
}

- (void)addTravel:(NSString *)name withCurrency:(NSString *)currency {
    Travel *_travel = [[Travel alloc] init];
    _travel.name = name;
    _travel.created = [NSDate date];
    _travel.currency = currency;
    [travelArray addObject:_travel];
    [_travel release];
    
    [self.tableView reloadData];
}

- (void)dealloc {
    [super dealloc];
    [travelArray release];
}

@end
