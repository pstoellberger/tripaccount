//  MultiLineSegmentedControl.m
//  iphone
//
//  Created by Jens Kreiensiek on 20.07.11.
//  Copyright 2011 SoButz. All rights reserved.
//

#import "MultiLineSegmentedControl.h"

static NSInteger MY_TAG = 0x666;

@implementation MultiLineSegmentedControl

@synthesize subTitles;

- (id)initWithItems:(NSArray *)items andSubTitles:(NSArray *)newTitles {
    
    if ([items count] != [newTitles count]) {
        [NSException raise:NSInvalidArgumentException format:@"Titles and subtitles array must be of the same size."];
        return nil;
    }
    
    if (self = [super initWithItems:items]) {
        self.subTitles = newTitles;
    }
    
    return self;
}


- (void)initialize {
    
    if (!initialized) {
        
        int segIndex = 0;
        for (UIView *segmentView in self.subviews) {
            
            UILabel *label = [[UILabel alloc] initWithFrame:CGRectZero];
            label.textColor = [UIColor lightGrayColor];
            label.backgroundColor = [UIColor clearColor];
            label.font = [UIFont boldSystemFontOfSize:10];
            label.textAlignment = UITextAlignmentCenter;
            label.shadowColor = [UIColor blackColor];
            label.tag = MY_TAG;
            label.text = [self.subTitles objectAtIndex:[self.subTitles count] - segIndex - 1];
            
            [segmentView addSubview:label];
            [label release];
            
            segIndex++;
        }
        
        initialized = YES;
    }
}

- (void)layoutSubviews {
    
    [super layoutSubviews];
    [self initialize];
    
    for (UIView *segmentView in self.subviews) {
        
        UIView *segmentLabel = [[segmentView subviews] objectAtIndex:0];
        if (segmentLabel) {
            
            UILabel *myLabel = (UILabel *)[segmentView viewWithTag:MY_TAG];
            if (myLabel) {
                
                if (self.frame.size.height >= 30) {
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

@end