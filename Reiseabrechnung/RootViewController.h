//
//  RootViewController.h
//  Reiseabrechnung
//
//  Created by Martin Maier on 28/06/2011.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Travel.h"
#import "AlertPrompt.h"

@interface RootViewController : UITableViewController {
    
    NSMutableArray *travelArray;
    AlertPrompt *prompt;

}

@property (nonatomic, retain) NSMutableArray *travelArray;
@property (nonatomic, retain) IBOutlet UIButton *addButton;
@property (nonatomic, retain) IBOutlet UITableView *tableView;

- (void)addTravel:(NSString *)name withCurrency:(NSString *)currency;

@end
