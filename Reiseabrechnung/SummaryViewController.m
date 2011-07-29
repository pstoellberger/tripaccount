//
//  SummaryViewController.m
//  Reiseabrechnung
//
//  Created by Martin Maier on 30/06/2011.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "SummaryViewController.h"
#import "Summary.h"
#import "Participant.h"
#import "SummaryCell.h"
#import "UIFactory.h"

@implementation SummaryViewController

@synthesize travel=_travel, summaryCell=_summaryCell ;

- (id)initWithTravel:(Travel *) travel {

    if (self = [super initWithStyle:UITableViewStylePlain]) {
    
        _travel = travel;
        
        [UIFactory initializeTableViewController:self.tableView];
        
        self.tableView.delegate = self;
        self.tableView.dataSource = self;

        self.title = @"Summary";
        self.tabBarItem.image = [UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"138-scales" ofType:@"png"]];
        
        [self viewWillAppear:YES];
    }
    return self;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [_summary.accounts count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *ReuseIdentifier = @"SummaryCell";
    
    SummaryCell *cell = (SummaryCell *) [tableView dequeueReusableCellWithIdentifier:ReuseIdentifier];
    if (cell == nil) {
        [[NSBundle mainBundle] loadNibNamed:@"SummaryCell" owner:self options:nil];
        
        cell = self.summaryCell;
        [UIFactory initializeCell:cell];
    }
    
    ParticipantKey *key = [[[_summary.accounts keyEnumerator] allObjects] objectAtIndex:indexPath.row]; 

    NSNumber *value = [_summary.accounts objectForKey:key];
    if (value > 0) {
        cell.debtor.text = key.payer.name;
        cell.leftImage.image = [UIImage imageWithData:key.payer.image];
        cell.debtee.text = key.receiver.name;
        cell.rightImage.image = [UIImage imageWithData:key.receiver.image];
    } else {
        cell.debtor.text = key.receiver.name;
        cell.leftImage.image = [UIImage imageWithData:key.receiver.image];
        cell.debtee.text = key.payer.name;
        cell.rightImage.image = [UIImage imageWithData:key.payer.image];
    }
    cell.amount.text = [NSString stringWithFormat:@"%.02f EUR", fabs([value doubleValue])];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    
    
    return cell;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 64;
}

- (void)recalculateSummary {
    [_summary release];
    _summary = [[Summary createSummary:self.travel] retain];
    NSMutableDictionary *dic = _summary.accounts;
    for (NSString* key in [dic keyEnumerator]) {
        NSLog(@"%@ %@", key, [dic objectForKey:key]);
    }    
}


#pragma mark - View lifecycle

- (void)dealloc
{
    [super dealloc];
}

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}


- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
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

@end
