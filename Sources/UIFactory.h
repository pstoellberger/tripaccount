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
#import "HelpView.h"

#define NAVIGATIONBAR_HEIGHT 44
#define STATUSBAR_HEIGHT 20
#define TABBAR_HEIGHT 49
#define ENTRY_SORT_HEIGHT 40
#define CURRENCY_SORT_HEIGHT 45

#define RATE_SORT_TOOLBAR_HEIGHT 15
#define RATE_LABEL_HEIGHT 10
#define ACTIVITY_VIEW_SIZE 13


@class HelpView;

@interface UIFactory : NSObject {
    
}

+ (UIView *)createDefaultTableSectionHeader:(id <UITableViewDataSource>)tableViewDataSource andTableView:(UITableView *)tableView andSection:(NSInteger)section;
+ (void)initializeTableViewController:(UITableView *)controller;
+ (void)initializeCell:(UITableViewCell *)cell;
+ (void)addGradientToView:(UIView *)cell;
+ (void)addGradientToView:(UIView *)cell color1:(UIColor *)color1 color2:(UIColor *)color2;
+ (void)addGradientToView:(UIView *)cell color1:(UIColor *)color1 color2:(UIColor *)color2 startPoint:(CGPoint)startPoint endPoint:(CGPoint)endPoint;
+ (int)defaultSectionHeaderCellHeight;
+ (int)defaultCellHeight;
+ (void)addShadowToView:(UIView *)view;
+ (void)removeShadowFromView:(UIView *)view;
+ (BOOL)dateHasTime:(NSDate *)date;
+ (NSDate *)createDateWithoutTimeFromDate:(NSDate *)date;
+ (UIColor *)defaultTintColor;
+ (UIColor *)defaultDarkTintColor; 
+ (UIColor *)defaultLightTintColor;
+ (void)changeTextColorOfSegControler:(UISegmentedControl *)segControl color:(UIColor *)color;
+ (UIView *)createBackgroundViewWithFrame:(CGRect)rect;
+ (void)setColorOfSearchBarInABPicker:(ABPeoplePickerNavigationController *)picker color:(UIColor *)color;
+ (UIAlertView *)createAlterViewForRefreshingRatesOnOpeningTravel:(id <UIAlertViewDelegate>)delegate;
+ (NSString *)formatNumber:(NSNumber *)number;
+ (NSString *)formatNumber:(NSNumber *)number withDecimals:(int)decimals;
+ (void)addHelpViewToView:(HelpView *)helpView toView:(UIView *)view;
+ (void)replaceHelpViewInView:(NSString *)replaceHelpViewId withView:(HelpView *)helpView toView:(UIView *)view;
+ (UIImage *)imageWithImage:(UIImage *)image scaledToSize:(CGSize)newSize;
+ (NSString *)translateString:(NSString *)dbString;

@end
