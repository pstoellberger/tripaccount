//
//  EntrySortViewController.m
//  Reiseabrechnung
//
//  Created by Martin Maier on 25/07/2011.
//  Copyright 2011 Martin Maier. All rights reserved.
//

#import "EntrySortViewController.h"
#import "UIFactory.h"
#import "ReiseabrechnungAppDelegate.h"
#import "Currency.h"

@implementation EntrySortViewController

@synthesize travel=_travel, detailViewController=_detailViewController, segControl=_segControl, totalLabel=_totalLabel;

- (id)initWithTravel:(Travel *)travel {
    
    [Crittercism leaveBreadcrumb:@"EntrySortViewController: init"];
    
    if (self = [super init]) {
        self.travel = travel;
        
        _sortOrderDesc = NO;
        
        EntryViewController *entryListViewController = [[EntryViewController alloc] initWithTravel:travel];
        self.detailViewController = entryListViewController;
        entryListViewController.delegate = self;
        [entryListViewController release];
        
        self.title = NSLocalizedString(@"Expenses", @"tabbar expenses");
        
        if ([[ReiseabrechnungAppDelegate defaultCurrency:[travel managedObjectContext]].code isEqualToString:@"USD"]) {
            
            self.tabBarItem.image = [UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"pricetag" ofType:@"png"]];            
        } else {
            
            self.tabBarItem.image = [UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"pricetag_euro" ofType:@"png"]];
        }
    }
    return self;
}

- (void)sortTable:(UISegmentedControl *)sender {
    [self.detailViewController sortTable:self.segControl.selectedSegmentIndex desc:_sortOrderDesc];
}

