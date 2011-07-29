//
//  DateSortCategory.h
//  Reiseabrechnung
//
//  Created by Martin Maier on 29/07/2011.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Entry.h"

@interface Entry (DateWithOutTime)

- (NSDate *)dateWithOutTime;

@end