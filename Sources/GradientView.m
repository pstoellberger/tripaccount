//
//  GradientView.m
//  Reiseabrechnung
//
//  Created by Martin Maier on 06/09/2011.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "GradientView.h"


@interface GradientView () 
- (void)initGradient;
@end

@implementation GradientView

- (id)initWithFrame:(CGRect)frame andColor1:(UIColor *)color1 andColor2:(UIColor *)color2 {
    
    self = [super initWithFrame:frame];
    if (self) {
        _color1 = [color1 retain];
        _color2 = [color2 retain];
        
        [self initGradient];
    }
    return self;
    
}

- (id)initWithFrame:(CGRect)frame {
    
    self = [self initWithFrame:frame andColor1:[UIColor colorWithWhite:1 alpha:1] andColor2:[UIColor colorWithWhite:0.85 alpha:1]];
    return self;
}

- (void)initGradient {
    
    self.backgroundColor = [UIColor clearColor];
    
    _gradient = [[CAGradientLayer layer] retain];
    _gradient.frame = self.bounds;
    _gradient.startPoint = CGPointMake(0, 0);
    _gradient.endPoint = CGPointMake(0, 1);
    _gradient.colors = [NSArray arrayWithObjects:(id)[_color1 CGColor], (id)[_color2 CGColor], nil];
    _gradient.needsDisplayOnBoundsChange = YES;
    
    [self.layer insertSublayer:_gradient atIndex:0];    
}

- (void)layoutSubviews {
    [super layoutSubviews];
    _gradient.frame = self.bounds;
}

- (void)dealloc {
    [_gradient release];
    [_color1 release];
    [_color2 release];
    [super dealloc];
}

@end
