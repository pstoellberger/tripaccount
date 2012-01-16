//
//  NotesEditViewController.m
//  Reiseabrechnung
//
//  Created by Martin Maier on 15/01/2012.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "NotesEditViewController.h"
#import "UIFactory.h"
#import "AlignedStyle2Cell.h"

@interface NotesEditViewController ()
- (void)setTextFieldFrame:(UIInterfaceOrientation)interfaceOrientation;
@end

@implementation NotesEditViewController

@synthesize target=_target, selector=_selector;
@synthesize textView=_textView, textCell=_textCell;
@synthesize namedImage=_namedImage;

- (id)initWithText:(NSString *)text target:(id)target selector:(SEL)selector {
    
    [Crittercism leaveBreadcrumb:@"NotesEditViewController: init"];
    
    if (self = [super initWithStyle:UITableViewStyleGrouped]) {
        
        self.namedImage = @"notebook.png";
        
        [UIFactory initializeTableViewController:self.tableView];
        
        self.target = target;
        self.selector = selector;
        
        self.tableView.delegate = self;
        self.tableView.dataSource = self;
        
        self.textView.text = text;
        
        self.navigationItem.rightBarButtonItem = [[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(done)] autorelease];
        
        self.navigationItem.leftBarButtonItem = [[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel target:self action:@selector(cancel)] autorelease];
        
    }
    return self;    
}

- (void)done {
    
    [Crittercism leaveBreadcrumb:@"NotesEditViewController: done"];
    
    if ([_target respondsToSelector:_selector]) {
        [_target performSelector:_selector withObject:[_textView.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]]];
    }    
    
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)cancel {
    
    [Crittercism leaveBreadcrumb:@"NotesEditViewController: cancel"];
    
    [[self navigationController] popViewControllerAnimated:YES];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    
    [self setTextFieldFrame:interfaceOrientation];
    return YES;
}

#define IMAGE_SIZE 24
#define IMAGE_GAP 10
#define IMAGE_TEXT_GAP 10
#define TEXT_CELL_TOP 12
#define TEXT_CELL_HEIGHT_PORT 150
#define TEXT_CELL_HEIGHT_LANDSC 60
#define IMAGE_TOP 10

- (void)setTextFieldFrame:(UIInterfaceOrientation)interfaceOrientation {
    
    int left = IMAGE_SIZE + IMAGE_GAP + IMAGE_TEXT_GAP;
    int right = 10;
    
    if (interfaceOrientation == UIInterfaceOrientationPortrait || interfaceOrientation == UIInterfaceOrientationPortraitUpsideDown) {
        self.textView.frame = CGRectMake(left, TEXT_CELL_TOP, self.tableView.bounds.size.width - left - right, TEXT_CELL_HEIGHT_PORT);
    } else {
        self.textView.frame = CGRectMake(left, TEXT_CELL_TOP, self.tableView.bounds.size.width - left - right, TEXT_CELL_HEIGHT_LANDSC);
    }
}

#pragma mark - UITableViewDelegate

#pragma mark - UITableViewDataSource

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return self.textView.frame.size.height + TEXT_CELL_TOP + TEXT_CELL_TOP;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    return self.textCell;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 1;
}

#pragma mark - UITextViewDelegate

- (void)loadView {
    
    [super loadView];
    
    AlignedStyle2Cell *_myTextCell = [[[AlignedStyle2Cell alloc] initWithStyle:UITableViewCellStyleValue2 reuseIdentifier:@"TextEditViewControllerCell" andNamedImage:self.namedImage] autorelease];
    _myTextCell.textLabel.text = @" ";
    _myTextCell.imageOnTop = YES;
    self.textCell = _myTextCell;
    
    self.textView = [[[UITextView alloc] initWithFrame:CGRectMake(0, 0, 0, 0)] autorelease];
    [self setTextFieldFrame:[UIApplication sharedApplication].statusBarOrientation];
    self.textView.delegate = self;
    self.textView.backgroundColor = [UIColor clearColor];
    
    [self.textCell addSubview:self.textView];
    
    [UIFactory initializeCell:self.textCell];
    
    [self.textView becomeFirstResponder];
    
}

@end
