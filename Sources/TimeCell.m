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
    
    _insertedView.frame = CGRectMake([[UIScreen mainScreen] bounds].size.width - _insertedView.frame.size.width - GAP, (self.frame.size.height - _insertedView.frame.size.height) / 2, _insertedView.frame.size.width, _insertedView.frame.size.height);
    
    self.textLabel.frame = CGRectMake(self.textLabel.frame.origin.x, self.textLabel.frame.origin.y, [[UIScreen mainScreen] bounds].size.width - self.textLabel.frame.origin.x - GAP - _insertedView.frame.size.width - GAP, self.textLabel.frame.size.height);
    
    self.textLabel.textAlignment = NSTextAlignmentRight;
}

- (void)dealloc {
    [super dealloc];
    [_insertedView release];
}


@end
