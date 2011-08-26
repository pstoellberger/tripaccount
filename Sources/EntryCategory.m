//
//  EntryCategory.m
//  Reiseabrechnung
//
//  Created by Martin Maier on 25/08/2011.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "EntryCategory.h"
#import "UIFactory.h"

@implementation Entry (Sort)

- (NSArray *)sortedReceivers {
    
    NSArray *allSortDescriptor = [NSArray arrayWithObject:[[[NSSortDescriptor alloc] initWithKey:@"name" ascending:YES] autorelease]];
    return [[self.receivers allObjects] sortedArrayUsingDescriptors:allSortDescriptor];
}

- (BOOL)hasTimeSpecified {
    return [UIFactory dateHasTime:self.date]; 
}

@end
