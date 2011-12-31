//
//  TimeCell.m
//  Reiseabrechnung
//
//  Created by Martin Maier on 07/12/2011.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "TimeCell.h"

@implementation TimeCell

#define GAP 5

- (id) initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier andNamedImage:(NSString *)namedImage andInsertedView:(UIView *)view {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier andNamedImage:namedImage];
    if (self) {
        _insertedView = view;
        _insertedView.autoresizingMask = UIViewAutoresizingFlexibleRightMargin;
        [self.contentView addSubview:_insertedView];
    }
    return self;
} 

- (void)layoutSubviews {
    
    [super layoutSubviews];
    
    _insertedView.frame = CGRectMake(self.myImageView.frame.origin.x + self.myImageView.frame.size.width + GAP, self.myImageView.frame.origin.y, _insertedView.frame.size.width, _insertedView.frame.size.height);
    self.textLabel.frame = CGRectMake(_insertedView.frame.origin.x + _insertedView.frame.size.width + GAP, self.textLabel.frame.origin.y, self.textLabel.frame.size.width, self.textLabel.frame.size.height);
    
}

- (void)dealloc {
    [_insertedView release];
}


@end
