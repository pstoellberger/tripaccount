//
//  I18NSortCategory.m
//  Reiseabrechnung
//
//  Created by Martin Maier on 31/08/2011.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "I18NSortCategory.h"

@implementation Type (I18NSortCategory)

- (NSString *)nameI18N {
    
    if ([[[NSLocale preferredLanguages] objectAtIndex:0] isEqualToString:@"de"]) {
        return self.name_de;
    } else {
        return self.name;
    }
    
}

+ (NSString *)sortAttributeI18N {

    if ([[[NSLocale preferredLanguages] objectAtIndex:0] isEqualToString:@"de"]) {
        return @"name_de";
    } else {
        return @"name";
    }
    
}

@end

@implementation Currency (I18NSortCategory)

- (NSString *)nameI18N {
    
    if ([[[NSLocale preferredLanguages] objectAtIndex:0] isEqualToString:@"de"]) {
        return self.name_de;
    } else {
        return self.name;
    }
    
    
}

+ (NSString *)sortAttributeI18N {
    
    if ([[[NSLocale preferredLanguages] objectAtIndex:0] isEqualToString:@"de"]) {
        return @"name_de";
    } else {
        return @"name";
    }
    
}


@end

@implementation Country (I18NSortCategory)

- (NSString *)nameI18N {
    
    if ([[[NSLocale preferredLanguages] objectAtIndex:0] isEqualToString:@"de"]) {
        return self.name_de;
    } else {
        return self.name;
    }
    
    
}

+ (NSString *)sortAttributeI18N {
    
    if ([[[NSLocale preferredLanguages] objectAtIndex:0] isEqualToString:@"de"]) {
        return @"name_de";
    } else {
        return @"name";
    }
    
}

@end
