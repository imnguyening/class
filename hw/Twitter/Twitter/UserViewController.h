//
//  ProfileViewController.h
//  Twitter
//
//  Created by Minh Nguyen on 9/30/15.
//  Copyright (c) 2015 Minh Nguyen. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TweetTableViewCell.h"
#import "User.h"
#import "Tweet.h"
#import "TweetTimeline.h"

@interface UserViewController : UIViewController <UITableViewDataSource, UITableViewDelegate, TweetTableViewCellDelegate>

@property (nonatomic, strong) User *user;

@end
