//
//  TextEditViewController.h
//  Reiseabrechnung
//
//  Created by Martin Maier on 22/07/2011.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>

@interface TextEditViewController : UITableViewController <UITextFieldDelegate> {

    id _target;
    SEL _selector;
    
    UITableViewCell *_textCell;
    UITextField *_textField;
}

@property (nonatomic, retain) id target;
@property (nonatomic, assign) SEL selector;

@property (nonatomic, retain) UITableViewCell *textCell;
@property (nonatomic, retain) UITextField *textField;

- (id)initWithText:(NSString *)text target:(id)target selector:(SEL)selector;
- (void)done;

@end
