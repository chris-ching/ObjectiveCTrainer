//
//  RemoveAdsViewController.m
//  ObjectiveTrainerApp
//
//  Created by Christopher Ching on 2014-03-29.
//  Copyright (c) 2014 CodeWithChris. All rights reserved.
//

#import "RemoveAdsViewController.h"
#import "SWRevealViewController.h"

@interface RemoveAdsViewController ()

@end

@implementation RemoveAdsViewController

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
    
    [self.view addGestureRecognizer:self.revealViewController.panGestureRecognizer];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
