//
//  EntryCell.h
//  Reiseabrechnung
//
//  Created by Martin Maier on 30/06/2011.
//  Copyright 2011 Martin Maier. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ParticipantView.h"
#import "GradientCell.h"

@interface EntryCell : GradientCell {
    
}

@property (nonatomic, retain) IBOutlet UILabel *top;
@property (nonatomic, retain) IBOutlet ParticipantView *bottom;
@property (nonatomic, retain) IBOutlet UILabel *right;
@property (nonatomic, retain) IBOutlet UIImageView *image;
@property (nonatomic, retain) IBOutlet UILabel *rightBottom;
@property (nonatomic, retain) IBOutlet UILabel *forLabel;

@end
