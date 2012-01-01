//
//  EntryCategory.m
//  Reiseabrechnung
//
//  Created by Martin Maier on 25/08/2011.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "EntryCategory.h"
#import "UIFactory.h"
#import "I18NSortCategory.h"
#import "ReceiverWeight.h"

@implementation Entry (Sort)

- (NSArray *)sortedReceivers {
    
    NSArray *allSortDescriptor = [NSArray arrayWithObject:[[[NSSortDescriptor alloc] initWithKey:@"name" ascending:YES] autorelease]];
    NSMutableArray *receivers = [NSMutableArray arrayWithCapacity:[self.receiverWeights count]];
    for (ReceiverWeight *recWeight in self.receiverWeights) {
        [receivers addObject:recWeight.participant];
    }
    return [receivers sortedArrayUsingDescriptors:allSortDescriptor];
}

- (NSArray *)sortedReceiverWeights {
    
    NSArray *allSortDescriptor = [NSArray arrayWithObject:[NSSortDescriptor sortDescriptorWithKey:@"participant.name" ascending:YES]];
    NSArray *returnArray = [self.receiverWeights sortedArrayUsingDescriptors:allSortDescriptor];
    return returnArray;
}

- (BOOL)hasTimeSpecified {
    return [UIFactory dateHasTime:self.date]; 
}

- (NSString *)typeSectionName {
    NSString *returnValue = self.type.nameI18N;
    if (!returnValue) {
        returnValue = NSLocalizedString(@"<no type>", @"section key");
    }
    return returnValue;
}

- (double)totalReceiverWeights {
    
    double total = 0;
    for (ReceiverWeight *recWeight in self.receiverWeights) {
        total += [recWeight.weight doubleValue];
    }
    return total;
}


- (BOOL)isWeightInUse {
    
    for (ReceiverWeight *recWeight in self.receiverWeights) {
        if ([recWeight.weight doubleValue] != 1.0) {
            return YES;
        }
    }
    return NO;
}


@end
