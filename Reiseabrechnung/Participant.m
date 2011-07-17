//
//  Participant.m
//  Reiseabrechnung
//
//  Created by Martin Maier on 16/07/2011.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "Participant.h"
#import "Entry.h"
#import "Travel.h"


@implementation Participant
@dynamic name;
@dynamic image;
@dynamic travel;
@dynamic getPayedFor;
@dynamic pays;


- (void)addGetPayedForObject:(Entry *)value {    
    NSSet *changedObjects = [[NSSet alloc] initWithObjects:&value count:1];
    [self willChangeValueForKey:@"getPayedFor" withSetMutation:NSKeyValueUnionSetMutation usingObjects:changedObjects];
    [[self primitiveValueForKey:@"getPayedFor"] addObject:value];
    [self didChangeValueForKey:@"getPayedFor" withSetMutation:NSKeyValueUnionSetMutation usingObjects:changedObjects];
    [changedObjects release];
}

- (void)removeGetPayedForObject:(Entry *)value {
    NSSet *changedObjects = [[NSSet alloc] initWithObjects:&value count:1];
    [self willChangeValueForKey:@"getPayedFor" withSetMutation:NSKeyValueMinusSetMutation usingObjects:changedObjects];
    [[self primitiveValueForKey:@"getPayedFor"] removeObject:value];
    [self didChangeValueForKey:@"getPayedFor" withSetMutation:NSKeyValueMinusSetMutation usingObjects:changedObjects];
    [changedObjects release];
}

- (void)addGetPayedFor:(NSSet *)value {    
    [self willChangeValueForKey:@"getPayedFor" withSetMutation:NSKeyValueUnionSetMutation usingObjects:value];
    [[self primitiveValueForKey:@"getPayedFor"] unionSet:value];
    [self didChangeValueForKey:@"getPayedFor" withSetMutation:NSKeyValueUnionSetMutation usingObjects:value];
}

- (void)removeGetPayedFor:(NSSet *)value {
    [self willChangeValueForKey:@"getPayedFor" withSetMutation:NSKeyValueMinusSetMutation usingObjects:value];
    [[self primitiveValueForKey:@"getPayedFor"] minusSet:value];
    [self didChangeValueForKey:@"getPayedFor" withSetMutation:NSKeyValueMinusSetMutation usingObjects:value];
}


- (void)addPaysObject:(Entry *)value {    
    NSSet *changedObjects = [[NSSet alloc] initWithObjects:&value count:1];
    [self willChangeValueForKey:@"pays" withSetMutation:NSKeyValueUnionSetMutation usingObjects:changedObjects];
    [[self primitiveValueForKey:@"pays"] addObject:value];
    [self didChangeValueForKey:@"pays" withSetMutation:NSKeyValueUnionSetMutation usingObjects:changedObjects];
    [changedObjects release];
}

- (void)removePaysObject:(Entry *)value {
    NSSet *changedObjects = [[NSSet alloc] initWithObjects:&value count:1];
    [self willChangeValueForKey:@"pays" withSetMutation:NSKeyValueMinusSetMutation usingObjects:changedObjects];
    [[self primitiveValueForKey:@"pays"] removeObject:value];
    [self didChangeValueForKey:@"pays" withSetMutation:NSKeyValueMinusSetMutation usingObjects:changedObjects];
    [changedObjects release];
}

- (void)addPays:(NSSet *)value {    
    [self willChangeValueForKey:@"pays" withSetMutation:NSKeyValueUnionSetMutation usingObjects:value];
    [[self primitiveValueForKey:@"pays"] unionSet:value];
    [self didChangeValueForKey:@"pays" withSetMutation:NSKeyValueUnionSetMutation usingObjects:value];
}

- (void)removePays:(NSSet *)value {
    [self willChangeValueForKey:@"pays" withSetMutation:NSKeyValueMinusSetMutation usingObjects:value];
    [[self primitiveValueForKey:@"pays"] minusSet:value];
    [self didChangeValueForKey:@"pays" withSetMutation:NSKeyValueMinusSetMutation usingObjects:value];
}


@end
