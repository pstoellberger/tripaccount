//
//  ExchangeRate.h
//  Reiseabrechnung
//
//  Created by Martin Maier on 8/4/11.
//  Copyright (c) 2011 Martin Maier. All rights reserved.
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
@property (nonatomic, retain) NSNumber * defaultRate;
@property (nonatomic, retain) Currency *baseCurrency;
@property (nonatomic, retain) Currency *counterCurrency;
@property (nonatomic, retain) NSSet *travels;
@end

@interface ExchangeRate (CoreDataGeneratedAccessors)

- (void)addTravelsObject:(Travel *)value;
- (void)removeTravelsObject:(Travel *)value;
- (void)addTravels:(NSSet *)values;
- (void)removeTravels:(NSSet *)values;

@end
