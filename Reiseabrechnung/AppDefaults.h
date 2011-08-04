//
//  AppDefaults.h
//  Reiseabrechnung
//
//  Created by Martin Maier on 28/07/2011.
//  Copyright (c) 2011 Martin Maier. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Currency, Type;

@interface AppDefaults : NSManagedObject {
@private
}
@property (nonatomic, retain) Currency *homeCurrency;
@property (nonatomic, retain) Type *defaultType;

@end
