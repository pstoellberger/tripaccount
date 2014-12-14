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
#import "TravelCategory.h"
#import "I18NSortCategory.h"

@implementation SummarySortViewController

@synthesize travel=_travel, detailViewController=_detailViewController, lastUpdatedLabel=_lastUpdatedLabel, updateIndicator=_updateIndicator;
@synthesize segControl=_segControl, ratesView=_ratesView;

- (id)initWithTravel:(Travel *)travel {
    
    
    if (self = [super init]) {
        self.travel = travel;
        _currencyArray = [self.travel.sortedCurrencies retain];

        _dateFormatter = [[[NSDateFormatter alloc] init] retain];
        _dateFormatter.dateStyle = NSDateFormatterMediumStyle;
        _dateFormatter.timeStyle = NSDateFormatterMediumStyle;
        
        SummaryViewController *evc = [[SummaryViewController alloc] initWithTravel:travel];
        self.detailViewController = evc;
        [evc release];
        
        self.title = NSLocalizedString(@"Summary", @"tabbar summary");
        self.tabBarItem.image = [UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"scales" ofType:@"png"]];
    }
    return self;
}

- (void)sortTable:(UISegmentedControl *)sender {
    [self.detailViewController changeDisplayedCurrency:[_currencyArray objectAtIndex:sender.selectedSegmentIndex]];
}

- (void)updateRateLabel:(BOOL)animate; {
    
    
    float animationDuration = 0.5;
    if (!animate) {
        animationDuration = 0;
    }
    
    if ([self.travel isOpen]) {
        
        if (self.segControl.numberOfSegments <= 1) {
            
            if (CGAffineTransformIsIdentity(self.ratesView.transform)) {
                [UIView animateWithDuration:animationDuration animations:^{ self.ratesView.transform = CGAffineTransformTranslate(self.ratesView.transform, 0, self.ratesView.frame.size.height); } ];
            } else {
                [UIView animateWithDuration:animationDuration animations:^{ self.ratesView.transform = CGAffineTransformIdentity; } ];
            }
        } else {
            
            NSDate *lastUpdated = [[NSUserDefaults standardUserDefaults] objectForKey:[CurrencyRefresh lastUpdatedKey]];
            self.lastUpdatedLabel.text = [NSString stringWithFormat:NSLocalizedString(@"Rates last updated at %@", @"status bar last updated"), [_dateFormatter stringFromDate:lastUpdated]];
        }
            
    } else {
        
        self.lastUpdatedLabel.text = [NSString stringWithFormat:NSLocalizedString(@"Travel closed at %@", @"status bar travel closed"), [_dateFormatter stringFromDate:self.travel.closedDate]];
        
        if (!CGAffineTransformIsIdentity(self.ratesView.transform)) {
            [UIView animateWithDuration:animationDuration animations:^{ self.ratesView.transform = CGAffineTransformIdentity; } ];
        }
    }
    
    [self centerRateLabel];
    
    self.detailViewController.view.frame = CGRectMake(0, 0, self.detailViewController.view.frame.size.width, self.ratesView.frame.origin.y);
    
}

- (void)centerRateLabel {
    
    [self.lastUpdatedLabel sizeToFit];
    
    self.lastUpdatedLabel.frame = CGRectMake((self.ratesView.frame.size.width - self.lastUpdatedLabel.frame.size.width) / 2, (self.ratesView.frame.size.height - self.lastUpdatedLabel.frame.size.height) / 2, self.lastUpdatedLabel.frame.size.width, self.lastUpdatedLabel.frame.size.height);
    
    self.updateIndicator.frame = CGRectMake(self.lastUpdatedLabel.frame.origin.x + self.lastUpdatedLabel.frame.size.width + ACTIVITY_VIEW_SIZE, (self.ratesView.frame.size.height - ACTIVITY_VIEW_SIZE) / 2, ACTIVITY_VIEW_SIZE, ACTIVITY_VIEW_SIZE);
    
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    return YES;
}

#pragma mark - EntryViewControllerDelegate

