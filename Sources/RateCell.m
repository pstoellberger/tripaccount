//
//  RateCell.m
//  Reiseabrechnung
//
//  Created by Martin Maier on 8/3/11.
//  Copyright 2011 Martin Maier. All rights reserved.
//

#import "RateCell.h"

@implementation RateCell

@synthesize subTextLabel=_subTextLabel, nameLabel=_nameLabel, rateLabel=_rateLabel;
    
- (void)setEditing:(BOOL)editing animated:(BOOL)animated {
    
    [super setEditing:editing animated:animated]; 
    
    if (editing) {
        [UIView animateWithDuration:0.3
                              delay:0 
                            options:(UIViewAnimationOptionCurveEaseIn | UIViewAnimationOptionAllowUserInteraction | UIViewAnimationOptionBeginFromCurrentState)
                         animations:^{
                             self.subTextLabel.transform = CGAffineTransformTranslate(CGAffineTransformIdentity, - self.subTextLabel.frame.origin.x - self.subTextLabel.bounds.size.width - 20, 0);
                         } 
                         completion:nil];
        [UIView animateWithDuration:0.3
                              delay:0 
                            options:(UIViewAnimationOptionCurveEaseIn | UIViewAnimationOptionAllowUserInteraction | UIViewAnimationOptionBeginFromCurrentState)
                         animations:^{
                             self.rateLabel.transform = CGAffineTransformTranslate(CGAffineTransformIdentity, - self.rateLabel.frame.origin.x - self.rateLabel.bounds.size.width - 20, 0);
                         } 
                         completion:nil];
    } else {
        [UIView animateWithDuration:0.3
                              delay:0 
                            options:(UIViewAnimationOptionCurveEaseOut | UIViewAnimationOptionAllowUserInteraction | UIViewAnimationOptionBeginFromCurrentState)
                         animations:^{
                             self.subTextLabel.transform = CGAffineTransformIdentity;
                         } 
                         completion:^(BOOL fin) { [self.subTextLabel setNeedsDisplay]; }];  
        [UIView animateWithDuration:0.3
                              delay:0 
                            options:(UIViewAnimationOptionCurveEaseOut | UIViewAnimationOptionAllowUserInteraction | UIViewAnimationOptionBeginFromCurrentState)
                         animations:^{
                             self.rateLabel.transform = CGAffineTransformIdentity;
                         } 
                         completion:^(BOOL fin) { [self.rateLabel setNeedsDisplay]; }];  
    }
}

- (void)dealloc {
    
    self.subTextLabel = nil;
    self.nameLabel = nil;
    self.rateLabel = nil;
    
    [super dealloc];
}

@end
