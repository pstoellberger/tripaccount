//
//  CurrencySelectViewController.m
//  Reiseabrechnung
//
//  Created by Martin Maier on 01/07/2011.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "CurrencySelectViewController.h"
#import "Currency.h"

@implementation CurrencySelectViewController

@synthesize travel=_travel, entryEditViewController=_entryEditViewController;
@synthesize selectedCurrency=_selectedCurrency;

- (id)initInManagedObjectContext:(NSManagedObjectContext *)context target:(id)target action:(SEL)selector {
    self = [super initWithNibName:nil bundle:nil];
    if (self) {
        _selector = selector;
        _target = target;
        
        NSFetchRequest *req = [[NSFetchRequest alloc] init];
        req.entity = [NSEntityDescription entityForName:@"Currency" inManagedObjectContext: context];
        req.sortDescriptors = [NSArray arrayWithObject:[NSSortDescriptor sortDescriptorWithKey:@"name" ascending:YES]];
        
        self.fetchedResultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:req managedObjectContext:context sectionNameKeyPath:nil cacheName:@"Currency"];
        [req release];
        
        self.fetchedResultsController.delegate = self;
        
        self.titleKey = @"name";
        self.title = @"Select currency";
        
        [self.navigationController setToolbarHidden:YES];
        [self.navigationController setNavigationBarHidden:YES animated:NO];
        
        [self viewWillAppear:true];
    }
    return self;
}



- (void)managedObjectSelected:(NSManagedObject *)managedObject {

    if ([_target respondsToSelector:_selector]) {
        [_target performSelector:_selector withObject:managedObject];
    }

    [self.navigationController popViewControllerAnimated:YES];

}

- (UITableViewCellAccessoryType)accessoryTypeForManagedObject:(NSManagedObject *)managedObject {
    if ([managedObject isEqual:self.selectedCurrency]) {
        return UITableViewCellAccessoryCheckmark;
    } else {
        return UITableViewCellAccessoryNone;
    }
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
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return YES;
}

@end
