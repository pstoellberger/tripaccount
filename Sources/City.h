//
//  City.h
//  Reiseabrechnung
//
//  Created by Martin Maier on 31/08/2011.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Country;

@interface City : NSManagedObject {
@private
}
@property (nonatomic, retain) NSNumber * latitude;
@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) NSNumber * longitude;
@property (nonatomic, retain) NSString * name_de;
@property (nonatomic, retain) Country *country;

@end
