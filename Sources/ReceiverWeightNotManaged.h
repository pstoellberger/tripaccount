//
//  ReceiverWeightNotManaged.h
//  Reiseabrechnung
//
//  Created by Martin Maier on 04/12/2011.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Participant.h"
#import "Entry.h"

@interface ReceiverWeightNotManaged : NSObject

@property (nonatomic, retain) NSNumber * weight;
@property (nonatomic, retain) Participant *participant;
@property (nonatomic, retain) Entry *entry;
@property (nonatomic) BOOL active;

- (id)initWithParticiant:(Participant *)participant andWeight:(NSNumber *)weight;

@end
