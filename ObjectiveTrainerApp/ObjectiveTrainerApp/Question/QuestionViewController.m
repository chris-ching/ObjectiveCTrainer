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
    
    ResultView *_resultView;
    UIView *_dimmedBackground;
    
    // Banner
    ADBannerView *_adView;
    BOOL _bannerIsVisible;
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
    
    // Add background behind status bar
    UIView *statusBarBg = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 320, 20)];
    statusBarBg.backgroundColor = [UIColor colorWithRed:11/255.0 green:187/255.0 blue:115/255.0 alpha:1.0];
    [self.view addSubview:statusBarBg];
    
    // Set button styles
    UIColor *buttonBorderColor = [UIColor colorWithRed:232/255.0 green:232/255.0 blue:232/255.0 alpha:1.0];
    
    [self.questionMCAnswer1.layer setBorderWidth:1.0];
    [self.questionMCAnswer2.layer setBorderWidth:1.0];
    [self.questionMCAnswer3.layer setBorderWidth:1.0];
    [self.questionMCAnswer1.layer setBorderColor:buttonBorderColor.CGColor];
    [self.questionMCAnswer2.layer setBorderColor:buttonBorderColor.CGColor];
    [self.questionMCAnswer3.layer setBorderColor:buttonBorderColor.CGColor];
    
}

- (void)viewDidAppear:(BOOL)animated
{
    // Call super implementation
    [super viewDidAppear:animated];
    
    // Create a result view
    _resultView = [[ResultView alloc] initWithFrame:CGRectMake(10, 10, self.view.frame.size.width - 20, self.view.frame.size.height - 20)];
    _resultView.delegate = self;
    
    // Create dimmed bg
    _dimmedBackground = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height)];
    _dimmedBackground.backgroundColor = [UIColor blackColor];
    _dimmedBackground.alpha = 0.4;
    
    // Check flag to see if we should show ad
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    
    NSString *flag = [defaults objectForKey:@"removeads"];
    if (![flag isEqualToString:@"bought"])
    {
        // Create iAd banner and place at bottom
        _adView = [[ADBannerView alloc] initWithFrame:CGRectMake(0, self.view.frame.size.height, 320, 50)];
        _adView.delegate = self;
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)hideAllQuestionElements
{
    // Hide the header elements
    self.questionHeaderLabel.alpha = 0.0;

    CGRect answerHeaderLabelFrame = self.answerHeaderLabel.frame;
    answerHeaderLabelFrame.origin.y = 2000;
    self.answerHeaderLabel.frame = answerHeaderLabelFrame;
    
    // Hide answer background
    CGRect answerBackgroundFrame = self.answerBackgroundView.frame;
    answerBackgroundFrame.origin.y = 2000;
    self.answerBackgroundView.frame = answerBackgroundFrame;
    
    // Fade out the question text label
    self.questionText.alpha = 0.0;
    
    // Hide answer buttons and position off screen
    CGRect buttonFrame = self.questionMCAnswer1.frame;
    buttonFrame.origin.y = 2000;
    self.questionMCAnswer1.frame = buttonFrame;
    
    buttonFrame = self.questionMCAnswer2.frame;
    buttonFrame.origin.y = 2000;
    self.questionMCAnswer2.frame = buttonFrame;
    
    buttonFrame = self.questionMCAnswer3.frame;
    buttonFrame.origin.y = 2000;
    self.questionMCAnswer3.frame = buttonFrame;
    
    // Set fill in the blank elements off the screen
    buttonFrame = self.submitAnswerForBlankButton.frame;
    buttonFrame.origin.y = 2000;
    self.submitAnswerForBlankButton.frame = buttonFrame;
    
    buttonFrame = self.blankTextField.frame;
    buttonFrame.origin.y = 2000;
    self.blankTextField.frame = buttonFrame;
    
    // Set alpha for image view to 0 so that we can fade it in
    self.imageQuestionImageView.alpha = 0.0;
    
    // Remove the tappable uiview for image questions
    if (_tappablePortionOfImageQuestion.superview != nil)
    {
        [_tappablePortionOfImageQuestion removeFromSuperview];
    }
}

