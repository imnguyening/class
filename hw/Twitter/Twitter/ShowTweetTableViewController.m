//
//  ShowTweetTableViewController.m
//  Twitter
//
//  Created by Minh Nguyen on 9/25/15.
//  Copyright (c) 2015 Minh Nguyen. All rights reserved.
//

#import "ShowTweetTableViewController.h"
#import "NewTweetViewController.h"
#import "UIImageView+AFNetworking.h"

@interface ShowTweetTableViewController ()

@property (nonatomic, strong) Tweet *currentTweet;

// first cell
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *fRetweetImageTopConstraint;
@property (weak, nonatomic) IBOutlet UIImageView *fRetweetImage;
@property (weak, nonatomic) IBOutlet UILabel *fRetweetText;

@property (weak, nonatomic) IBOutlet UIImageView *fUserImage;
@property (weak, nonatomic) IBOutlet UILabel *fUserName;
@property (weak, nonatomic) IBOutlet UILabel *fUserScreenName;
@property (weak, nonatomic) IBOutlet UILabel *fText;
@property (weak, nonatomic) IBOutlet UILabel *fDate;

// second cell
@property (weak, nonatomic) IBOutlet UILabel *sRetweetCount;
@property (weak, nonatomic) IBOutlet UILabel *sFavoritesCount;

// third cell
@property (weak, nonatomic) IBOutlet UIButton *tReplyButton;
@property (weak, nonatomic) IBOutlet UIButton *tRetweetButton;
@property (weak, nonatomic) IBOutlet UIButton *tFavoriteButton;

@end

@implementation ShowTweetTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    _currentTweet = (self.tweet.retweetedTweet != nil) ? self.tweet.retweetedTweet : self.tweet;
    self.tableView.allowsSelection = NO;
    
    self.tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    
    [self.fUserImage setImageWithURL:[NSURL URLWithString:_currentTweet.user.profileImageUrl]];
    
    self.fUserName.text = _currentTweet.user.name;
    self.fUserScreenName.text = [NSString stringWithFormat:@"@%@",_currentTweet.user.screenName];
    self.fText.text = _currentTweet.text;
    
    if (_currentTweet.retweetedTweet == nil) {
        self.fRetweetImage.hidden = YES;
        self.fRetweetText.hidden = YES;
        self.fRetweetImageTopConstraint.constant = -24;
    } else {
        self.fRetweetText.text = [NSString stringWithFormat: @"%@ retweeted", _currentTweet.retweetedTweet.user.name];
    }
    
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    
    [dateFormatter setTimeStyle:NSDateFormatterShortStyle];
    [dateFormatter setDateStyle:NSDateFormatterMediumStyle];
    
    [dateFormatter setLocale:[NSLocale currentLocale]];
    
    NSString *dateString = [dateFormatter stringFromDate:_currentTweet.createdAt];
    
    self.fDate.text = dateString;
    
    self.sRetweetCount.text = [NSString stringWithFormat:@"%li", _currentTweet.retweets];
    self.sFavoritesCount.text = [NSString stringWithFormat:@"%li", _currentTweet.favorites];
    
    [self updateRetweetButtonAndText];
    [self updateFavoriteButtonAndText];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // Return the number of rows in the section.
    return 3;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return UITableViewAutomaticDimension;
}

-(CGFloat)tableView:(UITableView *)tableView estimatedHeightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 49;
}

# pragma mark - Actions
- (IBAction)replyPressed:(UIButton *)sender {
    [self performSegueWithIdentifier:@"com.twitter.replytweet.segue" sender:self];
}

- (IBAction)retweetPressed:(id)sender {
    // Cannot retweet your own tweets
    [[TweetTimeline sharedInstance] updateRetweetForTweet:_currentTweet completion:^(Tweet *tweet, NSError *error) {
        if (tweet) {
            _currentTweet = tweet;
            [self updateRetweetButtonAndText];
        } else {
            NSLog(@"Failed update retweet: %@", error);
        }
    }];
}

- (IBAction)favoritePressed:(id)sender {
    [[TweetTimeline sharedInstance] updateFavoriteForTweet:_currentTweet completion:^(Tweet *tweet, NSError *error) {
        if (tweet) {
            _currentTweet = tweet;
            [self updateFavoriteButtonAndText];
        } else {
            NSLog(@"Failed to update fav: %@", error);
        }
    }];
}

- (void)updateRetweetButtonAndText {
    if (_currentTweet.retweeted == 1) {
        [self.tRetweetButton setImage:[UIImage imageNamed:@"retweet_on"] forState:UIControlStateNormal];
    } else {
        [self.tRetweetButton setImage:[UIImage imageNamed:@"retweet"] forState:UIControlStateNormal];
    }
    self.sRetweetCount.text = [NSString stringWithFormat:@"%li", _currentTweet.retweets];
}

- (void)updateFavoriteButtonAndText {
    if (_currentTweet.favorited == 1) {
        [self.tFavoriteButton setImage:[UIImage imageNamed:@"favorite_on"] forState:UIControlStateNormal];
    } else {
        [self.tFavoriteButton setImage:[UIImage imageNamed:@"favorite"] forState:UIControlStateNormal];
    }
    self.sFavoritesCount.text = [NSString stringWithFormat:@"%li", _currentTweet.favorites];
}


#pragma mark - Navigation
 - (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
 // Get the new view controller using [segue destinationViewController].
 // Pass the selected object to the new view controller.
     if ([[segue identifier] isEqualToString:@"com.twitter.replytweet.segue"])
     {
         NewTweetViewController *vc = [segue destinationViewController];
         [vc setReplyTweet:_currentTweet];
     }
 }

@end
