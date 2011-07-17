//
//  CreateSummary.h
//  Reiseabrechnung
//
//  Created by Martin Maier on 01/07/2011.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Summary.h"
#import "Travel.h"


@interface CreateSummary : NSObject {
    
}

- (Summary *) createSummary:(Travel *) travel;

@end
