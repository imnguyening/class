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

@interface TweetTableViewCell()

@property (nonatomic, strong) Tweet *currentTweet;

@end

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
    _currentTweet = (_tweet.retweetedTweet != nil) ? _tweet.retweetedTweet : _tweet;
    
    [self.userImage setImageWithURL:[NSURL URLWithString:_currentTweet.user.profileImageUrl]];
    self.userImage.layer.cornerRadius = 5.0;
    self.userImage.layer.masksToBounds = YES;
    self.userImage.userInteractionEnabled = YES;
    
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(userImagePressed)];
    [self.userImage addGestureRecognizer:tap];
    
    self.userName.text = _currentTweet.user.name;
    self.userScreenName.text = [NSString stringWithFormat:@"@%@", _currentTweet.user.screenName];
    self.text.text = _currentTweet.text;
    
    int seconds = -(int)[_currentTweet.createdAt timeIntervalSinceNow];
    int hours = seconds/3600;
    int days = hours/24;
    
    if (hours < 1) {
        int minutes = seconds/60;
        self.timeSince.text = [NSString stringWithFormat:@"%im", minutes];
    } else if (hours < 24) {
        self.timeSince.text = [NSString stringWithFormat:@"%ih", hours];
    } else {
        /*NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
         
         [dateFormatter setTimeStyle:NSDateFormatterShortStyle];
         [dateFormatter setDateStyle:NSDateFormatterMediumStyle];
         
         [dateFormatter setLocale:[NSLocale currentLocale]];
         
         NSString *dateString = [dateFormatter stringFromDate:_tweet.createdAt];
         self.timeSince.text = [NSString stringWithFormat:@"%@", dateString];*/
        self.timeSince.text = [NSString stringWithFormat:@"%id", days];
    }
    
    if (_tweet.retweetedTweet != nil) {
        self.retweetedImage.image = [UIImage imageNamed:@"retweet"];
        User *user = [User currentUser];
        if ([user.screenName isEqualToString:_tweet.user.screenName]) {
            self.retweetedUserName.text = @"You retweeted";
        } else {
            self.retweetedUserName.text = [NSString stringWithFormat: @"%@ retweeted", _tweet.user.name];
        }
    } else {
        if (_tweet.inReplyToScreenName != nil) {
            //typically for your replies?
            self.retweetedImage.image = [UIImage imageNamed:@"reply"];
            self.retweetedUserName.text = [NSString stringWithFormat: @"In reply to @%@", _tweet.inReplyToScreenName];
        } else {
            self.retweetedImage.hidden = YES;
            self.retweetedUserName.hidden = YES;
            self.retweetedImageVerticalConstraint.constant = -24;
        }
    }
    
    [self updateRetweetButton];
    [self updateFavoriteButton];
}

- (void)updateRetweetButton {
    if (_currentTweet.retweeted == 1) {
        [self.retweetButton setImage:[UIImage imageNamed:@"retweet_on"] forState:UIControlStateNormal];
    } else {
        [self.retweetButton setImage:[UIImage imageNamed:@"retweet"] forState:UIControlStateNormal];
    }
}

- (void)updateFavoriteButton {

    if (_currentTweet.favorited == 1) {
        [self.favoriteButton setImage:[UIImage imageNamed:@"favorite_on"] forState:UIControlStateNormal];
    } else {
        [self.favoriteButton setImage:[UIImage imageNamed:@"favorite"] forState:UIControlStateNormal];
    }
}

- (void)userImagePressed {    
    if ([self.delegate respondsToSelector:@selector(viewUserProfile:)]) {
        [self.delegate viewUserProfile:_currentTweet.user];
    }
}

- (IBAction)replyPressed:(UIButton *)sender {
    if ([self.delegate respondsToSelector:@selector(replyToTweet:)]) {
        [self.delegate replyToTweet:_currentTweet];
    }
}

- (IBAction)retweetPressed:(UIButton *)sender {
    [[TweetTimeline sharedInstance] updateRetweetForTweet:_currentTweet completion:^(Tweet *tweet, NSError *error) {
        if (tweet) {
            _currentTweet = tweet;
            [self updateRetweetButton];
        } else {
            NSLog(@"Failed update retweet: %@", error);
        }
    }];
}
- (IBAction)favoritePressed:(UIButton *)sender {
    [[TweetTimeline sharedInstance] updateFavoriteForTweet:_currentTweet completion:^(Tweet *tweet, NSError *error) {
        if (tweet) {
            _currentTweet = tweet;
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
