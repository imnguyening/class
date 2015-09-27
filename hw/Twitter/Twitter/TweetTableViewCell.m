//
//  TweetTableViewself.m
//  Twitter
//
//  Created by Minh Nguyen on 9/23/15.
//  Copyright (c) 2015 Minh Nguyen. All rights reserved.
//

#import "TweetTableViewCell.h"
#import "TweetTimeline.h"
#import "UIImageView+AFNetworking.h"

@implementation TweetTableViewCell

- (void)awakeFromNib {
    // Initialization code
}

- (void)setTweet:(Tweet *)tweet
{
    _tweet = tweet;
    [self setupCell];
}

- (void)setupCell {
    [self.userImage setImageWithURL:[NSURL URLWithString:_tweet.user.profileImageUrl]];
    
    self.userName.text = _tweet.user.name;
    self.userScreenName.text = [NSString stringWithFormat:@"@%@", _tweet.user.screenName];
    self.text.text = _tweet.text;
    
    if (_tweet.retweetedTweet == nil) {
        self.retweetedImage.hidden = YES;
        self.retweetedUserName.hidden = YES;
        self.retweetedImageVerticalConstraint.constant = -24;
    } else {
        self.retweetedUserName.text = [NSString stringWithFormat: @"%@ retweeted", _tweet.retweetedTweet.user.name];
    }
    
    int seconds = -(int)[_tweet.createdAt timeIntervalSinceNow];
    int hours = seconds/3600;
    
    if (hours < 1) {
        int minutes = seconds/60;
        self.timeSince.text = [NSString stringWithFormat:@"%im", minutes];
    } else if (hours < 24) {
        self.timeSince.text = [NSString stringWithFormat:@"%ih", hours];
    } else {
        NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
        
        [dateFormatter setTimeStyle:NSDateFormatterShortStyle];
        [dateFormatter setDateStyle:NSDateFormatterMediumStyle];
        
        [dateFormatter setLocale:[NSLocale currentLocale]];
        
        NSString *dateString = [dateFormatter stringFromDate:_tweet.createdAt];
        self.timeSince.text = [NSString stringWithFormat:@"%@", dateString];
    }
    
    [self updateRetweetButton];
    [self updateFavoriteButton];
}

- (void)updateRetweetButton {
    if (_tweet.retweeted == 1) {
        [self.retweetButton setImage:[UIImage imageNamed:@"retweet_on"] forState:UIControlStateNormal];
    } else {
        [self.retweetButton setImage:[UIImage imageNamed:@"retweet"] forState:UIControlStateNormal];
    }
}

- (void)updateFavoriteButton {
    if (_tweet.favorited == 1) {
        [self.favoriteButton setImage:[UIImage imageNamed:@"favorite_on"] forState:UIControlStateNormal];
    } else {
        [self.favoriteButton setImage:[UIImage imageNamed:@"favorite"] forState:UIControlStateNormal];
    }
}

- (IBAction)replyPressed:(UIButton *)sender {
    if ([self.delegate respondsToSelector:@selector(replyToTweet:)]) {
        [self.delegate replyToTweet:_tweet];
    }
}
- (IBAction)retweetPressed:(UIButton *)sender {
    [[TweetTimeline sharedInstance] updateRetweetForTweet:_tweet completion:^(Tweet *tweet, NSError *error) {
        if (tweet) {
            _tweet = tweet;
            [self updateRetweetButton];
        } else {
            NSLog(@"Failed update retweet: %@", error);
        }
    }];
}
- (IBAction)favoritePressed:(UIButton *)sender {
    [[TweetTimeline sharedInstance] updateFavoriteForTweet:_tweet completion:^(Tweet *tweet, NSError *error) {
        if (tweet) {
            _tweet = tweet;
            [self updateFavoriteButton];
        } else {
            NSLog(@"Failed to update fav: %@", error);
        }
    }];
}

/*
- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}*/

@end
