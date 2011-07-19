//
//  UIFactory.h
//  Reiseabrechnung
//
//  Created by Martin Maier on 18/07/2011.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface UIFactory : NSObject {
    
}

+ (UIView *)createDefaultTableSectionHeader:(id <UITableViewDataSource>)tableViewDataSource andTableView:(UITableView *)tableView andSection:(NSInteger)section;

@end