- (IBAction)menuButtonTapped:(id)sender
{
    [self.revealViewController revealToggleAnimated:YES];
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
    
    // Set text for answer label and positioning
    self.answerHeaderLabel.text = @"Answer";
    CGRect answerLabelFrame = self.answerHeaderLabel.frame;
    answerLabelFrame.size.width = 280;
    self.answerHeaderLabel.frame = answerLabelFrame;
    [self.answerHeaderLabel sizeToFit];
    
    // Set question status label
    self.questionStatusLabel.text = @"Multiple Choice";
    
    // Adjust scrollview
    self.questionScrollView.contentSize = CGSizeMake(self.questionScrollView.frame.size.width, self.skipButton.frame.origin.y + self.skipButton.frame.size.height + 30);
    
    // Animate the labels and buttons back to their positions
    [UIView animateWithDuration:1 animations:^(void){
        
        // Fade question text in
        self.questionText.alpha = 1.0;
        
    }];
    
    [UIView animateWithDuration:1
                          delay:0.1
                        options:UIViewAnimationOptionCurveEaseOut
                     animations:^(void){
                     
                         // Position answer 1 text
                         CGRect answerButton1Frame = self.questionMCAnswer1.frame;
                         answerButton1Frame.origin.y = 259;
                         self.questionMCAnswer1.frame = answerButton1Frame;
                         
                         // Slide up answer background with question
                         CGRect answerBackgroundFrame = self.answerBackgroundView.frame;
                         answerBackgroundFrame.origin.y = 227;
                         self.answerBackgroundView.frame = answerBackgroundFrame;
                         
                     }
                     completion:nil];

    
    [UIView animateWithDuration:1
                          delay:0.2
                        options:UIViewAnimationOptionCurveEaseOut
                     animations:^(void){
                         
                         // Position answer 2 text
                         CGRect answerButton2Frame = self.questionMCAnswer2.frame;
                         answerButton2Frame.origin.y = 329;
                         self.questionMCAnswer2.frame = answerButton2Frame;
                         
                     }
                     completion:nil];
    
    
    [UIView animateWithDuration:1
                          delay:0.3
                        options:UIViewAnimationOptionCurveEaseOut
                     animations:^(void){
                         
                         // Position answer 3 text
                         CGRect answerButton3Frame = self.questionMCAnswer3.frame;
                         answerButton3Frame.origin.y = 397;
                         self.questionMCAnswer3.frame = answerButton3Frame;
                         
                     }
                     completion:nil];
}

- (void)displayImageQuestion
{
    // Hide all elements
    [self hideAllQuestionElements];
    
    // Set question elements
    
    // Set Image
    UIImage *tempImage = [UIImage imageNamed:_currentQuestion.questionImageName];
    self.imageQuestionImageView.image = tempImage;

    // Resize imageview
    CGRect imageViewFrame = self.imageQuestionImageView.frame;
    imageViewFrame.size.height = tempImage.size.height;
    imageViewFrame.size.width = tempImage.size.width;
    self.imageQuestionImageView.frame = imageViewFrame;
    
    // Create tappable part
    int tappable_x = self.imageQuestionImageView.frame.origin.x + _currentQuestion.offset_x - 10;
    int tappable_y = self.imageQuestionImageView.frame.origin.y + _currentQuestion.offset_y - 10;
    
    _tappablePortionOfImageQuestion = [[UIView alloc] initWithFrame:CGRectMake(tappable_x, tappable_y, 20, 20)];
    _tappablePortionOfImageQuestion.backgroundColor = [UIColor clearColor];
    
    // Create and attach gesture recognizer
    _tapRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(imageQuestionAnswered)];
    [_tappablePortionOfImageQuestion addGestureRecognizer:_tapRecognizer];
    
    // Add tappable part
    [self.questionScrollView addSubview:_tappablePortionOfImageQuestion];
    
    // Set instruction label
    self.answerHeaderLabel.text = @"Tap on the error in the image above.";
    CGRect answerLabelFrame = self.answerHeaderLabel.frame;
    answerLabelFrame.size.width = 280;
    self.answerHeaderLabel.frame = answerLabelFrame;
    [self.answerHeaderLabel sizeToFit];
    
    // Set question status label
    self.questionStatusLabel.text = @"Find The Error";
    
    // Animate the elements in
    [UIView animateWithDuration:0.5
                          delay:0.5
                        options:UIViewAnimationOptionCurveEaseOut
                     animations:^(void){
                         
                         // Reveal the instruction label and image
                         self.imageQuestionImageView.alpha = 1.0;
                     }
                     completion:nil];
    
    // Reveal answer background and slide in
    [UIView animateWithDuration:1
                          delay:0.1
                        options:UIViewAnimationOptionCurveEaseOut
                     animations:^(void){
                         
                         // Slide up answer background with question
                         CGRect answerBackgroundFrame = self.answerBackgroundView.frame;
                         answerBackgroundFrame.origin.y = self.imageQuestionImageView.frame.origin.y + self.imageQuestionImageView.frame.size.height;
                         self.answerBackgroundView.frame = answerBackgroundFrame;
                         
                         // Slide up answer header/instruction label
                         CGRect answerLabelFrame = self.answerHeaderLabel.frame;
                         answerLabelFrame.origin.y = self.imageQuestionImageView.frame.origin.y + self.imageQuestionImageView.frame.size.height + 20;
                         self.answerHeaderLabel.frame = answerLabelFrame;
                         
                     }
                     completion:nil];
}

