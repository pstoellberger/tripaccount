//
//  ReceiverWeight.h
//  Reiseabrechnung
//
//  Created by Martin Maier on 04/12/2011.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Entry, Participant;

@interface ReceiverWeight : NSManagedObject

@property (nonatomic, retain) NSNumber * weight;
@property (nonatomic, retain) Participant *participant;
@property (nonatomic, retain) Entry *entry;

@end
