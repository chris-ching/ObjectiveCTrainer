//
//  QuestionViewController.m
//  ObjectiveTrainerApp
//
//  Created by Christopher Ching on 2014-03-29.
//  Copyright (c) 2014 CodeWithChris. All rights reserved.
//

#import "QuestionViewController.h"
#import "SWRevealViewController.h"

@interface QuestionViewController ()
{
    Question *_currentQuestion;
    
    UIView *_tappablePortionOfImageQuestion;
    UITapGestureRecognizer *_tapRecognizer;
    UITapGestureRecognizer *_scrollViewTapGestureRecognizer;
}
@end

@implementation QuestionViewController

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
    
    // Add tap gesture recognizer to scrollview
    _scrollViewTapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(scrollViewTapped)];
    [self.questionScrollView addGestureRecognizer:_scrollViewTapGestureRecognizer];
    
    // Add pan gesture recognizer for menu reveal
    [self.view addGestureRecognizer:self.revealViewController.panGestureRecognizer];
    
    // Hide everything
    [self hideAllQuestionElements];
    
    // Create quiz model
    self.model = [[QuestionModel alloc] init];
    
    // Check difficulty level and retrieve questions for desired level
    self.questions = [self.model getQuestions:self.questionDifficulty];
    
    // Display a random question
    [self randomizeQuestionForDisplay];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)hideAllQuestionElements
{
    self.questionText.hidden = YES;
    self.questionMCAnswer1.hidden = YES;
    self.questionMCAnswer2.hidden = YES;
    self.questionMCAnswer3.hidden = YES;
    self.submitAnswerForBlankButton.hidden = YES;
    self.blankTextField.hidden = YES;
    self.instructionLabelForBlank.hidden = YES;
    self.imageQuestionImageView.hidden = YES;
    
    // Remove the tappable uiview for image questions
    if (_tappablePortionOfImageQuestion.superview != nil)
    {
        [_tappablePortionOfImageQuestion removeFromSuperview];
    }
}

#pragma mark Question Methods

- (void)displayCurrentQuestion
{
    switch (_currentQuestion.questionType) {
        case QuestionTypeMC:
            [self displayMCQuestion];
            break;
            
        case QuestionTypeBlank:
            [self displayBlankQuestion];
            break;
            
        case QuestionTypeImage:
            [self displayImageQuestion];
            break;
            
        default:
            break;
    }
}

- (void)displayMCQuestion
{
    // Hide all elements
    [self hideAllQuestionElements];
    
    // Set question elements
    self.questionText.text = _currentQuestion.questionText;
    [self.questionMCAnswer1 setTitle:_currentQuestion.questionAnswer1 forState:UIControlStateNormal];
    [self.questionMCAnswer2 setTitle:_currentQuestion.questionAnswer2 forState:UIControlStateNormal];
    [self.questionMCAnswer3 setTitle:_currentQuestion.questionAnswer3 forState:UIControlStateNormal];
    
    // Adjust scrollview
    self.questionScrollView.contentSize = CGSizeMake(self.questionScrollView.frame.size.width, self.skipButton.frame.origin.y + self.skipButton.frame.size.height + 30);
    
    // Reveal question elements
    self.questionText.hidden = NO;
    self.questionMCAnswer1.hidden = NO;
    self.questionMCAnswer2.hidden = NO;
    self.questionMCAnswer3.hidden = NO;
}

- (void)displayImageQuestion
{
    // Hide all elements
    [self hideAllQuestionElements];
    
    // Set question elements
    
    // TODO: Set Image
    self.imageQuestionImageView.backgroundColor = [UIColor greenColor];
    
    // Create tappable part
    int tappable_x = self.imageQuestionImageView.frame.origin.x + _currentQuestion.offset_x - 10;
    int tappable_y = self.imageQuestionImageView.frame.origin.y + _currentQuestion.offset_y - 10;
    
    _tappablePortionOfImageQuestion = [[UIView alloc] initWithFrame:CGRectMake(tappable_x, tappable_y, 20, 20)];
    _tappablePortionOfImageQuestion.backgroundColor = [UIColor redColor];
    
    // Create and attach gesture recognizer
    _tapRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(imageQuestionAnswered)];
    [_tappablePortionOfImageQuestion addGestureRecognizer:_tapRecognizer];
    
    // Add tappable part
    [self.questionScrollView addSubview:_tappablePortionOfImageQuestion];
    
    self.imageQuestionImageView.hidden = NO;
}

