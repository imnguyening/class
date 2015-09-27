//
//  NewTweetViewController.h
//  Twitter
//
//  Created by Minh Nguyen on 9/25/15.
//  Copyright (c) 2015 Minh Nguyen. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TweetTimeline.h"
#import "Tweet.h"
#import "User.h"

@interface NewTweetViewController : UIViewController <UITextViewDelegate>

@property (nonatomic, strong) Tweet *replyTweet;
@property (nonatomic, strong) Tweet *retweetTweet;

@end
