//
//  RemoveAdsViewController.h
//  ObjectiveTrainerApp
//
//  Created by Christopher Ching on 2014-03-29.
//  Copyright (c) 2014 CodeWithChris. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "StoreKitHelper.h"

@interface RemoveAdsViewController : UIViewController<StoreKitHelperProtocol>

@property (weak, nonatomic) IBOutlet UILabel *productInfoLabel;
@property (weak, nonatomic) IBOutlet UIButton *productPurchaseButton;
@end
