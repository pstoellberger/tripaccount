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

@implementation NumberEditViewController

@synthesize target=_target, selector=_selector;
@synthesize textField=_textField, textCell=_textCell, convertView=_convertView;
@synthesize travel=_travel, currency=_currency, number=_number, decimals=_decimals;

#define TEXTFIELD_LABEL_GAP 15
#define BORDER_GAP 10
#define FOOTER_HEIGHT 155

- (id)initWithNumber:(NSNumber *)startNumber withDecimals:(int)decimals currency:(Currency *)currency travel:(Travel *)travel target:(id)target selector:(SEL)selector {
    
    if (self = [super initWithStyle:UITableViewStylePlain]) {
        
        [UIFactory initializeTableViewController:self.tableView];
        
        self.decimals = decimals;
        
        self.target = target;
        self.selector = selector;
        
        self.tableView.delegate = self;
        self.tableView.dataSource = self;
        
        self.travel = travel;
        self.currency = currency;
        
        self.number = [[startNumber copy] autorelease];
        self.textField.text = [UIFactory formatNumberWithoutThSep:startNumber withDecimals:decimals];        
        self.navigationItem.rightBarButtonItem = [[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(done)] autorelease];
        
        self.tableView.allowsSelection = NO;
        
        if (currency) {
            self.textField.frame = CGRectMake(BORDER_GAP, (self.textCell.bounds.size.height - self.textField.bounds.size.height) / 2, self.tableView.bounds.size.width - BORDER_GAP - BORDER_GAP, self.textField.bounds.size.height);            
            
            UILabel *label = [[[UILabel alloc] initWithFrame:CGRectMake(0, 0, 0, 0)] autorelease];
            
            label.text = currency.code;
            label.font = self.textField.font;
            [label sizeToFit];
            
            label.frame = CGRectMake(self.textCell.contentView.bounds.size.width - label.bounds.size.width - BORDER_GAP, (self.textCell.contentView.bounds.size.height - label.bounds.size.height) / 2, label.bounds.size.width, label.bounds.size.height);
            label.backgroundColor = [UIColor clearColor];
            label.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin;
            
            self.textField.frame = CGRectMake(self.textField.frame.origin.x, (self.textCell.frame.size.height - self.textField.frame.size.height) / 2, label.frame.origin.x - self.textField.frame.origin.x - TEXTFIELD_LABEL_GAP, self.textField.bounds.size.height);
            
            [self.textCell.contentView addSubview:label]; 
            
        } else {
            
            self.textField.frame = CGRectMake(self.textField.frame.origin.x, (self.textCell.frame.size.height - self.textField.frame.size.height) / 2, self.textCell.frame.size.width - self.textField.frame.origin.x - TEXTFIELD_LABEL_GAP, self.textField.frame.size.height);
        }
        
        if (currency && [travel.currencies count] > 1) {
            self.tableView.tableFooterView = [[[UIView alloc] initWithFrame:CGRectMake(0, 0, self.tableView.frame.size.width, FOOTER_HEIGHT)] autorelease];
            
            [self.tableView.tableFooterView addSubview:self.convertView];

            if ([self.number doubleValue] != 0) {
                [self refreshConversion];

            }
        } 
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

- (void)refreshConversion {
    
    if ([self.number intValue] != 0) {
        const unichar cr = '\n';
        NSString *singleCR = [NSString stringWithCharacters:&cr length:1];    
        
        NSString *conversionString = @"";
        for (Currency *currency in self.travel.currencies) {
            
            if (![currency isEqual:self.currency]) {
                NSString *line = [NSString stringWithFormat:@"%@ %@", [UIFactory formatNumber:[NSNumber numberWithDouble:[self.currency convertTravelAmount:self.travel currency:currency amount:[self.number doubleValue]]] withDecimals:self.decimals],currency.code];
                conversionString = [[conversionString stringByAppendingString:line] stringByAppendingString:singleCR];
            }
        }
        
        self.convertView.text = [conversionString stringByTrimmingCharactersInSet:[NSCharacterSet newlineCharacterSet]];
        
        [self.convertView flashScrollIndicators];
    } else {
        self.convertView.text = @"";
    }
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
    
    [self refreshConversion];

    return returnValue;
}

#pragma mark - View lifecycle


- (void)loadView {
    
    [super loadView];
    
    self.tableView.scrollEnabled = NO;
    
    self.textCell = [[[GradientCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"TextEditViewControllerCell"] autorelease];
 
    self.textField = [[[UITextField alloc] initWithFrame:CGRectMake(0, 0, 0, 0)] autorelease];
    [self.textField sizeToFit];
    self.textField.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleLeftMargin;
    self.textField.textAlignment = UITextAlignmentRight;
    self.textField.keyboardType = UIKeyboardTypeDecimalPad;
    self.textField.keyboardAppearance = UIKeyboardAppearanceAlert;
    self.textField.font = [UIFont systemFontOfSize:25.0];
    [self.textField sizeToFit];
    
    self.textField.delegate = self;
    
    [self.textCell addSubview:self.textField];
    
    [self.textField becomeFirstResponder];
    
    self.convertView = [[[UITextView alloc] initWithFrame:CGRectMake(CONVERSION_VIEW_GAP, CONVERSION_VIEW_GAP, [[UIScreen mainScreen] applicationFrame].size.width - CONVERSION_VIEW_GAP - CONVERSION_VIEW_GAP, FOOTER_HEIGHT - CONVERSION_VIEW_GAP - CONVERSION_VIEW_GAP)] autorelease];
    self.convertView.textAlignment = UITextAlignmentRight;
    self.convertView.textColor = [UIColor grayColor];
    self.convertView.editable = NO;
    self.convertView.font = [UIFont systemFontOfSize:18.0];
    self.convertView.userInteractionEnabled = YES;
    self.convertView.contentInset = UIEdgeInsetsMake(0,0,0,0);
    self.convertView.layer.cornerRadius = 5;
    self.convertView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    
}


- (void)viewDidUnload {
    [super viewDidUnload];
    
    self.target = nil;
    self.selector = nil;
    
    self.textCell = nil;
    self.textField = nil;
}

@end
