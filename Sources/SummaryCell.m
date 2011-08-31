//
//  SummaryCell.m
//  Reiseabrechnung
//
//  Created by Martin Maier on 21/07/2011.
//  Copyright 2011 Martin Maier. All rights reserved.
//

#import "SummaryCell.h"

@implementation SummaryCell

@synthesize debtor, debtee, amount, leftImage, rightImage, paid, owes, to, paidLabel;

- (void)setFrame:(CGRect)frame {
    
    self.paid.transform = CGAffineTransformIdentity;
    
    [super setFrame:frame];
    
    self.paid.transform = CGAffineTransformMakeRotation( -M_PI/6 ); // = 45 degrees
}

@end
