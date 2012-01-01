//
//  Style2ImageCell.m
//  Reiseabrechnung
//
//  Created by Martin Maier on 01/01/2012.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "Style2ImageCell.h"
#import "ImageCache.h"

@implementation Style2ImageCell

@synthesize rightImage=_rightImage;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier andNamedImage:(NSString *)namedImage {
    
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier andNamedImage:namedImage]) {
        
        _rightImageView = [[[UIImageView alloc] initWithFrame:CGRectMake(0, 2, 40, 40)] retain];
        [self.contentView addSubview:_rightImageView];
    }
    return self;
}

- (void)layoutSubviews {
    
    [super layoutSubviews];
    
    _rightImageView.frame = CGRectMake(self.contentView.frame.size.width - _rightImageView.frame.size.width - 5, _rightImageView.frame.origin.y, _rightImageView.frame.size.width, _rightImageView.frame.size.height);
    
}

- (void)setRightImage:(NSData *)rightImage {
    _rightImageView.image = [[ImageCache instance] getImage:rightImage]; 
}

- (void)dealloc {
    
    [_rightImageView release];
    
    [super dealloc];
}

@end
