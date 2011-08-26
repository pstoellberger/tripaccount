//
//  SummaryCell.h
//  Reiseabrechnung
//
//  Created by Martin Maier on 21/07/2011.
//  Copyright 2011 Martin Maier. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "GradientCell.h"

@interface SummaryCell : GradientCell {

}

@property (nonatomic, retain) IBOutlet UILabel *debtor;
@property (nonatomic, retain) IBOutlet UILabel *debtee;
@property (nonatomic, retain) IBOutlet UILabel *amount;
@property (nonatomic, retain) IBOutlet UIImageView *leftImage;
@property (nonatomic, retain) IBOutlet UIImageView *rightImage;
@property (nonatomic, retain) IBOutlet UIView *paid;
@property (nonatomic, retain) IBOutlet UILabel *owes;
@property (nonatomic, retain) IBOutlet UILabel *to;

@end
