//
//  InfoViewController.h
//  Reiseabrechnung
//
//  Created by Martin Maier on 27/07/2011.
//  Copyright 2011 Martin Maier. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MessageUI/MFMailComposeViewController.h>

@interface InfoViewController : UIViewController <MFMailComposeViewControllerDelegate> {
    
}

@property (nonatomic, retain) IBOutlet UILabel *feedBackLabel;
@property (nonatomic, retain) IBOutlet UILabel *titleLabel;
@property (nonatomic, retain) IBOutlet UILabel *versionLabel;
@property (nonatomic, retain) IBOutlet UILabel *copyrightLabel;
@property (nonatomic, retain) IBOutlet UIButton *feedbackButton;
@property (nonatomic, retain) IBOutlet UIButton *featureButton;
@property (nonatomic, retain) IBOutlet UIButton *licenseButton;
@property (nonatomic, retain) IBOutlet UIButton *closeButton;

- (IBAction)cancel;
- (IBAction)requestFeature;
- (IBAction)sendFeedback;
- (IBAction)licenseNotes;
- (void)openEmailPopup:(NSString *)subject withTitle:(NSString *)title withMailName:(NSString *)mailName;
- (void)setButtonTitle:(UIButton *)button title:(NSString *)title;

@end
