//
//  Entry.h
//  Reiseabrechnung
//
//  Created by Martin Maier on 30/06/2011.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Travel;

@interface Entry : NSManagedObject {
@private
}
@property (nonatomic, retain) NSNumber * amount;
@property (nonatomic, retain) NSString * currency;
@property (nonatomic, retain) NSString * text;
@property (nonatomic, retain) NSDate * date;
@property (nonatomic, retain) Travel * travel;

@end
