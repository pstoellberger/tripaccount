//
//  DateSelecte.h
//  Reiseabrechnung
//
//  Created by Martin Maier on 26/07/2011.
//  Copyright 2011 Martin Maier. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>

@interface DateSelectViewController : UIViewController {
    
    IBOutlet UILabel *_dateLabel;
    IBOutlet UILabel *_timeDescriptionLabel;
    IBOutlet UIDatePicker *_picker;
    IBOutlet UISwitch *_timeSwitch;
    IBOutlet UIView *_switchSuperView;
    IBOutlet UIView *_labelSuperView;
    
    SEL _action;
    id _target;
    NSDate *_date;
    
}

- (id)initWithDate:(NSDate *)date target:(id)target selector:(SEL)action;
- (void)done;
- (void)selectDate:(id)sender;
- (void)toggleTime:(id)sender;

@end
