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
    UITapGestureRecognizer *_tappablePortionTapRecognizer;
    UITapGestureRecognizer *_imageQuestionTapRecognizer;
    UITapGestureRecognizer *_scrollViewTapGestureRecognizer;
    
    ResultView *_resultView;
    
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
    
    // Set self as the delegate of the Fill in the blank textfield so later we can detect when user taps it
    self.blankTextField.delegate = self;
    
    // Add tap gesture recognizer to scrollview
    _scrollViewTapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(scrollViewTapped)];
    [self.questionScrollView addGestureRecognizer:_scrollViewTapGestureRecognizer];
    
    // Add a tap gesture to image view question
    _imageQuestionTapRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(imageQuestionIncorrect)];
    [self.imageQuestionImageView addGestureRecognizer:_imageQuestionTapRecognizer];
    
    // Add pan gesture recognizer for menu reveal
    [self.view addGestureRecognizer:self.revealViewController.panGestureRecognizer];
    
    // Hide everything
    [self hideAllQuestionElements];
    
    // Create quiz model
    self.model = [[QuestionModel alloc] init];
    
    // Check difficulty level and retrieve questions for desired level
    self.questions = [self.model getQuestions:self.questionDifficulty];
    
    // Set new bg
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    int prevDifficulty = (int)[userDefaults integerForKey:@"PreviousQuestionDifficulty"];
    [self changeAssetsForDifficulty:prevDifficulty animate:NO];
    
    // Display a random question
    [self randomizeQuestionForDisplay];
}

