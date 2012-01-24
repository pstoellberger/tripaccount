//
//  TextEditViewController.m
//  Reiseabrechnung
//
//  Created by Martin Maier on 22/07/2011.
//  Copyright 2011 Martin Maier. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>
#import <Foundation/Foundation.h>
#import "NumberEditViewController.h"
#import "UIFactory.h"
#import "GradientCell.h"
#import "CurrencyHelperCategory.h"
#import "AlignedStyle2Cell.h"

@interface NumberEditViewController ()
    - (NSString *)getInfoImageName;
@end

@implementation NumberEditViewController

@synthesize target=_target, selector=_selector;
@synthesize textField=_textField, textCell=_textCell, detailView=_detailView, infoImageView=_infoImageView;
@synthesize number=_number, decimals=_decimals;
@synthesize allowNull=_allowNull, allowZero=_allowZero;

- (id)initWithNumber:(NSNumber *)startNumber withDecimals:(int)decimals andNamedImage:(NSString *)namedImage description:(NSString *)description target:(id)target selector:(SEL)selector {
    
    [Crittercism leaveBreadcrumb:@"NumberEditViewController: init"];
    
    if (self = [super initWithStyle:UITableViewStyleGrouped]) {
        
        _donePressed = NO;
        
        _namedImage = namedImage;
        _description = description;
        
        self.decimals = decimals;
        
        self.target = target;
        self.selector = selector;
        
        self.allowNull = YES;
        self.allowZero = YES;
        
        self.tableView.delegate = self;
        self.tableView.dataSource = self;
        
        [UIFactory initializeTableViewController:self.tableView];
        
        self.number = [[startNumber copy] autorelease];
        self.textField.text = [UIFactory formatNumberWithoutThSep:startNumber withDecimals:decimals];        
        self.navigationItem.rightBarButtonItem = [[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(done)] autorelease];
        
        self.tableView.allowsSelection = NO;
                    
        self.textField.frame = CGRectMake(self.textField.frame.origin.x, (self.textCell.frame.size.height - self.textField.frame.size.height) / 2, self.textCell.frame.size.width - self.textField.frame.origin.x - TEXTFIELD_LABEL_GAP, self.textField.frame.size.height);
        
        if (description) {
            
            self.tableView.tableFooterView = [[[UIView alloc] initWithFrame:CGRectMake(0, 0, self.tableView.frame.size.width, FOOTER_HEIGHT)] autorelease];
            
            [self.tableView.tableFooterView addSubview:self.detailView];
            
            self.detailView.text = _description;
            [self.tableView.tableFooterView addSubview:self.infoImageView];
        }
        
        self.navigationItem.hidesBackButton = YES;
        self.navigationItem.leftBarButtonItem = [[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel target:self action:@selector(cancel)] autorelease];
    }
    return self;    
}

- (void)done {
    
    [Crittercism leaveBreadcrumb:@"NumberEditViewController: done"];
    
    _donePressed = YES;
    
    if ([_target respondsToSelector:_selector]) {
        [_target performSelector:_selector withObject:self.number];
    }    
    
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)cancel {
    
    _donePressed = YES;
    
    [Crittercism leaveBreadcrumb:@"NumberEditViewController: cancel"];
    
    [self.navigationController popViewControllerAnimated:YES];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    return YES;
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

- (BOOL)textFieldShouldEndEditing:(UITextField *)textField {
    return _donePressed;
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {

    BOOL returnValue = NO;
    
    NSNumberFormatter *nf = [[NSNumberFormatter alloc] init];
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
    
    // check if return is possible
    self.navigationItem.rightBarButtonItem.enabled = YES;
    
    if (!self.allowNull && numberString.length == 0) {
        self.navigationItem.rightBarButtonItem.enabled = NO;
    }
    if (!self.allowZero && [self.number doubleValue] == 0.0) {
        self.navigationItem.rightBarButtonItem.enabled = NO;
    }

    return returnValue;
}

#pragma mark - View lifecycle


#define IMAGE_SIZE 24
#define IMAGE_GAP 10
#define IMAGE_TEXT_GAP 10
#define IMAGE_TOP 10
#define INFO_IMAGE_SIZE 24
#define INFO_IMAGE_GAP 4

- (void)loadView {
    
    [super loadView];
    
    self.tableView.scrollEnabled = NO;
    
    self.textCell = [[[AlignedStyle2Cell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:nil andNamedImage:_namedImage] autorelease];
    self.textCell.textLabel.text = @" ";
 
    self.textField = [[[UITextField alloc] initWithFrame:CGRectMake(IMAGE_GAP + IMAGE_SIZE + IMAGE_TEXT_GAP, 5, 250, 30)] autorelease];
    self.textField.textAlignment = UITextAlignmentRight;
    self.textField.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleLeftMargin;
    self.textField.keyboardType = UIKeyboardTypeDecimalPad;
    self.textField.keyboardAppearance = UIKeyboardAppearanceAlert;
    self.textField.font = [UIFont systemFontOfSize:25.0];
    self.textField.delegate = self;
    
    [self.textCell.contentView addSubview:self.textField];
    
    [self.textField becomeFirstResponder];
    
    self.detailView = [[[UITextView alloc] initWithFrame:CGRectMake(CONVERSION_VIEW_GAP+INFO_IMAGE_GAP+INFO_IMAGE_SIZE+INFO_IMAGE_GAP, 0, [[UIScreen mainScreen] applicationFrame].size.width - (CONVERSION_VIEW_GAP+INFO_IMAGE_GAP+INFO_IMAGE_SIZE+INFO_IMAGE_GAP+CONVERSION_VIEW_GAP), FOOTER_HEIGHT - CONVERSION_VIEW_GAP - CONVERSION_VIEW_GAP)] autorelease];
    self.detailView.textAlignment = UITextAlignmentLeft;
    self.detailView.textColor = self.textField.backgroundColor;
    self.detailView.editable = NO;
    self.detailView.font = [UIFont systemFontOfSize:11];
    self.detailView.userInteractionEnabled = YES;
    self.detailView.contentInset = UIEdgeInsetsMake(0,0,0,0);
    self.detailView.layer.cornerRadius = 5;
    self.detailView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    
    self.infoImageView = [[[UIImageView alloc] initWithImage:[UIImage imageNamed:[self getInfoImageName]]] autorelease];
    self.infoImageView.frame = CGRectMake(CONVERSION_VIEW_GAP+INFO_IMAGE_GAP, INFO_IMAGE_GAP, INFO_IMAGE_SIZE, INFO_IMAGE_SIZE);
    self.infoImageView.autoresizingMask = UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleBottomMargin;
    
}

- (NSString *)getInfoImageName {
    return @"information.png";
}


- (void)viewDidUnload {
    
    [super viewDidUnload];
    
    self.target = nil;
    self.selector = nil;
    
    self.textCell = nil;
    self.textField.delegate = nil;
    self.textField = nil;
}

- (void)dealloc {
    
    [_detailView release];
    [_infoImageView release];
    [_number release];
    [super dealloc];
}

@end