- (void)displayBlankQuestion
{
    // Hide all elements
    [self hideAllQuestionElements];
    
    // Set question image for fill in the blank question
    UIImage *tempImage = [UIImage imageNamed:_currentQuestion.questionImageName];
    self.imageQuestionImageView.image = tempImage;
    
    // Resize imageview
    CGRect imageViewFrame = self.imageQuestionImageView.frame;
    imageViewFrame.size.height = tempImage.size.height;
    imageViewFrame.size.width = tempImage.size.width;
    self.imageQuestionImageView.frame = imageViewFrame;
    
    // Set Instruction label text and Y-Offset
    self.answerHeaderLabel.text = @"Fill in the keyword that is blurred in the image above (case-sensitive)";
    CGRect answerLabelFrame = self.answerHeaderLabel.frame;
    answerLabelFrame.size.width = 280;
    self.answerHeaderLabel.frame = answerLabelFrame;
    [self.answerHeaderLabel sizeToFit];
    
    // Set question status label
    self.questionStatusLabel.text = @"Fill In The Blank";
    
    // Adjust scrollview
    self.questionScrollView.contentSize = CGSizeMake(self.questionScrollView.frame.size.width, self.skipButton.frame.origin.y + self.skipButton.frame.size.height + 30);
    
    // Animate the elements in
    [UIView animateWithDuration:0.5
                          delay:0.5
                        options:UIViewAnimationOptionCurveEaseOut
                     animations:^(void){
                         
                         // Reveal the instruction label and image
                         self.imageQuestionImageView.alpha = 1.0;
                     }
                     completion:nil];
    
    // Animate the elements in
    [UIView animateWithDuration:1
                          delay:0
                        options:UIViewAnimationOptionCurveEaseOut
                     animations:^(void){
                         
                         // Reveal and slide up the answer background
                         CGRect answerBackgroundFrame = self.answerBackgroundView.frame;
                         answerBackgroundFrame.origin.y = self.imageQuestionImageView.frame.origin.y + self.imageQuestionImageView.frame.size.height;
                         self.answerBackgroundView.frame = answerBackgroundFrame;
                         
                         // Reveal and slide up the answer header/instruction label
                         CGRect answerLabelFrame = self.answerHeaderLabel.frame;
                         answerLabelFrame.origin.y = self.imageQuestionImageView.frame.origin.y + self.imageQuestionImageView.frame.size.height + 20;
                         self.answerHeaderLabel.frame = answerLabelFrame;
                         
                         // Reveal and slide up the textbox
                         CGRect textboxFrame = self.blankTextField.frame;
                         
                         textboxFrame.origin.y = self.answerHeaderLabel.frame.origin.y + self.answerHeaderLabel.frame.size.height + 20;
                         
                         self.blankTextField.frame = textboxFrame;
                         
                         // Reveal and slide up the submit button
                         CGRect buttonFrame = self.submitAnswerForBlankButton.frame;
                         
                         buttonFrame.origin.y = self.answerHeaderLabel.frame.origin.y + self.answerHeaderLabel.frame.size.height + 20;
                         
                         self.submitAnswerForBlankButton.frame = buttonFrame;
                     }
                     completion:nil];
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
    [UIView animateWithDuration:0.5
                          delay:0
                        options:UIViewAnimationOptionCurveEaseIn
                     animations:^(void){
                         
                         [self hideAllQuestionElements];
                         
                     }
                    completion:^(BOOL finished) {
                        
                        // Randomize and display another question
                        [self randomizeQuestionForDisplay];
                        
                    }];
    
    
}

