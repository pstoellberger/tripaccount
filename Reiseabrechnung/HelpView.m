//
//  HelpView.m
//  Reiseabrechnung
//
//  Created by Martin Maier on 27/07/2011.
//  Copyright 2011 Martin Maier. All rights reserved.
//

#import "HelpView.h"
#import <QuartzCore/QuartzCore.h>
#import "ArrowView.h"

@implementation HelpView

@synthesize text=_text;

#define ARROW_HEIGHT 15
#define ARROW_WIDTH 30
#define ARROW_BORDERSPACE 5

#define ANIMATE_DISTANCE 3

#define ARROW_MARGIN 1

#define degreesToRadians(x) (M_PI * x / 180.0)

static NSString *DICTIONARY_KEY;

- (id)initWithFrame:(CGRect)frame text:(NSString *)text arrowPosition:(ArrowPosition)arrowPosition uniqueIdentifier:(NSString *)uniqueIdentifier {
    
    if ((self = [super initWithFrame:frame])) {
        
        DICTIONARY_KEY = @"HelpViewClickedAway";
        
        _aboutToLeave = NO;
        _uniqueIdentifier = uniqueIdentifier;
        
        UIColor *bgColor = [UIColor blackColor];
        
        self.text = text;
        
        self.backgroundColor = [UIColor clearColor];
        self.alpha = 0.75;
        self.opaque = NO;
        
        UIView *bodyView = nil;
        if (arrowPosition == ARROWPOSITION_TOP_RIGHT || arrowPosition == ARROWPOSITION_TOP_LEFT) {
            bodyView = [[UIView alloc] initWithFrame:CGRectMake(0, ARROW_HEIGHT, frame.size.width, frame.size.height - ARROW_HEIGHT)];
        } else {
            bodyView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, frame.size.width, frame.size.height - ARROW_HEIGHT)];
        }

        bodyView.backgroundColor = bgColor;
        bodyView.layer.cornerRadius = 3;
        bodyView.layer.masksToBounds = YES;
        bodyView.opaque = NO;
        
        UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(5, 5, bodyView.frame.size.width - 5, bodyView.frame.size.height - 5)];
        label.text = text;
        label.textColor = [UIColor whiteColor];
        label.backgroundColor = [UIColor clearColor];
        label.numberOfLines = 0;
        label.font = [UIFont fontWithName:@"Arial Rounded MT Bold" size:(12.0)];
        
        [bodyView addSubview:label];
        [label release];
        
        ArrowView *arrayView = nil;
        if (arrowPosition == ARROWPOSITION_TOP_RIGHT) {
            arrayView = [[ArrowView alloc] initWithFrame:CGRectMake(frame.size.width - ARROW_WIDTH - ARROW_BORDERSPACE, 0, ARROW_WIDTH, ARROW_HEIGHT + ARROW_MARGIN)];
        } else if (arrowPosition == ARROWPOSITION_TOP_LEFT) {
            arrayView = [[ArrowView alloc] initWithFrame:CGRectMake(ARROW_BORDERSPACE, 0, ARROW_WIDTH, ARROW_HEIGHT + ARROW_MARGIN)];
        } else if (arrowPosition == ARROWPOSITION_BOTTOM_RIGHT) {
            arrayView = [[ArrowView alloc] initWithFrame:CGRectMake(frame.size.width - ARROW_WIDTH - ARROW_BORDERSPACE, frame.size.height - ARROW_HEIGHT - ARROW_MARGIN, ARROW_WIDTH, ARROW_HEIGHT + ARROW_MARGIN)];
            arrayView.upsideDown = YES;
        } else if (arrowPosition == ARROWPOSITION_BOTTOM_LEFT) {
            arrayView = [[ArrowView alloc] initWithFrame:CGRectMake(ARROW_BORDERSPACE, frame.size.height - ARROW_HEIGHT - ARROW_MARGIN, ARROW_WIDTH, ARROW_HEIGHT + ARROW_MARGIN)];
            arrayView.upsideDown = YES;
        }        
        
        arrayView.opaque = NO;
        
        [self addSubview:bodyView];
        [self addSubview:arrayView];
        
        self.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin;
        
        [bodyView release];
        [arrayView release];
        
        //[UIFactory addShadowToView:self];
        
        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
        
        #if TARGET_IPHONE_SIMULATOR
            //[defaults removeObjectForKey:DICTIONARY_KEY];        
            //NSLog(@"Removing userdefaults because we are in the simulator");
        #endif
        
        NSDictionary *dictionary = [defaults dictionaryForKey:DICTIONARY_KEY];
        if (dictionary) {
            if ([dictionary objectForKey:uniqueIdentifier]) {
                self.hidden = YES;
            }
        }
        
        [self enterStage];
        
    }
    
    return self;
}

- (void)enterStage {
    
    if (!self.hidden) {
        int stageY = self.frame.origin.y;
        self.frame = CGRectMake(self.frame.origin.x, -self.frame.size.height, self.frame.size.width, self.frame.size.height);
        
        [UIView animateWithDuration:1
                              delay:0 
                            options:(UIViewAnimationOptionCurveEaseInOut | UIViewAnimationOptionAllowUserInteraction)
                         animations:^{ self.frame = CGRectMake(self.frame.origin.x, stageY, self.frame.size.width, self.frame.size.height); } 
                         completion:^(BOOL fin) { [self hoverHelpView]; } ];    
    }
}

- (void)leaveStage {
    
    _aboutToLeave = YES; 
    
    self.transform = CGAffineTransformIdentity;
    
    if (!self.hidden) {
        [UIView animateWithDuration:0.5
                              delay:0 
                            options:(UIViewAnimationOptionCurveLinear | UIViewAnimationOptionAllowUserInteraction | UIViewAnimationOptionBeginFromCurrentState)
                         animations:^{
                             self.transform = CGAffineTransformTranslate(self.transform, -self.frame.origin.x - self.bounds.size.width/2, -self.frame.origin.y - self.frame.size.height/2);
                             self.transform = CGAffineTransformRotate(self.transform, -degreesToRadians(340));
                             self.transform = CGAffineTransformScale(self.transform, 0.1, 0.1);
                              } 
                         completion:^(BOOL fin) { self.hidden = YES; } ];

    }
}

- (void)hoverHelpView {
    
    if (!self.hidden && !_aboutToLeave) {
        [UIView animateWithDuration:0.5
                              delay:0 
                            options:(UIViewAnimationOptionCurveEaseInOut | UIViewAnimationOptionAllowUserInteraction | UIViewAnimationOptionRepeat | UIViewAnimationOptionAutoreverse)
                         animations:^{ self.frame = CGRectMake(self.frame.origin.x, self.frame.origin.y + ANIMATE_DISTANCE, self.frame.size.width, self.frame.size.height); } 
                         completion:nil ];
    }
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
    
    [self leaveStage];
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSMutableDictionary *dictionary = [NSMutableDictionary dictionaryWithDictionary:[defaults dictionaryForKey:DICTIONARY_KEY]];
    [dictionary setObject:@"YES" forKey:_uniqueIdentifier];
    [defaults setObject:dictionary forKey:DICTIONARY_KEY];
    [defaults synchronize];
}

#pragma mark Memory Management

- (void)dealloc {
    [_text release];
    [_uniqueIdentifier release];
    [super dealloc];
}


@end
