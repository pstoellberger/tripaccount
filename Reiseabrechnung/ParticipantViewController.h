//
//  ParticipantViewController.h
//  Reiseabrechnung
//
//  Created by Martin Maier on 30/06/2011.
//  Copyright 2011 Martin Maier. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Travel.h"
#import "CoreDataTableViewController.h"

@protocol ParticipantViewControllerEditDelegate
- (void)participantWasDeleted:(Participant *)participant;
- (void)openParticipantPopup:(Participant *)participant;
@end

@interface ParticipantViewController : CoreDataTableViewController {
}

@property (nonatomic, retain, readonly) Travel *travel;
@property (nonatomic, assign) id <ParticipantViewControllerEditDelegate> editDelegate;

- (void)updateBadgeValue;

@end
