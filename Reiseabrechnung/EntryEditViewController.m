//
//  EntryEditViewController.m
//  Reiseabrechnung
//
//  Created by Martin Maier on 30/06/2011.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "EntryEditViewController.h"


@implementation EntryEditViewController

@synthesize rootViewController=_rootViewController, travel=_travel;
@synthesize descriptionField=_descriptionField, amountField=_amountField, currencyField=_currencyField, datePicker=_datePicker, dateToggle=_dateToggle;

- (id) initWithTravel: (Travel *) travel {
    self = [super init];
    if (self) {
        _travel = travel;
    }
    return self;
}

- (IBAction)done:(UIBarButtonItem *)sender {
    
    NSNumberFormatter * f = [[NSNumberFormatter alloc] init];
    [f setNumberStyle:NSNumberFormatterDecimalStyle];
    NSNumber * myNumber = [f numberFromString:_amountField.text];
    [f release];
    
    [_rootViewController addEntry:_descriptionField.text 
                       withAmount:myNumber 
                     withCurrency:_currencyField.text 
                         withDate:_datePicker.date];
    
    [self dismissModalViewControllerAnimated:YES];
}

- (IBAction)cancel:(UIBarButtonItem *)sender {
    self.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
    [self dismissModalViewControllerAnimated:YES];
}

- (void)dealloc
{
    [super dealloc];
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
    // Do any additional setup after loading the view from its nib.
    
    _currencyField.text = _travel.currency;
    [_descriptionField becomeFirstResponder];
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
