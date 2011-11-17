//
//  ParticipantHelper.m
//  Reiseabrechnung
//
//  Created by Martin Maier on 20/07/2011.
//  Copyright 2011 Martin Maier. All rights reserved.
//

#import "ParticipantHelperCategory.h"
#import "Travel.h"
#import "UIFactory.h"
#import "ImageCache.h"

@implementation Participant (ParticipantHelper)

+ (BOOL)addParticipant:(Participant *)person toTravel:(Travel *)travel withABRecord:(ABRecordRef)recordRef {
    return [Participant addParticipant:person toTravel:travel withABRecord:recordRef andEmail:nil];
}

+ (BOOL)addParticipant:(Participant *)person toTravel:(Travel *)travel withABRecord:(ABRecordRef)recordRef andEmail:(NSString *)email {
    
    
    BOOL addPerson = YES;
    
    NSString *firstName = (NSString *) ABRecordCopyValue(recordRef, kABPersonFirstNameProperty);
    NSString *lastName = (NSString *) ABRecordCopyValue(recordRef, kABPersonLastNameProperty);
    
    NSString *fullName = nil;
    if (firstName && lastName) {
        fullName = [NSString stringWithFormat:@"%@ %@", firstName, lastName];
    } else if (firstName) {
        fullName = firstName;
    } else if (lastName) {
        fullName = lastName;
    } else {
        addPerson = NO;
    }
    
    if (fullName) {
        ABMultiValueRef emailMultiValue = (ABMultiValueRef *) ABRecordCopyValue(recordRef, kABPersonEmailProperty);
        NSArray *emailList = (NSArray *) ABMultiValueCopyArrayOfAllValues(emailMultiValue);
        
        if (!email && [emailList count] > 0) {
            email = (NSString *) [emailList objectAtIndex:0];
        }
                
        for(Participant *p in travel.participants) {
            if ([p.name isEqualToString:fullName]) {
                addPerson= NO;
                break;
            }
        }
        
        if (addPerson) {
            person.travel = travel;
            person.name = fullName;
            person.email = email;
            
            UIImage *image = nil;
            if(ABPersonHasImageData(recordRef)) {
                
                NSData *imgData = nil;
                if (&ABPersonCopyImageDataWithFormat != nil) {
                    // iOS >= 4.1
                    imgData = (NSData *) ABPersonCopyImageDataWithFormat(recordRef, kABPersonImageFormatThumbnail);
                } else {
                    // iOS < 4.1
                    imgData = (NSData *) ABPersonCopyImageData(recordRef);
                }
                
                image = [[ImageCache instance] getImage:imgData];
                
                if (image) {
                    person.image = UIImagePNGRepresentation(image);
                }
                [imgData release];
                
            } else {
                person.image = [NSData dataWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"noImage" ofType:@"png"]];
            }
            
            // get thumbnail
            person.imageSmall = [Participant createThumbnail:person.image];
        }
        
        CFRelease(emailMultiValue);
        [emailList release];
        [firstName release];
        [lastName release];
    }
    
    return addPerson;
}

+ (NSData *)createThumbnail:(NSData *)bigData {
    return UIImagePNGRepresentation([UIFactory imageWithImage:[UIImage imageWithData:bigData] scaledToSize:CGSizeMake(32, 32)]);
}

@end
