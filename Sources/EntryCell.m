//
//  EntryCell.m
//  Reiseabrechnung
//
//  Created by Martin Maier on 30/06/2011.
//  Copyright 2011 Martin Maier. All rights reserved.
//

#import "EntryCell.h"
#import <QuartzCore/QuartzCore.h>

@implementation EntryCell

@synthesize top, bottom, right, image, rightBottom, checkMark;

- (void)setEditing:(BOOL)editing animated:(BOOL)animated {
    
    [super setEditing:editing animated:animated]; 

    if (editing) {
        [UIView animateWithDuration:0.3
                              delay:0 
                            options:(UIViewAnimationOptionCurveEaseIn | UIViewAnimationOptionAllowUserInteraction | UIViewAnimationOptionBeginFromCurrentState)
                         animations:^{
                             right.transform = CGAffineTransformTranslate(CGAffineTransformIdentity, - right.frame.origin.x - right.bounds.size.width, 0);
                         } 
                         completion:nil];
        [UIView animateWithDuration:0.3
                              delay:0 
                            options:(UIViewAnimationOptionCurveEaseIn | UIViewAnimationOptionAllowUserInteraction | UIViewAnimationOptionBeginFromCurrentState)
                         animations:^{
                             rightBottom.transform = CGAffineTransformTranslate(CGAffineTransformIdentity, - rightBottom.frame.origin.x - rightBottom.bounds.size.width, 0);
                         } 
                         completion:nil];
    } else {
        [UIView animateWithDuration:0.3
                              delay:0 
                            options:(UIViewAnimationOptionCurveEaseOut | UIViewAnimationOptionAllowUserInteraction | UIViewAnimationOptionBeginFromCurrentState)
                         animations:^{
                             right.transform = CGAffineTransformIdentity;
                         } 
                         completion:^(BOOL fin) { [right setNeedsDisplay]; }];  
        [UIView animateWithDuration:0.3
                              delay:0 
                            options:(UIViewAnimationOptionCurveEaseOut | UIViewAnimationOptionAllowUserInteraction | UIViewAnimationOptionBeginFromCurrentState)
                         animations:^{
                             rightBottom.transform = CGAffineTransformIdentity;
                         } 
                         completion:^(BOOL fin) { [rightBottom setNeedsDisplay]; }];
    }
}

@end
