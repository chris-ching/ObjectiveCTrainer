//
//  ResultView.m
//  ObjectiveTrainerApp
//
//  Created by Christopher Ching on 2014-04-19.
//  Copyright (c) 2014 CodeWithChris. All rights reserved.
//

#import "ResultView.h"
@interface ResultView ()
{
    CAShapeLayer *_dimLayer;
}
@end


@implementation ResultView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self)
    {
        self.backgroundColor = [UIColor clearColor];
        
        self.resultLabel = [[UILabel alloc] initWithFrame:CGRectMake(32, 55, 256, 29)];
        self.resultLabel.font = [UIFont fontWithName:@"HelveticaNeue-Light" size:24];
        self.resultLabel.textAlignment = NSTextAlignmentCenter;
        self.resultLabel.textColor = [UIColor whiteColor];
        [self addSubview:self.resultLabel];
        
        self.nextButton = [UIButton buttonWithType:UIButtonTypeSystem];
        self.nextButton.frame = CGRectMake(257, 527, 64, 40);
        [self.nextButton setTitle:@"Next" forState:UIControlStateNormal];
        self.nextButton.titleLabel.font = [UIFont fontWithName:@"HelveticaNeue-Light" size:18];
        [self.nextButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        self.nextButton.backgroundColor = [UIColor colorWithRed:74/255.0 green:74/255.0 blue:74/255.0 alpha:0.1];
        [self.nextButton addTarget:self action:@selector(nextButtonTapped) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:self.nextButton];

    }
    return self;
}

- (void)showImageResultAt:(CGPoint)point forResult:(NSString*)result
{
    // Remove elements first
    if (_dimLayer != nil)
        [_dimLayer removeFromSuperlayer];
    
    [self.resultLabel removeFromSuperview];
    [self.nextButton removeFromSuperview];
    
    // Add the dimmed out view with circular cut out
    int radius = 20;
    UIBezierPath *path = [UIBezierPath bezierPathWithRoundedRect:CGRectMake(0, 0, self.bounds.size.width, self.bounds.size.height) cornerRadius:0];
    UIBezierPath *circlePath = [UIBezierPath bezierPathWithRoundedRect:CGRectMake(point.x, point.y, 2.0*radius, 2.0*radius) cornerRadius:radius];
    [path appendPath:circlePath];
    [path setUsesEvenOddFillRule:YES];
    
    _dimLayer = [CAShapeLayer layer];
    _dimLayer.path = path.CGPath;
    _dimLayer.fillRule = kCAFillRuleEvenOdd;
    _dimLayer.fillColor = [UIColor blackColor].CGColor;
    _dimLayer.opacity = 0.8;
    [self.layer addSublayer:_dimLayer];
    
    self.resultLabel.text = result;
    
    // Add the result label and next button
    [self addSubview:self.resultLabel];
    [self addSubview:self.nextButton];
}

- (void)nextButtonTapped
{
    // Notify delegate that result view can be dismissed
    [self.delegate resultViewDismissed];
}

@end
