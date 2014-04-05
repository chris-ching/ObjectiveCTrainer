//
//  StatsViewController.h
//  ObjectiveTrainerApp
//
//  Created by Christopher Ching on 2014-03-29.
//  Copyright (c) 2014 CodeWithChris. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface StatsViewController : UIViewController

@property (weak, nonatomic) IBOutlet UILabel *totalQuestionsLabel;
@property (weak, nonatomic) IBOutlet UILabel *easyQuestionsStats;
@property (weak, nonatomic) IBOutlet UILabel *mediumQuestionsStats;
@property (weak, nonatomic) IBOutlet UILabel *hardQuestionsStats;

@end
