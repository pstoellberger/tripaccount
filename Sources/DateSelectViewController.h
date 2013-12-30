//
//  DateSelecte.h
//  Reiseabrechnung
//
//  Created by Martin Maier on 26/07/2011.
//  Copyright 2011 Martin Maier. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>
#import "DateCell.h"

@interface DateSelectViewController : UITableViewController {
    
    UILabel *_dateLabel;
    UILabel *_timeDescriptionLabel;
    UIDatePicker *_picker;
    UISwitch *_timeSwitch;
    UIView *_switchSuperView;
    UIView *_labelSuperView;
    
    SEL _action;
    id _target;
    NSDate *_date;
    
    DateCell *_dateCell;
    UITableViewCell *_timeCell;
}

- (id)initWithDate:(NSDate *)date target:(id)target selector:(SEL)action;
- (void)done;
- (void)selectDate:(id)sender;
- (void)toggleTime:(id)sender;

@end
