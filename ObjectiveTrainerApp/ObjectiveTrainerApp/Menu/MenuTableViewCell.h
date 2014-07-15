//
//  MenuTableViewCell.h
//  ObjectiveTrainerApp
//
//  Created by Christopher Ching on 2014-07-10.
//  Copyright (c) 2014 CodeWithChris. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MenuTableViewCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UIImageView *progressImageView;
@property (weak, nonatomic) IBOutlet UILabel *sectionTitleLabel;
@property (weak, nonatomic) IBOutlet UILabel *scoreLabel;

- (void)setMenuCellTitle:(NSString*)title;

@end
