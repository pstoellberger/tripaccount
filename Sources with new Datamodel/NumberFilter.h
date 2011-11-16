//
//  NumberFilter.h
//  Reiseabrechnung
//
//  Created by Martin Maier on 25/08/2011.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MGTemplateFilter.h"

@interface NumberFilter : NSObject <MGTemplateFilter>

- (NSArray *)filters;
- (NSObject *)filterInvoked:(NSString *)filter withArguments:(NSArray *)args onValue:(NSObject *)value;

@end
