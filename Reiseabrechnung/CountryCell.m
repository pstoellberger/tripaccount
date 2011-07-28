//
//  CountryCell.m
//  Reiseabrechnung
//
//  Created by Martin Maier on 21/07/2011.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "CountryCell.h"



@implementation CountryCell

- (void) layoutSubviews {
    [super layoutSubviews];
    NSLog(@"layout country cell %@", self.textLabel.text);
    
    self.imageView.bounds = CGRectMake(self.imageView.bounds.origin.x, self.imageView.bounds.origin.y, self.imageView.bounds.size.width - (10 * self.imageView.bounds.size.width / self.imageView.bounds.size.height), self.imageView.bounds.size.height - 10);    
    if (self.imageView.bounds.size.width > IMAGE_CELL_WIDTH) {
        self.imageView.bounds = CGRectMake(self.imageView.bounds.origin.x, self.imageView.bounds.origin.y, IMAGE_CELL_WIDTH, IMAGE_CELL_WIDTH * self.imageView.bounds.size.height / self.imageView.bounds.size.width);         
    }
    
    self.imageView.frame = CGRectMake(IMAGE_CELL_WIDTH - self.imageView.frame.size.width, 5, self.imageView.frame.size.width, self.imageView.frame.size.height);
    self.textLabel.frame = CGRectMake(IMAGE_CELL_WIDTH + IMAGE_TEXT_GAP, self.textLabel.frame.origin.y, self.textLabel.frame.size.width - (IMAGE_CELL_WIDTH + IMAGE_TEXT_GAP - self.textLabel.frame.origin.x) , self.textLabel.frame.size.height);
    NSLog(@"%f", self.imageView.contentScaleFactor);
}

@end
