//
//  Participant.m
//  Reiseabrechnung
//
//  Created by Martin Maier on 15/01/2012.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "Participant.h"
#import "Entry.h"
#import "ReceiverWeight.h"
#import "Transfer.h"
#import "Travel.h"


@implementation Participant

@dynamic imageSmall;
@dynamic yourself;
@dynamic weight;
@dynamic image;
@dynamic email;
@dynamic name;
@dynamic notes;
@dynamic transfersAsDebtor;
@dynamic transfersAsDebtee;
@dynamic pays;
@dynamic getPayedFor;
@dynamic receiverWeights;
@dynamic travel;
@dynamic lastUsedInTravel;

@end
