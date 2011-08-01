//
//  SummarySortViewController.h
//  Reiseabrechnung
//
//  Created by Martin Maier on 01/08/2011.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>
#import "SummaryViewController.h"

@interface SummarySortViewController : UIViewController {
    Travel *_travel;
    SummaryViewController *_detailViewController;
    NSArray *_currencyArray;
}

@property (nonatomic, retain) Travel *travel;
@property (nonatomic, retain) SummaryViewController *detailViewController;

- (id)initWithTravel:(Travel *) travel;

@end
