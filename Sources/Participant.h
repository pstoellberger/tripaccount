//
//  Participant.h
//  Reiseabrechnung
//
//  Created by Martin Maier on 30/08/2011.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Entry, Transfer, Travel;

@interface Participant : NSManagedObject {
@private
}
@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) NSData * image;
@property (nonatomic, retain) NSString * email;
@property (nonatomic, retain) NSNumber * yourself;
@property (nonatomic, retain) NSData * imageSmall;
@property (nonatomic, retain) Travel *travel;
@property (nonatomic, retain) NSSet *transfersAsDebtor;
@property (nonatomic, retain) Travel *lastUsedInTravel;
@property (nonatomic, retain) NSSet *pays;
@property (nonatomic, retain) NSSet *transfersAsDebtee;
@property (nonatomic, retain) NSSet *getPayedFor;
@end

@interface Participant (CoreDataGeneratedAccessors)

- (void)addTransfersAsDebtorObject:(Transfer *)value;
- (void)removeTransfersAsDebtorObject:(Transfer *)value;
- (void)addTransfersAsDebtor:(NSSet *)values;
- (void)removeTransfersAsDebtor:(NSSet *)values;

- (void)addPaysObject:(Entry *)value;
- (void)removePaysObject:(Entry *)value;
- (void)addPays:(NSSet *)values;
- (void)removePays:(NSSet *)values;

- (void)addTransfersAsDebteeObject:(Transfer *)value;
- (void)removeTransfersAsDebteeObject:(Transfer *)value;
- (void)addTransfersAsDebtee:(NSSet *)values;
- (void)removeTransfersAsDebtee:(NSSet *)values;

- (void)addGetPayedForObject:(Entry *)value;
- (void)removeGetPayedForObject:(Entry *)value;
- (void)addGetPayedFor:(NSSet *)values;
- (void)removeGetPayedFor:(NSSet *)values;

@end
