//
//  QuestionModel.h
//  ObjectiveTrainerApp
//
//  Created by Christopher Ching on 2014-03-29.
//  Copyright (c) 2014 CodeWithChris. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface QuestionModel : NSObject

@property (strong, nonatomic) NSMutableArray *easyQuestions;
@property (strong, nonatomic) NSMutableArray *mediumQuestions;
@property (strong, nonatomic) NSMutableArray *hardQuestions;

- (NSMutableArray *)getQuestions:(QuizQuestionDifficulty)difficulty;

@end
