//
//  MenuTableViewCell.m
//  ObjectiveTrainerApp
//
//  Created by Christopher Ching on 2014-07-10.
//  Copyright (c) 2014 CodeWithChris. All rights reserved.
//

#import "MenuTableViewCell.h"

@implementation MenuTableViewCell

- (void)awakeFromNib
{
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)setMenuCellTitle:(NSString*)title
{
    self.backgroundColor = [UIColor colorWithRed:74/255.0 green:74/255.0 blue:74/255.0 alpha:1.0];
    
    // Set title
    self.sectionTitleLabel.text = title;
    
    // Get standard defaults
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    
    // Check what the title is and set the corresponding info
    if ([title isEqualToString:@"Easy"])
    {
        // Set the background
        self.contentView.backgroundColor = [UIColor colorWithRed:131/255.0 green:196/255.0 blue:89/255.0 alpha:0.3];
        
        // Set the score
        int easyQuestionsAnswered = (int)[userDefaults integerForKey:@"EasyQuestionsAnswered"];
        int easyQuestionsCorrect = (int)[userDefaults integerForKey:@"EasyQuestionsAnsweredCorrectly"];
        self.scoreLabel.text = [NSString stringWithFormat:@"%i/%i", easyQuestionsCorrect, easyQuestionsAnswered];
        
        // Set the progress bar image
        self.progressImageView.image = [UIImage imageNamed:@"EasyProgressBar"];

        // Calculate width to animate to
        float pct = (float)easyQuestionsCorrect/(float)easyQuestionsAnswered;
        int widthToAnimate = self.frame.size.width * pct;
        
        // Animate to width
        [self animateProgressBarTo:widthToAnimate];
    }
    else if ([title isEqualToString:@"Medium"])
    {
        // Set the background
        self.contentView.backgroundColor = [UIColor colorWithRed:37/255.0 green:47/255.0 blue:167/255.0 alpha:0.3];
        
        // Set the score
        int mediumQuestionsAnswered = (int)[userDefaults integerForKey:@"MediumQuestionsAnswered"];
        int mediumQuestionsCorrect = (int)[userDefaults integerForKey:@"MediumQuestionsAnsweredCorrectly"];
        self.scoreLabel.text = [NSString stringWithFormat:@"%i/%i", mediumQuestionsCorrect, mediumQuestionsAnswered];
        
        // Set the progress bar image
        self.progressImageView.image = [UIImage imageNamed:@"MediumProgressBar"];
        
        // Calculate width to animate to
        float pct = (float)mediumQuestionsCorrect/(float)mediumQuestionsAnswered;
        int widthToAnimate = self.frame.size.width * pct;
        
        // Animate to width
        [self animateProgressBarTo:widthToAnimate];
    }
    else if ([title isEqualToString:@"Hard"])
    {
        // Set the background
        self.contentView.backgroundColor = [UIColor colorWithRed:157/255.0 green:21/255.0 blue:22/255.0 alpha:0.3];
        
        // Set the score
        int hardQuestionsAnswered = (int)[userDefaults integerForKey:@"HardQuestionsAnswered"];
        int hardQuestionsCorrect = (int)[userDefaults integerForKey:@"HardQuestionsAnsweredCorrectly"];
        self.scoreLabel.text = [NSString stringWithFormat:@"%i/%i", hardQuestionsCorrect, hardQuestionsAnswered];
    
        // Set the progress bar image
        self.progressImageView.image = [UIImage imageNamed:@"HardProgressBar"];
        
        // Calculate width to animate to
        float pct = (float)hardQuestionsCorrect/(float)hardQuestionsAnswered;
        int widthToAnimate = self.frame.size.width * pct;
        
        // Animate to width
        [self animateProgressBarTo:widthToAnimate];
    }
}

- (void)animateProgressBarTo:(float)toWidth
{
    // Set width of image view to 0
    CGRect imageViewFrame = self.progressImageView.frame;
    imageViewFrame.size.width = 0;
    self.progressImageView.frame = imageViewFrame;
    
    // Animate the progress bar
    [UIView animateWithDuration:1
                          delay:0
                        options:UIViewAnimationOptionCurveEaseOut
                     animations:^(void){
                         
                         // Set width of image view to pct * full width
                         CGRect imageViewFrame = self.progressImageView.frame;
                         imageViewFrame.size.width = toWidth;
                         self.progressImageView.frame = imageViewFrame;
                         
                     }
                     completion:nil];
}

@end
