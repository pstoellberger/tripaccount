//
//  EntryNotManaged.h
//  Reiseabrechnung
//
//  Created by Martin Maier on 01/07/2011.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Participant.h"
#import "Travel.h"
#import "Currency.h"
#import "Type.h"

@interface EntryNotManaged : NSObject {

    
}

@property (nonatomic, retain) NSNumber * amount;
@property (nonatomic, retain) NSDate * date;
@property (nonatomic, retain) NSString * text;
@property (nonatomic, retain) Travel * travel;
@property (nonatomic, retain) Participant * payer;
@property (nonatomic, retain) NSSet* receivers;
@property (nonatomic, retain) Currency * currency;
@property (nonatomic, retain) Type * type;

- (id)initWithEntry:(Entry *)entry;

@end
