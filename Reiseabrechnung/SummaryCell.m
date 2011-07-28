//
//  SummaryCell.m
//  Reiseabrechnung
//
//  Created by Martin Maier on 21/07/2011.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "SummaryCell.h"

@implementation SummaryCell

@synthesize debtor, debtee, amount;

+ (SummaryCell *)cellFromNibNamed:(NSString *)nibName {
    NSArray *nibContents = [[NSBundle mainBundle] loadNibNamed:nibName owner:nil options:NULL];
    NSEnumerator *nibEnumerator = [nibContents objectEnumerator];
    SummaryCell *customCell = nil;
    NSObject* nibItem = nil;
    while ((nibItem = [nibEnumerator nextObject]) != nil) {
        if ([nibItem isKindOfClass:[SummaryCell class]]) {
            customCell = (SummaryCell *)nibItem;
            break; // we have a winner
        }
    }
    return customCell;
}

@end
