//
//  SummaryCell.h
//  Reiseabrechnung
//
//  Created by Martin Maier on 21/07/2011.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SummaryCell : UITableViewCell {
    UILabel *debtor;
    UILabel *debtee;
    UILabel *amount;
}

@property (nonatomic, retain) IBOutlet UILabel *debtor;
@property (nonatomic, retain) IBOutlet UILabel *debtee;
@property (nonatomic, retain) IBOutlet UILabel *amount;

+ (SummaryCell *)cellFromNibNamed:(NSString *)nibName;

@end
