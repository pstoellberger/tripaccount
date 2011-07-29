//
//  ParticipantView.m
//  Reiseabrechnung
//
//  Created by Martin Maier on 28/07/2011.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "ParticipantView.h"
#import "Participant.h"

@implementation ParticipantView

@synthesize participants=_participants;

- (id)initWithFrame:(CGRect)frame {
    
    if (self = [super initWithFrame:frame]) {

    }
    return self;
}

#define IMAGE_SIZE 16
#define IMAGE_GAP 2

- (void)drawRect:(CGRect)rect {
    
    [super drawRect:rect];
        
    CGContextRef context = UIGraphicsGetCurrentContext();

	UIGraphicsPushContext(context);								
    
    int counter = 0;
    for (Participant *participant in self.participants) {
        UIImage *image = [UIImage imageWithData:participant.image];
        [image drawInRect:CGRectMake(((IMAGE_SIZE+IMAGE_GAP) * counter), 0, IMAGE_SIZE, IMAGE_SIZE)];
        counter++;
        
        if (((IMAGE_SIZE+IMAGE_GAP) * (counter+2)) > rect.size.width) {
            UIImage *moreImages = [UIImage imageWithData:[NSData dataWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"moreImages" ofType:@"png"]]];
            [moreImages drawInRect:CGRectMake(((IMAGE_SIZE+IMAGE_GAP) * counter), 0, IMAGE_SIZE, IMAGE_SIZE)];
            break;
        }
    }
    
    UIGraphicsPopContext();
    
}


@end
