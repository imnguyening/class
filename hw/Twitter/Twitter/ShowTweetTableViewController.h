//
//  ShowTweetTableViewController.h
//  Twitter
//
//  Created by Minh Nguyen on 9/25/15.
//  Copyright (c) 2015 Minh Nguyen. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Tweet.h"
#import "TweetTimeline.h"

@interface ShowTweetTableViewController : UITableViewController

@property (nonatomic, strong) Tweet *tweet;

@end
