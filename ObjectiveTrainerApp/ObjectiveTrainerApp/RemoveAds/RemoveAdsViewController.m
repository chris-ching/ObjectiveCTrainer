//
//  RemoveAdsViewController.m
//  ObjectiveTrainerApp
//
//  Created by Christopher Ching on 2014-03-29.
//  Copyright (c) 2014 CodeWithChris. All rights reserved.
//

#import "RemoveAdsViewController.h"
#import "SWRevealViewController.h"

@interface RemoveAdsViewController ()
{
    StoreKitHelper *_skHelper;
    SKProduct *_removeAdsProduct;
}
@end

@implementation RemoveAdsViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    
    [self.view addGestureRecognizer:self.revealViewController.panGestureRecognizer];
    
    // Create store kit helper object
    // Retrieve items for sale
    _skHelper = [[StoreKitHelper alloc] init];
    _skHelper.delegate = self;
    [_skHelper retrieveProductIds];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark Store Kit Helper Protocol Methods

- (void)productsRetrieved:(NSArray *)products
{
    if (products.count > 0)
    {
        _removeAdsProduct = products[0];
        
        // Set the info for the product
        self.productInfoLabel.text = _removeAdsProduct.localizedDescription;

        NSString *purchaseButtonTitle = [NSString stringWithFormat:@"Remove Ads for $%f", _removeAdsProduct.price.doubleValue];
        [self.productPurchaseButton setTitle:purchaseButtonTitle forState:UIControlStateNormal];
    }
}

- (IBAction)purchaseTapped:(id)sender
{
    // Initiate the payment process
    SKMutablePayment *payment = [SKMutablePayment paymentWithProduct:_removeAdsProduct];
    payment.quantity = 1;
    [[SKPaymentQueue defaultQueue] addPayment:payment];
}

@end
