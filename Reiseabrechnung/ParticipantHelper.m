//
//  ParticipantHelper.m
//  Reiseabrechnung
//
//  Created by Martin Maier on 20/07/2011.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "ParticipantHelper.h"
#import "Travel.h"

@implementation ParticipantHelper

+ (BOOL) addParticipant:(Participant *)person toTravel:(Travel *)travel withABRecord:(ABRecordRef)recordRef {
    
    NSString *firstName = (NSString *) ABRecordCopyValue(recordRef, kABPersonFirstNameProperty);
    NSString *lastName = (NSString *) ABRecordCopyValue(recordRef, kABPersonLastNameProperty);
    NSString *fullName = [NSString stringWithFormat:@"%@ %@", firstName, lastName];
    
    BOOL addPerson = YES;
    
    for(Participant *p in travel.participants) {
        if ([p.name isEqualToString:fullName]) {
            addPerson= NO;
            break;
        }
    }

    if (addPerson) {
        person.travel = travel;
        person.name = fullName;
        
        UIImage *image = nil;
        if(ABPersonHasImageData(recordRef)) {
            NSData *imgData = (NSData *)ABPersonCopyImageData(recordRef);
            image = [UIImage imageWithData:imgData];
            if (image) {
                person.image = UIImagePNGRepresentation(image);
            }
            [imgData release];
        } else {
            person.image = [NSData dataWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"noImage" ofType:@"png"]];
        }
    }
    
    [firstName release];
    [lastName release];
    
    return addPerson;
}

@end
