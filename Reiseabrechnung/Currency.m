//
//  Currency.m
//  Reiseabrechnung
//
//  Created by Martin Maier on 18/07/2011.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "Currency.h"
#import "Country.h"
#import "Entry.h"
#import "Travel.h"


@implementation Currency
@dynamic code;
@dynamic name;
@dynamic digits;
@dynamic entries;
@dynamic travels;
@dynamic origins;
@dynamic countries;

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


- (void)addTravelsObject:(Travel *)value {    
    NSSet *changedObjects = [[NSSet alloc] initWithObjects:&value count:1];
    [self willChangeValueForKey:@"travels" withSetMutation:NSKeyValueUnionSetMutation usingObjects:changedObjects];
    [[self primitiveValueForKey:@"travels"] addObject:value];
    [self didChangeValueForKey:@"travels" withSetMutation:NSKeyValueUnionSetMutation usingObjects:changedObjects];
    [changedObjects release];
}

- (void)removeTravelsObject:(Travel *)value {
    NSSet *changedObjects = [[NSSet alloc] initWithObjects:&value count:1];
    [self willChangeValueForKey:@"travels" withSetMutation:NSKeyValueMinusSetMutation usingObjects:changedObjects];
    [[self primitiveValueForKey:@"travels"] removeObject:value];
    [self didChangeValueForKey:@"travels" withSetMutation:NSKeyValueMinusSetMutation usingObjects:changedObjects];
    [changedObjects release];
}

- (void)addTravels:(NSSet *)value {    
    [self willChangeValueForKey:@"travels" withSetMutation:NSKeyValueUnionSetMutation usingObjects:value];
    [[self primitiveValueForKey:@"travels"] unionSet:value];
    [self didChangeValueForKey:@"travels" withSetMutation:NSKeyValueUnionSetMutation usingObjects:value];
}

- (void)removeTravels:(NSSet *)value {
    [self willChangeValueForKey:@"travels" withSetMutation:NSKeyValueMinusSetMutation usingObjects:value];
    [[self primitiveValueForKey:@"travels"] minusSet:value];
    [self didChangeValueForKey:@"travels" withSetMutation:NSKeyValueMinusSetMutation usingObjects:value];
}


- (void)addOriginsObject:(Travel *)value {    
    NSSet *changedObjects = [[NSSet alloc] initWithObjects:&value count:1];
    [self willChangeValueForKey:@"origins" withSetMutation:NSKeyValueUnionSetMutation usingObjects:changedObjects];
    [[self primitiveValueForKey:@"origins"] addObject:value];
    [self didChangeValueForKey:@"origins" withSetMutation:NSKeyValueUnionSetMutation usingObjects:changedObjects];
    [changedObjects release];
}

- (void)removeOriginsObject:(Travel *)value {
    NSSet *changedObjects = [[NSSet alloc] initWithObjects:&value count:1];
    [self willChangeValueForKey:@"origins" withSetMutation:NSKeyValueMinusSetMutation usingObjects:changedObjects];
    [[self primitiveValueForKey:@"origins"] removeObject:value];
    [self didChangeValueForKey:@"origins" withSetMutation:NSKeyValueMinusSetMutation usingObjects:changedObjects];
    [changedObjects release];
}

- (void)addOrigins:(NSSet *)value {    
    [self willChangeValueForKey:@"origins" withSetMutation:NSKeyValueUnionSetMutation usingObjects:value];
    [[self primitiveValueForKey:@"origins"] unionSet:value];
    [self didChangeValueForKey:@"origins" withSetMutation:NSKeyValueUnionSetMutation usingObjects:value];
}

- (void)removeOrigins:(NSSet *)value {
    [self willChangeValueForKey:@"origins" withSetMutation:NSKeyValueMinusSetMutation usingObjects:value];
    [[self primitiveValueForKey:@"origins"] minusSet:value];
    [self didChangeValueForKey:@"origins" withSetMutation:NSKeyValueMinusSetMutation usingObjects:value];
}


- (void)addCountriesObject:(Country *)value {    
    NSSet *changedObjects = [[NSSet alloc] initWithObjects:&value count:1];
    [self willChangeValueForKey:@"countries" withSetMutation:NSKeyValueUnionSetMutation usingObjects:changedObjects];
    [[self primitiveValueForKey:@"countries"] addObject:value];
    [self didChangeValueForKey:@"countries" withSetMutation:NSKeyValueUnionSetMutation usingObjects:changedObjects];
    [changedObjects release];
}

- (void)removeCountriesObject:(Country *)value {
    NSSet *changedObjects = [[NSSet alloc] initWithObjects:&value count:1];
    [self willChangeValueForKey:@"countries" withSetMutation:NSKeyValueMinusSetMutation usingObjects:changedObjects];
    [[self primitiveValueForKey:@"countries"] removeObject:value];
    [self didChangeValueForKey:@"countries" withSetMutation:NSKeyValueMinusSetMutation usingObjects:changedObjects];
    [changedObjects release];
}

- (void)addCountries:(NSSet *)value {    
    [self willChangeValueForKey:@"countries" withSetMutation:NSKeyValueUnionSetMutation usingObjects:value];
    [[self primitiveValueForKey:@"countries"] unionSet:value];
    [self didChangeValueForKey:@"countries" withSetMutation:NSKeyValueUnionSetMutation usingObjects:value];
}

- (void)removeCountries:(NSSet *)value {
    [self willChangeValueForKey:@"countries" withSetMutation:NSKeyValueMinusSetMutation usingObjects:value];
    [[self primitiveValueForKey:@"countries"] minusSet:value];
    [self didChangeValueForKey:@"countries" withSetMutation:NSKeyValueMinusSetMutation usingObjects:value];
}


@end
