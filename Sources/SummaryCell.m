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

- (void)layoutSubviews {
    
    [super layoutSubviews];
    
    self.separatorInset = UIEdgeInsetsMake(0, 0, 0, 0);
}

- (void)dealloc {
    
    self.debtor = nil;
    self.debtee = nil;
    self.amount = nil;
    self.leftImage = nil;
    self.rightImage = nil;
    self.paid = nil;
    self.paidLabel = nil;
    self.owes = nil;
    self.to = nil;
    [super dealloc];
}

@end
