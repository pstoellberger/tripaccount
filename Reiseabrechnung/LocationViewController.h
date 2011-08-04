//
//  LocationViewController.h
//  Reiseabrechnung
//
//  Created by Martin Maier on 22/07/2011.
//  Copyright 2011 Martin Maier. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Country.h"

@interface LocationViewController : UITableViewController <UITableViewDelegate, UITableViewDataSource, UITextFieldDelegate> {
    
    Travel *_travel;
    
    id _target;
    SEL _selector;
    
    Country *_country;
    NSString *_city;
    
    UITableViewCell *_countryCell;
    UITableViewCell *_cityCell;
}

@property (nonatomic, retain) Travel *travel;

@property (nonatomic, retain) id target;
@property (nonatomic, assign) SEL selector;

@property (nonatomic, retain) Country *country;
@property (nonatomic, retain) NSString *city;

@property (nonatomic, retain) UITableViewCell *countryCell;
@property (nonatomic, retain) UITableViewCell *cityCell;

- (id) initWithTravel:(Travel *) travel target:(id)target selector:(SEL)selector;

@end
