//
//  HelpView.h
//  Reiseabrechnung
//
//  Created by Martin Maier on 27/07/2011.
//  Copyright 2011 Martin Maier. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "UIFactory.h"

typedef enum {
    ARROWPOSITION_TOP_RIGHT,
    ARROWPOSITION_TOP_LEFT,
    ARROWPOSITION_BOTTOM_RIGHT,
    ARROWPOSITION_BOTTOM_LEFT
} ArrowPosition;

@interface HelpView : UIView {
    NSString *_text;
    NSString *_uniqueIdentifier;
    BOOL _aboutToLeave;
}

@property (nonatomic, copy) NSString *text;

- (id)initWithFrame:(CGRect)frame text:(NSString *)text arrowPosition:(ArrowPosition)arrowPosition uniqueIdentifier:(NSString *)uniqueIdentifier;
- (void)hoverHelpView;
- (void)enterStage;
- (void)leaveStage;

@end
