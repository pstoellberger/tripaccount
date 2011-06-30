//
//  TravelEditViewController.m
//  Reiseabrechnung
//
//  Created by Martin Maier on 29/06/2011.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "TravelEditViewController.h"


@implementation TravelEditViewController

@synthesize doneButton=_doneButton, nameField=_nameField, currencyPicker=_currencyPicker, rootViewController=_rootViewController;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        currencies = [[NSMutableArray alloc] initWithObjects:@"EUR", @"USD", @"AUD", @"ILS", nil];
    }
    return self;
}

- (IBAction)done:(UIBarButtonItem *)sender {
    
    NSUInteger selectedRow = [_currencyPicker selectedRowInComponent:0];
    NSString *_currency = [self pickerView:_currencyPicker titleForRow:selectedRow forComponent:0];    
    [_rootViewController addTravel:_nameField.text withCurrency:_currency];
    [self dismissModalViewControllerAnimated:YES];
}

- (IBAction)cancel:(UIBarButtonItem *)sender {
    self.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
    [self dismissModalViewControllerAnimated:YES];
}

- (void)dealloc
{
    [super dealloc];
    [currencies dealloc];
}

- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)thePickerView {
    return 1;
}

- (NSInteger)pickerView:(UIPickerView *)thePickerView numberOfRowsInComponent:(NSInteger)component {
    return [currencies count];
}

- (NSString *)pickerView:(UIPickerView *)thePickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component {
    return [currencies objectAtIndex:row];
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)repString {
    if([repString isEqualToString:@"\n"]) {
        [textField resignFirstResponder];
        return NO;
    }
    
	if ([[repString  stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]] length] > 0) {
        self.doneButton.enabled = YES;
    } else {
        self.doneButton.enabled = NO;
    }   
	return YES;
}

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self.nameField becomeFirstResponder];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

@end
