//
//  TravelEditViewController.h
//  Reiseabrechnung
//
//  Created by Martin Maier on 29/06/2011.
//  Copyright 2011 Martin Maier. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>
#import "Participant.h"

@protocol ParticipantEditViewControllerEditDelegate
- (void)participantEditFinished:(Participant *)participant wasSaved:(BOOL)wasSaved;
@optional
- (void)openParticipantPopup:(Participant *)participant;
@end

@interface ParticipantEditViewController : UITableViewController <UITextFieldDelegate, UITextViewDelegate, UITableViewDelegate, UITableViewDataSource, UINavigationControllerDelegate> {
    
    NSManagedObjectContext *_context;
    
    NSMutableArray* _cellsToReloadAndFlash;
    
    BOOL _isFirstView;
    BOOL _viewAppeared;
    
}

@property (nonatomic, retain) NSString *name;
@property (nonatomic, retain) NSString *email;

@property (nonatomic, retain) Travel *travel;
@property (nonatomic, retain) Participant *participant;

@property (nonatomic, assign) id <ParticipantEditViewControllerEditDelegate> editDelegate;

- (IBAction)done:(UIBarButtonItem *)sender;
- (IBAction)cancel:(UIBarButtonItem *)sender;

- (id)initInManagedObjectContext:(NSManagedObjectContext *)context withTravel:(Travel *)travel withParticipant:(Participant *)participant;

- (void)checkIfDoneIsPossible;

@end