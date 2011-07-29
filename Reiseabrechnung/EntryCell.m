//
//  EntryCell.m
//  Reiseabrechnung
//
//  Created by Martin Maier on 30/06/2011.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "EntryCell.h"
#import <QuartzCore/QuartzCore.h>

@implementation EntryCell

@synthesize top, bottom, right, image, rightBottom;

- (void)setEditing:(BOOL)editing animated:(BOOL)animated {
    
    [super setEditing:editing animated:animated]; 

    if (editing) {
        [UIView animateWithDuration:0.3
                              delay:0 
                            options:(UIViewAnimationOptionCurveLinear | UIViewAnimationOptionAllowUserInteraction | UIViewAnimationOptionBeginFromCurrentState)
                         animations:^{
                             right.transform = CGAffineTransformTranslate(CGAffineTransformIdentity, -right.frame.origin.x - right.bounds.size.width/2, 0);
                             right.transform = CGAffineTransformScale(right.transform, 0.1, 0.1);
                         } 
                         completion:nil];
        [UIView animateWithDuration:0.3
                              delay:0 
                            options:(UIViewAnimationOptionCurveLinear | UIViewAnimationOptionAllowUserInteraction | UIViewAnimationOptionBeginFromCurrentState)
                         animations:^{
                             rightBottom.transform = CGAffineTransformTranslate(CGAffineTransformIdentity, -rightBottom.frame.origin.x - rightBottom.bounds.size.width/2, 0);
                             rightBottom.transform = CGAffineTransformScale(rightBottom.transform, 0.1, 0.1);
                         } 
                         completion:nil];
        [UIView animateWithDuration:0.3
                              delay:0 
                            options:(UIViewAnimationOptionCurveLinear | UIViewAnimationOptionAllowUserInteraction | UIViewAnimationOptionBeginFromCurrentState)
                         animations:^{
                             top.frame = CGRectMake(self.top.frame.origin.x, self.top.frame.origin.y, self.contentView.frame.size.width - self.top.frame.origin.x, self.top.frame.size.height);
                         } 
                         completion:nil];
    } else {
        [UIView animateWithDuration:0.3
                              delay:0 
                            options:(UIViewAnimationOptionCurveLinear | UIViewAnimationOptionAllowUserInteraction | UIViewAnimationOptionBeginFromCurrentState)
                         animations:^{
                             right.transform = CGAffineTransformIdentity;
                         } 
                         completion:^(BOOL fin) { [right setNeedsDisplay]; }];  
        [UIView animateWithDuration:0.3
                              delay:0 
                            options:(UIViewAnimationOptionCurveLinear | UIViewAnimationOptionAllowUserInteraction | UIViewAnimationOptionBeginFromCurrentState)
                         animations:^{
                             rightBottom.transform = CGAffineTransformIdentity;
                         } 
                         completion:^(BOOL fin) { [rightBottom setNeedsDisplay]; }];
        [UIView animateWithDuration:0.3
                              delay:0 
                            options:(UIViewAnimationOptionCurveLinear | UIViewAnimationOptionAllowUserInteraction | UIViewAnimationOptionBeginFromCurrentState)
                         animations:^{
                             top.frame = CGRectMake(self.top.frame.origin.x, self.top.frame.origin.y, self.right.frame.origin.x - self.top.frame.origin.x, self.top.frame.size.height);
                         } 
                         completion:nil];
    }
}

//- (void)layoutSubviews {
//    
//    [super layoutSubviews];
//    
//    if (![self.contentView.subviews containsObject:self.right]) {
//        self.top.frame = CGRectMake(self.top.frame.origin.x, self.top.frame.origin.y, self.bounds.size.width - self.top.frame.origin.x, self.top.frame.size.height);
//        self.bottom.frame = CGRectMake(self.bottom.frame.origin.x, self.bottom.frame.origin.y, self.bounds.size.width - self.bottom.frame.origin.x, self.bottom.frame.size.height);
//    } else {
//        self.top.frame = CGRectMake(self.top.frame.origin.x, self.top.frame.origin.y, self.right.frame.origin.x - self.top.frame.origin.x, self.top.frame.size.height);
//        self.bottom.frame = CGRectMake(self.bottom.frame.origin.x, self.bottom.frame.origin.y, self.right.frame.origin.x - self.bottom.frame.origin.x, self.bottom.frame.size.height);
//    }
//}

//- (void)layoutSubviews {
//    [super layoutSubviews];
//    NSLog(@"layouting layer %@", [self.backgroundView.layer.sublayers objectAtIndex:0]);
//    ((CALayer *)[self.backgroundView.layer.sublayers objectAtIndex:0]).frame = self.backgroundView.bounds;
//}

@end
