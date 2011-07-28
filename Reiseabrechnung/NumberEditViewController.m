//
//  TextEditViewController.m
//  Reiseabrechnung
//
//  Created by Martin Maier on 22/07/2011.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>
#import "NumberEditViewController.h"
#import "UIFactory.h"

@implementation NumberEditViewController

@synthesize target=_target, selector=_selector;
@synthesize textField=_textField, textCell=_textCell, number=_number;

- (id)initWithNumber:(NSNumber *)startNumber target:(id)target selector:(SEL)selector {
    
    if (self = [super initWithStyle:UITableViewStylePlain]) {
        
        [UIFactory initializeTableViewController:self.tableView];
        
        self.target = target;
        self.selector = selector;
        
        self.tableView.delegate = self;
        self.tableView.dataSource = self;
        
        self.number = [[startNumber copy] autorelease];
        NSNumberFormatter *numberFormatter = [[NSNumberFormatter alloc] init];
        numberFormatter.maximumFractionDigits = 2;
        self.textField.text = [numberFormatter stringFromNumber:self.number];
        [numberFormatter release];
        
        self.navigationItem.rightBarButtonItem = [[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(done)] autorelease];
        
    }
    return self;    
}

- (void)done {
    if ([_target respondsToSelector:_selector]) {
        [_target performSelector:_selector withObject:self.number];
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

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {

    BOOL returnValue = NO;
    
    NSNumberFormatter *nf = [[NSNumberFormatter alloc] init] ;
    NSString *numberString = [textField.text stringByReplacingCharactersInRange:range withString:string];
    
    if ([numberString length] == 0) {
        returnValue = YES;
        self.number = nil;
    } else {
        NSNumber *tempNumber = [nf numberFromString:numberString];
        if (tempNumber) {
            self.number = tempNumber;
            returnValue = YES;
        }
    }
    [nf release];
    
    return returnValue;
}

#pragma mark - View lifecycle


- (void)loadView {
    
    [super loadView];
    
    self.tableView.scrollEnabled = NO;
    
    self.textCell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue2 reuseIdentifier:@"TextEditViewControllerCell"] autorelease];
 
    self.textField = [[[UITextField alloc] initWithFrame:CGRectMake(25, 12, self.tableView.bounds.size.width - 25 - 20, 40)] autorelease];
    self.textField.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    self.textField.textAlignment = UITextAlignmentRight;
    self.textField.keyboardType = UIKeyboardTypeDecimalPad;
    self.textField.keyboardAppearance = UIKeyboardAppearanceAlert;
    //self.textField.font.pointSize = 20;
    
    [UIFactory initializeCell:self.textCell];
    
    self.textField.delegate = self;
    
    [self.textCell addSubview:self.textField];
    
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
