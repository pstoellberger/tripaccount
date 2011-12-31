//
//  Entry.h
//  Reiseabrechnung
//
//  Created by Martin Maier on 04/12/2011.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Currency, Participant, ReceiverWeight, Travel, Type;

@interface Entry : NSManagedObject

@property (nonatomic, retain) NSNumber * amount;
@property (nonatomic, retain) NSNumber * checked;
@property (nonatomic, retain) NSDate * lastUpdated;
@property (nonatomic, retain) NSDate * date;
@property (nonatomic, retain) NSString * text;
@property (nonatomic, retain) NSDate * created;
@property (nonatomic, retain) Travel *travel;
@property (nonatomic, retain) Type *type;
@property (nonatomic, retain) Participant *payer;
@property (nonatomic, retain) NSSet *receivers;
@property (nonatomic, retain) Currency *currency;
@property (nonatomic, retain) NSSet *receiverWeights;
@end

@interface Entry (CoreDataGeneratedAccessors)

- (void)addReceiversObject:(Participant *)value;
- (void)removeReceiversObject:(Participant *)value;
- (void)addReceivers:(NSSet *)values;
- (void)removeReceivers:(NSSet *)values;

- (void)addReceiverWeightsObject:(ReceiverWeight *)value;
- (void)removeReceiverWeightsObject:(ReceiverWeight *)value;
- (void)addReceiverWeights:(NSSet *)values;
- (void)removeReceiverWeights:(NSSet *)values;

@end
