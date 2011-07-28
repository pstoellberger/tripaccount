//
//  AlignedStyle2Cell.m
//  Reiseabrechnung
//
//  Created by Martin Maier on 22/07/2011.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "AlignedStyle2Cell.h"

@implementation AlignedStyle2Cell

- (void) layoutSubviews {
    [super layoutSubviews];
    
    self.detailTextLabel.textAlignment = UITextAlignmentRight;
    self.detailTextLabel.frame = CGRectMake(self.detailTextLabel.frame.origin.x, self.detailTextLabel.frame.origin.y, self.bounds.size.width - self.detailTextLabel.frame.origin.x - 60, self.detailTextLabel.frame.size.height);
    self.textLabel.textAlignment = UITextAlignmentLeft;
    
    self.detailTextLabel.backgroundColor = [UIColor clearColor];
    self.textLabel.backgroundColor = [UIColor clearColor];
}

@end
