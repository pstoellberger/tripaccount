//
//  InfoView.m
//  Reiseabrechnung
//
//  Created by Martin Maier on 27/07/2011.
//  Copyright 2011 Martin Maier. All rights reserved.
//

#import "InfoViewController.h"
#import "UIFactory.h"
#import "Appirater.h"

@implementation InfoViewController

@synthesize feedBackLabel=_feedBackLabel, titleLabel=_titleLabel, versionLabel=_versionLabel, copyrightLabel=_copyrightLabel;
@synthesize feedbackButton=_feedbackButton, featureButton=_featureButton, licenseButton=_licenseButton, closeButton=_closeButton, rateButton=_rateButton, purchaseButton=_purchaseButton, twitterLogo=_twitterLogo;
@synthesize image=_image;
@synthesize bottomView=_bottomView, topView=_topView;

#define CLOSE_LABEL_GAP 6
#define CLOSE_LABEL_SIZE_REDUCTION 10

#define COPYRIGHT_LABEL_GAP 10

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    
    
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        
        self.view.frame = [[UIScreen mainScreen] applicationFrame];
        
        UIView *bgView = [UIFactory createBackgroundViewWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height)];
        [self.view addSubview:bgView];
        [self.view sendSubviewToBack:bgView];
        self.view.backgroundColor = [UIColor clearColor];

        self.versionLabel.text = [NSString stringWithFormat:NSLocalizedString(@"versionlabel", @""), [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleVersion"]];

        self.feedBackLabel.text = NSLocalizedString(@"feedbackLabel", @"info feedbackLabel");
        self.copyrightLabel.text = NSLocalizedString(@"copyrightLabel", @"info feedback button");
        
        [self setButtonTitle:self.closeButton title:NSLocalizedString(@"close", @"info close button")];
        [self setButtonTitle:self.licenseButton title:NSLocalizedString(@"Donate", @"Donate")];
        [self setButtonTitle:self.featureButton title:NSLocalizedString(@"Request a feature", @"info feature button")];
        [self setButtonTitle:self.feedbackButton title:NSLocalizedString(@"Provide Feedback", @"info feedback button")];
        [self setButtonTitle:self.rateButton title:NSLocalizedString(@"rate this app", @"rate button")];
        [self setButtonTitle:self.purchaseButton title:NSLocalizedString(@"purchase app", @"purchase button")];
        
        self.feedbackButton.enabled = [MFMailComposeViewController canSendMail];
        self.featureButton.enabled = [MFMailComposeViewController canSendMail];
        
        self.copyrightLabel.frame = CGRectMake(COPYRIGHT_LABEL_GAP, self.copyrightLabel.frame.origin.y, self.view.frame.size.width - self.closeButton.frame.size.width - COPYRIGHT_LABEL_GAP - COPYRIGHT_LABEL_GAP, self.copyrightLabel.frame.size.height);
        
        self.titleLabel.text = @"Trip Account";
        
        self.topView.backgroundColor = [UIFactory defaultLightTintColor];
        self.bottomView.backgroundColor = [UIFactory defaultLightTintColor];
        //self.bottomView.frame = CGRectMake(self.bottomView.frame.origin.x, [UIScreen mainScreen].bounds.size.height - self.bottomView.frame.size.height, self.bottomView.frame.size.width, self.bottomView.frame.size.height);
    }
    return self;
}

- (void)setButtonTitle:(UIButton *)button title:(NSString *)title {
    
    [button setTitle:title forState:UIControlStateNormal];
    [button setTitle:title forState:UIControlStateHighlighted];
    [button setTitle:title forState:UIControlStateApplication];
    [button setTitle:title forState:UIControlStateDisabled];
    [button setTitle:title forState:UIControlStateReserved];
    [button setTitle:title forState:UIControlStateSelected];
}


- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    return YES;
}

- (void)setCloseAction:(id)target action:(SEL)action {
    _target = target;
    _action = action;
}

- (IBAction)cancel {
    
    
    if (_target && _action && [_target respondsToSelector:_action]) {
        [_target performSelector:_action];
    }
}

- (IBAction)rate {
    
//    NSString* url = [NSString stringWithFormat: ITUNES_STORE_RATE_LINK, TRIP_ACCOUNT_ID];
//    [[UIApplication sharedApplication] openURL: [NSURL URLWithString: url]];
}

- (IBAction)purchaseApp {
//    NSString* url = [NSString stringWithFormat: ITUNES_STORE_LINK, TRIP_ACCOUNT_ID];
//    [[UIApplication sharedApplication] openURL: [NSURL URLWithString: url]];
}

- (IBAction)requestFeature {
    [self openEmailPopup:[NSLocalizedString(@"Feature Request for Trip Account Version ", @"subject feature request") stringByAppendingString:[[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleVersion"]] withTitle:NSLocalizedString(@"Feature Request", @"Feature Request") withMailName:NSLocalizedString(@"Feature Request", @"Feature Request")];    
}

- (IBAction)sendFeedback {
    [self openEmailPopup:[NSLocalizedString(@"Feedback for Trip Account Version ", @"subject feedback request") stringByAppendingString:[[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleVersion"]] withTitle:NSLocalizedString(@"Feedback", @"Feedback") withMailName:NSLocalizedString(@"Feedback", @"Feedback")];
}

- (void)openEmailPopup:(NSString *)subject withTitle:(NSString *)title withMailName:(NSString *)mailName {

    MFMailComposeViewController* controller = [[MFMailComposeViewController alloc] init];
    controller.navigationBar.barStyle = UIBarStyleBlack;
    controller.mailComposeDelegate = self;
    [controller setSubject:subject];
    [controller setMessageBody:nil isHTML:NO];
    [controller setToRecipients:[NSArray arrayWithObject:[NSString stringWithFormat:@"Trip Account %@ <tripaccount@martinmaier.name>", mailName]]];
    
    if (controller)  {
        [self presentViewController:controller animated:YES completion:NULL];
        [controller becomeFirstResponder];
    }
    [controller release];
    
}

- (IBAction)donateNow {
    
    [ReiseabrechnungAppDelegate askForDonation:nil];
}

#pragma mark - MFMailComposeViewControllerDelegate

- (void)mailComposeController:(MFMailComposeViewController*)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError*)error {
    if (result == MFMailComposeResultSent) {
        NSLog(@"It's away!");
    }
    [self dismissViewControllerAnimated:YES completion:NULL];
}

#pragma mark - View lifecycle

- (void)dealloc {
    [_feedBackLabel release];
    [_titleLabel release];
    [_versionLabel release];
    [_copyrightLabel release];
    [_feedbackButton release];
    [_featureButton release];
    [_licenseButton release];
    [_closeButton release];
    [_rateButton release];
    [_image release];
    [_twitterLogo release];
    [super dealloc];
}

@end
