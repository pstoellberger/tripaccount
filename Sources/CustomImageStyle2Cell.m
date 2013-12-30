//
//  CustomImageStyle2Cell.m
//  Reiseabrechnung
//
//  Created by Martin Maier on 06/12/2011.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "CustomImageStyle2Cell.h"

@implementation CustomImageStyle2Cell

- (id)initWithImage:(UIImage *)imageName reuseIdentifier:(NSString *)reuseIdentifier {
    
    self = [super initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:reuseIdentifier];
    if (self) {
        self.imageView.image = imageName;
    }
    return self;
}

#define GAP 10
#define TOP 10
#define IMAGE_SIZE 24

- (void)layoutSubviews {
    
    [super layoutSubviews];
    
    self.imageView.frame = CGRectMake(GAP, TOP, IMAGE_SIZE, IMAGE_SIZE);
    self.textLabel.frame = CGRectMake(GAP + IMAGE_SIZE + GAP, self.textLabel.frame.origin.y, self.textLabel.frame.size.width, self.textLabel.frame.size.height);

}

@end
