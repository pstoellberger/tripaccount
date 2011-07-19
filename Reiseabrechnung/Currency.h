//
//  Currency.h
//  Reiseabrechnung
//
//  Created by Martin Maier on 18/07/2011.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Country, Entry, Travel;

@interface Currency : NSManagedObject {
@private
}

- (void)addCountriesObject:(Country *)value;

@property (nonatomic, retain) NSString * code;
@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) NSNumber * digits;
@property (nonatomic, retain) NSSet* entries;
@property (nonatomic, retain) NSSet* travels;
@property (nonatomic, retain) NSSet* origins;
@property (nonatomic, retain) NSSet* countries;

@end
