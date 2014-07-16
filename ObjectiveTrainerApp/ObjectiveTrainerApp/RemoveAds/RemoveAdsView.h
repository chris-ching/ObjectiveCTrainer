//
//  RemoveAdsView.h
//  ObjectiveTrainerApp
//
//  Created by Christopher Ching on 2014-07-15.
//  Copyright (c) 2014 CodeWithChris. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "StoreKitHelper.h"

@protocol RemoveAdsViewProtocol <NSObject>

- (void)dismissRemoveAdsView;

@end

@interface RemoveAdsView : UIView<StoreKitHelperProtocol>

@property (nonatomic, weak) id<RemoveAdsViewProtocol> delegate;

- (void)retrieveProducts;

@end
