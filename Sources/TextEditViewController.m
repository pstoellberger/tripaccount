//
//  TextEditViewController.m
//  Reiseabrechnung
//
//  Created by Martin Maier on 22/07/2011.
//  Copyright 2011 Martin Maier. All rights reserved.
//

#import "TextEditViewController.h"
#import "UIFactory.h"
#import "AlignedStyle2Cell.h"

@implementation TextEditViewController

@synthesize target=_target, selector=_selector;
@synthesize textField=_textField, textCell=_textCell;
@synthesize namedImage=_namedImage;


- (id)initWithText:(NSString *)text target:(id)target selector:(SEL)selector {
     return [self initWithText:text target:target selector:selector andNamedImage:nil];
}

- (id)initWithText:(NSString *)text target:(id)target selector:(SEL)selector andNamedImage:(NSString *)namedImage {
    
    [Crittercism leaveBreadcrumb:@"TextEditViewController: init"];
    
    if (self = [super initWithStyle:UITableViewStyleGrouped]) {
        
        if (!namedImage) {
            self.namedImage = @"pencil.png";
        } else {
            self.namedImage = namedImage;
        }
        
        [UIFactory initializeTableViewController:self.tableView];
        
        self.target = target;
        self.selector = selector;
        
        self.tableView.delegate = self;
        self.tableView.dataSource = self;
        
        self.textField.text = text;
        self.textField.placeholder = text;
        
        self.navigationItem.rightBarButtonItem = [[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(done)] autorelease];
        
        self.navigationItem.leftBarButtonItem = [[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel target:self action:@selector(cancel)] autorelease];
        
    }
    return self;    
}

- (void)setKeyBoardType:(UIKeyboardType)keyboardType {
    self.textField.keyboardType = keyboardType;
}

- (void)done {
    
    [Crittercism leaveBreadcrumb:@"TextEditViewController: done"];
    
    if ([_target respondsToSelector:_selector]) {
        [_target performSelector:_selector withObject:[_textField.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]]];
    }    
    
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)cancel {
    
    [Crittercism leaveBreadcrumb:@"TextEditViewController: cancel"];
    
    [[self navigationController] popViewControllerAnimated:YES];
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

#pragma mark - View lifecycle

#define IMAGE_SIZE 24
#define IMAGE_GAP 10
#define IMAGE_TEXT_GAP 10
#define TEXT_CELL_TOP 12
#define TEXT_CELL_HEIGHT 24
#define IMAGE_TOP 10

- (void)loadView {
    
    [super loadView];
    
    self.tableView.scrollEnabled = NO;
    
    self.textCell = [[[AlignedStyle2Cell alloc] initWithStyle:UITableViewCellStyleValue2 reuseIdentifier:@"TextEditViewControllerCell" andNamedImage:self.namedImage] autorelease];
    self.textCell.textLabel.text = @" ";
    
    int left = IMAGE_SIZE + IMAGE_GAP + IMAGE_TEXT_GAP;
    int right = 10;
    self.textField = [[[UITextField alloc] initWithFrame:CGRectMake(left, TEXT_CELL_TOP, self.tableView.bounds.size.width - left - right, TEXT_CELL_HEIGHT)] autorelease];
    self.textField.delegate = self;
    
    [self.textCell addSubview:self.textField];
    
    [UIFactory initializeCell:self.textCell];
    
    [self.textField becomeFirstResponder];
    
}


- (void)viewDidUnload {
    [super viewDidUnload];

    self.namedImage = nil;
    
    self.target = nil;
    self.selector = nil;
    
    self.textCell = nil;
    self.textField = nil;
}

- (void)dealloc {
    
    [_textCell release];
    [_textField release];
    [_namedImage release];
    
    [super dealloc];
}

@end
