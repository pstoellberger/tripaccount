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
    
    if (self = [super init]) {
        self.travel = travel;
        
        ParticipantViewController *evc = [[ParticipantViewController alloc] initWithTravel:travel];
        self.detailViewController = evc;
        evc.delegate = self;
        [evc release];
        
        self.title = @"People";
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
    self.detailViewController.tableView.contentInset = UIEdgeInsetsMake(NAVIGATIONBAR_HEIGHT, 0, 0, 0);
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
    [super dealloc];
}

@end
