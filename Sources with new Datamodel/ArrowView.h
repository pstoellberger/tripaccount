//
//  ArrowView.h
//  Reiseabrechnung
//
//  Created by Martin Maier on 27/07/2011.
//  Copyright 2011 Martin Maier. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ArrowView : UIView {
    BOOL _upsideDown;
}

@property (nonatomic) BOOL upsideDown;
@property (nonatomic, retain) UIColor *arrowColor;
@property (nonatomic, retain) UIColor *borderColor;
@property (nonatomic) int arrowBottomGap;

@end
