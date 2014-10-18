//
//  iAdViewController.h
//  TripAccount
//
//  Created by Christian Mayr on 18.10.14.
//
//

#ifndef TripAccount_iAdViewController_h
#define TripAccount_iAdViewController_h
#import <iAd/iAd.h>

@interface iAdViewController : UIViewController <ADInterstitialAdDelegate> {
    
    ADInterstitialAd *interstitial;
    BOOL requestingAd;
    
}

-(void)showFullScreenAd;

@end

#endif
