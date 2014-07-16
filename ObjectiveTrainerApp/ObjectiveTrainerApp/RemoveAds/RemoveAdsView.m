//
//  RemoveAdsView.m
//  ObjectiveTrainerApp
//
//  Created by Christopher Ching on 2014-07-15.
//  Copyright (c) 2014 CodeWithChris. All rights reserved.
//

#import "RemoveAdsView.h"

@interface RemoveAdsView()
{
    UILabel *_messageLabel;
    UIButton *_purchaseButton;
    UIButton *_restoreButton;
    UIButton *_closeButton;
    
    StoreKitHelper *_skHelper;
    SKProduct *_removeAdsProduct;
}
@end

@implementation RemoveAdsView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self)
    {
        self.backgroundColor = [UIColor colorWithRed:74/255.0 green:74/255.0 blue:74/255.0 alpha:0.8];
        
        // Create ui element objects
        _messageLabel = [[UILabel alloc] initWithFrame:CGRectMake(27, 49, 268, 76)];
        _messageLabel.text = @"Support the app and Remove Ads?";
        _messageLabel.textAlignment = NSTextAlignmentCenter;
        _messageLabel.numberOfLines = 0;
        _messageLabel.textColor = [UIColor whiteColor];
        _messageLabel.font = [UIFont fontWithName:@"HelveticaNeue-UltraLight" size:32];
        [self addSubview:_messageLabel];
        
        _restoreButton = [UIButton buttonWithType:UIButtonTypeSystem];
        _restoreButton.frame = CGRectMake(46, 432, 228, 45);
        _restoreButton.backgroundColor = [UIColor colorWithRed:56/255.0 green:56/255.0 blue:56/255.0 alpha:0.5];
        [_restoreButton setTitle:@"Restore Purchase" forState:UIControlStateNormal];
        [_restoreButton.layer setBorderWidth:1.0];
        [_restoreButton.layer setBorderColor:[UIColor colorWithRed:255/255.0 green:255/255.0 blue:255/255.0 alpha:0.5].CGColor];
        [_restoreButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        _restoreButton.titleLabel.font = [UIFont fontWithName:@"HelveticaNeue-Light" size:20];
        [_restoreButton addTarget:self action:@selector(restoreTapped) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:_restoreButton];
        
        _closeButton = [UIButton buttonWithType:UIButtonTypeSystem];
        _closeButton.frame = CGRectMake(261, 532, 58, 35);
        _closeButton.backgroundColor = [UIColor colorWithRed:56/255.0 green:56/255.0 blue:56/255.0 alpha:0.5];
        [_closeButton setTitle:@"Close" forState:UIControlStateNormal];
        [_closeButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        _closeButton.titleLabel.font = [UIFont fontWithName:@"HelveticaNeue-Light" size:15];
        [_closeButton addTarget:self action:@selector(closeTapped) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:_closeButton];
        
        // Start store kit
        _skHelper = [[StoreKitHelper alloc] init];
        _skHelper.delegate = self;
    }
    return self;
}

#pragma mark Public Methods

- (void)retrieveProducts
{
    [_skHelper retrieveProductIds];
}

#pragma mark Store Kit Helper Protocol Methods

- (void)productsRetrieved:(NSArray *)products
{
    if (products.count > 0)
    {
        _removeAdsProduct = products[0];
        
        // Set the info for the product
        //self.productInfoLabel.text = _removeAdsProduct.localizedDescription;
        
        if (_purchaseButton == nil)
        {
            _purchaseButton = [UIButton buttonWithType:UIButtonTypeSystem];
            _purchaseButton.frame = CGRectMake(27, 208, 267, 69);
            _purchaseButton.backgroundColor = [UIColor colorWithRed:126/255.0 green:211/255.0 blue:33/255.0 alpha:0.5];
            [_purchaseButton.layer setBorderWidth:1.0];
            [_purchaseButton.layer setBorderColor:[UIColor colorWithRed:255/255.0 green:255/255.0 blue:255/255.0 alpha:0.5].CGColor];
            [_purchaseButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
            _purchaseButton.titleLabel.font = [UIFont fontWithName:@"HelveticaNeue-Light" size:24];
            [_purchaseButton addTarget:self action:@selector(purchaseTapped) forControlEvents:UIControlEventTouchUpInside];
            [self addSubview:_purchaseButton];
        }
        
        NSString *purchaseButtonTitle = [NSString stringWithFormat:@"Remove Ads for $%f", _removeAdsProduct.price.doubleValue];
        [_purchaseButton setTitle:purchaseButtonTitle forState:UIControlStateNormal];
    }
}

#pragma mark Button Handler Method

- (void)purchaseTapped
{
    // Initiate the payment process
    SKMutablePayment *payment = [SKMutablePayment paymentWithProduct:_removeAdsProduct];
    payment.quantity = 1;
    [[SKPaymentQueue defaultQueue] addPayment:payment];
}

- (void)restoreTapped
{
    
}

- (void)closeTapped
{
    // Notify delegate that the user dismissed the remove ads view
    if (self.delegate)
        [self.delegate dismissRemoveAdsView];
}

@end
