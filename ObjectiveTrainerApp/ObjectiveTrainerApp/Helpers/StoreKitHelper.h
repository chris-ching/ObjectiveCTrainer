//
//  StoreKitHelper.h
//  ObjectiveTrainerApp
//
//  Created by Christopher Ching on 2014-06-06.
//  Copyright (c) 2014 CodeWithChris. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <StoreKit/StoreKit.h>

@protocol StoreKitHelperProtocol <NSObject>

- (void)productsRetrieved:(NSArray*)products;

@end

@interface StoreKitHelper : NSObject<SKProductsRequestDelegate, SKPaymentTransactionObserver>

@property (nonatomic, weak) id<StoreKitHelperProtocol> delegate;

- (void)retrieveProductIds;

@end
