//
//  EntrySortViewController.m
//  Reiseabrechnung
//
//  Created by Martin Maier on 25/07/2011.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "SummarySortViewController.h"
#import "UIFactory.h"
#import "Currency.h"

@implementation SummarySortViewController

@synthesize travel=_travel, detailViewController=_detailViewController;

- (id)initWithTravel:(Travel *)travel {
    
    if (self = [super init]) {
        self.travel = travel;
        _currencyArray = [[self.travel.currencies allObjects] retain];
        
        SummaryViewController *evc = [[SummaryViewController alloc] initWithTravel:travel andDisplayedCurrency:[_currencyArray objectAtIndex:0]];
        self.detailViewController = evc;
        [evc release];
        
        self.title = @"Summary";
        self.tabBarItem.image = [UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"138-scales" ofType:@"png"]];
    }
    return self;
}

- (void)sortTable:(UISegmentedControl *)sender {
    [self.detailViewController changeDisplayedCurrency:[_currencyArray objectAtIndex:sender.selectedSegmentIndex]];
}

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - EntryViewControllerDelegate

- (void)didItemCountChange:(NSUInteger)itemCount {
    if (itemCount == 0) {
        self.tabBarItem.badgeValue = nil;
    } else {
        self.tabBarItem.badgeValue = [NSString stringWithFormat:@"%d", itemCount];
    }   
}

#pragma mark - View lifecycle

#define SORT_TOOLBAR_HEIGHT 40

- (void)loadView {
    
    [super loadView];
    
    UIView *newView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, [[UIScreen mainScreen] applicationFrame].size.width, [[UIScreen mainScreen] applicationFrame].size.height - NAVIGATIONBAR_HEIGHT - TABBAR_HEIGHT)];
    newView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleBottomMargin | UIViewAutoresizingFlexibleRightMargin;
    
    NSMutableArray *segArray = [NSMutableArray array];
    for (Currency *currency in _currencyArray) {
        [segArray addObject:currency.code];
    }
    
    UISegmentedControl *segControl = [[UISegmentedControl alloc] initWithItems:segArray]; 
    segControl.frame = CGRectMake(10, 5, [UIScreen mainScreen].bounds.size.width - 20, SORT_TOOLBAR_HEIGHT - 10);
    segControl.selectedSegmentIndex = 0;
    [segControl addTarget:self action:@selector(sortTable:) forControlEvents:UIControlEventValueChanged];
    segControl.segmentedControlStyle = UISegmentedControlStyleBezeled;
    segControl.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleBottomMargin;
    segControl.tintColor = [UIColor clearColor];
    
    UIToolbar *toolbar = [[UIToolbar alloc] initWithFrame:CGRectMake(0, newView.frame.size.height - SORT_TOOLBAR_HEIGHT, newView.frame.size.width, SORT_TOOLBAR_HEIGHT)];
    toolbar.barStyle = UIBarStyleBlack;
    toolbar.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleTopMargin;
    toolbar.tintColor = [UIFactory defaultTintColor];
    [toolbar addSubview:segControl];
    
    if ([segArray count] > 1) {
        self.detailViewController.view.frame = CGRectMake(0, 0, newView.frame.size.width, newView.frame.size.height - SORT_TOOLBAR_HEIGHT);
        [newView addSubview:self.detailViewController.view];
        [newView addSubview:toolbar];
        self.view = newView;
    } else {
        self.view = self.detailViewController.view;
    }
    
    [toolbar release];
    [newView release];
    [segControl release];
}

/*
 // Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
 - (void)viewDidLoad
 {
 [super viewDidLoad];
 }
 */

- (void)viewDidUnload {
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    return YES;
}

@end
