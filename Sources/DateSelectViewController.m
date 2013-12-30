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
#import "AlignedStyle2Cell.h"
#import "TimeCell.h"

@implementation DateSelectViewController

#define GAP 55

- (id)initWithDate:(NSDate *)date target:(id)target selector:(SEL)action {
    
    [Crittercism leaveBreadcrumb:[NSString stringWithFormat:@"%@: %@ ", self.class, @"init"]];
    
    self = [super initWithStyle:UITableViewStyleGrouped];
    
    if (self) {
        _action = action;
        _target = target;
        _date = [[date copy] retain];
        
        self.tableView.backgroundColor = [UIColor clearColor];
        self.tableView.backgroundView = [UIFactory createBackgroundViewWithFrame:self.view.frame];
        
        _picker = [[[UIDatePicker alloc] initWithFrame:CGRectMake(0, GAP, 320, 160)] retain];
        _picker.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        [_picker addTarget:self action:@selector(selectDate:) forControlEvents:UIControlEventValueChanged];
        [_picker setDate:_date animated:NO];
        
        _timeSwitch = [[[UISwitch alloc] initWithFrame:CGRectMake(0, 0, 0, 0)] retain];
        [_timeSwitch addTarget:self action:@selector(toggleTime:) forControlEvents:UIControlEventValueChanged];
        
        if ([UIFactory dateHasTime:_picker.date]) {
            _timeSwitch.on = YES;
        } else {
            _timeSwitch.on = NO;
        }
        [self toggleTime:_timeSwitch];
        
        _dateCell = [[[AlignedStyle2Cell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:nil andNamedImage:@"calendar.png"] retain];
        _dateCell.textLabel.minimumScaleFactor = 1; // CHECK?!
        _dateCell.textLabel.adjustsFontSizeToFitWidth = YES;
        _dateCell.selectionStyle = UITableViewCellSelectionStyleNone;
        
        _timeCell = [[[TimeCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:nil andNamedImage:@"clock.png" andInsertedView:_timeSwitch] retain];
        _timeCell.textLabel.text = NSLocalizedString(@"Specify time", @"specify time label");
        _timeCell.selectionStyle = UITableViewCellSelectionStyleNone;
        
        [self selectDate:_picker];
                
        self.tableView.tableFooterView = _picker;
        self.tableView.scrollEnabled = NO;
        
        self.navigationItem.hidesBackButton = YES;
        self.navigationItem.leftBarButtonItem = [[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel target:self action:@selector(cancel)] autorelease];
        
    }
    return self;
}

- (void)done {
    
    [Crittercism leaveBreadcrumb:[NSString stringWithFormat:@"%@: %@ ", self.class, @"done"]];
    
    if ([_target respondsToSelector:_action]) {
        [_target performSelector:_action withObject:_picker.date];
    }    
    
    [self.navigationController popViewControllerAnimated:YES];    
}

- (void)cancel { 
    
    [Crittercism leaveBreadcrumb:[NSString stringWithFormat:@"%@: %@ ", self.class, @"cancel"]];
    
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

    [Crittercism leaveBreadcrumb:[NSString stringWithFormat:@"%@: %@ ", self.class, @"selectDate"]];
    
    UIDatePicker *datePicker = (UIDatePicker *) sender;
	NSDateFormatter *df = [[NSDateFormatter alloc] init];
    if (_timeSwitch.on) {
        df.dateStyle = NSDateFormatterLongStyle;
        df.timeStyle = NSDateFormatterShortStyle;
    } else {
        df.dateStyle = NSDateFormatterFullStyle;        
    }
	_dateCell.textLabel.text = [NSString stringWithFormat:@"%@", [df stringFromDate:datePicker.date]];
	[df release];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    return YES;
}

#pragma mark - TableView

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 2;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    if ([UIApplication sharedApplication].statusBarOrientation == UIInterfaceOrientationPortrait 
        || [UIApplication sharedApplication].statusBarOrientation == UIInterfaceOrientationPortraitUpsideDown) {
        return GAP;
    } else {
        return 0;
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    if ([UIApplication sharedApplication].statusBarOrientation == UIInterfaceOrientationPortrait 
        || [UIApplication sharedApplication].statusBarOrientation == UIInterfaceOrientationPortraitUpsideDown) {
        return GAP;
    } else {
        return 0;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {

    if (indexPath.row == 0) {
        return _dateCell;
    } else if (indexPath.row == 1) {
        return _timeCell;
    }
    return nil;
}


#pragma mark - View lifecycle

- (void)viewDidLoad {
    
    [super viewDidLoad];
    
    self.navigationItem.rightBarButtonItem = [[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(done)] autorelease];

}

- (void)viewDidUnload {
    [super viewDidUnload];

    _dateLabel = nil;
    _timeDescriptionLabel = nil;
    
    [_picker release];
    [_timeSwitch release];
    
    [_dateCell release];
    [_timeCell release];
}

#pragma mark - Memory management

- (void)dealloc {
    
    [_date release];
    [_dateLabel release];
    [_timeDescriptionLabel release];
    [_picker release];
    [_timeSwitch release];
    [_switchSuperView release];
    [_labelSuperView release];
    [_date release];
    [_dateCell release];
    [_timeCell release];
    
    [super dealloc];
}

@end
