//
//  InAppPurchaseManager.h
//  TripAccount
//
//  Created by Martin Maier-Moessner on 30/12/13.
//
//

#import <Foundation/Foundation.h>
#import <StoreKit/StoreKit.h>

#define PURCHASE_ID @"FULL_VERSION"

@interface InAppPurchaseManager : NSObject <SKProductsRequestDelegate, SKPaymentTransactionObserver>

- (BOOL)isFullVersion;
- (void)requestPayment;

@end
