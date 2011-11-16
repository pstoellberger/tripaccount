//
//  ShadowNavigationController.m
//  Reiseabrechnung
//
//  Created by Martin Maier on 24/07/2011.
//  Copyright 2011 Martin Maier. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "ShadowNavigationController.h"
#import "UIFactory.h"

@implementation ShadowNavigationController

- (void)viewWillAppear:(BOOL)animated {   
    [super viewWillAppear:animated];   
    
    self.navigationBar.barStyle = UIBarStyleBlackTranslucent;
    [UIFactory addShadowToView:self.navigationBar];
} 

@end
