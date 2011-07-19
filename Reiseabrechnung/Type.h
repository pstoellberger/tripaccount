//
//  Type.h
//  Reiseabrechnung
//
//  Created by Martin Maier on 19/07/2011.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Entry;

@interface Type : NSManagedObject {
@private
}
@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) NSNumber * buildIn;
@property (nonatomic, retain) Entry * entries;

@end