- (void)displayBlankQuestion
{
    // Hide all elements
    [self hideAllQuestionElements];
    
    // Set question elements
    self.questionText.text = _currentQuestion.questionText;
    
    // Adjust scrollview
    self.questionScrollView.contentSize = CGSizeMake(self.questionScrollView.frame.size.width, self.skipButton.frame.origin.y + self.skipButton.frame.size.height + 30);
    
    // Reveal question elements
    self.questionText.hidden = NO;
    self.submitAnswerForBlankButton.hidden = NO;
    self.blankTextField.hidden = NO;
    self.instructionLabelForBlank.hidden = NO;
}

- (void)randomizeQuestionForDisplay
{
    // Randomize a question
    int randomQuestionIndex = arc4random() % self.questions.count;
    _currentQuestion = self.questions[randomQuestionIndex];
    
    // Display the question
    [self displayCurrentQuestion];
}

#pragma mark Question Answer Handlers

- (IBAction)skipButtonClicked:(id)sender
{
    // Randomize and display another question
    [self randomizeQuestionForDisplay];
}

- (IBAction)questionMCAnswer:(id)sender
{
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    
    // Record that they answered an MC question
    int mcQuestionsAnswered = [userDefaults integerForKey:@"MCQuestionsAnswered"];
    mcQuestionsAnswered++;
    [userDefaults setInteger:mcQuestionsAnswered forKey:@"MCQuestionsAnswered"];
    
    UIButton *selectedButton = (UIButton *)sender;
    
    if (selectedButton.tag == _currentQuestion.correctMCQuestionIndex)
    {
        // User got it right
         
        // TODO: display message for correct answer
        
        // Record that they answered an MC question correctly
        int mcQuestionsAnsweredCorrectly = [userDefaults integerForKey:@"MCQuestionsAnsweredCorrectly"];
        mcQuestionsAnsweredCorrectly++;
        [userDefaults setInteger:mcQuestionsAnsweredCorrectly forKey:@"MCQuestionsAnsweredCorrectly"];
    }
    else
    {
        // User got it wrong
    }
    
    [userDefaults synchronize];
    
    // Display next question
    [self randomizeQuestionForDisplay];
}

- (void)imageQuestionAnswered
{
    // User got it right
    
    // TODO: display message for correct answer
    
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    
    // Record that they answered an Image question
    int imageQuestionsAnswered = [userDefaults integerForKey:@"ImageQuestionsAnswered"];
    imageQuestionsAnswered++;
    [userDefaults setInteger:imageQuestionsAnswered forKey:@"ImageQuestionsAnswered"];
    
    // Record that they answered an Image question correctly
    int imageQuestionsAnsweredCorrectly = [userDefaults integerForKey:@"ImageQuestionsAnsweredCorrectly"];
    imageQuestionsAnsweredCorrectly++;
    [userDefaults setInteger:imageQuestionsAnsweredCorrectly forKey:@"ImageQuestionsAnsweredCorrectly"];
    
    [userDefaults synchronize];
    
    // Display next question
    [self randomizeQuestionForDisplay];
}

- (IBAction)blankSubmitted:(id)sender
{
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    
    // Record that they answered an Blank question
    int blankQuestionsAnswered = [userDefaults integerForKey:@"BlankQuestionsAnswered"];
    blankQuestionsAnswered++;
    [userDefaults setInteger:blankQuestionsAnswered forKey:@"BlankQuestionsAnswered"];
    
    NSString *answer = self.blankTextField.text;
    
    if ([answer isEqualToString:_currentQuestion.correctAnswerForBlank])
    {
        // User got it right
        
        // TODO: display message for correct answer
        
        // Record that they answered an Blank question correctly
        int blankQuestionsAnsweredCorrectly = [userDefaults integerForKey:@"BlankQuestionsAnsweredCorrectly"];
        blankQuestionsAnsweredCorrectly++;
        [userDefaults setInteger:blankQuestionsAnsweredCorrectly forKey:@"BlankQuestionsAnsweredCorrectly"];
    }
    else
    {
        // User got it wrong
    }
    
    [userDefaults synchronize];
    
    // Display next question
    [self randomizeQuestionForDisplay];
}

- (void)scrollViewTapped
{
    [self.blankTextField resignFirstResponder];
}


@end
