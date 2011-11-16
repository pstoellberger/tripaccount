//
//  EntryReceiver.h
//  Reiseabrechnung
//
//  Created by Martin Maier on 18/10/2011.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Entry, Participant;

@interface EntryReceiver : NSManagedObject

@property (nonatomic, retain) NSDecimalNumber * coefficient;
@property (nonatomic, retain) Participant *receiver;
@property (nonatomic, retain) Entry *entry;

@end
