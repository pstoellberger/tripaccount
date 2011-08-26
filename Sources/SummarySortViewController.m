//
//  EntrySortViewController.m
//  Reiseabrechnung
//
//  Created by Martin Maier on 25/07/2011.
//  Copyright 2011 Martin Maier. All rights reserved.
//

#import "SummarySortViewController.h"
#import "UIFactory.h"
#import "Currency.h"
#import "CurrencyRefresh.h"
#import "MultiLineSegmentedControl.h"

#define SORT_TOOLBAR_HEIGHT 45
#define RATE_SORT_TOOLBAR_HEIGHT 15
#define RATE_LABEL_HEIGHT 10
#define ACTIVITY_VIEW_SIZE 10


@implementation SummarySortViewController

@synthesize travel=_travel, detailViewController=_detailViewController, lastUpdatedLabel=_lastUpdatedLabel, updateIndicator=_updateIndicator;
@synthesize sortToolBar=_sortToolBar, ratesToolBar=_ratesToolBar;
@synthesize segControl=_segControl;

- (id)initWithTravel:(Travel *)travel {
    
    if (self = [super init]) {
        self.travel = travel;
        _currencyArray = [[self.travel.currencies allObjects] retain];
        
        SummaryViewController *evc = [[SummaryViewController alloc] initWithTravel:travel andDisplayedCurrency:[_currencyArray objectAtIndex:0]];
        self.detailViewController = evc;
        [evc release];
        
        self.title = @"Summary";
        self.tabBarItem.image = [UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"scales" ofType:@"png"]];
    }
    return self;
}

- (void)sortTable:(UISegmentedControl *)sender {
    [self.detailViewController changeDisplayedCurrency:[_currencyArray objectAtIndex:sender.selectedSegmentIndex]];
}

