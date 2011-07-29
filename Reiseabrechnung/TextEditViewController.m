//
//  TextEditViewController.m
//  Reiseabrechnung
//
//  Created by Martin Maier on 22/07/2011.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "TextEditViewController.h"
#import "UIFactory.h"
#import "GradientCell.h"

@implementation TextEditViewController

@synthesize target=_target, selector=_selector;
@synthesize textField=_textField, textCell=_textCell;

- (id)initWithText:(NSString *)text target:(id)target selector:(SEL)selector {
    
    if (self = [super initWithStyle:UITableViewStylePlain]) {
        
        [UIFactory initializeTableViewController:self.tableView];
        
        self.target = target;
        self.selector = selector;
        
        self.tableView.delegate = self;
        self.tableView.dataSource = self;
        
        self.textField.text = text;
        self.textField.placeholder = text;
        
        self.navigationItem.rightBarButtonItem = [[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(done)] autorelease];
        
    }
    return self;    
}

- (void)done {
    if ([_target respondsToSelector:_selector]) {
        [_target performSelector:_selector withObject:[_textField.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]]];
    }    
    
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)cancel {
    [[self navigationController] popViewControllerAnimated:YES];
}

#pragma mark - UITableViewDelegate


#pragma mark - UITableViewDataSource

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    return self.textCell;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 1;
}

#pragma mark - UITextFieldDelegate

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [self done];
    return YES;
}

#pragma mark - View lifecycle


- (void)loadView {
    
    [super loadView];
    
    self.tableView.scrollEnabled = NO;
    
    self.textCell = [[[GradientCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"TextEditViewControllerCell"] autorelease];
    
    self.textField = [[[UITextField alloc] initWithFrame:CGRectMake(25, 12, self.tableView.bounds.size.width - 25 - 20, 40)] autorelease];
    self.textField.delegate = self;
    self.textField.placeholder = @"Description (optional)";
    
    [self.textCell addSubview:self.textField];
    
    [UIFactory initializeCell:self.textCell];
    
    [self.textField becomeFirstResponder];
    
}


- (void)viewDidUnload {
    [super viewDidUnload];

    self.target = nil;
    self.selector = nil;
    
    self.textCell = nil;
    self.textField = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    return YES;
}

@end
