//
//  ResultView.h
//  ObjectiveTrainerApp
//
//  Created by Christopher Ching on 2014-04-19.
//  Copyright (c) 2014 CodeWithChris. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Question.h"

@protocol ResultViewProtocol <NSObject>

- (void)resultViewDismissed;

@end

@interface ResultView : UIView

@property (nonatomic, weak) id<ResultViewProtocol> delegate;

// Label to display correct or incorrect
@property (nonatomic, strong) UILabel *resultLabel;

// Button to next
@property (nonatomic, strong) UIButton *nextButton;


- (void)showImageResultAt:(CGPoint)point forResult:(NSString*)result;

@end
