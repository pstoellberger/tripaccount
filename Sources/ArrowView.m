//
//  ArrowView.m
//  Reiseabrechnung
//
//  Created by Martin Maier on 27/07/2011.
//  Copyright 2011 Martin Maier. All rights reserved.
//

#import "ArrowView.h"

@implementation ArrowView

@synthesize upsideDown=_upsideDown, arrowColor=_arrowColor, borderColor=_borderColor, arrowBottomGap=_arrowBottomGap;

- (id)initWithFrame:(CGRect)frame {
    
    if ((self = [super initWithFrame:frame])) {
        self.backgroundColor = [UIColor clearColor];
        self.arrowColor = [UIColor whiteColor];
        self.borderColor = [UIColor blackColor];
        self.arrowBottomGap = 0;
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
    
    CGContextSetFillColorWithColor(context, self.arrowColor.CGColor);
    CGContextDrawPath(context, kCGPathFill);
    
    // border
    CGContextSetLineCap(context, kCGLineCapSquare);
    CGContextSetStrokeColorWithColor(context, self.borderColor.CGColor);
    CGContextSetLineWidth(context, 1.0);
    
    if (!self.upsideDown) {
        CGContextMoveToPoint(context ,  self.arrowBottomGap, rect.size.height - self.arrowBottomGap);
        CGContextAddLineToPoint(context , rect.size.width / 2, 0);
        CGContextStrokePath(context);
        
        CGContextMoveToPoint(context , rect.size.width - self.arrowBottomGap, rect.size.height - self.arrowBottomGap);
        CGContextAddLineToPoint(context , rect.size.width / 2, 0);
        CGContextStrokePath(context);
        
    } else {
        CGContextMoveToPoint(context ,  self.arrowBottomGap, self.arrowBottomGap);
        CGContextAddLineToPoint(context , rect.size.width / 2, rect.size.height);
        CGContextStrokePath(context);
        
        CGContextMoveToPoint(context , rect.size.width - self.arrowBottomGap, self.arrowBottomGap);
        CGContextAddLineToPoint(context , rect.size.width / 2, rect.size.height);
        CGContextStrokePath(context);

    }
}

- (void)dealloc {
    self.arrowColor = nil;
    self.borderColor = nil;
    [super dealloc];
}

@end
