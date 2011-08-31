//
//  I18NSortCategory.h
//  Reiseabrechnung
//
//  Created by Martin Maier on 31/08/2011.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Type.h"
#import "Country.h"
#import "Currency.h"

@interface Type (I18NSortCategory)

@property (nonatomic, retain, readonly) NSString *nameI18N;
+ (NSString *)sortAttributeI18N;

@end

@interface Country (I18NSortCategory)

@property (nonatomic, retain, readonly) NSString *nameI18N;
+ (NSString *)sortAttributeI18N;

@end

@interface Currency (I18NSortCategory)

@property (nonatomic, retain, readonly) NSString *nameI18N;
+ (NSString *)sortAttributeI18N;

@end
