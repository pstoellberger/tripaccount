//
//  Entry.h
//  Reiseabrechnung
//
//  Created by Martin Maier on 30/06/2011.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface Entry : NSObject {
    
    NSNumber *amount;
    NSString *description;
    NSString *currency;
    NSDate *date;
    
}

@property (nonatomic, retain) NSNumber *amount;
@property (nonatomic, retain) NSString *description;
@property (nonatomic, retain) NSString *currency;
@property (nonatomic, retain) NSDate *date;

@end
