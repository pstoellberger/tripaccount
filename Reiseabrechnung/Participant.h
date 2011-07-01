//
//  Participant.h
//  Reiseabrechnung
//
//  Created by Martin Maier on 30/06/2011.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Travel;

@interface Participant : NSManagedObject {
@private
}
@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) Travel * travel;

@end
