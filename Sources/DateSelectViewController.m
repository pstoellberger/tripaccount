//
//  DateSelectViewController.m
//  Reiseabrechnung
//
//  Created by Martin Maier on 26/07/2011.
//  Copyright 2011 Martin Maier. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>
#import "DateSelectViewController.h"
#import "UIFactory.h"

@implementation DateSelectViewController

- (id)initWithDate:(NSDate *)date target:(id)target selector:(SEL)action {
    
    self = [super initWithNibName:nil bundle:nil];
    
    if (self) {
        _action = action;
        _target = target;
        _date = [[date copy] retain];
    }
    return self;
}

- (void)done {
    if ([_target respondsToSelector:_action]) {
        [_target performSelector:_action withObject:_picker.date];
    }    
    
    [self.navigationController popViewControllerAnimated:YES];    
}

- (void)toggleTime:(id)sender {
    
    UISwitch *timeSwitch = (UISwitch *) sender;
    if (timeSwitch.on) {
        _picker.datePickerMode = UIDatePickerModeDateAndTime;
    } else {
        _picker.datePickerMode = UIDatePickerModeDate;
    }
    [self selectDate:_picker];
}

- (void)selectDate:(id)sender {

    UIDatePicker *datePicker = (UIDatePicker *) sender;
	NSDateFormatter *df = [[NSDateFormatter alloc] init];
    df.dateStyle = NSDateFormatterFullStyle;
    if (_timeSwitch.on) {
        df.timeStyle = NSDateFormatterShortStyle;
    }
	df.dateStyle = NSDateFormatterFullStyle;
	_dateLabel.text = [NSString stringWithFormat:@"%@", [df stringFromDate:datePicker.date]];
	[df release];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    return YES;
}

#pragma mark - View lifecycle

- (void)viewDidLoad {
    [super viewDidLoad];

    [_picker addTarget:self action:@selector(selectDate:) forControlEvents:UIControlEventValueChanged];
    [_picker setDate:_date animated:NO];
    [self selectDate:_picker];
    
    [_timeSwitch addTarget:self action:@selector(toggleTime:) forControlEvents:UIControlEventValueChanged];
    
    if ([UIFactory dateHasTime:_picker.date]) {
        _timeSwitch.on = YES;
    } else {
        _timeSwitch.on = NO;
    }
    [self toggleTime:_timeSwitch];
    
    [UIFactory addGradientToView:_switchSuperView];
    [UIFactory addGradientToView:_labelSuperView];
    
    self.navigationItem.rightBarButtonItem = [[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(done)] autorelease];
}

- (void)viewDidUnload {
    [super viewDidUnload];

    _dateLabel = nil;
    _timeDescriptionLabel = nil;
    _picker = nil;
    _timeSwitch = nil;
}

#pragma mark - Memory management

- (void)dealloc {
    
    [_date release];   
    
    [super dealloc];
}

@end
