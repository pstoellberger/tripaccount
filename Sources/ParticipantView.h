//
//  ParticipantView.h
//  Reiseabrechnung
//
//  Created by Martin Maier on 28/07/2011.
//  Copyright 2011 Martin Maier. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>

@interface ParticipantView : UIView

@property (nonatomic, retain) NSArray *participants;

+ (UIImage *)moreImagesImage;

@end
