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
@synthesize infoButton=_infoButton;
@synthesize animationOngoing=_animationOngoing;

- (id) initInManagedObjectContext:(NSManagedObjectContext *) context {
     
     [Crittercism leaveBreadcrumb:@"RootViewController: init"];
     
     if (self = [super init]) {
          
          _managedObjectContext = [context retain];
          
          self.view.autoresizingMask = UIViewAutoresizingFlexibleBottomMargin | UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
          
          self.tableViewController = [[[TravelListViewController alloc] initInManagedObjectContext:context withRootViewController:self] autorelease];
          self.tableViewController.view.frame = CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height);
          self.tableViewController.view.autoresizingMask = UIViewAutoresizingFlexibleBottomMargin | UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
          
          UIEdgeInsets insets = self.tableViewController.tableView.contentInset;
          insets.top = NAVIGATIONBAR_HEIGHT;
          self.tableViewController.tableView.contentInset = insets;
          self.tableViewController.tableView.scrollIndicatorInsets = self.tableViewController.tableView.contentInset;
          
          [self.view addSubview:self.tableViewController.view];
          
          // bring button to front
          [self.view bringSubviewToFront:self.infoButton];
          
          self.title = @"Trips";
          
          self.navigationItem.rightBarButtonItem = self.addButton;
          self.navigationItem.leftBarButtonItem = self.editButton;
     }
     return self;
}

- (void)updateTableViewInsets {
     
     UIEdgeInsets insets = self.tableViewController.tableView.contentInset;
     insets.top = self.navigationController.navigationBar.frame.size.height;
     self.tableViewController.tableView.contentInset = insets;
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
     
     [Crittercism leaveBreadcrumb:@"RootViewController: openTravelEditViewController"];
     
     TravelEditViewController *detailViewController = [[TravelEditViewController alloc] initInManagedObjectContext:self.managedObjectContext];
     detailViewController.editDelegate = self;
     UINavigationController *navController = [[ShadowNavigationController alloc] initWithRootViewController:detailViewController];
     navController.delegate = detailViewController;
     
     [self.navigationController presentModalViewController:navController animated:YES];   
     [detailViewController release];
     [navController release];
}

- (void)travelEditFinished:(Travel *)travel wasSaved:(BOOL)wasSaved {
     
     [Crittercism leaveBreadcrumb:@"RootViewController: travelEditFinished"];
     
     [self.tableViewController.tableView deselectRowAtIndexPath:[self.tableViewController.tableView indexPathForSelectedRow] animated:YES];
     
     if (wasSaved) {
          [self doneEditing];
     }
}

- (void)openInfoPopup {
     
     [Crittercism leaveBreadcrumb:@"RootViewController: openInfoPopup"];
     
     self.infoButton.hidden = YES;
     
     self.infoViewController = [[[InfoViewController alloc] initWithNibName:nil bundle:nil] autorelease];
     self.infoViewController.view.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
     [self.infoViewController setCloseAction:self action:@selector(closeInfoPopup)];
     
     self.infoViewController.view.frame = CGRectMake(0, 0, [UIScreen mainScreen].applicationFrame.size.width, [[UIScreen mainScreen] applicationFrame].size.height);
     
     [UIView beginAnimations:nil context:nil];
     [UIView setAnimationDuration:0.8];
     [UIView setAnimationTransition:UIViewAnimationTransitionFlipFromRight
                            forView:self.navigationController.view.superview
                              cache:YES];
     
     [self.navigationController.view.superview addSubview:self.infoViewController.view];
     [UIView commitAnimations];
     
}

- (void)closeInfoPopup {
     
     [Crittercism leaveBreadcrumb:@"RootViewController: closeInfoPopup"];
     
     self.infoButton.hidden = NO;

     [UIView beginAnimations:nil context:nil];
     [UIView setAnimationDuration:0.8];
     [UIView setAnimationTransition:UIViewAnimationTransitionFlipFromLeft
                            forView:self.navigationController.view.superview
                              cache:YES];
     
     [self.infoViewController.view removeFromSuperview];
     [UIView commitAnimations];
     
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
     return YES;
}

- (void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration {
     NSLog(@"willRotateToInterfaceOrientation");
     if (self.infoViewController.view.superview == nil && !self.animationOngoing) {

          NSLog(@"willRotateToInterfaceOrientation remove");
          
     }
               [self.navigationController.view.layer removeAllAnimations];
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
     [super didRotateFromInterfaceOrientation:fromInterfaceOrientation];
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
     
     UIButton *iButton = [UIButton buttonWithType:UIButtonTypeInfoLight];
     iButton.frame = CGRectMake(self.view.frame.size.width - iButton.frame.size.width - 10, self.view.frame.size.height - iButton.frame.size.height - 10, iButton.frame.size.width, iButton.frame.size.height);
     iButton.adjustsImageWhenHighlighted = YES;
     iButton.adjustsImageWhenDisabled = YES;
     iButton.showsTouchWhenHighlighted = YES;
     iButton.reversesTitleShadowWhenHighlighted = YES;
     iButton.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleTopMargin;
     
     [iButton addTarget:self action:@selector(openInfoPopup) forControlEvents:UIControlEventTouchUpInside];
     self.infoButton = iButton;
     
     [self.view addSubview:iButton];

}

- (void)viewWillAppear:(BOOL)animated {
     
     double navBarHeight = self.navigationController.navigationBar.frame.size.height;
     double windowWidth = self.view.frame.size.width;
     
     NSString *text = NSLocalizedString(@"help add trip", @"help bubble add trip");
     HelpView *helpView = [[HelpView alloc] initWithFrame:CGRectMake(windowWidth - 102, navBarHeight, 100, 100) text:text arrowPosition:ARROWPOSITION_TOP_RIGHT enterStage:ENTER_STAGE_FROM_TOP uniqueIdentifier:@"travel add button"];
     [UIFactory addHelpViewToView:helpView toView:self.view];
     [helpView release];
     
     text = NSLocalizedString(@"help sample trip", @"help bubble sample trip");
     helpView = [[HelpView alloc] initWithFrame:CGRectMake(2, navBarHeight + 70, 100, 100) text:text arrowPosition:ARROWPOSITION_TOP_LEFT enterStage:ENTER_STAGE_FROM_TOP uniqueIdentifier:@"sample trip"];
     [UIFactory addHelpViewToView:helpView toView:self.view];       
     [helpView release];
     
     [self.tableViewController.tableView scrollRectToVisible:CGRectMake(0, 0, 1, 1) animated:NO];
     
     [self updateTableViewInsets];
}

- (void)dealloc {
     
     [_addButton release];
     [_editButton release];
     [_doneButton release];
     
     [_tableViewController release];
     [_managedObjectContext release];
     
     [_infoButton release];
     [_infoViewController release];
     
     [super dealloc];
}

@end
