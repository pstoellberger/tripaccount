//
//  TravelCategory.h
//  Reiseabrechnung
//
//  Created by Martin Maier on 10/08/2011.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Travel.h"

@interface Travel (OpenClose)

@property (nonatomic, readonly) NSString *location;
@property (nonatomic, readonly) NSArray *sortedEntries;
@property (nonatomic, readonly) NSArray *sortedCurrencies;

- (void)open:(BOOL)useLatestRates;
- (void)close;

@end
