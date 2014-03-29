//
//  MenuItem.h
//  ObjectiveTrainerApp
//
//  Created by Christopher Ching on 2014-03-29.
//  Copyright (c) 2014 CodeWithChris. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface MenuItem : NSObject

@property (strong, nonatomic) NSString *menuTitle;
@property (strong, nonatomic) NSString *menuIcon;
@property (nonatomic) int screenType;

@end
