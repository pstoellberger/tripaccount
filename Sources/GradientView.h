//
//  GradientView.h
//  Reiseabrechnung
//
//  Created by Martin Maier on 06/09/2011.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>
#import <Foundation/Foundation.h>

@interface GradientView : UIView {
    CAGradientLayer *_gradient;
    UIColor *_color1;
    UIColor *_color2;
}

- (id)initWithFrame:(CGRect)frame andColor1:(UIColor *)color1 andColor2:(UIColor *)color2;

@end
