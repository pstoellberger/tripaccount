//
//  UIFactory.h
//  Reiseabrechnung
//
//  Created by Martin Maier on 18/07/2011.
//  Copyright 2011 Martin Maier. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AddressBook/AddressBook.h>
#import <AddressBookUI/AddressBookUI.h>

#define NAVIGATIONBAR_HEIGHT 44
#define TOOLBAR_HEIGHT 44
#define STATUSBAR_HEIGHT 20
#define TABBAR_HEIGHT 49

@interface UIFactory : NSObject {
    
}

+ (UIView *)createDefaultTableSectionHeader:(id <UITableViewDataSource>)tableViewDataSource andTableView:(UITableView *)tableView andSection:(NSInteger)section;
+ (void)initializeTableViewController:(UITableView *)controller;
+ (void)initializeCell:(UITableViewCell *)cell;
+ (void)addGradientToView:(UIView *)cell;
+ (void)addGradientToView:(UIView *)cell color1:(UIColor *)color1 color2:(UIColor *)color2;
+ (int)defaultSectionHeaderCellHeight;
+ (int)defaultCellHeight;
+ (void)addShadowToView:(UIView *)view;
+ (void)removeShadowFromView:(UIView *)view;
+ (BOOL)dateHasTime:(NSDate *)date;
+ (NSDate *)createDateWithoutTimeFromDate:(NSDate *)date;
+ (UIColor *)defaultTintColor;
+ (void)changeTextColorOfSegControler:(UISegmentedControl *)segControl color:(UIColor *)color;
+ (UIView *)createBackgroundViewWithFrame:(CGRect)rect;
+ (void)setColorOfSearchBarInABPicker:(ABPeoplePickerNavigationController *)picker color:(UIColor *)color;
+ (UIAlertView *)createAlterViewForRefreshingRatesOnOpeningTravel:(id <UIAlertViewDelegate>)delegate;

@end
