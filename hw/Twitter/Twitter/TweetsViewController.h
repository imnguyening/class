//
//  TweetViewController.h
//  Twitter
//
//  Created by Minh Nguyen on 9/23/15.
//  Copyright (c) 2015 Minh Nguyen. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TweetTableViewCell.h"
#import "User.h"
#import "Tweet.h"
#import "TweetTimeline.h"

@interface TweetsViewController : UIViewController <UITableViewDataSource, UITableViewDelegate, TweetTableViewCellDelegate>

@end

