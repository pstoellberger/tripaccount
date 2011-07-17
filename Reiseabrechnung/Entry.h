//
//  Entry.h
//  Reiseabrechnung
//
//  Created by Martin Maier on 16/07/2011.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Currency, Participant, Travel;

@interface Entry : NSManagedObject {
@private
}
@property (nonatomic, retain) NSNumber * amount;
@property (nonatomic, retain) NSDate * date;
@property (nonatomic, retain) NSString * text;
@property (nonatomic, retain) Travel * travel;
@property (nonatomic, retain) Participant * payer;
@property (nonatomic, retain) NSSet* receivers;
@property (nonatomic, retain) Currency * currency;

@end
