//
//  NotesEditViewController.h
//  Reiseabrechnung
//
//  Created by Martin Maier on 15/01/2012.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "TextEditViewController.h"

@interface NotesEditViewController :  UITableViewController <UITextViewDelegate>

@property (nonatomic, retain) UITextView *textView;

@property (nonatomic, retain) id target;
@property (nonatomic, assign) SEL selector;

@property (nonatomic, retain) UITableViewCell *textCell;
@property (nonatomic, retain) NSString *namedImage;

- (id)initWithText:(NSString *)text target:(id)target selector:(SEL)selector;

@end