- (void)toggleSortOrder:(UIGestureRecognizer *)gr {
    _sortOrderDesc = !_sortOrderDesc;
    [self sortTable:self.segControl];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    return YES;
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

- (void)loadView {
    
    [super loadView];
    
    UIView *segControlView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, [UIScreen mainScreen].applicationFrame.size.width, ENTRY_SORT_HEIGHT)];

    NSArray *segArray = [NSArray arrayWithObjects:NSLocalizedString(@"Payer", @"sort button"), NSLocalizedString(@"Type", @"sort button"), NSLocalizedString(@"Date", @"sort button"), nil];
    UISegmentedControl *segControl = [[UISegmentedControl alloc] initWithItems:segArray];
    segControl.frame = CGRectMake(5, 5, [UIScreen mainScreen].applicationFrame.size.width - 10, ENTRY_SORT_HEIGHT - 10);
    [segControl addTarget:self action:@selector(sortTable:) forControlEvents:UIControlEventValueChanged];
    segControl.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleLeftMargin |UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleBottomMargin;
    self.segControl = segControl;
    
    self.segControl.selectedSegmentIndex = [self.travel.displaySort intValue];
    _sortOrderDesc = [self.travel.displaySortOrderDesc intValue] == 1;
    // sort required on iOS 5
    [self sortTable:segControl];
    
    UIView *segControlBGView = [[UIView alloc] initWithFrame:segControlView.frame];
    segControlBGView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleLeftMargin;
    segControlBGView.contentMode = UIViewContentModeScaleToFill;
    
    UIView *segControlLine = [[UIView alloc] initWithFrame:CGRectMake(0, ENTRY_SORT_HEIGHT-2, [UIScreen mainScreen].applicationFrame.size.width, 1)];
    segControlLine.autoresizingMask = segControlBGView.autoresizingMask;
    segControlLine.contentMode = UIViewContentModeScaleToFill;
    
    [segControlView addSubview:segControlBGView];
    [segControlBGView release];
    [segControlView addSubview:segControlLine];
    [segControlLine release];
    [segControlView addSubview:segControl];
    
    UITapGestureRecognizer *gr = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(toggleSortOrder:)];
    gr.numberOfTapsRequired = 2;
    [segControlView addGestureRecognizer:gr];
    [gr release];
    
    [segControl release];
    
    self.detailViewController.tableView.tableHeaderView = segControlView;
    [segControlView release];
    
    UIView *totalViewContainer = [[UIView alloc] initWithFrame:CGRectMake(0, 0, [UIScreen mainScreen].applicationFrame.size.width, TOTAL_VIEW_HEIGHT)];
    totalViewContainer.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleLeftMargin;
    
    UIView *totalView = [[UIView alloc] initWithFrame:totalViewContainer.frame];
    totalView.autoresizingMask = totalViewContainer.autoresizingMask;
    [UIFactory addGradientToView:totalView color1:[UIFactory defaultDarkTintColor] color2:[UIFactory defaultLightTintColor]];
    totalView.alpha = 0.4;
    totalView.contentMode = UIViewContentModeScaleToFill;
    
    UIView *line = [[UIView alloc] initWithFrame:CGRectMake(0, 0, [UIScreen mainScreen].applicationFrame.size.width, 2)];
    line.autoresizingMask = totalViewContainer.autoresizingMask;
    [UIFactory addShadowToView:line];
    [UIFactory addGradientToView:line color1:[UIColor lightGrayColor] color2:[UIColor blackColor] startPoint:CGPointMake(0.5, 0) endPoint:CGPointMake(0.5, 1)];
    line.contentMode = UIViewContentModeScaleToFill;
    
    UILabel *totalLabelLabel = [[UILabel alloc] initWithFrame:CGRectMake(5, 5, [UIScreen mainScreen].applicationFrame.size.width - 15, TOTAL_VIEW_HEIGHT - 10)];
    totalLabelLabel.autoresizingMask = totalViewContainer.autoresizingMask;
    totalLabelLabel.textColor = [UIColor whiteColor];
    totalLabelLabel.textAlignment = NSTextAlignmentRight;
    totalLabelLabel.backgroundColor = [UIColor clearColor];
    totalLabelLabel.text = NSLocalizedString(@"total", "@total label");
    
    self.totalLabel = [[[UILabel alloc] initWithFrame:totalLabelLabel.frame] autorelease];
    self.totalLabel.autoresizingMask = totalViewContainer.autoresizingMask;
    self.totalLabel.textColor = [UIColor whiteColor];
    self.totalLabel.textAlignment = NSTextAlignmentRight;
    self.totalLabel.backgroundColor = [UIColor clearColor];

    [totalViewContainer addSubview:totalView];
    [totalView release];
    [totalViewContainer addSubview:line];
    [line release];
    [totalViewContainer addSubview:totalLabelLabel];
    [totalLabelLabel release];
    
    [totalViewContainer addSubview:self.totalLabel];
    
    [self updateTotalValue];
    
    self.detailViewController.tableView.tableFooterView = totalViewContainer;
    [totalViewContainer release];
    
    self.detailViewController.view.frame = CGRectMake(0, 0, [UIScreen mainScreen].applicationFrame.size.width, [[UIScreen mainScreen] applicationFrame].size.height - TABBAR_HEIGHT);
    
    UIView *detailViewContainer = [[[UIView alloc] initWithFrame:CGRectMake(0, 0, self.detailViewController.view.frame.size.width, self.detailViewController.view.frame.size.height)] autorelease];
    [detailViewContainer addSubview:self.detailViewController.view];
    self.view = detailViewContainer;

}

- (void)updateTotalValue {
    
    self.totalLabel.text = [self.travel totalCostLabel];
    
    if (![self.detailViewController.displayCurrency isEqual:self.detailViewController.travel.displayCurrency]) {
        [self.detailViewController.tableView reloadData];
    }
    
}

- (void)viewDidUnload {
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

#pragma mark Memory management

- (void)dealloc {
    [_detailViewController release];
    [_segControl release];
    [_totalLabel release];
    [_travel release];
    [super dealloc];
}

@end
