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

@interface DateSelectViewController()
-(void)setGap:(UIInterfaceOrientation)interfaceOrientation;
@end

@implementation DateSelectViewController

#define GAP 45

- (id)initWithDate:(NSDate *)date target:(id)target selector:(SEL)action {
    
    self = [super initWithStyle:UITableViewStyleGrouped];
    
    if (self) {
        _action = action;
        _target = target;
        _date = [[date copy] retain];
        
        self.tableView.backgroundColor = [UIColor clearColor];
        self.tableView.backgroundView = [UIFactory createBackgroundViewWithFrame:self.view.frame];
        
        _pickerView = [[[UIView alloc] initWithFrame:CGRectMake(0, 0, self.tableView.frame.size.width, 0)] retain];
        _picker = [[[UIDatePicker alloc] initWithFrame:CGRectMake(0, GAP, 0, 0)] retain];
        _picker.autoresizingMask = UIViewAutoresizingFlexibleWidth;
        [_picker addTarget:self action:@selector(selectDate:) forControlEvents:UIControlEventValueChanged];
        [_picker setDate:_date animated:NO];
        [_pickerView addSubview:_picker];
        
        _timeSwitch = [[[UISwitch alloc] initWithFrame:CGRectMake(0, 0, 0, 0)] retain];
        [_timeSwitch addTarget:self action:@selector(toggleTime:) forControlEvents:UIControlEventValueChanged];
        
        if ([UIFactory dateHasTime:_picker.date]) {
            _timeSwitch.on = YES;
        } else {
            _timeSwitch.on = NO;
        }
        [self toggleTime:_timeSwitch];
        
        _dateCell = [[[AlignedStyle2Cell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:nil andNamedImage:@"calendar.png"] retain];
        _dateCell.textLabel.minimumFontSize = 8;
        _dateCell.textLabel.adjustsFontSizeToFitWidth = YES;
        _dateCell.selectionStyle = UITableViewCellSelectionStyleNone;
        
        _timeCell = [[[TimeCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:nil andNamedImage:@"clock.png" andInsertedView:_timeSwitch] retain];
        _timeCell.textLabel.text = NSLocalizedString(@"Specify time", @"specify time label");
        _timeCell.selectionStyle = UITableViewCellSelectionStyleNone;
        
        [self selectDate:_picker];
                
        self.tableView.tableFooterView = _pickerView;
        self.tableView.scrollEnabled = NO;
        
        [self setGap:[[UIApplication sharedApplication] statusBarOrientation]];
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
    [self setGap:interfaceOrientation];
    return YES;
}

- (void)setGap:(UIInterfaceOrientation)interfaceOrientation {
    
    if (interfaceOrientation == UIInterfaceOrientationPortrait) {
        _picker.frame = CGRectMake(0, GAP, 0, 0);
        self.tableView.contentInset = UIEdgeInsetsMake(44 + GAP, 0, 0, 0);
    } else {
        _picker.frame = CGRectMake(0, 0, 0, 0);
        self.tableView.contentInset = UIEdgeInsetsMake(32, 0, 0, 0);
    }
}

#pragma mark - TableView

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 2;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 0;
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
    [_pickerView release];
    [_timeSwitch release];
    
    [_dateCell release];
    [_timeCell release];
}

#pragma mark - Memory management

- (void)dealloc {
    
    [_date release];   
    
    [super dealloc];
}

@end
