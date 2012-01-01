//
//  ImageUtils.h
//  Reiseabrechnung
//
//  Created by Martin Maier on 02/11/2011.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface UIImage (Resizing)

- (UIImage*)imageByScalingToSize:(CGSize)targetSize;

@end