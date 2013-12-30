//
//  InAppPurchaseManager.h
//  TripAccount
//
//  Created by Martin Maier-Moessner on 30/12/13.
//
//

#import <Foundation/Foundation.h>
#import <StoreKit/StoreKit.h>

@interface InAppPurchaseManager : NSObject <SKProductsRequestDelegate, SKPaymentTransactionObserver>

- (void)requestPayment;

@end
