//
//  EntryCategory.h
//  Reiseabrechnung
//
//  Created by Martin Maier on 25/08/2011.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Entry.h"

@interface Entry (Sort)

@property (nonatomic, readonly) NSArray *sortedReceivers;
@property (nonatomic, readonly) NSArray *sortedReceiverWeights;
@property (nonatomic, readonly) BOOL hasTimeSpecified;
@property (nonatomic, readonly) NSString *typeSectionName;

- (double)totalReceiverWeights;
- (BOOL)isWeightInUse;

@end