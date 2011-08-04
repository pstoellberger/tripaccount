//
//  UnitTests.h
//  UnitTests
//
//  Created by Martin Maier on 01/08/2011.
//  Copyright 2011 Martin Maier. All rights reserved.
//

#import <SenTestingKit/SenTestingKit.h>
#import <CoreData/CoreData.h>
#import <Foundation/Foundation.h>
#import "Currency.h"

@interface UnitTests : SenTestCase  {
    NSManagedObjectModel *model;
    NSPersistentStoreCoordinator *coordinator;
    NSManagedObjectContext *context;
}

- (Currency *)currencyWithCode:(NSString *)code;

@end
