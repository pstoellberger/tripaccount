//
//  DataInitialiser.m
//  Reiseabrechnung
//
//  Created by Martin Maier on 21/01/2012.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "DataInitialiser.h"
#import "Crittercism.h"

@interface DataInitialiser ()
- (void)fixUsDollar;
- (void)upgradeFromVersion1;
- (void)initializeSampleTrip;
- (void)initializeStartDatabase:(NSBundle *)bundle;
@end

@implementation DataInitialiser

- (void)performDataInitialisations:(UIWindow *)window inContext:(NSManagedObjectContext *)context {

    [Crittercism leaveBreadcrumb:@"DataInitialiser: performDataInitialisations start"];

    _context = [context retain];

    [self initializeStartDatabase:[NSBundle mainBundle]];
    
    [self initializeSampleTrip];
    
    [self fixUsDollar];

    [self upgradeFromVersion1];
    
    [Crittercism leaveBreadcrumb:@"DataInitialiser: performDataInitialisations end"];
    
}

- (void)fixUsDollar {
    
    [Crittercism leaveBreadcrumb:@"DataInitialiser: fixUsDollar"];
    
    NSFetchRequest *req = [[NSFetchRequest alloc] init];
    req.entity = [NSEntityDescription entityForName:@"Currency" inManagedObjectContext: _context];
    req.predicate = [NSPredicate predicateWithFormat:@"name_de == 'Us-Dollar'"];
    NSArray *currencies = [_context executeFetchRequest:req error:nil];    
    if (currencies && [currencies count] == 1) {
        Currency *currency = [currencies lastObject];
        currency.name_de = @"US-Dollar";
        [ReiseabrechnungAppDelegate saveContext:_context];
    }
    [req release];
}



