//
//  CountryFirstLetterCategory.m
//  Reiseabrechnung
//
//  Created by Martin Maier on 24/07/2011.
//  Copyright 2011 Martin Maier. All rights reserved.
//

#import "FirstLetterCategory.h"


@implementation Currency (FirstLetterCategory)

- (NSString *)uppercaseFirstLetterOfName {
    [self willAccessValueForKey:@"uppercaseFirstLetterOfName"];
    NSString *aString = [[self valueForKey:@"nameI18N"] uppercaseString];
    NSString *stringToReturn = [aString substringWithRange:[aString rangeOfComposedCharacterSequenceAtIndex:0]];
    [self didAccessValueForKey:@"uppercaseFirstLetterOfName"];
    return stringToReturn;
}

@end

@implementation Country (FirstLetterCategory)

- (NSString *)uppercaseFirstLetterOfName {
    [self willAccessValueForKey:@"uppercaseFirstLetterOfName"];
    NSString *aString = [[self valueForKey:@"nameI18N"] uppercaseString];
    NSString *stringToReturn = [aString substringWithRange:[aString rangeOfComposedCharacterSequenceAtIndex:0]];
    [self didAccessValueForKey:@"uppercaseFirstLetterOfName"];
    return stringToReturn;
}

@end