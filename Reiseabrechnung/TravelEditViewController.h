//
//  TravelEditViewController.h
//  Reiseabrechnung
//
//  Created by Martin Maier on 29/06/2011.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "RootViewController.h"
#import "TravelNotManaged.h"
#import <CoreLocation/CoreLocation.h>
#import <QuartzCore/QuartzCore.h>
#import <MapKit/MapKit.h>


@interface TravelEditViewController : UITableViewController <UITextFieldDelegate, UITextViewDelegate, CLLocationManagerDelegate, MKReverseGeocoderDelegate, UITableViewDelegate> {

    UITextField *_descField;
    UITableViewCell *_countryCell;
    UITableViewCell *_cityCell;
    UITextField *_cityCellField;
    
    NSManagedObjectContext *_context;
    
    Travel *_travel;
    Currency *_currency;
    NSArray *_foreignCurrencies;
    Country *_country;
    NSString *_name;
    NSString *_city;
    
    CLLocationManager *_locManager;
    MKReverseGeocoder *_geocoder;
}

@property (nonatomic, retain) NSString *name;
@property (nonatomic, retain) NSString *city;
@property (nonatomic, retain) Travel *travel;
@property (nonatomic, retain) Currency *currency;
@property (nonatomic, retain) Country *country;
@property (nonatomic, retain) NSArray *foreignCurrencies;

@property (nonatomic, retain) CLLocationManager *locManager;

- (IBAction)done:(UIBarButtonItem *)sender;
- (IBAction)cancel:(UIBarButtonItem *)sender;

- (id)initInManagedObjectContext:(NSManagedObjectContext *)context;
- (id)initInManagedObjectContext:(NSManagedObjectContext *)context withTravel:(Travel *)travel;

- (void)selectHomeCurrency:(Currency *)currency;
- (void)selectForeignCurrencies:(NSArray *)currencies;
- (void)selectCountry:(Country *)country;
- (void)checkIfDoneIsPossible:(NSString *)newString;

- (Currency *)defaultCurrency;

@end
