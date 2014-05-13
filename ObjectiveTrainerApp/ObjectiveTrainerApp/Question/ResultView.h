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

- (void)resultViewHeightDetermined;
- (void)resultViewDismissed;

@end

@interface ResultView : UIView

@property (nonatomic, weak) id<ResultViewProtocol> delegate;

// Label to display correct or incorrect
@property (nonatomic, strong) UILabel *resultLabel;
@property (nonatomic, strong) UIView *resultLabelBackgroundView;

// Label to display user answer
@property (nonatomic, strong) UILabel *userAnswerLabel;

// Label to display correct answer for text based questions
@property (nonatomic, strong) UILabel *correctAnswerLabel;

// Imageview to display the correct answer image for image based questions
@property (nonatomic, strong) UIImageView *correctAnswerImageView;

// Button to continue
@property (nonatomic, strong) UIButton *continueButton;

- (void)showResultForTextQuestion:(BOOL)wasCorrect forUserAnswer:(NSString*)useranswer forQuestion:(Question*)question;

- (void)showResultForImageQuestion:(BOOL)wasCorrect forQuestion:(Question*)question;

@end
