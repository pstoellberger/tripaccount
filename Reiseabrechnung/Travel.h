//
//  Travel.h
//  Reiseabrechnung
//
//  Created by Martin Maier on 30/06/2011.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Entry, Participant;

@interface Travel : NSManagedObject {
@private
}
@property (nonatomic, retain) NSString * currency;
@property (nonatomic, retain) NSDate * created;
@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) NSSet* entries;
@property (nonatomic, retain) NSSet* participants;

@end
