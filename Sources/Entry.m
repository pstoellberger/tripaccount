//
//  Entry.m
//  Reiseabrechnung
//
//  Created by Martin Maier on 15/01/2012.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "Entry.h"
#import "Currency.h"
#import "Participant.h"
#import "ReceiverWeight.h"
#import "Travel.h"
#import "Type.h"


@implementation Entry

@dynamic amount;
@dynamic lastUpdated;
@dynamic date;
@dynamic text;
@dynamic created;
@dynamic checked;
@dynamic notes;
@dynamic payer;
@dynamic type;
@dynamic receiverWeights;
@dynamic travel;
@dynamic currency;
@dynamic receivers;

@end
