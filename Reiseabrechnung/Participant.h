//
//  Participant.h
//  Reiseabrechnung
//
//  Created by Martin Maier on 16/07/2011.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Entry, Travel;

@interface Participant : NSManagedObject {
@private
}
@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) NSData * image;
@property (nonatomic, retain) Travel * travel;
@property (nonatomic, retain) NSSet* getPayedFor;
@property (nonatomic, retain) NSSet* pays;

@end
