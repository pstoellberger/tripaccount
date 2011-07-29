//
//  TravelEditViewController.h
//  Reiseabrechnung
//
//  Created by Martin Maier on 29/06/2011.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TravelNotManaged.h"
#import <CoreLocation/CoreLocation.h>
#import <QuartzCore/QuartzCore.h>
#import <MapKit/MapKit.h>

@protocol TravelEditViewControllerDelegate
- (void)travelDidSave:(Travel *)travel;
@end

@interface TravelEditViewController : UITableViewController <UITextFieldDelegate, UITextViewDelegate, CLLocationManagerDelegate, MKReverseGeocoderDelegate, UITableViewDelegate, UINavigationControllerDelegate> {

    NSManagedObjectContext *_context;
    
    Travel *_travel;
    NSArray *_currencies;
    Country *_country;
    NSString *_name;
    NSString *_city;
    
    NSMutableArray* _cellsToReloadAndFlash;
    
    CLLocationManager *_locManager;
    MKReverseGeocoder *_geocoder;
    
    BOOL _isFirstView;
}

@property (nonatomic, retain) NSString *name;
@property (nonatomic, retain) NSString *city;
@property (nonatomic, retain) Travel *travel;
@property (nonatomic, retain) Country *country;
@property (nonatomic, retain) NSArray *currencies;

@property (nonatomic, retain) CLLocationManager *locManager;

@property (nonatomic, assign) id <TravelEditViewControllerDelegate> editDelegate;

- (IBAction)done:(UIBarButtonItem *)sender;
- (IBAction)cancel:(UIBarButtonItem *)sender;

- (id)initInManagedObjectContext:(NSManagedObjectContext *)context;
- (id)initInManagedObjectContext:(NSManagedObjectContext *)context withTravel:(Travel *)travel;

- (void)selectCurrencies:(NSArray *)currencies;
- (void)selectCountry:(Country *)country;
- (void)checkIfDoneIsPossible;

@end