- (void)initializeStartDatabase:(NSBundle *)bundle {
    
    [Crittercism leaveBreadcrumb:@"DataInitialiser: initializeStartDatabase start"];
    
    NSFetchRequest *req = [[NSFetchRequest alloc] init];
    req.entity = [NSEntityDescription entityForName:@"Currency" inManagedObjectContext: _context];
    NSArray *currencies = [_context executeFetchRequest:req error:nil];

    [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"travelInitialised"];
    [[NSUserDefaults standardUserDefaults] synchronize];
    
    if (![currencies lastObject]) {
        
        dispatch_async(dispatch_get_main_queue(), ^{
            [[MTStatusBarOverlay sharedInstance] postMessage:NSLocalizedString(@"Initialising...", @"DataInitialiser") animated:YES];
        });
        
        NSLog(@"Initialising countries...");
        NSString *pathCountryPlist =[bundle pathForResource:@"countries" ofType:@"plist"];
        NSDictionary* countryDict = [[NSDictionary alloc] initWithContentsOfFile:pathCountryPlist];
        NSArray *countries = [countryDict valueForKey:@"countries"];
        
        NSMutableDictionary *orderCountryDict = [[NSMutableDictionary alloc] init];
        
        for (NSDictionary *countryItem in countries) {
            Country *_country = [NSEntityDescription insertNewObjectForEntityForName:@"Country" inManagedObjectContext:_context];
            _country.name = [countryItem valueForKey:@"name"];
            _country.name_de = [countryItem valueForKey:@"name_de"];
            _country.image = [countryItem valueForKey:@"image"];
            
            NSString *countryId = [NSString stringWithFormat:@"%@", [countryItem valueForKey:@"id"]];
            [orderCountryDict setValue:_country forKey:countryId];
            
            NSDictionary *cities = [countryItem valueForKey:@"cities"];
            for (NSDictionary *cityItem in cities) {
                City *_city = [NSEntityDescription insertNewObjectForEntityForName:@"City" inManagedObjectContext:_context];
                _city.name = [cityItem valueForKey:@"name"];
                _city.latitude = [cityItem valueForKey:@"latitude"];
                _city.longitude = [cityItem valueForKey:@"longitude"];
                _city.country = _country;
            }
        }
        [countryDict release];
        
        NSLog(@"Initialising currencies...");
        NSString *pathCurrencyPlist =[bundle pathForResource:@"currencies" ofType:@"plist"];
        NSDictionary* currencyDict = [[NSDictionary alloc] initWithContentsOfFile:pathCurrencyPlist];
        NSArray *currencies = [currencyDict valueForKey:@"currencies"];
        
        NSMutableDictionary *newCurrencies = [NSMutableDictionary dictionary];
        
        for (NSDictionary *currencyItem in currencies) {
            
            NSString *currencyIsoCode = [[currencyItem valueForKey:@"code"] uppercaseString];
            Currency *_currency = [newCurrencies objectForKey:currencyIsoCode];
            if (!_currency) {
                _currency = [NSEntityDescription insertNewObjectForEntityForName:@"Currency" inManagedObjectContext:_context];
                [newCurrencies setObject:_currency forKey:currencyIsoCode];
            }
            _currency.code = currencyIsoCode;
            _currency.name = [[currencyItem valueForKey:@"name"] capitalizedString];
            _currency.name_de = [[currencyItem valueForKey:@"name_de"] capitalizedString];
            _currency.digits = [currencyItem valueForKey:@"digits"];
            
            NSArray *countriesForCurrency = [currencyItem valueForKey:@"countries"];
            for (id countryItem in countriesForCurrency) {
                NSString *countryId = [NSString stringWithFormat:@"%@", countryItem];
                [_currency addCountriesObject:(Country *)[orderCountryDict objectForKey:countryId]];
            }
            
            NSDictionary *ratesForCurrency = [currencyItem valueForKey:@"rates"];
            NSEnumerator *ratesForCurrencyEnum = [ratesForCurrency keyEnumerator];
            for (NSString *ratesForCurrencyKey in [ratesForCurrencyEnum allObjects]) {
                
                if ([ratesForCurrencyKey isEqualToString:@"EUR"]) {
                    ratesForCurrencyKey = [ratesForCurrencyKey uppercaseString];
                    ExchangeRate *rate = [NSEntityDescription insertNewObjectForEntityForName:@"ExchangeRate" inManagedObjectContext:_context];
                    
                    rate.counterCurrency = _currency;
                    rate.rate = [ratesForCurrency valueForKey:ratesForCurrencyKey];
                    rate.defaultRate = [NSNumber numberWithInt:1];
                    
                    Currency *baseCurrency = [newCurrencies objectForKey:ratesForCurrencyKey];
                    if (!baseCurrency) {
                        baseCurrency = [NSEntityDescription insertNewObjectForEntityForName:@"Currency" inManagedObjectContext:_context];
                        baseCurrency.code = ratesForCurrencyKey;
                        [newCurrencies setObject:baseCurrency forKey:ratesForCurrencyKey];
                    }
                    rate.baseCurrency = baseCurrency;
                    
                    //[_currency addRatesObject:rate];
                }
            }
        }
        
        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
        if (![defaults objectForKey:[CurrencyRefresh lastUpdatedKey]]) {
            [defaults setObject:[currencyDict valueForKey:@"lastUpdated"] forKey:[CurrencyRefresh lastUpdatedKey]];
            [defaults synchronize];                
        }
        
        [currencyDict release];
        [orderCountryDict release];
        
        [ReiseabrechnungAppDelegate saveContext:_context];
        
    }
    
    currencies = [_context executeFetchRequest:req error:nil];
    [req release];
    
    for (Currency *c in currencies) {
        if ([c.rates count] == 0){
            NSLog(@"no rate for currency %@", c.name);
        }
    }
    
    [Crittercism leaveBreadcrumb:@"DataInitialiser: initializeStartDatabase initTypes"];
    
    NSFetchRequest *reqType = [[NSFetchRequest alloc] init];
    reqType.entity = [NSEntityDescription entityForName:@"Type" inManagedObjectContext: _context];
    NSArray *types = [_context executeFetchRequest:reqType error:nil];
    [reqType release];
    
    Type *_defaultType = nil;
    if (![types lastObject]) {
        
        NSLog(@"Initialising types...");
        
        NSString *typesPlistPath = [bundle pathForResource:@"types" ofType:@"plist"];
        NSArray *staticTypeNames = [[NSDictionary dictionaryWithContentsOfFile:typesPlistPath] valueForKey:@"types"];
        
        for (NSDictionary *staticTypeNameDict in staticTypeNames) {
            Type *_type = [NSEntityDescription insertNewObjectForEntityForName:@"Type" inManagedObjectContext:_context];
            
            for (NSString *key in [staticTypeNameDict keyEnumerator]) {
                SEL setter = NSSelectorFromString([NSString stringWithFormat:@"set%@%@:", [[key substringToIndex:1] uppercaseString], [key substringFromIndex:1], nil]);
                if ([_type respondsToSelector:setter]) {
                    [_type performSelector:setter withObject:[staticTypeNameDict objectForKey:key]];
                }
            }
            
            if ([_type.name isEqualToString:@"Other"]) {
                _defaultType = _type;
            }
        }
        
        [ReiseabrechnungAppDelegate saveContext:_context];
    }
    
    AppDefaults *defaultObject = [ReiseabrechnungAppDelegate defaultsObject:_context];
    
    if (!defaultObject.homeCurrency) {
        
        NSLog(@"Initialising defaults...");
        defaultObject.homeCurrency = [ReiseabrechnungAppDelegate defaultCurrency:_context];
        defaultObject.defaultType = _defaultType;
        
        [ReiseabrechnungAppDelegate saveContext:_context];
    }
    
}

