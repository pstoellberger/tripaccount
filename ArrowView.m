//
//  ArrowView.m
//  Reiseabrechnung
//
//  Created by Martin Maier on 27/07/2011.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "ArrowView.h"

@implementation ArrowView

@synthesize upsideDown=_upsideDown;

- (id)initWithFrame:(CGRect)frame {
    
    if ((self = [super initWithFrame:frame])) {
        self.backgroundColor = [UIColor clearColor];
    }
    
    return self;
}

- (void)drawRect:(CGRect)rect {
    
    [super drawRect:rect];
    
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    CGContextBeginPath(context);
    
    if (!self.upsideDown) {
        CGContextMoveToPoint(context , 0, rect.size.height);
        CGContextAddLineToPoint(context , rect.size.width, rect.size.height);
        CGContextAddLineToPoint(context , rect.size.width / 2, 0 );
    } else {
        CGContextMoveToPoint(context , 0, 0);
        CGContextAddLineToPoint(context , rect.size.width, 0);
        CGContextAddLineToPoint(context , rect.size.width / 2, rect.size.height);        
    }
    CGContextClosePath(context);
    
    CGContextDrawPath(context, kCGPathFill);
}

@end
