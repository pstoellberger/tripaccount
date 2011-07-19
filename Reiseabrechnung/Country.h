//
//  Country.h
//  Reiseabrechnung
//
//  Created by Martin Maier on 19/07/2011.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Currency, Travel;

@interface Country : NSManagedObject {
@private
}
@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) NSString * image;
@property (nonatomic, retain) NSSet* currencies;
@property (nonatomic, retain) NSSet* travels;

@end
