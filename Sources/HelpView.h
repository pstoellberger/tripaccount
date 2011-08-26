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
    ARROWPOSITION_BOTTOM_LEFT,
    ARROWPOSITION_NONE
} ArrowPosition;

typedef enum {
    ENTER_STAGE_FROM_TOP,
    ENTER_STAGE_FROM_BOTTOM,
} EnterStage;

@interface HelpView : UIView {
    BOOL _aboutToLeave;
    EnterStage _enterStage;
}

@property (nonatomic, readonly) NSString *uniqueIdentifier;

- (id)initWithFrame:(CGRect)frame text:(NSString *)text arrowPosition:(ArrowPosition)arrowPosition enterStage:(EnterStage)enterStage uniqueIdentifier:(NSString *)uniqueIdentifier;
- (void)hoverHelpView;
- (void)enterStage;
- (void)leaveStage:(BOOL)removeFromSuperView;

- (void)findBestSizeForLabel:(UILabel *)label maxWidth:(int)maxWidth;
- (UIColor *)crossColors:(UIColor *)color1 color2:(UIColor *)color2;

+ (NSString *)DICTIONARY_KEY;

@end
