//
//  ParticipantSortViewController.m
//  Reiseabrechnung
//
//  Created by Martin Maier on 30/08/2011.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "ParticipantSortViewController.h"

@implementation ParticipantSortViewController

@synthesize travel=_travel, detailViewController=_detailViewController;

- (id)initWithTravel:(Travel *)travel {
    
    [Crittercism leaveBreadcrumb:@"ParticipantSortViewController: init"];
    
    if (self = [super init]) {
        self.travel = travel;
        
        ParticipantViewController *participantListViewController = [[ParticipantViewController alloc] initWithTravel:travel];
        self.detailViewController = participantListViewController;
        participantListViewController.delegate = self;
        [participantListViewController release];
        
        self.title = NSLocalizedString(@"People", @"tabbar people");
        self.tabBarItem.image = [UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"group" ofType:@"png"]];
        
    }
    return self;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    return YES;
}

#pragma mark - ParticipantViewControllerDelegate

- (void)didItemCountChange:(NSUInteger)itemCount {
    if (itemCount == 0) {
        self.tabBarItem.badgeValue = nil;
    } else {
        self.tabBarItem.badgeValue = [NSString stringWithFormat:@"%d", itemCount];
    }   
}

#pragma mark - View lifecycle

- (void)loadView {
    
    [super loadView];
    
    self.detailViewController.view.frame = CGRectMake(0, 0, [UIScreen mainScreen].applicationFrame.size.width, [[UIScreen mainScreen] applicationFrame].size.height - TABBAR_HEIGHT);
    
    UIEdgeInsets insets = self.detailViewController.tableView.contentInset;
    insets.top = NAVIGATIONBAR_HEIGHT;
    self.detailViewController.tableView.contentInset = insets;
    self.detailViewController.tableView.scrollIndicatorInsets = self.detailViewController.tableView.contentInset;
    
    UIView *detailViewContainer = [[[UIView alloc] initWithFrame:CGRectMake(0, 0, self.detailViewController.view.frame.size.width, self.detailViewController.view.frame.size.height)] autorelease];
    [detailViewContainer addSubview:self.detailViewController.view];
    self.view = detailViewContainer;
    
}

- (void)viewDidUnload {
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

#pragma mark Memory management

- (void)dealloc {
    
    [_detailViewController release];
    [_travel release];
    
    [super dealloc];
}

@end
