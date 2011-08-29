//
//  SummarySortViewController.h
//  Reiseabrechnung
//
//  Created by Martin Maier on 01/08/2011.
//  Copyright 2011 Martin Maier. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>
#import "SummaryViewController.h"
#import "ShadowNavigationController.h"

@interface SummarySortViewController : ShadowNavigationController {
    NSArray *_currencyArray;
}

@property (nonatomic, retain) Travel *travel;
@property (nonatomic, retain) SummaryViewController *detailViewController;
@property (nonatomic, retain) UILabel *lastUpdatedLabel;
@property (nonatomic, retain) UIActivityIndicatorView *updateIndicator;
@property (nonatomic, retain) UISegmentedControl *segControl;

@property (nonatomic, retain) UIToolbar *ratesToolBar;

- (id)initWithTravel:(Travel *) travel;
- (void)updateRateLabel:(BOOL)animate; 

@end
