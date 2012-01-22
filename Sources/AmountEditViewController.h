//
//  AmountEditViewController.h
//  Reiseabrechnung
//
//  Created by Martin Maier on 22/01/2012.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "NumberEditViewController.h"

@interface AmountEditViewController : NumberEditViewController

@property (nonatomic, retain) Travel *travel;
@property (nonatomic, retain) Currency *currency;

@property (nonatomic, assign) SEL selectorCurrency;


- (id)initWithNumber:(NSNumber *)startNumber withDecimals:(int)decimals currency:(Currency *)currency travel:(Travel *)travel andNamedImage:(NSString *)namedImage description:(NSString *)description target:(id)target selectorAmount:(SEL)selectorAmount selectorCurrency:(SEL)selectorCurrency;

@end
