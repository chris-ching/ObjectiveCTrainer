//
//  MenuModel.m
//  ObjectiveTrainerApp
//
//  Created by Christopher Ching on 2014-03-29.
//  Copyright (c) 2014 CodeWithChris. All rights reserved.
//

#import "MenuModel.h"
#import "MenuItem.h"

@implementation MenuModel

#pragma mark Retrieve Menu Items

- (NSArray *)getMenuItems
{
    NSMutableArray *menuItemArray = [[NSMutableArray alloc] init];
    
    MenuItem *item1 = [[MenuItem alloc] init];
    item1.menuTitle = @"Easy";
    item1.menuIcon = @"EasyMenuIcon";
    item1.screenType = ScreenTypeQuestion;
    [menuItemArray addObject:item1];
    
    MenuItem *item2 = [[MenuItem alloc] init];
    item2.menuTitle = @"Medium";
    item2.menuIcon = @"MediumMenuIcon";
    item2.screenType = ScreenTypeQuestion;
    [menuItemArray addObject:item2];
    
    MenuItem *item3 = [[MenuItem alloc] init];
    item3.menuTitle = @"Hard";
    item3.menuIcon = @"HardMenuIcon";
    item3.screenType = ScreenTypeQuestion;
    [menuItemArray addObject:item3];
    
    return menuItemArray;
}

@end