- (void)viewDidAppear:(BOOL)animated
{
    // Call super implementation
    [super viewDidAppear:animated];
    
    // Set scrollview size
    self.questionScrollView.frame = CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height);
    
    // Create a result view
    _resultView = [[ResultView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height)];
    _resultView.delegate = self;
    
    // Check if question difficulty has changed, if so, change bg
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    int prevDifficulty = (int)[userDefaults integerForKey:@"PreviousQuestionDifficulty"];
    
    if (prevDifficulty != self.questionDifficulty)
    {
        [self changeAssetsForDifficulty:self.questionDifficulty animate:YES];
    }
    
    // Check flag to see if we should show ad
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    
    NSString *flag = [defaults objectForKey:@"removeads"];
    
    if (![flag isEqualToString:@"bought"])
    {
        // Create iAd banner and place at bottom
        _adView = [[ADBannerView alloc] initWithFrame:CGRectMake(0, self.view.frame.size.height, 320, 50)];
        _adView.delegate = self;
    }
    
    // If menu is open when this appears, then close it
    if (self.revealViewController.frontViewPosition == FrontViewPositionRight)
        [self.revealViewController revealToggleAnimated:YES];
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
    
    CGRect buttonBulletFrame = self.questionMCAnswer1Bullet.frame;
    buttonBulletFrame.origin.y = 2000;
    self.questionMCAnswer1Bullet.frame = buttonBulletFrame;
    
    buttonFrame = self.questionMCAnswer2.frame;
    buttonFrame.origin.y = 2000;
    self.questionMCAnswer2.frame = buttonFrame;
    
    buttonBulletFrame = self.questionMCAnswer2Bullet.frame;
    buttonBulletFrame.origin.y = 2000;
    self.questionMCAnswer2Bullet.frame = buttonBulletFrame;
    
    buttonFrame = self.questionMCAnswer3.frame;
    buttonFrame.origin.y = 2000;
    self.questionMCAnswer3.frame = buttonFrame;
    
    buttonBulletFrame = self.questionMCAnswer3Bullet.frame;
    buttonBulletFrame.origin.y = 2000;
    self.questionMCAnswer3Bullet.frame = buttonBulletFrame;
    
    // Set fill in the blank elements off the screen
    buttonFrame = self.submitAnswerForBlankButton.frame;
    buttonFrame.origin.y = 2000;
    self.submitAnswerForBlankButton.frame = buttonFrame;
    
    buttonFrame = self.blankTextField.frame;
    buttonFrame.origin.y = 2000;
    self.blankTextField.frame = buttonFrame;
    
    self.submittedAnswerLabel.alpha = 0;
    
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
    // Update status bar score
    [self updateStatusBarScore];
    
    // Update the difficulty
    switch (_currentQuestion.questionDifficulty) {
        case QuestionDifficultyEasy:
            self.statusBarQuestionDifficultyLabel.text = @"Easy";
            break;
            
        case QuestionDifficultyMedium:
            self.statusBarQuestionDifficultyLabel.text = @"Medium";
            break;
            
        case QuestionDifficultyHard:
            self.statusBarQuestionDifficultyLabel.text = @"Hard";
            break;
            
        default:
            break;
    }
    
    switch (_currentQuestion.questionType) {
        case QuestionTypeMC:
            self.statusBarQuestionTypeLabel.text = @"Multiple Choice";
            [self displayMCQuestion];
            break;
            
        case QuestionTypeBlank:
            self.statusBarQuestionTypeLabel.text = @"Fill In The Blank";
            [self displayBlankQuestion];
            break;
            
        case QuestionTypeImage:
            self.statusBarQuestionTypeLabel.text = @"Find The Error";
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
    self.questionScrollView.contentSize = CGSizeMake(self.questionScrollView.frame.size.width, 568);
    
    // Animate the labels and buttons back to their positions
    [UIView animateWithDuration:1 animations:^(void){
        
        // Fade question text in
        self.questionText.alpha = 1.0;
       
        // Position answer background
        CGRect answerBackgroundFrame = self.answerBackgroundView.frame;
        answerBackgroundFrame.origin.y = 218;
        self.answerBackgroundView.frame = answerBackgroundFrame;
        
    }];
    
    [UIView animateWithDuration:1
                          delay:0.1
                        options:UIViewAnimationOptionCurveEaseOut
                     animations:^(void){
                     
                         // Position answer 1 text
                         self.questionMCAnswer1.alpha = 1;
                         CGRect answerButton1Frame = self.questionMCAnswer1.frame;
                         answerButton1Frame.origin.y = 218;
                         self.questionMCAnswer1.frame = answerButton1Frame;
                         
                         // Position answer background
                         self.questionMCAnswer1Bullet.alpha = 1;
                         CGRect answerButtonBullet1Frame = self.questionMCAnswer1Bullet.frame;
                         answerButtonBullet1Frame.origin.y = 218;
                         self.questionMCAnswer1Bullet.frame = answerButtonBullet1Frame;
                         
                         [self positionStatusBar:187];
                     }
                     completion:nil];

    
    [UIView animateWithDuration:1
                          delay:0.2
                        options:UIViewAnimationOptionCurveEaseOut
                     animations:^(void){
                         
                         // Position answer 2 text
                         self.questionMCAnswer2.alpha = 1;
                         CGRect answerButton2Frame = self.questionMCAnswer2.frame;
                         answerButton2Frame.origin.y = 322;
                         self.questionMCAnswer2.frame = answerButton2Frame;
                         
                         self.questionMCAnswer2Bullet.alpha = 1;
                         CGRect answerButtonBullet2Frame = self.questionMCAnswer2Bullet.frame;
                         answerButtonBullet2Frame.origin.y = 322;
                         self.questionMCAnswer2Bullet.frame = answerButtonBullet2Frame;
                         
                     }
                     completion:nil];
    
    
    [UIView animateWithDuration:1
                          delay:0.3
                        options:UIViewAnimationOptionCurveEaseOut
                     animations:^(void){
                         
                         // Position answer 3 text
                         self.questionMCAnswer3.alpha = 1;
                         CGRect answerButton3Frame = self.questionMCAnswer3.frame;
                         answerButton3Frame.origin.y = 426;
                         self.questionMCAnswer3.frame = answerButton3Frame;
                         
                         self.questionMCAnswer3Bullet.alpha = 1;
                         CGRect answerButtonBullet3Frame = self.questionMCAnswer3Bullet.frame;
                         answerButtonBullet3Frame.origin.y = 426;
                         self.questionMCAnswer3Bullet.frame = answerButtonBullet3Frame;
                         
                     }
                     completion:nil];
    
    // Enable tapping on buttons
    self.questionMCAnswer1.userInteractionEnabled = YES;
    self.questionMCAnswer2.userInteractionEnabled = YES;
    self.questionMCAnswer3.userInteractionEnabled = YES;

    // Scroll back to top if 3.5" screen
    if (!IS_WIDESCREEN)
        [self.questionScrollView setContentOffset:CGPointMake(0, 0) animated:YES];
}

