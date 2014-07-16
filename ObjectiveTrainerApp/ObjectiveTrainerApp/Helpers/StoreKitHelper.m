//
//  StoreKitHelper.m
//  ObjectiveTrainerApp
//
//  Created by Christopher Ching on 2014-06-06.
//  Copyright (c) 2014 CodeWithChris. All rights reserved.
//

#import "StoreKitHelper.h"

@implementation StoreKitHelper

- (void)retrieveProductIds
{
    NSURL *url = [[NSBundle mainBundle] URLForResource:@"product_ids"
                                         withExtension:@"plist"];
    NSArray *productIdentifiers = [NSArray arrayWithContentsOfURL:url];
    
    // Pass product identifiers to the validate method
    [self validateProductIdentifiers:productIdentifiers];
}

- (void)validateProductIdentifiers:(NSArray *)productIdentifiers
{
    SKProductsRequest *productsRequest = [[SKProductsRequest alloc]
                                          initWithProductIdentifiers:[NSSet setWithArray:productIdentifiers]];
    productsRequest.delegate = self;
    [productsRequest start];
}

// SKProductsRequestDelegate protocol method
- (void)productsRequest:(SKProductsRequest *)request
     didReceiveResponse:(SKProductsResponse *)response
{
    // Products retrieved, notify delegate
    if (self.delegate)
    {
        [self.delegate productsRetrieved:response.products];
    }
}

#pragma mark Transaction Observer Delegate Methods

- (void)paymentQueue:(SKPaymentQueue *)queue
 updatedTransactions:(NSArray *)transactions
{
    for (SKPaymentTransaction *transaction in transactions)
    {
        switch (transaction.transactionState)
        {
            // Call the appropriate custom method.
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

- (void)completeTransaction:(SKPaymentTransaction*)transaction
{
    // Display a message to the user that purchase was successful
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Purchase Successful" message:@"Thank you. Ads have been removed." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
    [alertView show];
    
    // Set flag in user defaults to not show ads
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setObject:@"bought" forKey:@"removeads"];
    [defaults synchronize];
    
    [[SKPaymentQueue defaultQueue] finishTransaction:transaction];
}

- (void)failedTransaction:(SKPaymentTransaction*)transaction
{
    // Display a message to the user that purchase was not succesful
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Purchase Canceled" message:@"Your purchase was canceled." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
    [alertView show];
    
    [[SKPaymentQueue defaultQueue] finishTransaction:transaction];
}

- (void)restoreTransaction:(SKPaymentTransaction*)transaction
{
    // Display a message to the user that purchase was successful
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Restore Successful" message:@"Ads have been removed." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
    [alertView show];
    
    // Set flag in user defaults to not show ads
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setObject:@"bought" forKey:@"removeads"];
    [defaults synchronize];
    
    [[SKPaymentQueue defaultQueue] finishTransaction:transaction];
}

@end
