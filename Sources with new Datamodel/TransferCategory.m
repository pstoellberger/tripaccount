//
//  TransferCategory.m
//  Reiseabrechnung
//
//  Created by Martin Maier on 30/08/2011.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "TransferCategory.h"
#import <Foundation/Foundation.h>
#import "Travel.h"
#import "Currency.h"
#import "CurrencyHelperCategory.h"

@implementation Transfer (Sort)

- (NSNumber *)amountInDisplayCurrency {
    
    return [NSNumber numberWithDouble:[self.currency convertTravelAmount:self.travel currency:self.travel.displayCurrency amount:[self.amount doubleValue]]];
    
}

@end