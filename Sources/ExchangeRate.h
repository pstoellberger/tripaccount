//
//  ExchangeRate.h
//  Reiseabrechnung
//
//  Created by Martin Maier on 01/11/2011.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Currency, Travel;

@interface ExchangeRate : NSManagedObject

@property (nonatomic, retain) NSNumber * edited;
@property (nonatomic, retain) NSDate * lastUpdated;
@property (nonatomic, retain) NSNumber * defaultRate;
@property (nonatomic, retain) NSNumber * rate;
@property (nonatomic, retain) Currency *counterCurrency;
@property (nonatomic, retain) NSSet *travels;
@property (nonatomic, retain) Currency *baseCurrency;
@end

@interface ExchangeRate (CoreDataGeneratedAccessors)

- (void)addTravelsObject:(Travel *)value;
- (void)removeTravelsObject:(Travel *)value;
- (void)addTravels:(NSSet *)values;
- (void)removeTravels:(NSSet *)values;

@end
