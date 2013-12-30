//
//  InAppPurchaseManager.m
//  TripAccount
//
//  Created by Martin Maier-Moessner on 30/12/13.
//
//

#import "InAppPurchaseManager.h"

#define PURCHASE_ID @"FULL_VERSION"

@implementation InAppPurchaseManager

- (void)requestPayment {
    
    [[SKPaymentQueue defaultQueue] addTransactionObserver:self];
    
    SKProductsRequest *productsRequest = [[SKProductsRequest alloc]
                                          initWithProductIdentifiers:[NSSet setWithObject:PURCHASE_ID]];
    productsRequest.delegate = self;
    [productsRequest start];
}

- (void)request:(SKRequest *)request didFailWithError:(NSError *)error {
    
    NSLog(@"Failed to load list of products: %@", error);
    
    [[[[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Purchase error", @"purchase error") message:nil delegate:nil cancelButtonTitle:nil otherButtonTitles:NSLocalizedString(@"OK", @"alert item"), nil] autorelease] show];
    
}

- (void)recordTransaction:(SKPaymentTransaction *)transaction {
    if ([transaction.payment.productIdentifier isEqualToString:PURCHASE_ID]) {
        // save the transaction receipt to disk
        [[NSUserDefaults standardUserDefaults] setBool:YES forKey:PURCHASE_ID];
        [[NSUserDefaults standardUserDefaults] synchronize];
    }
}

//
// called when the transaction was successful
//
- (void)completeTransaction:(SKPaymentTransaction *)transaction {
    NSLog(@"Transaction: COMPLETED!");
    [self recordTransaction:transaction];
    [self provideContent:transaction.payment.productIdentifier];
    [self finishTransaction:transaction wasSuccessful:YES];
}

//
// called when a transaction has been restored and and successfully completed
//
- (void)restoreTransaction:(SKPaymentTransaction *)transaction {
    NSLog(@"Transaction: RESTORED!");
    [self recordTransaction:transaction.originalTransaction];
    [self provideContent:transaction.originalTransaction.payment.productIdentifier];
    [self finishTransaction:transaction wasSuccessful:YES];
}

//
// called when a transaction has failed
//
- (void)failedTransaction:(SKPaymentTransaction *)transaction {
    NSLog(@"Transaction: FAILED!");
    if (transaction.error.code != SKErrorPaymentCancelled) {
        // error!
        [self finishTransaction:transaction wasSuccessful:NO];
    } else {
        // this is fine, the user just cancelled, so don’t notify
        [[SKPaymentQueue defaultQueue] finishTransaction:transaction];
    }
}

//
// removes the transaction from the queue and posts a notification with the transaction result
//
- (void)finishTransaction:(SKPaymentTransaction *)transaction wasSuccessful:(BOOL)wasSuccessful {
    
    if (wasSuccessful) {
        NSLog(@"finishTransaction: SUCCESS!");
    } else {
        NSLog(@"finishTransaction: ERROR!");
    }
    
    // remove the transaction from the payment queue.
    [[SKPaymentQueue defaultQueue] finishTransaction:transaction];
}

- (void)provideContent:(NSString *)productId {
    if ([productId isEqualToString:PURCHASE_ID]) {
        // enable the pro features
        [[NSUserDefaults standardUserDefaults] setBool:YES forKey:PURCHASE_ID ];
        [[NSUserDefaults standardUserDefaults] synchronize];
    }
}

#pragma mark - SKProductsRequestDelegate

- (void)productsRequest:(SKProductsRequest *)request didReceiveResponse:(SKProductsResponse *)response {
    
    SKProduct *product = [response.products objectAtIndex:0];
    SKMutablePayment *payment = [SKMutablePayment paymentWithProduct:product];
    payment.quantity = 1;
    
    SKPaymentQueue *defaultQueue = [SKPaymentQueue defaultQueue];
    [defaultQueue addPayment:payment];
}

#pragma mark - SKPaymentTransactionObserver

- (void)paymentQueue:(SKPaymentQueue *)queue updatedTransactions:(NSArray *)transactions {
    for (SKPaymentTransaction *transaction in transactions) {
        switch (transaction.transactionState) {
            case SKPaymentTransactionStatePurchased:
                [self completeTransaction:transaction];
                break;
            case SKPaymentTransactionStateFailed:
                [self failedTransaction:transaction];
                break;
            case SKPaymentTransactionStateRestored:
                [self restoreTransaction:transaction];
                break;
            default:
                break;
        }
    }
}

@end
