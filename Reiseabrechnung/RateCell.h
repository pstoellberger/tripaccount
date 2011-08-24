//
//  RateCell.h
//  Reiseabrechnung
//
//  Created by Martin Maier on 8/3/11.
//  Copyright 2011 Martin Maier. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GradientCell.h"

@interface RateCell : GradientCell

@property (nonatomic, retain) IBOutlet UILabel *subTextLabel;
@property (nonatomic, retain) IBOutlet UILabel *nameLabel;
@property (nonatomic, retain) IBOutlet UILabel *rateLabel;


@end
