//
//  TransferCategory.h
//  Reiseabrechnung
//
//  Created by Martin Maier on 30/08/2011.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Transfer.h"

@interface Transfer (Sort)

@property (nonatomic, readonly) NSNumber *amountInDisplayCurrency;

- (BOOL)wasPaid;

@end