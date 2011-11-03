//
//  AppDefaults.h
//  Reiseabrechnung
//
//  Created by Martin Maier on 01/11/2011.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Currency, Type;

@interface AppDefaults : NSManagedObject

@property (nonatomic, retain) NSNumber * sampleTravelCreated;
@property (nonatomic, retain) Currency *homeCurrency;
@property (nonatomic, retain) Type *defaultType;

@end
