//
//  QuestionViewController.h
//  ObjectiveTrainerApp
//
//  Created by Christopher Ching on 2014-03-29.
//  Copyright (c) 2014 CodeWithChris. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "QuestionModel.h"
#import "Question.h"
#import "ResultView.h"
#import <iAd/iAd.h>

@interface QuestionViewController : UIViewController<ResultViewProtocol, ADBannerViewDelegate, UITextFieldDelegate>

@property (strong, nonatomic) QuestionModel *model;
@property (strong, nonatomic) NSArray *questions;

@property (nonatomic) QuizQuestionDifficulty questionDifficulty;

@property (weak, nonatomic) IBOutlet UIScrollView *questionScrollView;

// Question Status Bar
@property (weak, nonatomic) IBOutlet UIImageView *statusBarBackground;
@property (weak, nonatomic) IBOutlet UILabel *statusBarQuestionTypeLabel;
@property (weak, nonatomic) IBOutlet UILabel *statusBarQuestionDifficultyLabel;
@property (weak, nonatomic) IBOutlet UILabel *statusBarScoreLabel;


// Background view for question type
@property (weak, nonatomic) IBOutlet UIView *questionStatusBackgroundView;
@property (weak, nonatomic) IBOutlet UILabel *questionStatusLabel;

// Background for answer area
@property (weak, nonatomic) IBOutlet UIView *answerBackgroundView;

// Properties for MC Questions
@property (weak, nonatomic) IBOutlet UILabel *questionHeaderLabel;
@property (weak, nonatomic) IBOutlet UILabel *questionText;
@property (weak, nonatomic) IBOutlet UIButton *questionMCAnswer1;
@property (weak, nonatomic) IBOutlet UIView *questionMCAnswer1Bullet;

@property (weak, nonatomic) IBOutlet UIButton *questionMCAnswer2;
@property (weak, nonatomic) IBOutlet UIView *questionMCAnswer2Bullet;
@property (weak, nonatomic) IBOutlet UIButton *questionMCAnswer3;
@property (weak, nonatomic) IBOutlet UIView *questionMCAnswer3Bullet;

@property (weak, nonatomic) IBOutlet UILabel *answerHeaderLabel;

// Properties for Blank Questions
@property (weak, nonatomic) IBOutlet UIButton *submitAnswerForBlankButton;
@property (weak, nonatomic) IBOutlet UITextField *blankTextField;
@property (weak, nonatomic) IBOutlet UILabel *submittedAnswerLabel;

// Properties for Image Questions
@property (weak, nonatomic) IBOutlet UIImageView *imageQuestionImageView;

@property (weak, nonatomic) IBOutlet UIButton *skipButton;

@end
