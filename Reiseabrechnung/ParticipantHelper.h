//
//  ParticipantHelper.h
//  Reiseabrechnung
//
//  Created by Martin Maier on 20/07/2011.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AddressBook/AddressBook.h>
#import "Participant.h"

@interface ParticipantHelper : NSObject {
    
}

+ (BOOL) addParticipant:(Participant *)person toTravel:(Travel *)travel withABRecord:(ABRecordRef)recordRef;

@end
