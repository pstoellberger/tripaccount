//
//  ExchangeRate.h
//  Reiseabrechnung
//
//  Created by Martin Maier on 01/08/2011.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Currency;

@interface ExchangeRate : NSManagedObject {
@private
}
@property (nonatomic, retain) NSDate * lastUpdated;
@property (nonatomic, retain) NSNumber * edited;
@property (nonatomic, retain) NSNumber * rate;
@property (nonatomic, retain) Currency *baseCurrency;
@property (nonatomic, retain) Currency *counterCurrency;

@end
