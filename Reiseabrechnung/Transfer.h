//
//  Transfer.h
//  Reiseabrechnung
//
//  Created by Martin Maier on 02/08/2011.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Participant, Travel;

@interface Transfer : NSManagedObject {
@private
}
@property (nonatomic, retain) NSNumber * amount;
@property (nonatomic, retain) NSNumber * paid;
@property (nonatomic, retain) Participant *debtor;
@property (nonatomic, retain) Participant *debtee;
@property (nonatomic, retain) Travel *travel;

@end
