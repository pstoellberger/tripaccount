//
//  DateCell.m
//  TripAccount
//
//  Created by Martin Maier-Moessner on 30/12/13.
//
//

#import "DateCell.h"

@implementation DateCell

- (void)layoutSubviews {
    
    [super layoutSubviews];
    
    self.textLabel.frame = CGRectMake(self.textLabel.frame.origin.x, self.textLabel.frame.origin.y, [[UIScreen mainScreen] bounds].size.width - self.textLabel.frame.origin.x - 10, self.textLabel.frame.size.height);
    self.textLabel.textAlignment = NSTextAlignmentRight;
}

@end
