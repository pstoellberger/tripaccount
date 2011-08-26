//
//  ParticipantCategory.m
//  Reiseabrechnung
//
//  Created by Martin Maier on 09/08/2011.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "ParticipantCategory.h"
#import "NSData+Base64.h"

@implementation Participant (Base64Image)

- (NSString *)base64 {
    
    UIImage *image = [UIImage imageWithData:self.image];
    
    CGSize newSize = CGSizeMake(40,40);
    UIGraphicsBeginImageContext(newSize);
    [image drawInRect:CGRectMake(0,0,newSize.width,newSize.height)];
    //image is the original UIImage
    UIImage* newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return UIImagePNGRepresentation(newImage).base64EncodedString;
}

@end