- (void)displayImageQuestion
{
    // Hide all elements
    [self hideAllQuestionElements];
    
    // Set question elements
    self.questionText.text = @"What is wrong with the code below? \n\n Tap the error.";
    self.questionText.alpha = 1.0;
    
    // Set Image
    UIImage *tempImage = [UIImage imageNamed:_currentQuestion.questionImageName];
    self.imageQuestionImageView.image = tempImage;
    self.imageQuestionImageView.userInteractionEnabled = YES;
    
    // Get aspect ratio of image
    double aspect = tempImage.size.height/tempImage.size.width;
    
    // Resize imageview
    CGRect imageViewFrame = self.imageQuestionImageView.frame;
    imageViewFrame.size.width = self.view.frame.size.width;
    imageViewFrame.size.height = tempImage.size.width * aspect;
    imageViewFrame.origin.y = 497 - imageViewFrame.size.height;
    self.imageQuestionImageView.frame = imageViewFrame;
    
    // Create tappable part
    int tappable_x = self.imageQuestionImageView.frame.origin.x + _currentQuestion.offset_x - 20;
    int tappable_y = self.imageQuestionImageView.frame.origin.y + _currentQuestion.offset_y - 20;
    
    _tappablePortionOfImageQuestion = [[UIView alloc] initWithFrame:CGRectMake(tappable_x, tappable_y, 40, 40)];
    _tappablePortionOfImageQuestion.backgroundColor = [UIColor clearColor];
    
    // Create and attach gesture recognizer
    _tappablePortionTapRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(imageQuestionAnswered)];
    [_tappablePortionOfImageQuestion addGestureRecognizer:_tappablePortionTapRecognizer];
    
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
    
    // Adjust scrollview
    self.questionScrollView.contentSize = CGSizeMake(self.questionScrollView.frame.size.width, 568);
    
    // Animate the elements in
    [UIView animateWithDuration:0.5
                          delay:0
                        options:UIViewAnimationOptionCurveEaseOut
                     animations:^(void){
                         
                         // Position the status bar
                         [self positionStatusBar:497];
                         
                         // Position answer background
                         CGRect answerBackgroundFrame = self.answerBackgroundView.frame;
                         answerBackgroundFrame.origin.y = 497;
                         self.answerBackgroundView.frame = answerBackgroundFrame;
                     }
                     completion:nil];
    
    
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
    
    // Scroll back to top if 3.5" screen
    if (!IS_WIDESCREEN)
        [self.questionScrollView setContentOffset:CGPointMake(0, 0) animated:YES];
}

- (void)displayBlankQuestion
{
    // Hide all elements
    [self hideAllQuestionElements];
    
    // Set question image for fill in the blank question
    self.questionText.text = @"What is missing below? \n\n Type in the missing keyword.";
    self.questionText.alpha = 1.0;
    
    UIImage *tempImage = [UIImage imageNamed:_currentQuestion.questionImageName];
    self.imageQuestionImageView.image = tempImage;
    self.imageQuestionImageView.userInteractionEnabled = NO;
    
    // Get aspect ratio of image
    double aspect = tempImage.size.height/tempImage.size.width;
    
    // Resize imageview
    CGRect imageViewFrame = self.imageQuestionImageView.frame;
    imageViewFrame.size.width = self.view.frame.size.width;
    imageViewFrame.size.height = tempImage.size.width * aspect;
    imageViewFrame.origin.y = 350 - imageViewFrame.size.height;
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
    self.questionScrollView.contentSize = CGSizeMake(self.questionScrollView.frame.size.width, 568);
    
    // Animate the elements in
    [UIView animateWithDuration:0.5
                          delay:0
                        options:UIViewAnimationOptionCurveEaseOut
                     animations:^(void){
                         
                         // Position the answer background and status bar
                         [self positionStatusBar:350];
                         
                         CGRect answerBackgroundFrame = self.answerBackgroundView.frame;
                         answerBackgroundFrame.origin.y = 350;
                         self.answerBackgroundView.frame = answerBackgroundFrame;
                     }
                     completion:nil];
    
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
                         self.blankTextField.alpha = 1;
                         CGRect textboxFrame = self.blankTextField.frame;
                         textboxFrame.origin.y = 400;
                         self.blankTextField.frame = textboxFrame;
                         
                         // Reveal and slide up the submit button
                         self.submitAnswerForBlankButton.alpha = 1;
                         CGRect buttonFrame = self.submitAnswerForBlankButton.frame;
                         buttonFrame.origin.y = 400;
                         self.submitAnswerForBlankButton.frame = buttonFrame;
                     }
                     completion:nil];
    
    // Scroll back to top if 3.5" screen
    if (!IS_WIDESCREEN)
        [self.questionScrollView setContentOffset:CGPointMake(0, 0) animated:YES];
}

