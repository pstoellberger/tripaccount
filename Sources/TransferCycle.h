//
//  TransferCycle.h
//  Reiseabrechnung
//
//  Created by Martin Maier on 12/12/2011.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface TransferCycle : NSObject <NSMutableCopying>

@property (nonatomic, retain) NSMutableArray *participantKeys;
@property (nonatomic, copy) NSNumber *minWeight;

@end
