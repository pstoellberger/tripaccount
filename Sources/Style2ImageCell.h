//
//  Style2ImageCell.h
//  Reiseabrechnung
//
//  Created by Martin Maier on 01/01/2012.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AlignedStyle2Cell.h"

@interface Style2ImageCell : AlignedStyle2Cell {
    UIImageView *_rightImageView;
}

@property (nonatomic, retain) NSData *rightImage; 

@end