- (void)randomizeQuestionForDisplay
{
    // Randomize a question
    int randomQuestionIndex = arc4random() % self.questions.count;
    _currentQuestion = self.questions[randomQuestionIndex];
    
    // Display the question
    [self displayCurrentQuestion];
}

- (void)positionStatusBar:(int)yorigin
{
    // Position status bar
    CGRect statusBarFrame = self.statusBarBackground.frame;
    statusBarFrame.origin.y = yorigin;
    self.statusBarBackground.frame = statusBarFrame;
    
    // Position quesiton type label
    CGRect questionTypeFrame = self.statusBarQuestionTypeLabel.frame;
    questionTypeFrame.origin.y = yorigin;
    self.statusBarQuestionTypeLabel.frame = questionTypeFrame;
    
    // Position difficulty label
    CGRect questionDifficultyFrame = self.statusBarQuestionDifficultyLabel.frame;
    questionDifficultyFrame.origin.y = yorigin;
    self.statusBarQuestionDifficultyLabel.frame = questionDifficultyFrame;
    
    // Position score label
    CGRect scoreFrame = self.statusBarScoreLabel.frame;
    scoreFrame.origin.y = yorigin;
    self.statusBarScoreLabel.frame = scoreFrame;
}

- (void)updateStatusBarScore
{
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    
    int easyQuestionsAnswered = (int)[userDefaults integerForKey:@"EasyQuestionsAnswered"];
    int easyQuestionsCorrect = (int)[userDefaults integerForKey:@"EasyQuestionsAnsweredCorrectly"];
    int mediumQuestionsAnswered = (int)[userDefaults integerForKey:@"MediumQuestionsAnswered"];
    int mediumQuestionsCorrect = (int)[userDefaults integerForKey:@"MediumQuestionsAnsweredCorrectly"];
    int hardmQuestionsAnswered = (int)[userDefaults integerForKey:@"HardQuestionsAnswered"];
    int hardQuestionsCorrect = (int)[userDefaults integerForKey:@"HardQuestionsAnsweredCorrectly"];
    
    int totalCorrect = easyQuestionsCorrect + mediumQuestionsCorrect + hardQuestionsCorrect;
    int totalAttempted = easyQuestionsAnswered + mediumQuestionsAnswered + hardmQuestionsAnswered;
    
    self.statusBarScoreLabel.text = [NSString stringWithFormat:@"Score: %i / %i", totalCorrect, totalAttempted];
}

