//
//  RateSelectViewController.h
//  Reiseabrechnung
//
//  Created by Martin Maier on 8/3/11.
//  Copyright 2011 Martin Maier. All rights reserved.
//

#import "GenericSelectViewController.h"
#import "RateCell.h"

@protocol RatesSelectViewControllerDelegate
- (void)willDisappearWithChanges;
@end


@interface RateSelectViewController : GenericSelectViewController <UINavigationControllerDelegate> {
    
    NSMutableArray* _cellsToReloadAndFlash;
}

@property (nonatomic, retain) ExchangeRate *rateToEdit;
@property (nonatomic, retain) Travel *travel;

@property (nonatomic, assign) id <RatesSelectViewControllerDelegate> closeDelegate;

@property (nonatomic, assign) IBOutlet RateCell *rateCell;

- (id)initWithTravel:(Travel *)travel;



@end
