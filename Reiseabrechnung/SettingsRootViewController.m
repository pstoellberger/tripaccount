//
//  SettingsRootViewController.m
//  Reiseabrechnung
//
//  Created by Martin Maier on 01/08/2011.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "SettingsRootViewController.h"
#import "TypeViewController.h"
#import "UIFactory.h"

@implementation SettingsRootViewController

@synthesize settingsTabBarController=_settingsTabBarController;

- (id)initInManagedObjectContext:(NSManagedObjectContext *)context {

    self = [super init];
    
    if (self) {
        
        self.title = @"Settings";
        
        self.settingsTabBarController = [[[UITabBarController alloc] init] autorelease];
        self.settingsTabBarController.delegate = self;
        
        self.settingsTabBarController.view.frame = CGRectMake(0, 0, self.view.frame.size.width, [UIScreen mainScreen].applicationFrame.size.height - TABBAR_HEIGHT);
        self.settingsTabBarController.tabBar.frame = CGRectMake(0, self.tabBarController.view.frame.size.height - TABBAR_HEIGHT, self.tabBarController.view.frame.size.width, TABBAR_HEIGHT);
        
        self.navigationItem.leftBarButtonItem = [[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel target:self action:@selector(cancel)] autorelease];
        
        self.navigationItem.rightBarButtonItem = [[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(add)] autorelease];
        
        TypeViewController *detailViewController = [[[TypeViewController alloc] initInManagedObjectContext:context] autorelease];
        TypeViewController *detailViewController2 = [[[TypeViewController alloc] initInManagedObjectContext:context] autorelease];
        
        [self.settingsTabBarController setViewControllers:[NSArray arrayWithObjects:detailViewController, detailViewController2, nil] animated:NO];
        
        [self.view addSubview:self.settingsTabBarController.view];
        
    }
    return self;
}

- (void)cancel {
    
    self.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
    [self dismissModalViewControllerAnimated:YES];
}

- (void)add {
    
}

- (void)didReceiveMemoryWarning {
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - View lifecycle


/*
// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad
{
    [super viewDidLoad];
}
*/

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
