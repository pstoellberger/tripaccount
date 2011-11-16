//
//  Locator.m
//  Reiseabrechnung
//
//  Created by Martin Maier on 08/08/2011.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "Reachability.h"
#import "Locator.h"

@interface Locator () 
- (void)performOfflineLocalisation:(CLLocation *)newLocation;
- (void)startReverseGeoCoding;
@end

@implementation Locator

@synthesize locManager=_locManager, locationDelegate=_locationDelegate, context=_context, reachability=_reachability;
@synthesize lastKnowLocation=_lastKnowLocation;

- (id)initInManagedObjectContext:(NSManagedObjectContext *)context {
    
    if (self = [super init]) {
        
        self.reachability = [Reachability reachabilityForInternetConnection];
        
        self.context = context;
        
        alreadyProcessed = NO;
        geoCoderRetries = 0;
        
        _locale = [[NSUserDefaults standardUserDefaults] objectForKey:@"AppleLanguages"];
        
        // init location manager
        self.locManager = [[[CLLocationManager alloc] init] autorelease];
        self.locManager.purpose = NSLocalizedString(@"locManager", @"purpose");
        
        if (![CLLocationManager locationServicesEnabled]) {
            NSLog(@"User has opted out of location services");
        }
        
        self.locManager.delegate = self;
        self.locManager.desiredAccuracy = kCLLocationAccuracyKilometer;        
        self.locManager.distanceFilter = 5.0f; // in meters
        
    }
    return self;
}

#pragma mark - Location finding

- (void)startLocating {
    
    geoCoderRetries = 0;
    alreadyProcessed = NO;
    self.lastKnowLocation = nil;
    
    [self.locManager startUpdatingLocation];
}

- (void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error {
	NSLog(@"Location manager error: %@", [error description]);
    [self.locManager stopUpdatingLocation];
}

- (void)reverseGeocoder:(MKReverseGeocoder *)geocoder didFailWithError:(NSError *)error {
	NSLog(@"Reverse geocoder error: %@", [error description]);
    geoCoderRetries++;
    
    [[NSUserDefaults standardUserDefaults] setObject:_locale forKey:@"AppleLanguages"];
    
    if (geoCoderRetries < 3) {
        [self startReverseGeoCoding];
    } else {
        [self performOfflineLocalisation:self.lastKnowLocation];
    }
}

- (void)startReverseGeoCoding {
    
    [[NSUserDefaults standardUserDefaults] setObject: [NSArray arrayWithObjects:@"en", nil] forKey:@"AppleLanguages"];
    
    if (!_geocoder) {
        _geocoder = [[MKReverseGeocoder alloc] initWithCoordinate:self.lastKnowLocation.coordinate];
        _geocoder.delegate = self;
        [_geocoder retain];
    }
    
    [_geocoder start];    
}

- (void)locationManager:(CLLocationManager *)manager didUpdateToLocation:(CLLocation *)newLocation fromLocation:(CLLocation *)oldLocation {  
    
    NSDate *eventDate = newLocation.timestamp; 
    NSTimeInterval howRecent = [eventDate timeIntervalSinceNow];
    
    //Is the event recent and accurate enough ?
    NSLog(@"how recent %d secs", abs(howRecent));
    
    if (abs(howRecent) < 10) {    
        
        if (!self.lastKnowLocation || newLocation.horizontalAccuracy < self.lastKnowLocation.horizontalAccuracy) {
            self.lastKnowLocation = newLocation;
        }
        
        if (!alreadyProcessed) {
            
            NetworkStatus netStatus = [self.reachability currentReachabilityStatus];
            
            if (netStatus == ReachableViaWiFi || netStatus == ReachableViaWWAN) {
                
                // get location from google
                [self startReverseGeoCoding];            
                
            } else {
                
                // calculate local
                [self performOfflineLocalisation:self.lastKnowLocation];
                
            }
            
        }
        
        [self.locManager stopUpdatingLocation];
    }
}

- (void)performOfflineLocalisation:(CLLocation *)newLocation {

    NSLog(@"Performing offline localisation.");
    
    NSFetchRequest *req = [[NSFetchRequest alloc] init];
    req.entity = [NSEntityDescription entityForName:@"City" inManagedObjectContext:self.context];
    NSArray *allCities = [self.context executeFetchRequest:req error:nil];
    [req release];
    
    City *city = nil;
    Country *country = nil;
    
    double shortestDistanceSoFar = DBL_MAX;
    
    for (City *c in allCities) {
        
        double distanceX = fabs(newLocation.coordinate.latitude) - fabs([c.latitude doubleValue]);
        double distanceY = fabs(newLocation.coordinate.longitude) - fabs([c.longitude doubleValue]);
        
        double distance = sqrt(pow(distanceX, 2) + pow(distanceY, 2));
        
        if (distance < shortestDistanceSoFar) {
            shortestDistanceSoFar = distance;
            city = c;
            country = c.country;
            
            // dont set city when too far away
            if (distance > 1) {
                city = nil;
            } 
        }
    }
    
    alreadyProcessed = YES;
    [self.locationDelegate locationAquired:country city:city.name];
    
}

- (void)reverseGeocoder:(MKReverseGeocoder *)geocoder didFindPlacemark:(MKPlacemark *)placemark {
    
    [[NSUserDefaults standardUserDefaults] setObject:_locale forKey:@"AppleLanguages"];
    
    [geocoder cancel];
    
    NSLog(@"%@",[placemark.addressDictionary description]);
	
    NSString *city = nil;
    if ([placemark locality]) {
        city = [placemark locality];
    }
    
    Country *country = nil;
    if ([placemark country]) {
        NSFetchRequest *_fetchRequest = [[NSFetchRequest alloc] init];
        _fetchRequest.entity = [NSEntityDescription entityForName:@"Country" inManagedObjectContext:self.context];
        _fetchRequest.predicate = [NSPredicate predicateWithFormat:@"name = %@", [placemark country]];
        NSArray *countries = [self.context executeFetchRequest:_fetchRequest error:nil];
        [_fetchRequest release];
        
        country = [countries lastObject];
    }
    
    if (country) {
        alreadyProcessed = YES;
        [self.locationDelegate locationAquired:country city:city];
    }
}

#pragma mark Memory management

- (void)dealloc {
    
    [_geocoder release];
    [_locale release];
    
    [super dealloc];
}

@end
