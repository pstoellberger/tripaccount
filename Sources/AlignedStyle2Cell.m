//
//  AlignedStyle2Cell.m
//  Reiseabrechnung
//
//  Created by Martin Maier on 22/07/2011.
//  Copyright 2011 Martin Maier. All rights reserved.
//

#import "AlignedStyle2Cell.h"

@implementation AlignedStyle2Cell

#define GAP_BETWEEN_CELLS 5
#define ACCESSORY_SPACE 45

#define IMAGE_SIZE 24
#define IMAGE_GAP 5

@synthesize myImageView=_myImageView;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier andNamedImage:(NSString *)namedImage {
    
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        
        UIView *bgView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:namedImage]];
        self.myImageView = bgView;
        [bgView release];
        
        [self.contentView addSubview:self.myImageView];
    }
    return self;
}

- (void)layoutSubviews {
    
    [super layoutSubviews];
    
    [self.detailTextLabel sizeToFit];
    [self.textLabel sizeToFit];
    
    self.textLabel.frame = CGRectMake(IMAGE_SIZE + IMAGE_GAP + IMAGE_GAP, self.textLabel.frame.origin.y, self.textLabel.bounds.size.width, self.textLabel.bounds.size.height);
    
    self.detailTextLabel.textAlignment = UITextAlignmentRight;
    self.detailTextLabel.frame = CGRectMake(self.textLabel.frame.origin.x + self.textLabel.frame.size.width + GAP_BETWEEN_CELLS, self.detailTextLabel.frame.origin.y, self.bounds.size.width - (self.textLabel.frame.origin.x + self.textLabel.frame.size.width + GAP_BETWEEN_CELLS + ACCESSORY_SPACE), self.detailTextLabel.frame.size.height);
    self.textLabel.textAlignment = UITextAlignmentLeft;
    
    self.myImageView.frame = CGRectMake(IMAGE_GAP, self.textLabel.frame.origin.y + ((self.textLabel.frame.size.height - IMAGE_SIZE) / 2), IMAGE_SIZE, IMAGE_SIZE);
    
    self.detailTextLabel.backgroundColor = [UIColor clearColor];
    self.textLabel.backgroundColor = [UIColor clearColor];
    
}

- (void)setEditing:(BOOL)editing animated:(BOOL)animated {
    
    [super setEditing:editing animated:animated];
    
    [self.detailTextLabel.layer removeAllAnimations];
    
    if (editing) {
        [UIView animateWithDuration:0.3
                              delay:0 
                            options:(UIViewAnimationOptionCurveEaseIn | UIViewAnimationOptionAllowUserInteraction | UIViewAnimationOptionBeginFromCurrentState)
                         animations:^{
                             self.detailTextLabel.transform = CGAffineTransformTranslate(CGAffineTransformIdentity, - self.detailTextLabel.frame.origin.x - self.detailTextLabel.bounds.size.width - 20, 0);
                         } 
                         completion:nil];
    } else {
        [UIView animateWithDuration:0.3
                              delay:0 
                            options:(UIViewAnimationOptionCurveEaseOut | UIViewAnimationOptionAllowUserInteraction | UIViewAnimationOptionBeginFromCurrentState)
                         animations:^{
                             self.detailTextLabel.transform = CGAffineTransformIdentity;
                         } 
                         completion:^(BOOL fin) { [self.detailTextLabel setNeedsDisplay]; }];  
    }
}

@end
