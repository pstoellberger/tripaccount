//
//  LocationViewController.m
//  Reiseabrechnung
//
//  Created by Martin Maier on 22/07/2011.
//  Copyright 2011 Martin Maier. All rights reserved.
//

#import "LocationViewController.h"
#import "UIFactory.h"

@implementation LocationViewController

@synthesize travel=_travel, target=_target, selector=_selector;
@synthesize city=_city, country=_country;

@synthesize cityCell=_cityCell, countryCell=_countryCell;

- (id) initWithTravel:(Travel *) travel target:(id)target selector:(SEL)selector {

    if (self = [super initWithStyle:UITableViewStyleGrouped]) {

        [UIFactory initializeTableViewController:self.tableView];
        
        self.travel = travel;
        
        self.target = target;
        self.selector = selector;
        
        self.tableView.delegate = self;
        self.tableView.dataSource = self;
    }
    return self;    
}

#pragma mark - UITableViewDelegate


#pragma mark - UITableViewDataSource

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
      
    if (indexPath.section == 0) {
        switch (indexPath.row) {
            case 0:
                return self.countryCell;
            case 1:
                return self.cityCell;
        }
    }
    return nil;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 2;
}

#pragma mark - UITextFieldDelegate

// text field

#pragma mark - View lifecycle


- (void)loadView {
    
    [super loadView];
    
    self.countryCell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:@"CountryCell"] autorelease];
    self.countryCell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    self.countryCell.textLabel.text = @"Country";
    if (self.country) {
        self.countryCell.textLabel.text = [NSString stringWithFormat:@"%@", self.country.name];
        if (self.country.image) {
            NSString *pathCountryPlist =[[NSBundle mainBundle] pathForResource:self.country.image ofType:@""];
            self.countryCell.imageView.image = [UIImage imageWithContentsOfFile:pathCountryPlist];                       
        }
    }
    
    self.cityCell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue2 reuseIdentifier:@"CityEditCell"] autorelease];
    self.cityCell.textLabel.text = @"City";
    
    UITextField *_cityCellField = [[UITextField alloc] initWithFrame:CGRectMake(85, 10, 200, 200)];
    _cityCellField.delegate = self;
    _cityCellField.placeholder = @"City (optional)";
    _cityCellField.text = self.city;
    [self.cityCell.contentView addSubview:_cityCellField]; 
    [_cityCellField release];
}


- (void)viewDidUnload {
    [super viewDidUnload];
    
    self.travel = nil;
    self.target = nil;
    self.selector = nil;
    
    self.country = nil;
    self.city = nil;
    
    self.cityCell = nil;
    self.countryCell = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    return YES;
}

@end
