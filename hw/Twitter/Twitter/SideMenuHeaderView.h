//
//  SideMenuHeaderView.h
//  Twitter
//
//  Created by Minh Nguyen on 10/1/15.
//  Copyright (c) 2015 Minh Nguyen. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SideMenuHeaderView : UITableViewHeaderFooterView
@property (weak, nonatomic) IBOutlet UIImageView *userImage;
@property (weak, nonatomic) IBOutlet UILabel *userName;
@property (weak, nonatomic) IBOutlet UILabel *userScreenName;

@end
