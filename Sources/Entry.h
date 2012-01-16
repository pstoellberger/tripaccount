//
//  Entry.h
//  Reiseabrechnung
//
//  Created by Martin Maier on 15/01/2012.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Currency, Participant, ReceiverWeight, Travel, Type;

@interface Entry : NSManagedObject

@property (nonatomic, retain) NSNumber * amount;
@property (nonatomic, retain) NSDate * lastUpdated;
@property (nonatomic, retain) NSDate * date;
@property (nonatomic, retain) NSString * text;
@property (nonatomic, retain) NSDate * created;
@property (nonatomic, retain) NSNumber * checked;
@property (nonatomic, retain) NSString * notes;
@property (nonatomic, retain) Participant *payer;
@property (nonatomic, retain) Type *type;
@property (nonatomic, retain) NSSet *receiverWeights;
@property (nonatomic, retain) Travel *travel;
@property (nonatomic, retain) Currency *currency;
@property (nonatomic, retain) NSSet *receivers;
@end

@interface Entry (CoreDataGeneratedAccessors)

- (void)addReceiverWeightsObject:(ReceiverWeight *)value;
- (void)removeReceiverWeightsObject:(ReceiverWeight *)value;
- (void)addReceiverWeights:(NSSet *)values;
- (void)removeReceiverWeights:(NSSet *)values;

- (void)addReceiversObject:(Participant *)value;
- (void)removeReceiversObject:(Participant *)value;
- (void)addReceivers:(NSSet *)values;
- (void)removeReceivers:(NSSet *)values;

@end
