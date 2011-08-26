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
#import "ReiseabrechnungAppDelegate.h"

@implementation HelpView

#define ARROW_HEIGHT 15
#define ARROW_WIDTH 30
#define ARROW_BORDERSPACE 5

#define ANIMATE_DISTANCE 3

#define LABEL_GAP 5
#define IMAGE_GAP 5

#define ARROW_MARGIN 2

#define degreesToRadians(x) (M_PI * x / 180.0)

@synthesize uniqueIdentifier=_uniqueIdentifier;

+ (NSString *)DICTIONARY_KEY {
    return @"HelpViewClickedAway";
}

- (id)initWithFrame:(CGRect)frame text:(NSString *)text arrowPosition:(ArrowPosition)arrowPosition enterStage:(EnterStage)enterStage uniqueIdentifier:(NSString *)uniqueIdentifier {    
    if ((self = [super initWithFrame:frame])) {
        
        NSLog(@"%@ %@", self, text);

        _aboutToLeave = NO;
        _uniqueIdentifier = uniqueIdentifier;
        _enterStage = enterStage;
        
        self.backgroundColor = [UIColor clearColor];
        //self.alpha = 0.75;
        self.opaque = NO;
        
        UIColor *gradColor1 = [UIColor colorWithRed:0.8 green:0.8 blue:1.0 alpha:1];
        UIColor *gradColor2 = [UIColor colorWithRed:0.95 green:0.95 blue:1.0 alpha:1];
        
        UIView *bodyView = nil;
        if (arrowPosition == ARROWPOSITION_TOP_RIGHT || arrowPosition == ARROWPOSITION_TOP_LEFT) {
            bodyView = [[UIView alloc] initWithFrame:CGRectMake(0, ARROW_HEIGHT, frame.size.width, frame.size.height - ARROW_HEIGHT)];
        } else {
            bodyView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, frame.size.width, frame.size.height - ARROW_HEIGHT)];
        }
        
        bodyView.layer.cornerRadius = 5;
        bodyView.layer.masksToBounds = YES;
        bodyView.opaque = NO;
        bodyView.layer.borderColor = gradColor1.CGColor;
        bodyView.layer.borderWidth = 1.0f;
        
        UIImage *infoImage = [[UIImage alloc] initWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"about" ofType:@"png"]];
        UIImageView *infoImageView = [[UIImageView alloc] initWithImage:infoImage];
        infoImageView.frame = CGRectMake(IMAGE_GAP, IMAGE_GAP, 24, 24);
        [infoImage release];
        [bodyView addSubview:infoImageView];
        [infoImageView release];
        
        int labelLeft = infoImageView.frame.origin.x + infoImageView.frame.size.width + LABEL_GAP;
        UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(labelLeft, LABEL_GAP, bodyView.frame.size.width - labelLeft - LABEL_GAP, bodyView.frame.size.height - LABEL_GAP)];
        label.text = text;
        label.textColor = [UIColor colorWithRed:0.1 green:0.1 blue:0.5 alpha:1.0];
        label.backgroundColor = [UIColor clearColor];
        label.numberOfLines = 0;
        label.font = [UIFont fontWithName:@"Arial Rounded MT Bold" size:(12.0)];
        [self findBestSizeForLabel:label maxWidth:[[UIScreen mainScreen] applicationFrame].size.width - labelLeft - LABEL_GAP];
        
        [bodyView addSubview:label];
        
        bodyView.frame = CGRectMake(bodyView.frame.origin.x, bodyView.frame.origin.y, labelLeft + label.frame.size.width + LABEL_GAP, label.frame.size.height + LABEL_GAP + LABEL_GAP); 
        
        [UIFactory addGradientToView:bodyView color1:gradColor1 color2:gradColor2 startPoint:CGPointMake(0, 1) endPoint:CGPointMake(1,0)];
        
        [label release];  
        
        [self addSubview:bodyView];
        
        if (arrowPosition != ARROWPOSITION_NONE) {
            
            if (arrowPosition == ARROWPOSITION_TOP_RIGHT || arrowPosition == ARROWPOSITION_BOTTOM_RIGHT) {
                self.frame = CGRectMake(self.frame.origin.x - (bodyView.frame.size.width - self.frame.size.width), self.frame.origin.y, bodyView.frame.size.width,bodyView.frame.size.height + ARROW_HEIGHT);
            } else if (arrowPosition == ARROWPOSITION_BOTTOM_LEFT) {
                self.frame = CGRectMake(self.frame.origin.x - (bodyView.frame.size.width - self.frame.size.width), self.frame.origin.y - (bodyView.frame.size.height - self.frame.size.height), bodyView.frame.size.width, bodyView.frame.size.height + ARROW_HEIGHT);
            }
            
            ArrowView *arrowView = nil;
            if (arrowPosition == ARROWPOSITION_TOP_RIGHT) {
                
                arrowView = [[ArrowView alloc] initWithFrame:CGRectMake(self.frame.size.width - ARROW_WIDTH - ARROW_BORDERSPACE, 0, ARROW_WIDTH, ARROW_HEIGHT + ARROW_MARGIN)];
                arrowView.arrowColor = gradColor2;
                
            } else if (arrowPosition == ARROWPOSITION_TOP_LEFT) {
                
                arrowView = [[ArrowView alloc] initWithFrame:CGRectMake(ARROW_BORDERSPACE, 0, ARROW_WIDTH, ARROW_HEIGHT + ARROW_MARGIN)];
                arrowView.arrowColor = [self crossColors:gradColor1 color2:gradColor2];
                
            } else if (arrowPosition == ARROWPOSITION_BOTTOM_RIGHT) {
                
                arrowView = [[ArrowView alloc] initWithFrame:CGRectMake(self.frame.size.width - ARROW_WIDTH - ARROW_BORDERSPACE, self.frame.size.height - ARROW_HEIGHT - ARROW_MARGIN, ARROW_WIDTH, ARROW_HEIGHT + ARROW_MARGIN)];
                arrowView.upsideDown = YES;
                arrowView.arrowColor = [self crossColors:gradColor1 color2:gradColor2];
                
            } else if (arrowPosition == ARROWPOSITION_BOTTOM_LEFT) {
                
                arrowView = [[ArrowView alloc] initWithFrame:CGRectMake(ARROW_BORDERSPACE, self.frame.size.height - ARROW_HEIGHT - ARROW_MARGIN, ARROW_WIDTH, ARROW_HEIGHT + ARROW_MARGIN)];
                arrowView.upsideDown = YES;
                arrowView.arrowColor = gradColor1;
            }        
            
            arrowView.opaque = YES;
            arrowView.borderColor = gradColor1;
            arrowView.arrowBottomGap = ARROW_MARGIN;
            
            [self addSubview:arrowView];
            [arrowView release];
        }
        
        self.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin;
        
        [bodyView release];
  
        
        //[UIFactory addShadowToView:self];
        
        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
        
        #if TARGET_IPHONE_SIMULATOR
        //[defaults removeObjectForKey:DICTIONARY_KEY];        
        //NSLog(@"Removing userdefaults because we are in the simulator");
        #endif
        
        NSDictionary *dictionary = [defaults dictionaryForKey:[HelpView DICTIONARY_KEY]];
        if (dictionary) {
            if ([dictionary objectForKey:uniqueIdentifier]) {
                self.hidden = YES;
            }
        }
        
    }
    
    return self;
}

