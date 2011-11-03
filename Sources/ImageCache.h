//
//  ImageCache.h
//  Reiseabrechnung
//
//  Created by Martin Maier on 02/11/2011.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ImageCache : UIView

+ (ImageCache *)instance;
- (UIImage *)getImage:(NSData *)data;

@end
