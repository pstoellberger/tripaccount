//
//  CurrencyRefresh.h
//  Reiseabrechnung
//
//  Created by Martin Maier on 27/07/2011.
//  Copyright 2011 Martin Maier. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@interface CurrencyRefresh : NSObject {
    NSManagedObjectContext *_context;
    NSArray *_currencies;
}

+ (NSString *)lastUpdatedKey;

- (id)initInManagedContext:(NSManagedObjectContext *)context;
- (BOOL)refreshCurrencies;
- (BOOL)areRatesOutdated;
- (BOOL)shouldRetry:(BOOL)retryEnabled;

@end
