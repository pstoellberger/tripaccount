//
//  TimeCell.h
//  Reiseabrechnung
//
//  Created by Martin Maier on 07/12/2011.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "AlignedStyle2Cell.h"

@interface TimeCell : AlignedStyle2Cell {
    UIView *_insertedView;
}

- (id) initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier andNamedImage:(NSString *)namedImage andInsertedView:(UIView *)view;

@end
