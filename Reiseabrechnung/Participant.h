//
//  Participant.h
//  Reiseabrechnung
//
//  Created by Martin Maier on 02/08/2011.
//  Copyright (c) 2011 Martin Maier. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Entry, Travel;

@interface Participant : NSManagedObject {
@private
}
@property (nonatomic, retain) NSString * email;
@property (nonatomic, retain) NSData * image;
@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) Travel *travel;
@property (nonatomic, retain) NSSet *pays;
@property (nonatomic, retain) Travel *lastUsedInTravel;
@property (nonatomic, retain) NSSet *getPayedFor;
@property (nonatomic, retain) NSSet *transfersAsDebtor;
@property (nonatomic, retain) NSSet *transfersAsDebtee;
@end

@interface Participant (CoreDataGeneratedAccessors)

- (void)addPaysObject:(Entry *)value;
- (void)removePaysObject:(Entry *)value;
- (void)addPays:(NSSet *)values;
- (void)removePays:(NSSet *)values;

- (void)addGetPayedForObject:(Entry *)value;
- (void)removeGetPayedForObject:(Entry *)value;
- (void)addGetPayedFor:(NSSet *)values;
- (void)removeGetPayedFor:(NSSet *)values;

- (void)addTransfersAsDebtorObject:(NSManagedObject *)value;
- (void)removeTransfersAsDebtorObject:(NSManagedObject *)value;
- (void)addTransfersAsDebtor:(NSSet *)values;
- (void)removeTransfersAsDebtor:(NSSet *)values;

- (void)addTransfersAsDebteeObject:(NSManagedObject *)value;
- (void)removeTransfersAsDebteeObject:(NSManagedObject *)value;
- (void)addTransfersAsDebtee:(NSSet *)values;
- (void)removeTransfersAsDebtee:(NSSet *)values;

@end
