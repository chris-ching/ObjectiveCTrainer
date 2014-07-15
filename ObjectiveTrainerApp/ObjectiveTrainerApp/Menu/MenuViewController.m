//
//  MenuViewController.m
//  ObjectiveTrainerApp
//
//  Created by Christopher Ching on 2014-03-29.
//  Copyright (c) 2014 CodeWithChris. All rights reserved.
//

#import "MenuViewController.h"
#import "SWRevealViewController.h"
#import "MenuTableViewCell.h"

@interface MenuViewController ()

@end

@implementation MenuViewController

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
    
    // Set self as the data source and delegate for the table view
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    
    // Fetch the menu items
    self.menuItems = [[[MenuModel alloc] init] getMenuItems];
}

- (void)viewDidAppear:(BOOL)animated
{
    // Reload table
    [self.tableView reloadData];
    
    // Set stats
    [self calculateStats];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma Stats Methods

- (void)calculateStats
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
    
    int totalScore = ((float)totalCorrect/(float)totalAttempted) * 100;
    
    // Set labels
    self.attemptedLabel.text = [NSString stringWithFormat:@"Total Attempted %i", totalAttempted];
    self.scoreLabel.text = [NSString stringWithFormat:@"%i", totalScore];
}

#pragma mark Table View Delegate Methods

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.menuItems.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 72.0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Retrieve cell
    NSString *cellIdentifier = @"MenuItemCell";
    MenuTableViewCell *menuCell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    
    if (menuCell == nil)
    {
        // Create a new MenuTableViewCell
        [tableView registerNib:[UINib nibWithNibName:@"MenuTableViewCell" bundle:nil] forCellReuseIdentifier:cellIdentifier];
        menuCell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    }
    
    // Get menu item that it's asking for
    MenuItem *item = self.menuItems[indexPath.row];
    
    // Set info for the cell
    [menuCell setMenuCellTitle:item.menuTitle];
    
    return menuCell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Check which item was tapped
    MenuItem *item = self.menuItems[indexPath.row];
    
    switch (item.screenType) {
        case ScreenTypeQuestion:
            // Go to question screen
            [self performSegueWithIdentifier:@"GoToQuestionsSegue" sender:self];
            break;
            
        case ScreenTypeStats:
            // Go to stats screen
            [self performSegueWithIdentifier:@"GoToStatsSegue" sender:self];
            break;
            
        case ScreenTypeAbout:
            // Go to about screen
            [self performSegueWithIdentifier:@"GoToAboutSegue" sender:self];
            break;
            
        case ScreenTypeRemoveAds:
            // Go to remove ads screen
            [self performSegueWithIdentifier:@"GoToRemoveAdsSegue" sender:self];
            break;
            
        default:
            break;
    }
}

#pragma mark Segue Methods

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Set the front view controller to be the destination one
    [self.revealViewController setFrontViewController:segue.destinationViewController];
    
    // Slide the front view controller back into place
    [self.revealViewController revealToggleAnimated:YES];
}

#pragma mark Button Methods

- (IBAction)ResetButtonTapped:(id)sender {
}

- (IBAction)RemoveAdsButtonTapped:(id)sender {
}

- (IBAction)VisitWebsiteButtonTapped:(id)sender {
}

@end
