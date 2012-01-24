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
- (void)participantEditFinished:(Participant *)participant wasSaved:(BOOL)wasSaved cashierChanged:(BOOL)cashierChanged;
@optional
- (void)openParticipantPopup:(Participant *)participant;
@end

@interface ParticipantEditViewController : UITableViewController <UITextFieldDelegate, UITextViewDelegate, UITableViewDelegate, UITableViewDataSource, UINavigationControllerDelegate, UIActionSheetDelegate, UIImagePickerControllerDelegate> {
    
    NSManagedObjectContext *_context;
    
    NSMutableArray* _cellsToReloadAndFlash;
    
    BOOL _isFirstView;
    BOOL _viewAppeared;
    
    UISwitch *_toggleSwitch;
}

@property (nonatomic, retain) NSString *name;
@property (nonatomic, retain) NSString *notes;
@property (nonatomic, retain) NSString *email;
@property (nonatomic, retain) NSNumber *weight;
@property (nonatomic, retain) NSData *image;

@property (nonatomic, retain) Travel *travel;
@property (nonatomic, retain) Participant *participant;

@property (nonatomic, retain) UIActionSheet *imageActionSheet;

@property (nonatomic, assign) id <ParticipantEditViewControllerEditDelegate> editDelegate;

- (IBAction)done:(UIBarButtonItem *)sender;
- (IBAction)cancel:(UIBarButtonItem *)sender;

- (id)initInManagedObjectContext:(NSManagedObjectContext *)context withTravel:(Travel *)travel withParticipant:(Participant *)participant;

- (void)checkIfDoneIsPossible;

@end
