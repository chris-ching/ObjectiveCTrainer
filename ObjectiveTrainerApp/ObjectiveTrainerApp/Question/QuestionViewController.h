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

@interface QuestionViewController : UIViewController

@property (strong, nonatomic) QuestionModel *model;
@property (strong, nonatomic) NSArray *questions;

@property (nonatomic) QuizQuestionDifficulty questionDifficulty;

@property (weak, nonatomic) IBOutlet UIScrollView *questionScrollView;

// Properties for MC Questions
@property (weak, nonatomic) IBOutlet UILabel *questionText;
@property (weak, nonatomic) IBOutlet UIButton *questionMCAnswer1;
@property (weak, nonatomic) IBOutlet UIButton *questionMCAnswer2;
@property (weak, nonatomic) IBOutlet UIButton *questionMCAnswer3;

// Properties for Blank Questions
@property (weak, nonatomic) IBOutlet UIButton *submitAnswerForBlankButton;
@property (weak, nonatomic) IBOutlet UITextField *blankTextField;
@property (weak, nonatomic) IBOutlet UILabel *instructionLabelForBlank;

// Properties for Image Questions
@property (weak, nonatomic) IBOutlet UIImageView *imageQuestionImageView;

@property (weak, nonatomic) IBOutlet UIButton *skipButton;

@end
