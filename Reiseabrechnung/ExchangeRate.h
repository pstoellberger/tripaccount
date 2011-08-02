//
//  ExchangeRate.h
//  Reiseabrechnung
//
//  Created by Martin Maier on 02/08/2011.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Currency, Travel;

@interface ExchangeRate : NSManagedObject {
@private
}
@property (nonatomic, retain) NSDate * lastUpdated;
@property (nonatomic, retain) NSNumber * edited;
@property (nonatomic, retain) NSNumber * rate;
@property (nonatomic, retain) Currency *baseCurrency;
@property (nonatomic, retain) Currency *counterCurrency;
@property (nonatomic, retain) Travel *travels;

@end