- (void)changeAssetsForDifficulty:(int)difficulty animate:(BOOL)shouldAnimate
{
   
        UIImageView *newBg;
        // Fade in the appropriate colored bg
        if (difficulty == QuestionDifficultyEasy)
        {
            newBg = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"EasyQuestionBackground"]];
            
            self.questionMCAnswer1Bullet.backgroundColor = [UIColor colorWithRed:132/255.0 green:161/255.0 blue:99/255.0 alpha:1];
            self.questionMCAnswer1.backgroundColor = [UIColor colorWithRed:132/255.0 green:161/255.0 blue:99/255.0 alpha:0.14];
            
            self.questionMCAnswer2Bullet.backgroundColor = [UIColor colorWithRed:149/255.0 green:183/255.0 blue:111/255.0 alpha:1];
            self.questionMCAnswer2.backgroundColor = [UIColor colorWithRed:149/255.0 green:183/255.0 blue:111/255.0 alpha:0.14];
            
            self.questionMCAnswer3Bullet.backgroundColor = [UIColor colorWithRed:172/255.0 green:211/255.0 blue:128/255.0 alpha:1];
            self.questionMCAnswer3.backgroundColor = [UIColor colorWithRed:172/255.0 green:211/255.0 blue:128/255.0 alpha:0.14];
        }
        else if (difficulty == QuestionDifficultyMedium)
        {
            newBg = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"MedQuestionBackground"]];
            
            self.questionMCAnswer1Bullet.backgroundColor = [UIColor colorWithRed:131/255.0 green:99/255.0 blue:161/255.0 alpha:1];
            self.questionMCAnswer1.backgroundColor = [UIColor colorWithRed:131/255.0 green:99/255.0 blue:161/255.0 alpha:0.14];
            
            self.questionMCAnswer2Bullet.backgroundColor = [UIColor colorWithRed:139/255.0 green:111/255.0 blue:183/255.0 alpha:1];
            self.questionMCAnswer2.backgroundColor = [UIColor colorWithRed:139/255.0 green:111/255.0 blue:183/255.0 alpha:0.14];
            
            self.questionMCAnswer3Bullet.backgroundColor = [UIColor colorWithRed:164/255.0 green:128/255.0 blue:211/255.0 alpha:1];
            self.questionMCAnswer3.backgroundColor = [UIColor colorWithRed:164/255.0 green:128/255.0 blue:211/255.0 alpha:0.14];
        }
        else if (difficulty == QuestionDifficultyHard)
        {
            newBg = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"HardQuestionBackground"]];
            
            self.questionMCAnswer1Bullet.backgroundColor = [UIColor colorWithRed:161/255.0 green:99/255.0 blue:99/255.0 alpha:1];
            self.questionMCAnswer1.backgroundColor = [UIColor colorWithRed:161/255.0 green:99/255.0 blue:99/255.0 alpha:0.14];
            
            self.questionMCAnswer2Bullet.backgroundColor = [UIColor colorWithRed:183/255.0 green:111/255.0 blue:111/255.0 alpha:1];
            self.questionMCAnswer2.backgroundColor = [UIColor colorWithRed:183/255.0 green:111/255.0 blue:111/255.0 alpha:0.14];
            
            self.questionMCAnswer3Bullet.backgroundColor = [UIColor colorWithRed:211/255.0 green:128/255.0 blue:128/255.0 alpha:1];
            self.questionMCAnswer3.backgroundColor = [UIColor colorWithRed:211/255.0 green:128/255.0 blue:128/255.0 alpha:0.14];
        }
        
        
        UIImageView *oldBg = (UIImageView*)self.view.subviews[0];
        [self.view insertSubview:newBg belowSubview:oldBg];
    
        if (shouldAnimate)
        {
            [UIView animateWithDuration:1
                                  delay:0
                                options:UIViewAnimationOptionCurveEaseIn
                             animations:^(void){
                                 
                                 oldBg.alpha = 0.0;
                                 /*
                                  CGRect frame = oldBg.frame;
                                  frame.origin.x += 50;
                                  frame.origin.y += 50;
                                  oldBg.frame = frame;*/
                                 
                             }
                             completion:^(BOOL finished) {
                                 
                                 [oldBg removeFromSuperview];
                                 
                                 // Save old bg
                                 NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
                                 [userDefaults setInteger:(int)difficulty
                                                   forKey:@"PreviousQuestionDifficulty"];
                                 [userDefaults synchronize];
                             }];
        }
        else
        {
            [oldBg removeFromSuperview];
            
            // Save old bg
            NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
            [userDefaults setInteger:(int)difficulty
                              forKey:@"PreviousQuestionDifficulty"];
            [userDefaults synchronize];
        }
    
    
    
}

#pragma mark Question Answer Handlers

