//
//  Travel.h
//  Reiseabrechnung
//
//  Created by Martin Maier on 19/07/2011.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Country, Currency, Entry, Participant;

@interface Travel : NSManagedObject {
@private
}
@property (nonatomic, retain) NSString * city;
@property (nonatomic, retain) NSDate * created;
@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) Currency * homeCurrency;
@property (nonatomic, retain) NSSet* participants;
@property (nonatomic, retain) NSSet* foreignCurrencies;
@property (nonatomic, retain) NSSet* entries;
@property (nonatomic, retain) Country * country;

@end
