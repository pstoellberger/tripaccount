//
//  Travel.m
//  Reiseabrechnung
//
//  Created by Martin Maier on 19/07/2011.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "Travel.h"
#import "Country.h"
#import "Currency.h"
#import "Entry.h"
#import "Participant.h"


@implementation Travel
@dynamic city;
@dynamic created;
@dynamic name;
@dynamic homeCurrency;
@dynamic participants;
@dynamic foreignCurrencies;
@dynamic entries;
@dynamic country;


- (void)addParticipantsObject:(Participant *)value {    
    NSSet *changedObjects = [[NSSet alloc] initWithObjects:&value count:1];
    [self willChangeValueForKey:@"participants" withSetMutation:NSKeyValueUnionSetMutation usingObjects:changedObjects];
    [[self primitiveValueForKey:@"participants"] addObject:value];
    [self didChangeValueForKey:@"participants" withSetMutation:NSKeyValueUnionSetMutation usingObjects:changedObjects];
    [changedObjects release];
}

- (void)removeParticipantsObject:(Participant *)value {
    NSSet *changedObjects = [[NSSet alloc] initWithObjects:&value count:1];
    [self willChangeValueForKey:@"participants" withSetMutation:NSKeyValueMinusSetMutation usingObjects:changedObjects];
    [[self primitiveValueForKey:@"participants"] removeObject:value];
    [self didChangeValueForKey:@"participants" withSetMutation:NSKeyValueMinusSetMutation usingObjects:changedObjects];
    [changedObjects release];
}

- (void)addParticipants:(NSSet *)value {    
    [self willChangeValueForKey:@"participants" withSetMutation:NSKeyValueUnionSetMutation usingObjects:value];
    [[self primitiveValueForKey:@"participants"] unionSet:value];
    [self didChangeValueForKey:@"participants" withSetMutation:NSKeyValueUnionSetMutation usingObjects:value];
}

- (void)removeParticipants:(NSSet *)value {
    [self willChangeValueForKey:@"participants" withSetMutation:NSKeyValueMinusSetMutation usingObjects:value];
    [[self primitiveValueForKey:@"participants"] minusSet:value];
    [self didChangeValueForKey:@"participants" withSetMutation:NSKeyValueMinusSetMutation usingObjects:value];
}


- (void)addForeignCurrenciesObject:(Currency *)value {    
    NSSet *changedObjects = [[NSSet alloc] initWithObjects:&value count:1];
    [self willChangeValueForKey:@"foreignCurrencies" withSetMutation:NSKeyValueUnionSetMutation usingObjects:changedObjects];
    [[self primitiveValueForKey:@"foreignCurrencies"] addObject:value];
    [self didChangeValueForKey:@"foreignCurrencies" withSetMutation:NSKeyValueUnionSetMutation usingObjects:changedObjects];
    [changedObjects release];
}

- (void)removeForeignCurrenciesObject:(Currency *)value {
    NSSet *changedObjects = [[NSSet alloc] initWithObjects:&value count:1];
    [self willChangeValueForKey:@"foreignCurrencies" withSetMutation:NSKeyValueMinusSetMutation usingObjects:changedObjects];
    [[self primitiveValueForKey:@"foreignCurrencies"] removeObject:value];
    [self didChangeValueForKey:@"foreignCurrencies" withSetMutation:NSKeyValueMinusSetMutation usingObjects:changedObjects];
    [changedObjects release];
}

- (void)addForeignCurrencies:(NSSet *)value {    
    [self willChangeValueForKey:@"foreignCurrencies" withSetMutation:NSKeyValueUnionSetMutation usingObjects:value];
    [[self primitiveValueForKey:@"foreignCurrencies"] unionSet:value];
    [self didChangeValueForKey:@"foreignCurrencies" withSetMutation:NSKeyValueUnionSetMutation usingObjects:value];
}

- (void)removeForeignCurrencies:(NSSet *)value {
    [self willChangeValueForKey:@"foreignCurrencies" withSetMutation:NSKeyValueMinusSetMutation usingObjects:value];
    [[self primitiveValueForKey:@"foreignCurrencies"] minusSet:value];
    [self didChangeValueForKey:@"foreignCurrencies" withSetMutation:NSKeyValueMinusSetMutation usingObjects:value];
}


- (void)addEntriesObject:(Entry *)value {    
    NSSet *changedObjects = [[NSSet alloc] initWithObjects:&value count:1];
    [self willChangeValueForKey:@"entries" withSetMutation:NSKeyValueUnionSetMutation usingObjects:changedObjects];
    [[self primitiveValueForKey:@"entries"] addObject:value];
    [self didChangeValueForKey:@"entries" withSetMutation:NSKeyValueUnionSetMutation usingObjects:changedObjects];
    [changedObjects release];
}

- (void)removeEntriesObject:(Entry *)value {
    NSSet *changedObjects = [[NSSet alloc] initWithObjects:&value count:1];
    [self willChangeValueForKey:@"entries" withSetMutation:NSKeyValueMinusSetMutation usingObjects:changedObjects];
    [[self primitiveValueForKey:@"entries"] removeObject:value];
    [self didChangeValueForKey:@"entries" withSetMutation:NSKeyValueMinusSetMutation usingObjects:changedObjects];
    [changedObjects release];
}

- (void)addEntries:(NSSet *)value {    
    [self willChangeValueForKey:@"entries" withSetMutation:NSKeyValueUnionSetMutation usingObjects:value];
    [[self primitiveValueForKey:@"entries"] unionSet:value];
    [self didChangeValueForKey:@"entries" withSetMutation:NSKeyValueUnionSetMutation usingObjects:value];
}

- (void)removeEntries:(NSSet *)value {
    [self willChangeValueForKey:@"entries" withSetMutation:NSKeyValueMinusSetMutation usingObjects:value];
    [[self primitiveValueForKey:@"entries"] minusSet:value];
    [self didChangeValueForKey:@"entries" withSetMutation:NSKeyValueMinusSetMutation usingObjects:value];
}



@end