- (void)initializeSampleTrip {
    
    [Crittercism leaveBreadcrumb:@"DataInitialiser: initializeSampleTrip"];
    
    if (![[ReiseabrechnungAppDelegate defaultsObject:_context].sampleTravelCreated isEqual:[NSNumber numberWithInt:1]]) {
        
        NSLog(@"Initialising sample travel...");
        
        Travel *travel = [NSEntityDescription insertNewObjectForEntityForName:@"Travel" inManagedObjectContext:_context];
        travel.name = NSLocalizedString(@"Sample Trip", @"sample trip name");
        travel.city = NSLocalizedString(@"Vienna", @"sampe trip Stadt");
        travel.closed = [NSNumber numberWithInt:0];
        
        NSFetchRequest *req = [[NSFetchRequest alloc] init];
        req.entity = [NSEntityDescription entityForName:@"Country" inManagedObjectContext: _context];
        req.predicate = [NSPredicate predicateWithFormat:@"name = 'Austria'"];
        
        travel.country = [[_context executeFetchRequest:req error:nil] lastObject];
        [req release];
        
        // currencies
        req = [[NSFetchRequest alloc] init];
        req.entity = [NSEntityDescription entityForName:@"Currency" inManagedObjectContext: _context];
        req.predicate = [NSPredicate predicateWithFormat:@"code = 'USD'"];
        Currency *usdCurrency = [[_context executeFetchRequest:req error:nil] lastObject];
        [travel addCurrenciesObject:usdCurrency];
        [req release];
        
        req = [[NSFetchRequest alloc] init];
        req.entity = [NSEntityDescription entityForName:@"Currency" inManagedObjectContext: _context];
        req.predicate = [NSPredicate predicateWithFormat:@"code = 'EUR'"];
        Currency *eurCurrency = [[_context executeFetchRequest:req error:nil] lastObject];
        [travel addCurrenciesObject:eurCurrency];
        [req release];
        
        // rates
        [travel addRatesObject:usdCurrency.defaultRate];
        [travel addRatesObject:eurCurrency.defaultRate];
        
        travel.displayCurrency = eurCurrency;
        travel.displaySort = [NSNumber numberWithInt:1];
        
        Participant *p1 = [NSEntityDescription insertNewObjectForEntityForName:@"Participant" inManagedObjectContext:_context];
        p1.name =  @"Leonardo";
        p1.email = @"leonardo@tmnt.com";
        p1.image = [NSData dataWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"leo" ofType:@"png"]];
        p1.imageSmall = UIImagePNGRepresentation([UIFactory imageWithImage:[UIImage imageWithData:p1.image] scaledToSize:CGSizeMake(32, 32)]);
        
        Participant *p2 = [NSEntityDescription insertNewObjectForEntityForName:@"Participant" inManagedObjectContext:_context];
        p2.name =  @"Raphael";
        p2.email = @"raphael@tmnt.com";
        p2.image = [NSData dataWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"raphael" ofType:@"png"]];
        p2.imageSmall = UIImagePNGRepresentation([UIFactory imageWithImage:[UIImage imageWithData:p2.image] scaledToSize:CGSizeMake(32, 32)]);
        
        Participant *p3 = [NSEntityDescription insertNewObjectForEntityForName:@"Participant" inManagedObjectContext:_context];
        p3.name =  @"Donatello";
        p3.email = @"donatello@tmnt.com";
        p3.image = [NSData dataWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"donatello" ofType:@"png"]];
        p3.imageSmall = UIImagePNGRepresentation([UIFactory imageWithImage:[UIImage imageWithData:p3.image] scaledToSize:CGSizeMake(32, 32)]);
        
        Participant *p4 = [NSEntityDescription insertNewObjectForEntityForName:@"Participant" inManagedObjectContext:_context];
        p4.name =  @"Michelangelo";
        p4.email = @"michelangelo@tmnt.com";
        p4.image = [NSData dataWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"michelangelo" ofType:@"png"]];
        p4.imageSmall = UIImagePNGRepresentation([UIFactory imageWithImage:[UIImage imageWithData:p4.image] scaledToSize:CGSizeMake(32, 32)]);
        
        [travel addParticipantsObject:p1];
        [travel addParticipantsObject:p2];
        [travel addParticipantsObject:p3];
        [travel addParticipantsObject:p4];
        
        NSArray *participantArray = [NSArray arrayWithObjects:p1, p2, p3, p4, nil];
        
        NSString *sampleTripPlist =[[NSBundle mainBundle] pathForResource:@"sampleTrip" ofType:@"plist"];
        NSDictionary *sampleTripDict = [[NSDictionary alloc] initWithContentsOfFile:sampleTripPlist];
        
        NSArray *entriesArray = [sampleTripDict objectForKey:@"entries"];

        for (NSDictionary *entryDict in entriesArray) {
            
            Entry *entry = [NSEntityDescription insertNewObjectForEntityForName:@"Entry" inManagedObjectContext:_context];
            entry.travel = travel;
            
            entry.created = [NSDate date];
            entry.lastUpdated = [NSDate date];
            
            entry.payer = [participantArray objectAtIndex:[[entryDict objectForKey:@"payer"] intValue]];
            entry.text = [entryDict objectForKey:@"description"];
            entry.amount = [entryDict objectForKey:@"amount"];
            
            NSDate *date = [[UIFactory createDateWithoutTimeFromDate:[NSDate date]] dateByAddingTimeInterval:-7 * 60 * 60 * 24];
            entry.date = [date dateByAddingTimeInterval:([[entryDict objectForKey:@"date"] intValue] * 60 * 60 * 24)];
            
            NSArray *receiverArray = [entryDict objectForKey:@"receivers"];
            for (NSNumber *receiverNumber in receiverArray) {
                ReceiverWeight *recWeight = [NSEntityDescription insertNewObjectForEntityForName:@"ReceiverWeight" inManagedObjectContext:_context];
                recWeight.weight = [NSNumber numberWithDouble:1.0];
                recWeight.participant = [participantArray objectAtIndex:[receiverNumber intValue]];
                [entry addReceiverWeightsObject:recWeight];
            }
            
            if ([[entryDict objectForKey:@"currency"] isEqualToString:@"USD"]) {
                entry.currency = usdCurrency;
            } else if ([[entryDict objectForKey:@"currency"] isEqualToString:@"EUR"]) {
                entry.currency = eurCurrency;
            }
            
            req = [[NSFetchRequest alloc] init];
            req.entity = [NSEntityDescription entityForName:@"Type" inManagedObjectContext: _context];
            req.predicate = [NSPredicate predicateWithFormat:@"name = %@", [entryDict objectForKey:@"type"]];
            entry.type = [[_context executeFetchRequest:req error:nil] lastObject];
            [req release];
        }
        [sampleTripDict release];
        
        [Summary updateSummaryOfTravel:travel];
        
        [ReiseabrechnungAppDelegate defaultsObject:_context].sampleTravelCreated = [NSNumber numberWithInt:1];
        [ReiseabrechnungAppDelegate saveContext:_context];
    }
    
}

- (void)upgradeFromVersion1 {
    
    [Crittercism leaveBreadcrumb:@"DataInitialiser: upgradeFromVersion1"];
    
    NSFetchRequest *req = [[NSFetchRequest alloc] init];
    req.entity = [NSEntityDescription entityForName:@"Travel" inManagedObjectContext: _context];
    NSArray *travels = [_context executeFetchRequest:req error:nil];
    [req release];
    
    for (Travel* travel in travels) {
        for (Entry *entry in travel.entries) {
            if (entry.receivers) {
                for (Participant *participant in entry.receivers) {
                    ReceiverWeight *recWeight = [NSEntityDescription insertNewObjectForEntityForName:@"ReceiverWeight" inManagedObjectContext:_context];
                    recWeight.participant = participant;
                    recWeight.weight = [NSNumber numberWithInt:1];
                    [entry addReceiverWeightsObject:recWeight];
                }
                [entry removeReceivers:entry.receivers];
            }
        }
        if ([travel isOpen]) {
            [Summary updateSummaryOfTravel:travel]; 
        }
    }
    
    [ReiseabrechnungAppDelegate saveContext:_context];
}

- (void)dealloc {
    [_context release];
    [super dealloc];
}

@end
