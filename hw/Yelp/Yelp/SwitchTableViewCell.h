//
//  SwitchTableViewCell.h
//  Yelp
//
//  Created by Minh Nguyen on 9/17/15.
//  Copyright (c) 2015 Minh Nguyen. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SwitchTableViewCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UILabel *nameLabel;
@property (weak, nonatomic) IBOutlet UISwitch *settingSwitch;

@end
