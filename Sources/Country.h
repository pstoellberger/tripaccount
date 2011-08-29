//
//  Country.h
//  Reiseabrechnung
//
//  Created by Martin Maier on 08/08/2011.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class City, Currency, Travel;

@interface Country : NSManagedObject {
@private
}
@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) NSString * image;
@property (nonatomic, retain) NSSet *currencies;
@property (nonatomic, retain) NSSet *travels;
@property (nonatomic, retain) NSSet *cities;
@end

@interface Country (CoreDataGeneratedAccessors)

- (void)addCurrenciesObject:(Currency *)value;
- (void)removeCurrenciesObject:(Currency *)value;
- (void)addCurrencies:(NSSet *)values;
- (void)removeCurrencies:(NSSet *)values;

- (void)addTravelsObject:(Travel *)value;
- (void)removeTravelsObject:(Travel *)value;
- (void)addTravels:(NSSet *)values;
- (void)removeTravels:(NSSet *)values;

- (void)addCitiesObject:(City *)value;
- (void)removeCitiesObject:(City *)value;
- (void)addCities:(NSSet *)values;
- (void)removeCities:(NSSet *)values;

@end