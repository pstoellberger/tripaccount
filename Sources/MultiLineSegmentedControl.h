//
//  MultiLineSegmentedControl.h
//  iphone
//
//  Created by Jens Kreiensiek on 20.07.11.
//  Copyright 2011 SoButz. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface MultiLineSegmentedControl : UISegmentedControl {
    
    BOOL initialized;
    NSArray *subLabels;
    NSArray *titles;
    NSMutableDictionary *viewLabelMap;
}

@property (nonatomic, retain) NSArray *subTitles;

- (id)initWithItems:(NSArray *)items andSubTitles:(NSArray *)subTitles;

@end