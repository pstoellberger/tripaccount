//
//  Type.h
//  Reiseabrechnung
//
//  Created by Martin Maier on 31/08/2011.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class AppDefaults, Entry;

@interface Type : NSManagedObject {
@private
}
@property (nonatomic, retain) NSNumber * builtIn;
@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) NSString * name_de;
@property (nonatomic, retain) NSSet *entries;
@property (nonatomic, retain) AppDefaults *defaults;

@end

@interface Type (CoreDataGeneratedAccessors)

- (void)addEntriesObject:(Entry *)value;
- (void)removeEntriesObject:(Entry *)value;
- (void)addEntries:(NSSet *)values;
- (void)removeEntries:(NSSet *)values;

@end
