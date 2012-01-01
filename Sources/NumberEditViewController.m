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

@implementation NumberEditViewController

@synthesize target=_target, selector=_selector;
@synthesize textField=_textField, textCell=_textCell, convertView=_convertView, infoImageView=_infoImageView;
@synthesize travel=_travel, currency=_currency, number=_number, decimals=_decimals;
@synthesize allowNull=_allowNull, allowZero=_allowZero;

#define TEXTFIELD_LABEL_GAP 15
#define BORDER_GAP 10
#define FOOTER_HEIGHT 145

- (id)initWithNumber:(NSNumber *)startNumber withDecimals:(int)decimals andNamedImage:(NSString *)namedImage description:(NSString *)description target:(id)target selector:(SEL)selector {
    return [self initWithNumber:startNumber withDecimals:decimals currency:nil travel:nil andNamedImage:namedImage description:description target:target selector:selector];
}

- (id)initWithNumber:(NSNumber *)startNumber withDecimals:(int)decimals currency:(Currency *)currency travel:(Travel *)travel andNamedImage:(NSString *)namedImage description:(NSString *)description target:(id)target selector:(SEL)selector {
    
    if (self = [super initWithStyle:UITableViewStyleGrouped]) {
        
        _namedImage = namedImage;
        _description = description;
        
        self.decimals = decimals;
        
        self.target = target;
        self.selector = selector;
        
        self.allowNull = YES;
        self.allowZero = YES;
        
        self.travel = travel;
        self.currency = currency;
        
        self.tableView.delegate = self;
        self.tableView.dataSource = self;
        
        [UIFactory initializeTableViewController:self.tableView];
        
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
        
        if (description || (currency && [travel.currencies count] > 1)) {
            
            self.tableView.tableFooterView = [[[UIView alloc] initWithFrame:CGRectMake(0, 0, self.tableView.frame.size.width, FOOTER_HEIGHT)] autorelease];
            
            [self.tableView.tableFooterView addSubview:self.convertView];
            
            self.convertView.text = _description;
            [self.tableView.tableFooterView addSubview:self.infoImageView];
            
            if ([self.number doubleValue] != 0) {
                [self refreshConversion];
            }
        }
        
        self.navigationItem.hidesBackButton = YES;
        self.navigationItem.leftBarButtonItem = [[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel target:self action:@selector(cancel)] autorelease];
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
    
    if (self.currency) {
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
    
    self.textCell = [[[AlignedStyle2Cell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:@"TextEditViewControllerCell" andNamedImage:_namedImage] autorelease];
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
    
    self.convertView = [[[UITextView alloc] initWithFrame:CGRectMake(CONVERSION_VIEW_GAP+INFO_IMAGE_GAP+INFO_IMAGE_SIZE+INFO_IMAGE_GAP, 0, [[UIScreen mainScreen] applicationFrame].size.width - (CONVERSION_VIEW_GAP+INFO_IMAGE_GAP+INFO_IMAGE_SIZE+INFO_IMAGE_GAP+CONVERSION_VIEW_GAP), FOOTER_HEIGHT - CONVERSION_VIEW_GAP - CONVERSION_VIEW_GAP)] autorelease];
    self.convertView.textAlignment = UITextAlignmentLeft;
    self.convertView.textColor = [UIColor grayColor];
    self.convertView.editable = NO;
    self.convertView.font = [UIFont systemFontOfSize:11];
    if (self.currency) {
        self.convertView.font = [UIFont systemFontOfSize:18.0];
        self.convertView.textAlignment = UITextAlignmentRight;
    }
    self.convertView.userInteractionEnabled = YES;
    self.convertView.contentInset = UIEdgeInsetsMake(0,0,0,0);
    self.convertView.layer.cornerRadius = 5;
    self.convertView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    
    NSString *infoImageName = @"information.png";
    if (self.currency) {
        infoImageName = @"exchange.png";
    }
    
    self.infoImageView = [[[UIImageView alloc] initWithImage:[UIImage imageNamed:infoImageName]] autorelease];
    self.infoImageView.frame = CGRectMake(CONVERSION_VIEW_GAP+INFO_IMAGE_GAP, INFO_IMAGE_GAP, INFO_IMAGE_SIZE, INFO_IMAGE_SIZE);
    self.infoImageView.autoresizingMask = UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleBottomMargin;
    
}


- (void)viewDidUnload {
    [super viewDidUnload];
    
    self.target = nil;
    self.selector = nil;
    
    self.textCell = nil;
    self.textField = nil;
}

- (void)dealloc {
    [_textCell release];
    [_textField release];
    [_convertView release];
    [_infoImageView release];
    [_number release];
    [_currency release];
    [super dealloc];
}

@end
