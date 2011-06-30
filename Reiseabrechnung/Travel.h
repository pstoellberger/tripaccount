//
//  Travel.h
//  Reiseabrechnung
//
//  Created by Martin Maier on 29/06/2011.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface Travel : NSObject {
    NSString *name;
    NSDate *created;
    NSString *currency;
    NSMutableArray *participants;
    NSMutableArray *entries;
}

@property (nonatomic, retain) NSString *name;
@property (nonatomic, retain) NSDate *created;
@property (nonatomic, retain) NSString *currency;
@property (nonatomic, retain) NSMutableArray *participants;
@property (nonatomic, retain) NSMutableArray *entries;


@end