- (IBAction)skipButtonClicked:(id)sender
{
    // When skip/next button is tapped, make sure title is Skip
    [self.skipButton setTitle:@"Skip" forState:UIControlStateNormal];
    
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
    // Disable tapping on buttons
    self.questionMCAnswer1.userInteractionEnabled = NO;
    self.questionMCAnswer2.userInteractionEnabled = NO;
    self.questionMCAnswer3.userInteractionEnabled = NO;
    
    UIButton *selectedButton = (UIButton *)sender;
    BOOL isCorrect = NO;
    
    if (selectedButton.tag == _currentQuestion.correctMCQuestionIndex)
    {
        // User got it right
        isCorrect = YES;
    }
    else
    {
        // User got it wrong
    }
    
    // Animate and fade out the incorrect answers
    [UIView animateWithDuration:0.5
                     animations:^(void){
                         
                         if (_currentQuestion.correctMCQuestionIndex != 1)
                         {
                             self.questionMCAnswer1.alpha = 0.2;
                             self.questionMCAnswer1Bullet.alpha = 0.2;
                         }
                         
                         if (_currentQuestion.correctMCQuestionIndex != 2)
                         {
                             self.questionMCAnswer2.alpha = 0.2;
                             self.questionMCAnswer2Bullet.alpha = 0.2;
                         }
                         
                         if (_currentQuestion.correctMCQuestionIndex != 3)
                         {
                             self.questionMCAnswer3.alpha = 0.2;
                             self.questionMCAnswer3Bullet.alpha = 0.2;
                         }
                         
                     }];
    
    // Display message for answer
    //[_resultView showResultForTextQuestion:isCorrect forUserAnswer:userAnswer forQuestion:_currentQuestion];
    
    self.questionText.text = isCorrect ? @"Correct!" : @"Incorrect";
    
    // Save the question data
    [self saveQuestionData:_currentQuestion.questionType withDifficulty:_currentQuestion.questionDifficulty isCorrect:isCorrect];
    
    // Change skip to next
    [self.skipButton setTitle:@"Next" forState:UIControlStateNormal];
}

- (void)imageQuestionAnswered
{
    // User got it right
    
    // Create point to show the spotlight
    int tappable_x = self.imageQuestionImageView.frame.origin.x + _currentQuestion.offset_x - 20;
    int tappable_y = self.imageQuestionImageView.frame.origin.y + _currentQuestion.offset_y - 20 - self.questionScrollView.contentOffset.y;
    CGPoint spotlight = CGPointMake(tappable_x, tappable_y);
    
    // Display message for correct answer
    _resultView.alpha = 0;
    [self.view addSubview:_resultView];
    [_resultView showImageResultAt:spotlight forResult:@"Correct"];
    
    // Hide question text
    self.questionText.alpha = 0;
    
    [UIView animateWithDuration:0.3 animations:^(void){
        _resultView.alpha = 1.0;
    }];
    
    [self saveQuestionData:_currentQuestion.questionType withDifficulty:_currentQuestion.questionDifficulty isCorrect:YES];
}

- (void)imageQuestionIncorrect
{
    // User got it wrong
    
    // Create point to show the spotlight
    int tappable_x = self.imageQuestionImageView.frame.origin.x + _currentQuestion.offset_x - 20;
    int tappable_y = self.imageQuestionImageView.frame.origin.y + _currentQuestion.offset_y - 20 - self.questionScrollView.contentOffset.y;
    CGPoint spotlight = CGPointMake(tappable_x, tappable_y);
    
    // Display message for correct answer
    _resultView.alpha = 0;
    [self.view addSubview:_resultView];
    [_resultView showImageResultAt:spotlight forResult:@"Incorrect"];
    
    // Hide question text
    self.questionText.alpha = 0;
    
    [UIView animateWithDuration:0.3 animations:^(void){
        _resultView.alpha = 1.0;
    }];
    
    [self saveQuestionData:_currentQuestion.questionType withDifficulty:_currentQuestion.questionDifficulty isCorrect:NO];
}

