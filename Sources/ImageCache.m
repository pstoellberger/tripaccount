//
//  ImageCache.m
//  Reiseabrechnung
//
//  Created by Martin Maier on 02/11/2011.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "ImageCache.h"

static ImageCache *gInstance = NULL;

@implementation ImageCache {
    
    NSMutableDictionary *dic;
}

+ (ImageCache *)instance {
    @synchronized(self) {
        if (gInstance == NULL)
            gInstance = [[ImageCache alloc] init];
    }
    
    return(gInstance);
}

- (UIImage *)getImage:(NSData *)data {
    
    if (!dic) {
        dic = [[NSMutableDictionary alloc] initWithCapacity:10];
    }
    
    if (![dic objectForKey:data]) {
        [dic setObject:[UIImage imageWithData:data] forKey:data]; 
    }
    
    return [dic objectForKey:data];
    
}


@end
