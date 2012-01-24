//
//  TravelSerialiser.h
//  Reiseabrechnung
//
//  Created by Martin Maier on 22/01/2012.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Travel.h"
#import "Participant.h"
#import "Entry.h"
#import "ReceiverWeight.h"
#import "Type.h"

@interface Travel (Serialiser)
- (NSDictionary *)serialise;
@end

@interface Participant (Serialiser)
- (NSDictionary *)serialise;
@end

@interface Entry (Serialiser)
- (NSDictionary *)serialise;
@end

@interface ReceiverWeight (Serialiser)
- (NSDictionary *)serialise;
@end