- (IBAction)blankSubmitted:(id)sender
{
    // Retract keyboard
    [self.blankTextField resignFirstResponder];
    
    // Get answer
    NSString *answer = self.blankTextField.text;
    
    // Hide the text box and go button
    self.blankTextField.alpha = 0;
    self.submitAnswerForBlankButton.alpha = 0;
    
    // Show submitted answer label
    self.submittedAnswerLabel.text = answer;
    self.submittedAnswerLabel.alpha = 1;
    
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
    // [_resultView showResultForImageQuestion:YES forQuestion:_currentQuestion];
    
    self.questionText.text = isCorrect ? @"Correct!" : [NSString stringWithFormat:@"Incorrect: \n %@", _currentQuestion.correctAnswerForBlank];

    // Record question data
    [self saveQuestionData:_currentQuestion.questionType withDifficulty:_currentQuestion.questionDifficulty isCorrect:isCorrect];
    
    // Change skip button to next button
    [self.skipButton setTitle:@"Next" forState:UIControlStateNormal];
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
    int questionsAnsweredByType = (int)[userDefaults integerForKey:[NSString stringWithFormat:@"%@QuestionsAnswered", keyToSaveForType]];
    questionsAnsweredByType++;
    [userDefaults setInteger:questionsAnsweredByType forKey:[NSString stringWithFormat:@"%@QuestionsAnswered", keyToSaveForType]];
    
    // Record that they answered an Image question correctly
    int questionsAnsweredCorrectlyByType = (int)[userDefaults integerForKey:[NSString stringWithFormat:@"%@QuestionsAnsweredCorrectly", keyToSaveForType]];
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
    
    int questionAnsweredWithDifficulty = (int)[userDefaults integerForKey:[NSString stringWithFormat:@"%@QuestionsAnswered", keyToSaveForDifficulty]];
    questionAnsweredWithDifficulty++;
    [userDefaults setInteger:questionAnsweredWithDifficulty forKey:[NSString stringWithFormat:@"%@QuestionsAnswered", keyToSaveForDifficulty]];
    
    if (correct)
    {
        int questionAnsweredCorrectlyWithDifficulty = (int)[userDefaults integerForKey:[NSString stringWithFormat:@"%@QuestionsAnsweredCorrectly", keyToSaveForDifficulty]];
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
    [UIView animateWithDuration:0.3
                          delay:0
                        options:UIViewAnimationOptionCurveEaseOut
                     animations:^(void){
                         
                         _resultView.alpha = 0;
                         
                     }
                     completion:^(BOOL finished) {
                         
                         [UIView animateWithDuration:0.5
                                               delay:0
                                             options:UIViewAnimationOptionCurveEaseIn
                                          animations:^(void){
                                              
                                              [self hideAllQuestionElements];
                                              
                                          }
                                          completion:^(BOOL finished) {
                                              
                                              // Show question text
                                              self.questionText.alpha = 1;
                                              
                                              // Display next question
                                              [self randomizeQuestionForDisplay];
                                              
                                          }];
                          [_resultView removeFromSuperview];
                     }];
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
        
        // Adjust question text so it's still visible
        CGRect questionTextFrame = self.questionText.frame;
        questionTextFrame.origin.y += _adView.frame.size.height;
        questionTextFrame.size.height -= _adView.frame.size.height;
        self.questionText.frame = questionTextFrame;
        self.questionText.font = [UIFont fontWithName:@"HelveticaNeue-Light" size:18];
        
        [UIView commitAnimations];
        
        // Scroll so top is visible
        [self.questionScrollView setContentOffset:CGPointMake(0, _adView.frame.size.height) animated:YES];
        
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
        
        // Adjust question text so it's still visible
        CGRect questionTextFrame = self.questionText.frame;
        questionTextFrame.origin.y = 26;
        questionTextFrame.size.height = 159;
        self.questionText.frame = questionTextFrame;
        self.questionText.font = [UIFont fontWithName:@"HelveticaNeue-Light" size:24];
        
        [UIView commitAnimations];
      
        // Scroll to top
        [self.questionScrollView setContentOffset:CGPointMake(0, 0) animated:YES];
        
        _bannerIsVisible = NO;
    }
}

#pragma mark UITextField Delegate

- (void)textFieldDidBeginEditing:(UITextField *)textField
{
    int heightToIncrease = _bannerIsVisible ? 60 : 100;
    
    // Increase height of contentsize of scrollview
    self.questionScrollView.contentSize = CGSizeMake(self.questionScrollView.contentSize.width, self.questionScrollView.contentSize.height + heightToIncrease);
    
    // Hide question text
    self.questionText.alpha = 0;
    
    // Scroll the scrollview up
    [self.questionScrollView setContentOffset:CGPointMake(0, self.questionScrollView.contentOffset.y + heightToIncrease) animated:NO];
}

- (void)textFieldDidEndEditing:(UITextField *)textField
{
    int heightToShrink = _bannerIsVisible ? 60 : 100;

    // Scroll the scrollview back to the way it was before
    [self.questionScrollView setContentOffset:CGPointMake(0, self.questionScrollView.contentOffset.y - heightToShrink) animated:NO];
    
    // Shorten height of contentsize of scrollview
    self.questionScrollView.contentSize = CGSizeMake(self.questionScrollView.contentSize.width, self.questionScrollView.contentSize.height - heightToShrink);
    
    // Show question text
    self.questionText.alpha = 1;
}

@end
