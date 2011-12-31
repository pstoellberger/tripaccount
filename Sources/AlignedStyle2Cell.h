//
//  AlignedStyle2Cell.h
//  Reiseabrechnung
//
//  Created by Martin Maier on 22/07/2011.
//  Copyright 2011 Martin Maier. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "GradientCell.h"

@interface AlignedStyle2Cell : UITableViewCell

@property (nonatomic, retain) UIView *myImageView;

- (id) initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier andNamedImage:(NSString *)namedImage;

@end
