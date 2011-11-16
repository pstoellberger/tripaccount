//
//  Transfer.h
//  Reiseabrechnung
//
//  Created by Martin Maier on 25/08/2011.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Currency, Participant, Travel;

@interface Transfer : NSManagedObject {
@private
}
@property (nonatomic, retain) NSNumber * amount;
@property (nonatomic, retain) NSNumber * paid;
@property (nonatomic, retain) Travel *travel;
@property (nonatomic, retain) Participant *debtor;
@property (nonatomic, retain) Participant *debtee;
@property (nonatomic, retain) Currency *currency;

@end
