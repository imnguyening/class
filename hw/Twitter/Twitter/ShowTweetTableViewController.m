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
    self.tableView.allowsSelection = NO;
    
    self.tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    
    [self.fUserImage setImageWithURL:[NSURL URLWithString:self.tweet.user.profileImageUrl]];
    
    self.fUserName.text = self.tweet.user.name;
    self.fUserScreenName.text = [NSString stringWithFormat:@"@%@",self.tweet.user.screenName];
    self.fText.text = self.tweet.text;
    
    if (self.tweet.retweetedTweet == nil) {
        self.fRetweetImage.hidden = YES;
        self.fRetweetText.hidden = YES;
        self.fRetweetImageTopConstraint.constant = -24;
    } else {
        self.fRetweetText.text = [NSString stringWithFormat: @"%@ retweeted", self.tweet.retweetedTweet.user.name];
    }
    
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    
    [dateFormatter setTimeStyle:NSDateFormatterShortStyle];
    [dateFormatter setDateStyle:NSDateFormatterMediumStyle];
    
    [dateFormatter setLocale:[NSLocale currentLocale]];
    
    NSString *dateString = [dateFormatter stringFromDate:self.tweet.createdAt];
    
    self.fDate.text = dateString;
    
    self.sRetweetCount.text = [NSString stringWithFormat:@"%li", self.tweet.retweets];
    self.sFavoritesCount.text = [NSString stringWithFormat:@"%li", self.tweet.favorites];
    
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
    [[TweetTimeline sharedInstance] updateRetweetForTweet:self.tweet completion:^(Tweet *tweet, NSError *error) {
        if (tweet) {
            self.tweet = tweet;
            [self updateRetweetButtonAndText];
        } else {
            NSLog(@"Failed update retweet: %@", error);
        }
    }];
}

- (IBAction)favoritePressed:(id)sender {
    [[TweetTimeline sharedInstance] updateFavoriteForTweet:self.tweet completion:^(Tweet *tweet, NSError *error) {
        if (tweet) {
            self.tweet = tweet;
            [self updateFavoriteButtonAndText];
        } else {
            NSLog(@"Failed to update fav: %@", error);
        }
    }];
}

- (void)updateRetweetButtonAndText {
    if (self.tweet.retweeted == 1) {
        [self.tRetweetButton setImage:[UIImage imageNamed:@"retweet_on"] forState:UIControlStateNormal];
    } else {
        [self.tRetweetButton setImage:[UIImage imageNamed:@"retweet"] forState:UIControlStateNormal];
    }
    self.sRetweetCount.text = [NSString stringWithFormat:@"%li", self.tweet.retweets];
}

- (void)updateFavoriteButtonAndText {
    if (self.tweet.favorited == 1) {
        [self.tFavoriteButton setImage:[UIImage imageNamed:@"favorite_on"] forState:UIControlStateNormal];
    } else {
        [self.tFavoriteButton setImage:[UIImage imageNamed:@"favorite"] forState:UIControlStateNormal];
    }
    self.sFavoritesCount.text = [NSString stringWithFormat:@"%li", self.tweet.favorites];
}


#pragma mark - Navigation
 - (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
 // Get the new view controller using [segue destinationViewController].
 // Pass the selected object to the new view controller.
     if ([[segue identifier] isEqualToString:@"com.twitter.replytweet.segue"])
     {
         NewTweetViewController *vc = [segue destinationViewController];
         [vc setReplyTweet:self.tweet];
     }
 }

@end
