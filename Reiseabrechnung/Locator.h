//
//  Locator.h
//  Reiseabrechnung
//
//  Created by Martin Maier on 08/08/2011.
//  Copyright 2011 Martin Maier. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>
#import <MapKit/MapKit.h>
#import "Country.h"
#import "City.h"
#import "Reachability.h"

@protocol LocatorDelegate 
- (void)locationAquired:(Country *) country city:(NSString *)city;
@end

@interface Locator : NSObject <CLLocationManagerDelegate, MKReverseGeocoderDelegate> {
    MKReverseGeocoder *_geocoder;
    BOOL alreadyProcessed;
}

@property (nonatomic, retain) CLLocationManager *locManager;
@property (nonatomic, retain) Reachability *reachability;

@property (nonatomic, assign) id <LocatorDelegate> locationDelegate;

@property (nonatomic, retain) NSManagedObjectContext *context;

- (void)startLocating;
- (id)initInManagedObjectContext:(NSManagedObjectContext *)context;

@end
