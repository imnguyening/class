//
//  TweetViewController.m
//  Twitter
//
//  Created by Minh Nguyen on 9/23/15.
//  Copyright (c) 2015 Minh Nguyen. All rights reserved.
//

#import "TweetsViewController.h"
#import "UIImageView+AFNetworking.h"
#import "ShowTweetTableViewController.h"
#import "NewTweetViewController.h"

NSInteger const kMaxTimelineCount = 200;

@interface TweetsViewController ()

@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (nonatomic, strong) UIRefreshControl *refreshControl;
@property (nonatomic, assign) NSInteger rowSelected;
@property (nonatomic, strong) Tweet *replyTweet;
@property (nonatomic, assign) BOOL getMoreTweetsActive;

@end

@implementation TweetsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.getMoreTweetsActive = false;
    
    // Do any additional setup after loading the view, typically from a nib.
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(reloadTable) name:kTweetUpdated object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(reloadTable) name:kNewTweetCreated object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(getTweets) name:kUserDidLoginNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(showLoginScreen) name:kUserDidLogoutNotification object:nil];
    
    [self.tableView registerNib:[UINib nibWithNibName:@"TweetTableViewCell" bundle:nil] forCellReuseIdentifier:@"com.yahoo.tweet.cell"];
    self.tableView.estimatedRowHeight = 133;
    self.tableView.rowHeight = UITableViewAutomaticDimension;
    
    self.refreshControl = [[UIRefreshControl alloc]init];
    [self.tableView setContentOffset:CGPointMake(0, self.refreshControl.frame.size.height) animated:YES];
    [self.tableView addSubview:self.refreshControl];
    [self.refreshControl addTarget:self action:@selector(getTweets) forControlEvents:UIControlEventValueChanged];
    
    User *user = [User currentUser];
    
    if (user == nil) {
        [self showLoginScreen];
    } else {
        [self getTweets];
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - UITableView
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if ([[TweetTimeline sharedInstance] getTweets].count) {
        NSLog(@"Count: %li", [[TweetTimeline sharedInstance] getTweets].count);
    }
    return [[TweetTimeline sharedInstance] getTweets].count;
}

- (TweetTableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    Tweet *tweet = [[TweetTimeline sharedInstance] getTweetAtIndex:indexPath.row];
    TweetTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier: @"com.yahoo.tweet.cell"];
    
    cell.tweet = tweet;
    cell.delegate = self;
    
    NSInteger currentCount = indexPath.row+1;
    if (currentCount == [[TweetTimeline sharedInstance] getTweets].count && self.getMoreTweetsActive == false && currentCount+20 < kMaxTimelineCount) {
        [self getMoreTweets: currentCount+20];
    }
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    self.rowSelected = indexPath.row;
    [self performSegueWithIdentifier:@"com.twitter.showtweet.segue" sender:self];
    [self.tableView deselectRowAtIndexPath:indexPath animated:YES];
}

- (void)reloadTable {
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.tableView reloadData];
    });
}

#pragma mark - TweetTableViewCell
- (void)replyToTweet:(Tweet *)tweet {
    self.replyTweet = tweet;
    [self performSegueWithIdentifier:@"com.twitter.mainreplytweet.segue" sender:self];
}

#pragma mark - Actions
- (void)getTweets {
    [[TweetTimeline sharedInstance] homeTimelineWithParams:nil completion:^(TweetTimeline *timeline, NSError *error) {
        if (timeline != nil) {
            //for (Tweet * tweet in tweets) {
            //NSLog(@"%@",tweet.text);
            //}
            
            [self reloadTable];
        } else {
            NSLog(@"Error retrieving timeline %@", error);
        }
        [self.refreshControl endRefreshing];
    }];
}

- (void)getMoreTweets:(NSInteger)count {
    if (self.getMoreTweetsActive == false) {
        self.getMoreTweetsActive = true;
        UIView *tableFooterView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 320, 50)];
        UIActivityIndicatorView *loadingView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
        [loadingView startAnimating];
        loadingView.center = tableFooterView.center;
        [tableFooterView addSubview:loadingView];
        self.tableView.tableFooterView = tableFooterView;
        
        NSMutableDictionary *params = [NSMutableDictionary dictionaryWithDictionary:@{@"count": [NSString stringWithFormat:@"%li",count]}];
        [[TweetTimeline sharedInstance] homeTimelineWithParams:params completion:^(TweetTimeline *timeline, NSError *error) {
            if (timeline != nil) {
                //for (Tweet * tweet in tweets) {
                //NSLog(@"%@",tweet.text);
                //}
                [self reloadTable];
            } else {
                NSLog(@"Error retrieving timeline %@", error);
            }
            dispatch_async(dispatch_get_main_queue(), ^{
                self.tableView.tableFooterView = nil;
            });
            self.getMoreTweetsActive = false;
        }];
    }
}

- (IBAction)newPressed:(UIBarButtonItem *)sender {
    [self performSegueWithIdentifier:@"com.twitter.newtweet.segue" sender:self];
}

- (void)showLoginScreen {
    [self performSegueWithIdentifier:@"com.twitter.login.segue" sender:self];
}

- (IBAction)onSignout:(id)sender {
    [User logout];
}

#pragma mark - Navigation
 // In a storyboard-based application, you will often want to do a little preparation before navigation

 - (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
 // Get the new view controller using [segue destinationViewController].
 // Pass the selected object to the new view controller.
 
     if ([[segue identifier] isEqualToString:@"com.twitter.showtweet.segue"])
     {
         ShowTweetTableViewController *vc = [segue destinationViewController];
         Tweet *tweet = [[TweetTimeline sharedInstance] getTweetAtIndex:self.rowSelected];
         [vc setTweet:tweet];
     } else if ([[segue identifier] isEqualToString:@"com.twitter.mainreplytweet.segue"]) {
         NewTweetViewController *vc = [segue destinationViewController];
         [vc setReplyTweet:self.replyTweet];
     }
     
 }

@end
