//
//  iAdViewController.m
//  TripAccount
//
//  Created by Christian Mayr on 18.10.14.
//
//

#import <Foundation/Foundation.h>
#import "iAdViewController.h"

@implementation iAdViewController
-(void)viewDidLoad {
    requestingAd = NO;
}

//Interstitial iAd
-(void)showFullScreenAd {
    //Check if already requesting ad
    if (requestingAd == NO) {
        [ADInterstitialAd release];
        interstitial = [[ADInterstitialAd alloc] init];
        interstitial.delegate = self;
        self.interstitialPresentationPolicy = ADInterstitialPresentationPolicyManual;
        [self requestInterstitialAdPresentation];
        NSLog(@"interstitialAdREQUEST");
        requestingAd = YES;
    }//end if
}

-(void)interstitialAd:(ADInterstitialAd *)interstitialAd didFailWithError:(NSError *)error {
    interstitial = nil;
    [interstitialAd release];
    [ADInterstitialAd release];
    requestingAd = NO;
    NSLog(@"interstitialAd didFailWithERROR");
    NSLog(@"%@", error);
}

-(void)interstitialAdDidLoad:(ADInterstitialAd *)interstitialAd {
    NSLog(@"interstitialAdDidLOAD");
    if (interstitialAd != nil && interstitial != nil && requestingAd == YES) {
        [interstitial presentInView:self.view];
        NSLog(@"interstitialAdDidPRESENT");
    }//end if
}

-(void)interstitialAdDidUnload:(ADInterstitialAd *)interstitialAd {
    interstitial = nil;
    [interstitialAd release];
    [ADInterstitialAd release];
    requestingAd = NO;
    NSLog(@"interstitialAdDidUNLOAD");
}

-(void)interstitialAdActionDidFinish:(ADInterstitialAd *)interstitialAd {
    interstitial = nil;
    [interstitialAd release];
    [ADInterstitialAd release];
    requestingAd = NO;
    NSLog(@"interstitialAdDidFINISH");
}
@end
