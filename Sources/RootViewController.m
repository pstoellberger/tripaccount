//
//  RootViewController.m
//  Reiseabrechnung
//
//  Created by Martin Maier on 28/06/2011.
//  Copyright 2011 Martin Maier. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>
#import "RootViewController.h"
#import "TravelListViewController.h"
#import "UIFactory.h"
#import "TravelEditViewController.h"
#import "ShadowNavigationController.h"
#import "HelpView.h"
#import "InfoViewController.h"

@interface RootViewController ()
- (void)doneEditing;
- (void)changeToEditMode;
- (void)updateTableViewInsets;
@end

@implementation RootViewController

@synthesize managedObjectContext=_managedObjectContext;
@synthesize tableViewController=_tableViewController, infoViewController=_infoViewController;
@synthesize addButton=_addButton, editButton=_editButton, doneButton=_doneButton;
@synthesize infoToolBar=_infoToolBar;

- (id) initInManagedObjectContext:(NSManagedObjectContext *) context {
     
     if (self = [super init]) {
          _managedObjectContext = context;
          
          self.tableViewController = [[[TravelListViewController alloc] initInManagedObjectContext:context withRootViewController:self] autorelease];
          self.tableViewController.view.frame = CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height);
          self.tableViewController.view.autoresizingMask = UIViewAutoresizingFlexibleBottomMargin | UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
          self.tableViewController.tableView.contentInset = UIEdgeInsetsMake(NAVIGATIONBAR_HEIGHT, 0, TOOLBAR_HEIGHT, 0);
          self.tableViewController.tableView.scrollIndicatorInsets = self.tableViewController.tableView.contentInset;
          
          [self.view addSubview:self.tableViewController.view];
          
          // bring toolbar to front
          for (UIView *view in self.view.subviews) {
               if ([view isKindOfClass:[UIToolbar class]]) {
                    [self.view bringSubviewToFront:view];
                    break;
               }
          }
          
          
          self.title = @"Trips";
          
          self.navigationItem.rightBarButtonItem = self.addButton;
          self.navigationItem.leftBarButtonItem = self.editButton;
     }
     return self;
}

- (void)updateTableViewInsets {
     
     self.tableViewController.tableView.contentInset = UIEdgeInsetsMake(self.navigationController.navigationBar.frame.size.height, 0, self.infoToolBar.frame.size.height, 0);
     self.tableViewController.tableView.scrollIndicatorInsets = self.tableViewController.tableView.contentInset;
}

- (UIBarButtonItem *) addButton {
     if (!_addButton) {
          _addButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(openTravelEditViewController)];   
     }
     return [_addButton retain];    
}

- (UIBarButtonItem *) editButton {
     if (!_editButton) {
          _editButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemEdit target:self action:@selector(changeToEditMode)]; 
     }
     return [_editButton retain];    
}

- (UIBarButtonItem *) doneButton {
     if (!_doneButton) {
          _doneButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(doneEditing)];
     }
     return [_doneButton retain];       
}

- (void)openTravelEditViewController {
     
     TravelEditViewController *detailViewController = [[TravelEditViewController alloc] initInManagedObjectContext:self.managedObjectContext];
     detailViewController.editDelegate = self;
     UINavigationController *navController = [[ShadowNavigationController alloc] initWithRootViewController:detailViewController];
     navController.delegate = detailViewController;
     
     [self.navigationController presentModalViewController:navController animated:YES];   
     [detailViewController release];
     [navController release];
}

- (void)travelEditFinished:(Travel *)travel wasSaved:(BOOL)wasSaved {
     
     [self.tableViewController.tableView deselectRowAtIndexPath:[self.tableViewController.tableView indexPathForSelectedRow] animated:YES];
     
     if (wasSaved) {
          [self doneEditing];
     }
}

- (void)openInfoPopup {
     
     self.infoViewController = [[[InfoViewController alloc] init] autorelease];
     
     [UIView beginAnimations:nil context:nil];
     [UIView setAnimationDuration:1.0];
     [UIView setAnimationTransition:UIViewAnimationTransitionFlipFromRight
                            forView:[self.navigationController.view superview]
                              cache:YES];
     
     [[self.navigationController.view superview] addSubview:self.infoViewController.view];
     [UIView commitAnimations];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
     return YES;
}

- (void)changeToEditMode {
     [self.navigationItem setRightBarButtonItem:self.doneButton animated:YES];
     [self.navigationItem setLeftBarButtonItem:nil animated:YES];
     [self.tableViewController.tableView setEditing:YES animated:YES];
}

- (void)doneEditing {
     [self.navigationItem setRightBarButtonItem:self.addButton animated:YES];
     [self.navigationItem setLeftBarButtonItem:self.editButton animated:YES];
     [self.tableViewController.tableView setEditing:NO animated:YES];
}

- (void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation {
     [self updateTableViewInsets];
}

#pragma mark UINavigationControllerDelegate

- (void)navigationController:(UINavigationController *)navigationController didShowViewController:(UIViewController *)viewController animated:(BOOL)animated {
     
     if (viewController == self) {
          [self.tableViewController.tableView deselectRowAtIndexPath:[self.tableViewController.tableView indexPathForSelectedRow] animated:YES];
          
          self.tableViewController.reloadDisabled = NO;
     }
}

#pragma mark View lifecycle

- (void)viewDidLoad {
     [super viewDidLoad];
     
}

- (void)viewDidUnload {
     [super viewDidUnload];
}

- (void)loadView {
     
     [super loadView];
     
     UIToolbar *toolbar = [[UIToolbar alloc] initWithFrame:CGRectMake(0, self.view.frame.size.height - TOOLBAR_HEIGHT, self.view.frame.size.width, TOOLBAR_HEIGHT)];
     toolbar.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleHeight;
     toolbar.barStyle = UIBarStyleBlackTranslucent;
     self.infoToolBar = toolbar;
     
     UIBarButtonItem *infoButton = [[UIBarButtonItem alloc] initWithTitle:@"Info" style:UIBarButtonItemStyleBordered target:self action:@selector(openInfoPopup)];
     UIBarButtonItem *flexibleSpace = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
     
     toolbar.items = [NSArray arrayWithObjects:infoButton, nil];
     
     [infoButton release];
     [flexibleSpace release];
     
     [self.view addSubview:toolbar];
     [self.view bringSubviewToFront:toolbar];
     [toolbar release];

}

- (void)viewWillAppear:(BOOL)animated {
     
     NSString *text = @"Use this button to add a new trip to start tracking your expenses.";
     HelpView *helpView = [[HelpView alloc] initWithFrame:CGRectMake(218, NAVIGATIONBAR_HEIGHT, 100, 100) text:text arrowPosition:ARROWPOSITION_TOP_RIGHT enterStage:ENTER_STAGE_FROM_TOP uniqueIdentifier:@"travel add button"];
     [UIFactory addHelpViewToView:helpView toView:self.view];
     [helpView release];
     
     text = @"Try this app by using the sample trip to Vienna, Austria.";
     helpView = [[HelpView alloc] initWithFrame:CGRectMake(2, NAVIGATIONBAR_HEIGHT + 70, 100, 100) text:text arrowPosition:ARROWPOSITION_TOP_LEFT enterStage:ENTER_STAGE_FROM_TOP uniqueIdentifier:@"sample trip"];
     [UIFactory addHelpViewToView:helpView toView:self.view];       
     [helpView release];
     
     [self.tableViewController.tableView scrollRectToVisible:CGRectMake(0, 0, 1, 1) animated:NO];
}

- (void)dealloc {
     
     [super dealloc];
}

@end
