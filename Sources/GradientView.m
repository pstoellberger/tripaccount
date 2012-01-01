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

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self initGradient];
    }
    return self;
}

- (void)initGradient {
    
    self.backgroundColor = [UIColor clearColor];
    
    _gradient = [[CAGradientLayer layer] retain];
    _gradient.frame = self.bounds;
    _gradient.startPoint = CGPointMake(0, 0);
    _gradient.endPoint = CGPointMake(0, 1);
    _gradient.colors = [NSArray arrayWithObjects:(id)[[UIColor colorWithWhite:1 alpha:1] CGColor], (id)[[UIColor colorWithWhite:0.85 alpha:1] CGColor], nil];
    _gradient.needsDisplayOnBoundsChange = YES;
    
    [self.layer insertSublayer:_gradient atIndex:0];    
}

- (void)layoutSubviews {
    [super layoutSubviews];
    _gradient.frame = self.bounds;
}

- (void)dealloc {
    [_gradient release];
    [super dealloc];
}

@end
