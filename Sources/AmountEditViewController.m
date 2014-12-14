//
//  AmountEditViewController.m
//  Reiseabrechnung
//
//  Created by Martin Maier on 22/01/2012.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "AmountEditViewController.h"
#import "Travel.h"
#import "Currency.h"
#import "Entry.h"
#import "UIFactory.h"
#import "CurrencyHelperCategory.h"

@interface AmountEditViewController ()
@property (nonatomic, retain) UILabel *currencyCodeLabel;
- (void)refreshConversion;
- (void)refreshCurrencyCodeLabel;
- (void)circleCurrency;
@end

@implementation AmountEditViewController

@synthesize travel=_travel, currency=_currency;
@synthesize currencyCodeLabel=_currencyCodeLabel;
@synthesize selectorCurrency=_selectorCurrency;

- (id)initWithNumber:(NSNumber *)startNumber withDecimals:(int)decimals currency:(Currency *)currency travel:(Travel *)travel andNamedImage:(NSString *)namedImage description:(NSString *)description target:(id)target selectorAmount:(SEL)selectorAmount selectorCurrency:(SEL)selectorCurrency {

    if (self = [super initWithNumber:startNumber withDecimals:decimals andNamedImage:namedImage description:description target:target selector:selectorAmount]) {
        
        self.selectorCurrency = selectorCurrency;
        
        self.travel = travel;
        self.currency = currency;
        
        self.textField.frame = CGRectMake(BORDER_GAP, (self.textCell.bounds.size.height - self.textField.bounds.size.height) / 2, self.tableView.bounds.size.width - BORDER_GAP - BORDER_GAP, self.textField.bounds.size.height);            
       
        [self refreshCurrencyCodeLabel];
        
        [self.textCell.contentView addSubview:self.currencyCodeLabel];
        
        if (travel && currency && [travel.currencies count] > 0) {
            
            self.tableView.tableFooterView = [[[UIView alloc] initWithFrame:CGRectMake(0, 0, self.tableView.frame.size.width, FOOTER_HEIGHT)] autorelease];
            
            [self.tableView.tableFooterView addSubview:self.detailView];
            
            self.detailView.text = _description;
            [self.tableView.tableFooterView addSubview:self.infoImageView];
        }
        
        [self refreshConversion];
    }
    
    return self;
    
}

- (NSString *)getInfoImageName {
    return @"exchange.png";
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
        
        self.detailView.text = [conversionString stringByTrimmingCharactersInSet:[NSCharacterSet newlineCharacterSet]];
        
        [self.detailView flashScrollIndicators];
    } else {
        self.detailView.text = @"";
    }
}

- (void)refreshCurrencyCodeLabel {
    
    self.currencyCodeLabel.text = self.currency.code;            
    self.currencyCodeLabel.font = self.textField.font;
    [self.currencyCodeLabel  sizeToFit];
    
    self.currencyCodeLabel.frame = CGRectMake(self.textCell.contentView.bounds.size.width - self.currencyCodeLabel.bounds.size.width - BORDER_GAP, (self.textCell.contentView.bounds.size.height - self.currencyCodeLabel.bounds.size.height) / 2, self.currencyCodeLabel.bounds.size.width, self.currencyCodeLabel.bounds.size.height);
    self.currencyCodeLabel.backgroundColor = [UIColor clearColor];
    self.currencyCodeLabel.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin;
    
    self.textField.frame = CGRectMake(self.textField.frame.origin.x, (self.textCell.frame.size.height - self.textField.frame.size.height) / 2, self.currencyCodeLabel.frame.origin.x - self.textField.frame.origin.x - TEXTFIELD_LABEL_GAP, self.textField.bounds.size.height);
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {

    BOOL returnValue = [super textField:textField shouldChangeCharactersInRange:range replacementString:string];
    [self refreshConversion];
    return returnValue;
}

- (void)circleCurrency {
    
    int currencyIndex = (int)[[self.travel.currencies allObjects] indexOfObject:self.currency];
    currencyIndex++;
    
    if (currencyIndex >= [self.travel.currencies count]) {
        currencyIndex = 0;
    }
    
    self.currency = [[self.travel.currencies allObjects] objectAtIndex:currencyIndex];
    
    [self refreshCurrencyCodeLabel];
    [self refreshConversion];
    
}

- (void)loadView {
    
    [super loadView];
    self.detailView.font = [UIFont systemFontOfSize:18.0];
    self.detailView.textAlignment = NSTextAlignmentRight;
    
    UITapGestureRecognizer *gr = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(circleCurrency)];
    gr.numberOfTapsRequired = 1;
    //self.detailView.userInteractionEnabled = YES;
    //self.detailView.se
    [self.detailView addGestureRecognizer:gr];
    [gr release];
    
    UILabel *codeLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 0, 0)];
    codeLabel.userInteractionEnabled = YES;
    
    gr = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(circleCurrency)];
    gr.numberOfTapsRequired = 1;
    [codeLabel addGestureRecognizer:gr];
    [gr release];
    self.currencyCodeLabel = codeLabel;
    [codeLabel release];
}

- (void)done {
    
    [super done];
    
    
    if ([self.target respondsToSelector:_selectorCurrency]) {
        [self.target performSelector:_selectorCurrency withObject:self.currency];
    } 
    
}

@end
