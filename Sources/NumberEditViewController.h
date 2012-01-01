//
//  TextEditViewController.h
//  Reiseabrechnung
//
//  Created by Martin Maier on 22/07/2011.
//  Copyright 2011 Martin Maier. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>
#import "Currency.h"
#import "Travel.h"

#define CONVERSION_VIEW_GAP 10
#define CONVERSION_LABEL_GAP 5

@interface NumberEditViewController : UITableViewController <UITextFieldDelegate> {
    NSString *_namedImage;
    NSString *_description;
}

@property (nonatomic, retain) id target;
@property (nonatomic, assign) SEL selector;

@property (nonatomic, retain) UITableViewCell *textCell;
@property (nonatomic, retain) UITextField *textField;

@property (nonatomic, retain) UITextView *convertView;
@property (nonatomic, retain) UIImageView *infoImageView;

@property (nonatomic, retain) NSNumber *number;
@property (nonatomic, retain) Travel *travel;
@property (nonatomic, retain) Currency *currency;


@property (nonatomic) BOOL allowNull;
@property (nonatomic) BOOL allowZero;

@property (nonatomic) int decimals;

- (id)initWithNumber:(NSNumber *)startNumber withDecimals:(int)decimals currency:(Currency *)currency travel:(Travel *)travel andNamedImage:(NSString *)namedImage description:(NSString *)description target:(id)target selector:(SEL)selector;
- (id)initWithNumber:(NSNumber *)startNumber withDecimals:(int)decimals andNamedImage:(NSString *)namedImage description:(NSString *)description target:(id)target selector:(SEL)selector;
- (void)done;
- (void)refreshConversion;

@end