- (void)updateRateLabel {
    
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    formatter.dateStyle = NSDateFormatterMediumStyle;
    formatter.timeStyle = NSDateFormatterMediumStyle;     
    
    if (![self.travel.closed isEqual:[NSNumber numberWithInt:1] ]) {
        NSDate *lastUpdated = [[NSUserDefaults standardUserDefaults] objectForKey:[CurrencyRefresh lastUpdatedKey]];
        self.lastUpdatedLabel.text = [NSString stringWithFormat:@"Rates last updated at %@", [formatter stringFromDate:lastUpdated]];
   
    } else {
        
        self.lastUpdatedLabel.text = [NSString stringWithFormat:@"Travel closed at %@", [formatter stringFromDate:self.travel.closedDate]];
    }
    
    [self.lastUpdatedLabel sizeToFit];
    self.updateIndicator.frame = CGRectMake(self.lastUpdatedLabel.frame.origin.x + self.lastUpdatedLabel.frame.size.width + ACTIVITY_VIEW_SIZE, self.lastUpdatedLabel.frame.origin.y, ACTIVITY_VIEW_SIZE, ACTIVITY_VIEW_SIZE);
    self.lastUpdatedLabel.frame = CGRectMake((self.ratesToolBar.frame.size.width - self.lastUpdatedLabel.frame.size.width) / 2, (self.ratesToolBar.frame.size.height - self.lastUpdatedLabel.frame.size.height) / 2, self.lastUpdatedLabel.frame.size.width, self.lastUpdatedLabel.frame.size.height);
    
    [formatter release];
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
    
    UIView *newView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, [[UIScreen mainScreen] applicationFrame].size.width, [[UIScreen mainScreen] applicationFrame].size.height - TABBAR_HEIGHT)];
    newView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleBottomMargin | UIViewAutoresizingFlexibleRightMargin;
    
    NSMutableArray *segArrayTitles= [NSMutableArray array];
    NSMutableArray *segArraySubTitles= [NSMutableArray array];

    for (Currency *currency in _currencyArray) {
        [segArrayTitles addObject:currency.code];
        [segArraySubTitles addObject:currency.name];
    }

    MultiLineSegmentedControl *segControl = [[MultiLineSegmentedControl alloc] initWithItems:segArrayTitles andSubTitles:segArraySubTitles]; 
    segControl.frame = CGRectMake(5, 5, [[UIScreen mainScreen] applicationFrame].size.width - 10, SORT_TOOLBAR_HEIGHT - 10);
    segControl.selectedSegmentIndex = 0;
    [segControl addTarget:self action:@selector(sortTable:) forControlEvents:UIControlEventValueChanged];
    segControl.segmentedControlStyle = UISegmentedControlStyleBezeled;
    segControl.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleBottomMargin;
    segControl.tintColor = [UIColor clearColor];
    segControl.segmentedControlStyle = UISegmentedControlStyleBezeled;
    segControl.alpha = 0.9;
    self.segControl = segControl;
   
    self.segControl.selectedSegmentIndex = [_currencyArray indexOfObject:self.travel.displayCurrency];
    
    UIToolbar *toolbar = [[UIToolbar alloc] initWithFrame:CGRectMake(0, newView.frame.size.height - SORT_TOOLBAR_HEIGHT - RATE_SORT_TOOLBAR_HEIGHT, newView.frame.size.width, SORT_TOOLBAR_HEIGHT)];
    toolbar.barStyle = UIBarStyleBlackTranslucent;
    toolbar.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleHeight;
    [toolbar addSubview:segControl];
    self.sortToolBar = toolbar;

    UIToolbar *ratestoolbar = [[UIToolbar alloc] initWithFrame:CGRectMake(0, newView.frame.size.height - RATE_SORT_TOOLBAR_HEIGHT, newView.frame.size.width, RATE_SORT_TOOLBAR_HEIGHT)];
    ratestoolbar.barStyle = UIBarStyleBlack;
    ratestoolbar.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleTopMargin;
    self.ratesToolBar = ratestoolbar;
    
    UILabel *ratesUpdated = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 0, 0)];
    self.lastUpdatedLabel = ratesUpdated;

    ratesUpdated.backgroundColor = [UIColor clearColor];
    ratesUpdated.font = [UIFont systemFontOfSize:10];
    ratesUpdated.textColor = [UIColor colorWithRed:0.9 green:0.9 blue:0.9 alpha:1];
    ratesUpdated.textAlignment = UITextAlignmentCenter;
    ratesUpdated.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin;
    [self updateRateLabel];
    [ratestoolbar addSubview:ratesUpdated];
    
    self.updateIndicator = [[[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhite] autorelease];
    self.updateIndicator.frame = CGRectMake(ratesUpdated.frame.origin.x + ratesUpdated.frame.size.width + ACTIVITY_VIEW_SIZE, ratesUpdated.frame.origin.y, ACTIVITY_VIEW_SIZE, ACTIVITY_VIEW_SIZE);
    self.updateIndicator.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin;
    [ratestoolbar addSubview:self.updateIndicator];
    
    if ([segArrayTitles count] > 1) {
        
        self.detailViewController.view.frame = CGRectMake(0, 0, newView.frame.size.width, newView.frame.size.height);
        self.detailViewController.tableView.contentInset = UIEdgeInsetsMake(NAVIGATIONBAR_HEIGHT, 0, SORT_TOOLBAR_HEIGHT + RATE_SORT_TOOLBAR_HEIGHT, 0);
        self.detailViewController.tableView.scrollIndicatorInsets = self.detailViewController.tableView.contentInset;
        
        [newView addSubview:self.detailViewController.view];
        [newView addSubview:toolbar];
        [newView addSubview:ratestoolbar];
        self.view = newView;
    } else {
        self.view = self.detailViewController.view;
    }
    
    [ratesUpdated release];
    [toolbar release];
    [ratestoolbar release];
    [newView release];
    [segControl release];
}

- (void)viewDidUnload {
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

#pragma mark Memory management

-(void)dealloc {
    [_currencyArray release];
    
    [super dealloc];
}

@end
