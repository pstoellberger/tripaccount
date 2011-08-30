//
//  Participant.m
//  Reiseabrechnung
//
//  Created by Martin Maier on 30/08/2011.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "Participant.h"
#import "Entry.h"
#import "Transfer.h"
#import "Travel.h"


@implementation Participant
@dynamic name;
@dynamic image;
@dynamic email;
@dynamic yourself;
@dynamic imageSmall;
@dynamic travel;
@dynamic transfersAsDebtor;
@dynamic lastUsedInTravel;
@dynamic pays;
@dynamic transfersAsDebtee;
@dynamic getPayedFor;

@end