- (IBAction)questionMCAnswer:(id)sender
{
    UIButton *selectedButton = (UIButton *)sender;
    BOOL isCorrect = NO;
    
    NSString *userAnswer = @"";
    switch (selectedButton.tag) {
        case 1:
            userAnswer = _currentQuestion.questionAnswer1;
            break;
        case 2:
            userAnswer = _currentQuestion.questionAnswer2;
            break;
        case 3:
            userAnswer = _currentQuestion.questionAnswer3;
            break;
        default:
            break;
    }
    
    if (selectedButton.tag == _currentQuestion.correctMCQuestionIndex)
    {
        // User got it right
        isCorrect = YES;
    }
    else
    {
        // User got it wrong
    }
    
    // Display message for answer
    [_resultView showResultForTextQuestion:isCorrect forUserAnswer:userAnswer forQuestion:_currentQuestion];
    
    // Save the question data
    [self saveQuestionData:_currentQuestion.questionType withDifficulty:_currentQuestion.questionDifficulty isCorrect:isCorrect];
}

- (void)imageQuestionAnswered
{
    // User got it right
    
    // Display message for correct answer
    [_resultView showResultForImageQuestion:YES forQuestion:_currentQuestion];
    
    [self saveQuestionData:_currentQuestion.questionType withDifficulty:_currentQuestion.questionDifficulty isCorrect:YES];
}

- (IBAction)blankSubmitted:(id)sender
{
    // Retract keyboard
    [self.blankTextField resignFirstResponder];
    
    // Get answer
    NSString *answer = self.blankTextField.text;
    BOOL isCorrect = NO;
    
    // Check if answer is right
    if ([answer isEqualToString:_currentQuestion.correctAnswerForBlank])
    {
        // User got it right
        isCorrect = YES;
    }
    else
    {
        // User got it wrong
    }
    
    // Clear the text field
    self.blankTextField.text = @"";
    
    // Display message for answer
    [_resultView showResultForImageQuestion:YES forQuestion:_currentQuestion];

    // Record question data
    [self saveQuestionData:_currentQuestion.questionType withDifficulty:_currentQuestion.questionDifficulty isCorrect:isCorrect];
}

- (void)saveQuestionData:(QuizQuestionType)type withDifficulty:(QuizQuestionDifficulty)difficulty isCorrect:(BOOL)correct
{
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    
    // Save data based on type
    NSString *keyToSaveForType = @"";
    
    if (type == QuestionTypeBlank)
    {
        keyToSaveForType = @"Blank";
    }
    else if (type == QuestionTypeMC)
    {
        keyToSaveForType = @"MC";
    }
    else if (type == QuestionTypeImage)
    {
        keyToSaveForType = @"Image";
    }
    
    // Record that they answered an Image question
    int questionsAnsweredByType = [userDefaults integerForKey:[NSString stringWithFormat:@"%@QuestionsAnswered", keyToSaveForType]];
    questionsAnsweredByType++;
    [userDefaults setInteger:questionsAnsweredByType forKey:[NSString stringWithFormat:@"%@QuestionsAnswered", keyToSaveForType]];
    
    // Record that they answered an Image question correctly
    int questionsAnsweredCorrectlyByType = [userDefaults integerForKey:[NSString stringWithFormat:@"%@QuestionsAnsweredCorrectly", keyToSaveForType]];
    questionsAnsweredCorrectlyByType++;
    [userDefaults setInteger:questionsAnsweredCorrectlyByType forKey:[NSString stringWithFormat:@"%@QuestionsAnsweredCorrectly", keyToSaveForType]];
    
    // Save data based on difficulty
    NSString *keyToSaveForDifficulty = @"";
    
    if (difficulty == QuestionDifficultyEasy)
    {
        keyToSaveForDifficulty = @"Easy";
    }
    else if (difficulty == QuestionDifficultyMedium)
    {
        keyToSaveForDifficulty = @"Medium";
    }
    else if (difficulty == QuestionDifficultyHard)
    {
        keyToSaveForDifficulty = @"Hard";
    }
    
    int questionAnsweredWithDifficulty = [userDefaults integerForKey:[NSString stringWithFormat:@"%@QuestionsAnswered", keyToSaveForDifficulty]];
    questionAnsweredWithDifficulty++;
    [userDefaults setInteger:questionAnsweredWithDifficulty forKey:[NSString stringWithFormat:@"%@QuestionsAnswered", keyToSaveForDifficulty]];
    
    if (correct)
    {
        int questionAnsweredCorrectlyWithDifficulty = [userDefaults integerForKey:[NSString stringWithFormat:@"%@QuestionsAnsweredCorrectly", keyToSaveForDifficulty]];
        questionAnsweredCorrectlyWithDifficulty++;
        [userDefaults setInteger:questionAnsweredCorrectlyWithDifficulty forKey:[NSString stringWithFormat:@"%@QuestionsAnsweredCorrectly", keyToSaveForDifficulty]];
    }
    
    
    [userDefaults synchronize];
}

