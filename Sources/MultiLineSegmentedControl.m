//  MultiLineSegmentedControl.m
//  iphone
//
//  Created by Jens Kreiensiek on 20.07.11.
//  Copyright 2011 SoButz. All rights reserved.
//

#import "MultiLineSegmentedControl.h"

static NSInteger SUBLABEL_TAG = 0x666;
static NSInteger LABEL_TAG = 0x555;

@implementation MultiLineSegmentedControl

@synthesize subTitles;

- (id)initWithItems:(NSArray *)items andSubTitles:(NSArray *)newTitles {
    
    if (self = [super initWithItems:items]) {
        self.subTitles = newTitles;
        titles = [items retain];
        
        viewLabelMap = [[NSMutableDictionary alloc] init];
    }
    
    return self;
}


- (void)initialize {
    
    if (!initialized) {
        
        NSMutableArray *labelArray = [NSMutableArray arrayWithCapacity:[self.subviews count]];
        
        int segIndex = 0;
        for (UIView *segmentView in self.subviews) {
            
            UILabel *mainLabel = nil;
            for (UIView *subView in segmentView.subviews) {
                if ([subView isKindOfClass:[UILabel class]]) {
                    subView.tag = LABEL_TAG;
                    mainLabel = (UILabel *)subView;
                }
            }
            
            if ([self.subTitles count] > segIndex) {
                
                UILabel *label = [[UILabel alloc] initWithFrame:CGRectZero];
                label.backgroundColor = [UIColor clearColor];
                label.font = [UIFont boldSystemFontOfSize:10];
                label.textAlignment = UITextAlignmentCenter;
                label.tag = SUBLABEL_TAG;
                label.textColor = [UIColor whiteColor];
                
                if (mainLabel) {
                    label.shadowColor = mainLabel.shadowColor;
                    label.shadowOffset = mainLabel.shadowOffset;
                }
                
                NSString *code = nil;
                for (UIView *subView in segmentView.subviews) {
                    if ([subView respondsToSelector:@selector(text)]) {
                        code = [subView performSelector:@selector(text)];
                        break;
                    }
                }
                label.text = [self.subTitles objectAtIndex:[titles indexOfObject:code]];
                
                [segmentView addSubview:label];
                [labelArray addObject:label];
                [label release];
            }
            
            segIndex++;
        }
                
        subLabels = [[NSArray alloc] initWithArray:labelArray];
        
        initialized = YES;

    }
}

- (void)layoutSubviews {
    
    [super layoutSubviews];
    [self initialize];
    
    for (UIView *segmentView in self.subviews) {
        
        UIView *segmentLabel = [[segmentView subviews] objectAtIndex:0];
        if (segmentLabel) {
            
            UILabel *myLabel = (UILabel *)[segmentView viewWithTag:SUBLABEL_TAG];
            if (myLabel) {
                
                if (self.frame.size.height >= 25) {
                    CGFloat h = [myLabel.font lineHeight];
                    
                    CGRect f = segmentLabel.frame;
                    f.origin.y -= h / 2;
                    segmentLabel.frame = f;
                    
                    f.origin.y += h;
                    f.origin.x = 0;
                    f.size.width = segmentView.frame.size.width;
                    myLabel.frame = f;
                    
                    myLabel.hidden = NO;
                } else {
                    myLabel.hidden = YES;
                }
            }
        }
    }
}

- (void)dealloc {
    [subLabels release];
    [titles release];
    [viewLabelMap release];
    self.subTitles = nil;
    [super dealloc];
}

@end