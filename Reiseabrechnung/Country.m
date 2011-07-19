//
//  Country.m
//  Reiseabrechnung
//
//  Created by Martin Maier on 19/07/2011.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "Country.h"
#import "Currency.h"
#import "Travel.h"


@implementation Country
@dynamic name;
@dynamic image;
@dynamic currencies;
@dynamic travels;

- (void)addCurrenciesObject:(Currency *)value {    
    NSSet *changedObjects = [[NSSet alloc] initWithObjects:&value count:1];
    [self willChangeValueForKey:@"currencies" withSetMutation:NSKeyValueUnionSetMutation usingObjects:changedObjects];
    [[self primitiveValueForKey:@"currencies"] addObject:value];
    [self didChangeValueForKey:@"currencies" withSetMutation:NSKeyValueUnionSetMutation usingObjects:changedObjects];
    [changedObjects release];
}

- (void)removeCurrenciesObject:(Currency *)value {
    NSSet *changedObjects = [[NSSet alloc] initWithObjects:&value count:1];
    [self willChangeValueForKey:@"currencies" withSetMutation:NSKeyValueMinusSetMutation usingObjects:changedObjects];
    [[self primitiveValueForKey:@"currencies"] removeObject:value];
    [self didChangeValueForKey:@"currencies" withSetMutation:NSKeyValueMinusSetMutation usingObjects:changedObjects];
    [changedObjects release];
}

- (void)addCurrencies:(NSSet *)value {    
    [self willChangeValueForKey:@"currencies" withSetMutation:NSKeyValueUnionSetMutation usingObjects:value];
    [[self primitiveValueForKey:@"currencies"] unionSet:value];
    [self didChangeValueForKey:@"currencies" withSetMutation:NSKeyValueUnionSetMutation usingObjects:value];
}

- (void)removeCurrencies:(NSSet *)value {
    [self willChangeValueForKey:@"currencies" withSetMutation:NSKeyValueMinusSetMutation usingObjects:value];
    [[self primitiveValueForKey:@"currencies"] minusSet:value];
    [self didChangeValueForKey:@"currencies" withSetMutation:NSKeyValueMinusSetMutation usingObjects:value];
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


@end