- (void)scrollViewTapped
{
    // Retract keyboard
    [self.blankTextField resignFirstResponder];
}

#pragma mark Result View Delegate Methods

- (void)resultViewDismissed
{
    // Animate it into view
    [UIView animateWithDuration:0.3
                          delay:0
                        options:UIViewAnimationOptionCurveEaseOut
                     animations:^(void){
                         
                         _dimmedBackground.alpha = 0;
                         
                     }
                     completion:^(BOOL finished) {
                         [_dimmedBackground removeFromSuperview];
                     }];
    
    [UIView animateWithDuration:0.5
                          delay:0.1
                        options:UIViewAnimationOptionCurveEaseOut
                     animations:^(void){
                         
                         CGRect resultViewFrame = _resultView.frame;
                         resultViewFrame.origin.y = 2000;
                         _resultView.frame = resultViewFrame;
                         
                     }
                     completion:^(BOOL finished) {
                         
                         [UIView animateWithDuration:0.5
                                               delay:0
                                             options:UIViewAnimationOptionCurveEaseIn
                                          animations:^(void){
                                              
                                              [self hideAllQuestionElements];
                                              
                                          }
                                          completion:^(BOOL finished) {
                                              
                                              // Display next question
                                              [self randomizeQuestionForDisplay];
                                              
                                          }];
                          [_resultView removeFromSuperview];
                     }];
}

- (void)resultViewHeightDetermined
{
    // Fade in dimmed background
    _dimmedBackground.alpha = 0;
    
    [self.view addSubview:_dimmedBackground];
    
    // Position result view below screen
    CGRect resultViewFrame = _resultView.frame;
    resultViewFrame.origin.y = 2000;
    _resultView.frame = resultViewFrame;
    
    [self.view addSubview:_resultView];
    
    // Animate it into view
    [UIView animateWithDuration:0.3
                          delay:0
                        options:UIViewAnimationOptionCurveEaseOut
                     animations:^(void){
                         
                         _dimmedBackground.alpha = 0.4;
                         
                     }
                     completion:nil];
    
    [UIView animateWithDuration:0.5
                          delay:0.1
                        options:UIViewAnimationOptionCurveEaseOut
                     animations:^(void){
                         
                         CGRect resultViewFrame = _resultView.frame;
                         resultViewFrame.origin.y = (self.view.frame.size.height - _resultView.frame.size.height)/2;
                         _resultView.frame = resultViewFrame;
                         
                     }
                     completion:nil];
}

#pragma mark iAd Delegate Methods

- (void)bannerViewDidLoadAd:(ADBannerView *)banner
{
    // Banner was successfully retrieve. Show ad if ad is not visible
    if (!_bannerIsVisible)
    {
        // Add the banner into the view
        if (_adView.superview == nil)
        {
            [self.view addSubview:_adView];
        }
        
        // Animate it into view
        [UIView beginAnimations:@"animateAdBannerOn" context:NULL];
        
        // Assumes the banner view is just off the bottom of the screen.
        _adView.frame = CGRectOffset(_adView.frame, 0, -_adView.frame.size.height);
        
        // Adjust scrollview height so it doesn't get covered by the banner
        CGRect scrollViewFrame = self.questionScrollView.frame;
        scrollViewFrame.size.height = scrollViewFrame.size.height - _adView.frame.size.height;
        self.questionScrollView.frame = scrollViewFrame;
        
        [UIView commitAnimations];
        
        // Set flag
        _bannerIsVisible = YES;
    }
}

- (void)bannerView:(ADBannerView *)banner didFailToReceiveAdWithError:(NSError *)error
{
    // Banner failed to be retrieved. Remove ad if shown
    if (_bannerIsVisible)
    {
        [UIView beginAnimations:@"animateAdBannerOff" context:NULL];
        
        // Assumes the banner view is placed at the bottom of the screen.
        banner.frame = CGRectOffset(banner.frame, 0, banner.frame.size.height);
        
        // Adjust scrollview height to be the full height of the view again
        CGRect scrollViewFrame = self.questionScrollView.frame;
        scrollViewFrame.size.height = self.view.frame.size.height;
        self.questionScrollView.frame = scrollViewFrame;
        
        [UIView commitAnimations];
        
        _bannerIsVisible = NO;
    }
}

@end
