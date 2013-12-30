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

#define ICON_SIZE 24
#define ICON_GAP 5
#define ICON_TOP 8

@synthesize myImageView=_myImageView, imageOnTop=_imageOnTop;

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
    
    self.textLabel.frame = CGRectMake(ICON_SIZE + ICON_GAP + ICON_GAP, self.textLabel.frame.origin.y, self.textLabel.bounds.size.width, self.textLabel.bounds.size.height); 
    [self.textLabel.layer removeAllAnimations];
    
    self.detailTextLabel.textAlignment = NSTextAlignmentRight;
    self.detailTextLabel.frame = CGRectMake(self.textLabel.frame.origin.x + self.textLabel.frame.size.width + GAP_BETWEEN_CELLS, self.detailTextLabel.frame.origin.y, self.bounds.size.width - (self.textLabel.frame.origin.x + self.textLabel.frame.size.width + GAP_BETWEEN_CELLS + ACCESSORY_SPACE), self.detailTextLabel.frame.size.height);
    self.textLabel.textAlignment = NSTextAlignmentLeft;
    if (!_imageOnTop) {
        self.myImageView.frame = CGRectMake(ICON_GAP, self.textLabel.frame.origin.y + ((self.textLabel.frame.size.height - ICON_SIZE) / 2), ICON_SIZE, ICON_SIZE);
    } else {
        self.myImageView.frame = CGRectMake(ICON_GAP, ICON_TOP, ICON_SIZE, ICON_SIZE);
    }
    
    self.detailTextLabel.backgroundColor = [UIColor clearColor];
    self.textLabel.backgroundColor = [UIColor clearColor];
    
    self.separatorInset = UIEdgeInsetsMake(0, ICON_GAP + ICON_SIZE + ICON_GAP, 0, 0);
}


- (void)setEditing:(BOOL)editing animated:(BOOL)animated {
    
    [super setEditing:editing animated:animated];
    
    [self.detailTextLabel.layer removeAllAnimations];
    
    if (animated) {
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
    } else {
        if (editing) {
            self.detailTextLabel.transform = CGAffineTransformTranslate(CGAffineTransformIdentity, - self.detailTextLabel.frame.origin.x - self.detailTextLabel.bounds.size.width - 20, 0);
        } else {
            self.detailTextLabel.transform = CGAffineTransformIdentity;        
        }
    }
}

- (void)dealloc {
    self.myImageView = nil;
    [super dealloc];
}

@end