- (void)didItemCountChange:(NSUInteger)itemCount {
    if (itemCount == 0) {
        self.tabBarItem.badgeValue = nil;
    } else {
        self.tabBarItem.badgeValue = [NSString stringWithFormat:@"%lu", (unsigned long)itemCount];
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
        [segArraySubTitles addObject:currency.nameI18N];
    }
    
    if ([_currencyArray count] > 1) {
        
        UIView *segControlView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, [UIScreen mainScreen].applicationFrame.size.width, CURRENCY_SORT_HEIGHT)];
        
        UISegmentedControl *segControl = [[UISegmentedControl alloc] initWithItems:segArrayTitles];
        segControl.frame = CGRectMake(5, 5, [[UIScreen mainScreen] applicationFrame].size.width - 10, CURRENCY_SORT_HEIGHT - 10);
        segControl.selectedSegmentIndex = 0;
        [segControl addTarget:self action:@selector(sortTable:) forControlEvents:UIControlEventValueChanged];
        segControl.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleBottomMargin;
        self.segControl = segControl;
        
        self.segControl.selectedSegmentIndex = [_currencyArray indexOfObject:self.travel.displayCurrency];
        
        UIView *segControlBGView = [[UIView alloc] initWithFrame:segControlView.frame];
        segControlBGView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleLeftMargin;
        segControlBGView.contentMode = UIViewContentModeScaleToFill;
        
        UIView *segControlLine = [[UIView alloc] initWithFrame:CGRectMake(0, CURRENCY_SORT_HEIGHT-1, [UIScreen mainScreen].applicationFrame.size.width, 1)];
        segControlLine.autoresizingMask = segControlBGView.autoresizingMask;
        segControlLine.contentMode = UIViewContentModeScaleToFill;

        [segControlView addSubview:segControlBGView];
        [segControlBGView release];
        
        [segControlView addSubview:segControlLine];
        [segControlLine release];
        
        [segControlView addSubview:segControl];
        [segControl release];
        
        self.detailViewController.tableView.tableHeaderView = segControlView;
        [segControlView release];
        
    }
    
    UIView *ratesView = [[UIView alloc] initWithFrame:CGRectMake(0, newView.frame.size.height - RATE_SORT_TOOLBAR_HEIGHT, newView.frame.size.width, RATE_SORT_TOOLBAR_HEIGHT)];
    ratesView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleTopMargin;
    self.ratesView = ratesView;
    self.ratesView.backgroundColor = [UIFactory defaultLightTintColor];
    
    UILabel *ratesUpdated = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 0, 0)];
    self.lastUpdatedLabel = ratesUpdated;

    ratesUpdated.backgroundColor = [UIColor clearColor];
    ratesUpdated.font = [UIFont systemFontOfSize:10];
    ratesUpdated.textColor = [UIColor blackColor];
    ratesUpdated.textAlignment = NSTextAlignmentRight;
    ratesUpdated.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin;
    [ratesView addSubview:ratesUpdated];
    
    self.updateIndicator = [[[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhite] autorelease];
    self.updateIndicator.frame = CGRectMake(ratesUpdated.frame.origin.x + ratesUpdated.frame.size.width + ACTIVITY_VIEW_SIZE, ratesUpdated.frame.origin.y, ACTIVITY_VIEW_SIZE, ACTIVITY_VIEW_SIZE);
    self.updateIndicator.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin;
    [ratesView addSubview:self.updateIndicator];

    [newView addSubview:self.detailViewController.view];
    [newView addSubview:ratesView];
    
    self.detailViewController.view.frame = CGRectMake(0, 0, newView.frame.size.width, newView.frame.size.height);
    
    self.view = newView;
    
    [self updateRateLabel:NO];
    
    [ratesUpdated release];
    [ratesView release];
    [newView release];
}

- (void)viewDidUnload {
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

#pragma mark Memory management

-(void)dealloc {
    [_currencyArray release];
    [_dateFormatter release];
    [_travel release];
    
    [_detailViewController release];
    [_lastUpdatedLabel release];
    [_updateIndicator release];
    [_segControl release];
    
    [super dealloc];
}

@end
