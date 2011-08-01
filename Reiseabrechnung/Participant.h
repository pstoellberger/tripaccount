//
//  Participant.h
//  Reiseabrechnung
//
//  Created by Martin Maier on 01/08/2011.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Entry, Travel;

@interface Participant : NSManagedObject {
@private
}
@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) NSData * image;
@property (nonatomic, retain) NSString * email;
@property (nonatomic, retain) Travel *travel;
@property (nonatomic, retain) NSSet *getPayedFor;
@property (nonatomic, retain) NSSet *pays;
@property (nonatomic, retain) Travel *lastUsedInTravel;
@end

@interface Participant (CoreDataGeneratedAccessors)

- (void)addGetPayedForObject:(Entry *)value;
- (void)removeGetPayedForObject:(Entry *)value;
- (void)addGetPayedFor:(NSSet *)values;
- (void)removeGetPayedFor:(NSSet *)values;

- (void)addPaysObject:(Entry *)value;
- (void)removePaysObject:(Entry *)value;
- (void)addPays:(NSSet *)values;
- (void)removePays:(NSSet *)values;

@end
