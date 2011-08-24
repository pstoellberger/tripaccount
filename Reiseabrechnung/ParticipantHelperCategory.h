//
//  ParticipantHelper.h
//  Reiseabrechnung
//
//  Created by Martin Maier on 20/07/2011.
//  Copyright 2011 Martin Maier. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AddressBook/AddressBook.h>
#import "Participant.h"

@interface Participant (ParticipantHelper)
    
+ (BOOL)addParticipant:(Participant *)person toTravel:(Travel *)travel withABRecord:(ABRecordRef)recordRef;
+ (BOOL)addParticipant:(Participant *)person toTravel:(Travel *)travel withABRecord:(ABRecordRef)recordRef andEmail:(NSString *)email;

@end
