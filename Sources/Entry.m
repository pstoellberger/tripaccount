//
//  Entry.m
//  Reiseabrechnung
//
//  Created by Martin Maier on 01/11/2011.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "Entry.h"
#import "Currency.h"
#import "Participant.h"
#import "Travel.h"
#import "Type.h"


@implementation Entry

@dynamic amount;
@dynamic checked;
@dynamic lastUpdated;
@dynamic date;
@dynamic text;
@dynamic created;
@dynamic travel;
@dynamic type;
@dynamic payer;
@dynamic receivers;
@dynamic currency;

@end
