//
//  TravelSerialiser.m
//  Reiseabrechnung
//
//  Created by Martin Maier on 22/01/2012.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "Serialiser.h"
#import "Currency.h"
#import "Country.h"
#import "NSData+Base64.h"

@implementation Travel (Serialiser)

- (void)addToDictionary:(NSMutableDictionary *)dict object:(id)object key:(NSString *)key {
    if (object) {
        [dict setObject:object forKey:key];
    }
}

- (NSDictionary *)serialise {
    
    NSMutableDictionary *tripDict = [NSMutableDictionary dictionary];
    [self addToDictionary:tripDict object:self.name key:@"name"];
    [self addToDictionary:tripDict object:self.city key:@"city"];
    [self addToDictionary:tripDict object:self.notes key:@"notes"];
    [self addToDictionary:tripDict object:self.closed key:@"closed"];
    [self addToDictionary:tripDict object:self.closedDate key:@"closedDate"];
    [self addToDictionary:tripDict object:self.created key:@"created"];
    [self addToDictionary:tripDict object:self.country.name key:@"country"];
    
    NSMutableArray *currencyArray = [NSMutableArray array];
    for (Currency *currency in self.currencies) {
        [currencyArray addObject:currency.code];
    }
    [self addToDictionary:tripDict object:currencyArray key:@"currencies"];
    
    return tripDict;
}
@end

@implementation Participant (Serialiser)

- (void)addToDictionary:(NSMutableDictionary *)dict object:(id)object key:(NSString *)key {
    if (object) {
        [dict setObject:object forKey:key];
    }
}

- (NSDictionary *)serialise {

    NSMutableDictionary *dict = [NSMutableDictionary dictionary];
    [self addToDictionary:dict object:self.name key:@"name"];
    [self addToDictionary:dict object:self.weight key:@"weight"];
    [self addToDictionary:dict object:self.email key:@"email"];
    [self addToDictionary:dict object:self.image key:@"image"];
    [self addToDictionary:dict object:self.notes key:@"notes"];
    return dict;
}

@end

@implementation Entry (Serialiser)

- (void)addToDictionary:(NSMutableDictionary *)dict object:(id)object key:(NSString *)key {
    if (object) {
        [dict setObject:object forKey:key];
    }
}

- (NSDictionary *)serialise {
    
    NSMutableDictionary *dict = [NSMutableDictionary dictionary];
    [self addToDictionary:dict object:self.amount key:@"amount"];
    [self addToDictionary:dict object:self.lastUpdated key:@"lastUpdated"];
    [self addToDictionary:dict object:self.date key:@"date"];
    [self addToDictionary:dict object:self.text key:@"text"];
    [self addToDictionary:dict object:self.created key:@"created"];
    [self addToDictionary:dict object:self.notes key:@"notes"];
    [self addToDictionary:dict object:self.payer.name key:@"payer"];
    [self addToDictionary:dict object:self.type.name key:@"type"];
    [self addToDictionary:dict object:self.currency.code key:@"currency"];
    
    NSMutableArray *recWeightArray = [NSMutableArray array];
    for (ReceiverWeight *recWeight in self.receiverWeights) {
        [recWeightArray addObject:[recWeight serialise]];
    }
    [self addToDictionary:dict object:recWeightArray key:@"receiverWeights"];
 
    return dict;
}
    
@end

@implementation ReceiverWeight (Serialiser)

- (void)addToDictionary:(NSMutableDictionary *)dict object:(id)object key:(NSString *)key {
    if (object) {
        [dict setObject:object forKey:key];
    }
}

- (NSDictionary *)serialise {
    
    NSMutableDictionary *dict = [NSMutableDictionary dictionary];
    [self addToDictionary:dict object:self.participant.name key:@"participant"];
    [self addToDictionary:dict object:self.weight key:@"weight"];
    return dict;
}

@end