- (UIColor *)crossColors:(UIColor *)color1 color2:(UIColor *)color2 {
    
    const CGFloat* components1 = CGColorGetComponents(color1.CGColor);
    const CGFloat* components2 = CGColorGetComponents(color2.CGColor);
    
    return [UIColor colorWithRed:((components1[0] + components2[0]) / 2) 
                           green:((components1[1] + components2[1]) / 2)  
                            blue:((components1[2] + components2[2]) / 2) 
                           alpha:((CGColorGetAlpha(color1.CGColor) + CGColorGetAlpha(color2.CGColor)) / 2)];
}

- (void)findBestSizeForLabel:(UILabel *)label maxWidth:(int)maxWidth {
    
    int currentWidth = 50;
    
    label.frame = CGRectMake(label.frame.origin.x, label.frame.origin.y, currentWidth, label.frame.size.height);
    [label sizeToFit];
    
    while (label.frame.size.width / label.frame.size.height < 1.5) {
        
        currentWidth = currentWidth + 10;
        
        label.frame = CGRectMake(label.frame.origin.x, label.frame.origin.y, currentWidth, label.frame.size.height);
        [label sizeToFit];
        
        if (label.frame.size.width > maxWidth) {
            label.frame = CGRectMake(label.frame.origin.x, label.frame.origin.y, maxWidth, label.frame.size.height);
            [label sizeToFit];
            break;
        }
    }
}

- (void)enterStage {
    
    if (!self.hidden) {
        
        double transformY = [self convertPoint:self.frame.origin toView:nil].y + self.frame.size.height;
        
        if (_enterStage == ENTER_STAGE_FROM_TOP) {
            self.transform = CGAffineTransformTranslate(self.transform, 0, -transformY);
        } else {
            transformY = [[UIScreen mainScreen] applicationFrame].size.height - transformY;
            self.transform = CGAffineTransformTranslate(self.transform, 0, -transformY);
        }
        
        [UIView animateWithDuration:1
                              delay:0
                            options:(UIViewAnimationOptionCurveEaseInOut | UIViewAnimationOptionAllowUserInteraction)
                         animations:^{ self.transform = CGAffineTransformIdentity; } 
                         completion:^(BOOL fin) { [self hoverHelpView]; } ];

    }
}

- (void)didMoveToSuperview {
    
    [self enterStage];
    [((ReiseabrechnungAppDelegate *) [UIApplication sharedApplication].delegate) registerHelpBubble:self];
}

- (void)leaveStage:(BOOL)removeFromSuperView {
    
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
                         completion:^(BOOL fin) { 
                             self.hidden = YES;  
                             if (removeFromSuperView) {
                                 [self removeFromSuperview];
                             }
                         } ];
        
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
    
    [self leaveStage:NO];
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSMutableDictionary *dictionary = [NSMutableDictionary dictionaryWithDictionary:[defaults dictionaryForKey:[HelpView DICTIONARY_KEY]]];
    [dictionary setObject:@"YES" forKey:_uniqueIdentifier];
    [defaults setObject:dictionary forKey:[HelpView DICTIONARY_KEY]];
    [defaults synchronize];
}

#pragma mark Memory Management

- (void)dealloc {
    [_uniqueIdentifier release];
    [super dealloc];
}


@end
