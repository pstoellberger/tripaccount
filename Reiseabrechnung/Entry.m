//
//  Entry.m
//  Reiseabrechnung
//
//  Created by Martin Maier on 16/07/2011.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "Entry.h"
#import "Currency.h"
#import "Participant.h"
#import "Travel.h"


@implementation Entry
@dynamic amount;
@dynamic date;
@dynamic text;
@dynamic travel;
@dynamic payer;
@dynamic receivers;
@dynamic currency;



- (void)addReceiversObject:(Participant *)value {    
    NSSet *changedObjects = [[NSSet alloc] initWithObjects:&value count:1];
    [self willChangeValueForKey:@"receivers" withSetMutation:NSKeyValueUnionSetMutation usingObjects:changedObjects];
    [[self primitiveValueForKey:@"receivers"] addObject:value];
    [self didChangeValueForKey:@"receivers" withSetMutation:NSKeyValueUnionSetMutation usingObjects:changedObjects];
    [changedObjects release];
}

- (void)removeReceiversObject:(Participant *)value {
    NSSet *changedObjects = [[NSSet alloc] initWithObjects:&value count:1];
    [self willChangeValueForKey:@"receivers" withSetMutation:NSKeyValueMinusSetMutation usingObjects:changedObjects];
    [[self primitiveValueForKey:@"receivers"] removeObject:value];
    [self didChangeValueForKey:@"receivers" withSetMutation:NSKeyValueMinusSetMutation usingObjects:changedObjects];
    [changedObjects release];
}

- (void)addReceivers:(NSSet *)value {    
    [self willChangeValueForKey:@"receivers" withSetMutation:NSKeyValueUnionSetMutation usingObjects:value];
    [[self primitiveValueForKey:@"receivers"] unionSet:value];
    [self didChangeValueForKey:@"receivers" withSetMutation:NSKeyValueUnionSetMutation usingObjects:value];
}

- (void)removeReceivers:(NSSet *)value {
    [self willChangeValueForKey:@"receivers" withSetMutation:NSKeyValueMinusSetMutation usingObjects:value];
    [[self primitiveValueForKey:@"receivers"] minusSet:value];
    [self didChangeValueForKey:@"receivers" withSetMutation:NSKeyValueMinusSetMutation usingObjects:value];
}



@end
