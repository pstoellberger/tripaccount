//
//  UIFactory.m
//  Reiseabrechnung
//
//  Created by Martin Maier on 18/07/2011.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "UIFactory.h"


@implementation UIFactory

+ (UIView *)createDefaultTableSectionHeader:(id <UITableViewDataSource>)tableViewDataSource andTableView:(UITableView *)tableView andSection:(NSInteger)section {
    
    UIView *containerView = [[[UIView alloc] initWithFrame:CGRectMake(0, 0, 320, 40)] autorelease];
    
    containerView.backgroundColor = [UIColor groupTableViewBackgroundColor];
    CGRect labelFrame = CGRectMake(20, 2, 320, 30);
    if(section == 0) {
        labelFrame.origin.y = 13;
    }
    UILabel *label = [[UILabel alloc] initWithFrame:labelFrame];
    label.backgroundColor = [UIColor clearColor];
    label.font = [UIFont boldSystemFontOfSize:17];
    label.shadowColor = [UIColor colorWithWhite:1.0 alpha:1];
    label.shadowOffset = CGSizeMake(0, 1);
    label.textColor = [UIColor colorWithRed:0.265 green:0.294 blue:0.367 alpha:1.000];
    label.text = [tableViewDataSource tableView:tableView titleForHeaderInSection:section];
    [containerView addSubview:label];
    
    return containerView;
}

@end
