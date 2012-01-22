//
//  ParticipantView.h
//  Reiseabrechnung
//
//  Created by Martin Maier on 28/07/2011.
//  Copyright 2011 Martin Maier. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>
#import "ImageCache.h"

@interface ParticipantView : UIView {
    NSArray *_participants;
}

@property (nonatomic, retain) NSArray *participants;

- (id)initWithFrame:(CGRect)frame andParticipants:(NSArray *)participants;

+ (UIImage *) moreImagesImage;
+ (void)evictCache;

@end
