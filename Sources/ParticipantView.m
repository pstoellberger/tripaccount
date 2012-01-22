//
//  ParticipantView.m
//  Reiseabrechnung
//
//  Created by Martin Maier on 28/07/2011.
//  Copyright 2011 Martin Maier. All rights reserved.
//

#import "ParticipantView.h"
#import "Participant.h"
#import "ParticipantHelperCategory.h"
#import "ReiseabrechnungAppDelegate.h"

@implementation ParticipantView

static UIImage *moreImagesImage;
static NSMutableDictionary *cachedImages = NULL;

@synthesize participants=_participants;

- (id)initWithFrame:(CGRect)frame andParticipants:(NSArray *)participants {   
    if (self = [super initWithFrame:frame]) {
        _participants = [participants retain];
        self.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        self.backgroundColor = [UIColor clearColor];
    }
    return self;
}

#define IMAGE_SIZE 16
#define IMAGE_GAP 2

+ (UIImage *)moreImagesImage {
    if (!moreImagesImage) {
        moreImagesImage = [[UIImage imageWithData:[NSData dataWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"moreImages" ofType:@"png"]]] retain];
    }
    return moreImagesImage;
}

+ (void)evictCache {
    [cachedImages release];
    cachedImages = nil;
}

- (void)drawRect:(CGRect)rect {
    
    [super drawRect:rect];
    
    
    if (!cachedImages) {
        cachedImages = [[NSMutableDictionary dictionaryWithCapacity:5] retain];
    }
    
    NSString *key = [NSString stringWithFormat:@"%f %f %f %f", rect.origin.x, rect.origin.y, rect.size.width, rect.size.height, nil];
    
    NSString *partKey = @"empty";
    for (Participant *p in _participants) {
        partKey = [partKey stringByAppendingString:p.name];
    }
    
    NSMutableDictionary *partsWithRect = [cachedImages objectForKey:key];
    UIImage *drawImage = [partsWithRect objectForKey:partKey];
    if (!drawImage) {
        
        UIGraphicsBeginImageContextWithOptions(CGSizeMake(rect.size.width, rect.size.height), NO, [[UIScreen mainScreen]scale]);
        [self.layer renderInContext:UIGraphicsGetCurrentContext()];
        
        int counter = 0;
        for (Participant *participant in _participants) {
            
            // work around for inconsistent data
            if (!participant.imageSmall) {
                participant.imageSmall = [Participant createThumbnail:participant.image];
                [ReiseabrechnungAppDelegate saveContext:[participant managedObjectContext]];
            }
            
            UIImage *image = [[ImageCache instance] getImage:participant.imageSmall];
            [image drawInRect:CGRectMake(((IMAGE_SIZE+IMAGE_GAP) * counter), 0, IMAGE_SIZE, IMAGE_SIZE)];
            counter++;
            
            if (((IMAGE_SIZE+IMAGE_GAP) * (counter+2)) > rect.size.width) {
                [[ParticipantView moreImagesImage] drawInRect:CGRectMake(((IMAGE_SIZE+IMAGE_GAP) * counter), 0, IMAGE_SIZE, IMAGE_SIZE)];
                break;
            }
        }

        drawImage = UIGraphicsGetImageFromCurrentImageContext();
        if (!partsWithRect) {
            partsWithRect = [NSMutableDictionary dictionaryWithCapacity:5];
            [cachedImages setObject:partsWithRect forKey:key];
        }
        
        [partsWithRect setObject:drawImage forKey:partKey];
        
        UIGraphicsEndImageContext();
        
    } 
        
    CGContextRef context = UIGraphicsGetCurrentContext();
    UIGraphicsPushContext(context);
    [drawImage drawInRect:rect];
    UIGraphicsPopContext();
    
}

- (void)dealloc {
    [_participants release];
    [super dealloc];
}


@end
