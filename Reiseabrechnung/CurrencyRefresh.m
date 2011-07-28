//
//  CurrencyRefresh.m
//  Reiseabrechnung
//
//  Created by Martin Maier on 27/07/2011.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "CurrencyRefresh.h"
#import "Currency.h"
#import "ExchangeRate.h"
#import "ReiseabrechnungAppDelegate.h"

@interface CurrencyRefresh ()

- (NSString *)buildURL:(NSManagedObjectContext *)context baseIsoCode:(NSString *)baseCurrencyCode;

@end

@implementation CurrencyRefresh

- (id)initInManagedContext:(NSManagedObjectContext *)context {

    if (self = [super init]) {
        
        _context = [context retain];

        NSFetchRequest *req = [[NSFetchRequest alloc] init];
        req.entity = [NSEntityDescription entityForName:@"Currency" inManagedObjectContext: context];
        _currencies = [[context executeFetchRequest:req error:nil] retain];
        [req release];
        
    }
    
    return self;
}

- (NSString *)buildURL:(NSManagedObjectContext *)context baseIsoCode:(NSString *)baseCurrencyCode {
    
    NSMutableString *url = [NSMutableString stringWithString:@"http://finance.yahoo.com/d/quotes.csv?e=.csv&f=sl1d1t1&s="];
    for (Currency *currency in _currencies) {
        [url appendFormat:@"%@%@=X+", baseCurrencyCode, currency.code, nil]; 
    }
    
    return url;
}

- (BOOL)refreshCurrencies:(NSString *)baseIsoCode {
    
    NSHTTPURLResponse *response;
    NSError *error;
    BOOL returnValue = NO;
    
    //prepare request
	NSString *urlString = [self buildURL:_context baseIsoCode:baseIsoCode];
	NSMutableURLRequest *request = [[[NSMutableURLRequest alloc] initWithURL:[NSURL URLWithString:urlString]
                                                                 cachePolicy:NSURLRequestReloadIgnoringCacheData 
                                                             timeoutInterval:60] autorelease];
	
    NSData *responseData = [NSURLConnection sendSynchronousRequest:request returningResponse:&response error:&error]; 
    
    Currency *baseCurrency = nil;
    for (Currency *currency in _currencies) {
        if ([currency.code isEqualToString:baseIsoCode]) {
            baseCurrency = currency;
            break;
        }
    }
    if (!baseCurrency) {
        NSLog(@"Invalid base currency ISO code %@.", baseIsoCode);
        return NO;
    }
    
	//get response   
	NSString *result = [[NSString alloc] initWithData:responseData encoding:NSUTF8StringEncoding];
	NSLog(@"Response Code: %d", [response statusCode]);
    
	if ([response statusCode] >= 200 && [response statusCode] < 300) {
        
        NSArray *lines = [result componentsSeparatedByString: @"\n"];
        
        for (NSString *line in lines) {

            // format is: "EURSTD=X",24378.7051,"7/27/2011","11:22am"
            NSArray *lineComponents = [line componentsSeparatedByString: @","];
            
            if ([lineComponents count] > 2) {
                
                NSString *firstComponent = [lineComponents objectAtIndex:0];
                
                if ([firstComponent length] > 6) {
                    
                    NSString *currencyCode = [firstComponent substringWithRange:NSMakeRange(4, 3)];
                    double currencyRate = [[lineComponents objectAtIndex:1] doubleValue];
                    
                    if (currencyRate != 0 && currencyRate != HUGE_VAL  && currencyRate != -HUGE_VAL) {
                        NSLog(@"%@ = %f", currencyCode, currencyRate);
                        
                        for (Currency *counterCurrency in _currencies) {
                            
                            if ([currencyCode isEqualToString:counterCurrency.code]) {
                                
                                ExchangeRate *updateRate = nil;
                                for (ExchangeRate *rate in counterCurrency.ratesWithBaseCurrency) {
                                    
                                    if ([rate.baseCurrency.code isEqualToString:baseIsoCode]) {
                                        updateRate = rate;
                                        break;
                                    }
                                }
                                
                                if (!updateRate) {
                                    updateRate = [NSEntityDescription insertNewObjectForEntityForName:@"ExchangeRate" inManagedObjectContext:_context];
                                    updateRate.baseCurrency = baseCurrency;
                                    updateRate.counterCurrency = counterCurrency;
                                }
                                
                                updateRate.rate = [NSNumber numberWithDouble:currencyRate];
                                updateRate.lastUpdated = [NSDate date];
                            }
                        }
                    }
                }
            }
        }
        
        [ReiseabrechnungAppDelegate saveContext:_context];
		        
        //here you get the response
        returnValue = YES;
	} else {
        returnValue = NO;
    }
    [result release];
    
    return returnValue;
}

- (void)dealloc {
    [_context release];
    [_currencies release];
    
    [super dealloc];
}

@end
