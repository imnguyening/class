//
//  TweetViewController.m
//  Twitter
//
//  Created by Minh Nguyen on 9/23/15.
//  Copyright (c) 2015 Minh Nguyen. All rights reserved.
//

#import "HomeViewController.h"
#import "UIImageView+AFNetworking.h"
#import "ShowTweetTableViewController.h"
#import "NewTweetViewController.h"
#import "SWRevealViewController.h"

NSInteger const kMaxTimelineCount = 200;
NSString * const kShowHomeTab = @"kShowHomeTab";
NSString * const kShowUserTab = @"kShowUserTab";

@interface HomeViewController ()

@property (weak, nonatomic) IBOutlet UIBarButtonItem *menuButton;
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (nonatomic, strong) UIRefreshControl *refreshControl;
@property (nonatomic, assign) NSInteger rowSelected;
@property (nonatomic, strong) Tweet *replyTweet;
@property (nonatomic, strong) User *userToView;
@property (nonatomic, assign) BOOL getMoreTweetsActive;

//@property (nonatomic, strong) UITapGestureRecognizer *closeRevealTap;

@end

@implementation HomeViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    SWRevealViewController *revealViewController = self.revealViewController;
    if ( revealViewController )
    {
        [self.menuButton setTarget: self.revealViewController];
        [self.menuButton setAction: @selector( revealToggle: )];
        
        self.revealViewController.rearViewRevealWidth = 300;
    }
    
    self.getMoreTweetsActive = false;
    
    // Do any additional setup after loading the view, typically from a nib.
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(reloadTable) name:kNewTweetCreated object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(reloadTable) name:kTweetUpdated object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(reloadTable) name:kTweetDeleted object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(getTweets) name:kUserDidLoginNotification object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(showHomeTab) name:kShowHomeTab object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(showUserTab) name:kShowUserTab object:nil];
    
    [self.tableView registerNib:[UINib nibWithNibName:@"TweetTableViewCell" bundle:nil] forCellReuseIdentifier:@"com.yahoo.tweet.cell"];
    self.tableView.estimatedRowHeight = 133;
    self.tableView.rowHeight = UITableViewAutomaticDimension;
    
    self.refreshControl = [[UIRefreshControl alloc]init];
    [self.tableView setContentOffset:CGPointMake(0, self.refreshControl.frame.size.height) animated:YES];
    [self.tableView addSubview:self.refreshControl];
    [self.refreshControl addTarget:self action:@selector(refreshCurrentUser) forControlEvents:UIControlEventValueChanged];
    
    User *user = [User currentUser];
    
    if (user == nil) {
        [self showLoginScreen];
    } else {
        [self refreshCurrentUser];
    }
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    SWRevealViewController *revealViewController = self.revealViewController;
    if ( revealViewController )
    {
        [self.view addGestureRecognizer:self.revealViewController.panGestureRecognizer];
    }
    
}

-(void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    SWRevealViewController *revealViewController = self.revealViewController;
    if ( revealViewController )
    {
        [self.view removeGestureRecognizer:self.revealViewController.panGestureRecognizer];
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - UITableView
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if ([[TweetTimeline sharedInstance] getHomeTweets].count) {
        NSLog(@"Count: %li", [[TweetTimeline sharedInstance] getHomeTweets].count);
    }
    return [[TweetTimeline sharedInstance] getHomeTweets].count;
}

- (TweetTableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    Tweet *tweet = [[TweetTimeline sharedInstance] getHomeTweetAtIndex:indexPath.row];
    TweetTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier: @"com.yahoo.tweet.cell"];
    
    cell.tweet = tweet;
    cell.delegate = self;
    
    //Get more tweets if needed
    NSInteger currentCount = indexPath.row+1;
    if (currentCount == [[TweetTimeline sharedInstance] getHomeTweets].count && self.getMoreTweetsActive == false && currentCount+20 < kMaxTimelineCount) {
        [self getMoreTweets: currentCount+20];
    }
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    self.rowSelected = indexPath.row;
    [self performSegueWithIdentifier:@"com.twitter.home.show.tweet.segue" sender:self];
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
    [self performSegueWithIdentifier:@"com.twitter.home.reply.tweet.segue" sender:self];
}

- (void)viewUserProfile:(User *)user {
    User *currentUser = [User currentUser];
    
    if ([currentUser.screenName isEqualToString:user.screenName]) {
        [self showUserTab];
    } else {
        self.userToView = user;
        [self performSegueWithIdentifier:@"com.twitter.home.user.segue" sender:self];
    }
}

#pragma mark - Actions
- (void)refreshCurrentUser {
    User *user = [User currentUser];
    NSMutableDictionary *params = [NSMutableDictionary dictionaryWithDictionary:@{@"screen_name": [NSString stringWithFormat:@"%@", user.screenName], @"count": @"1"}];
    [[TweetTimeline sharedInstance] userTimelineWithParams:params completion:^(TweetTimeline *timeline, NSError *error) {
        if (timeline != nil) {
            Tweet *tweet = [timeline getUserTweetAtIndex:0];
            
            if (tweet) {
                User *updateUser = tweet.user;
                [User setCurrentUser:updateUser]; // This will trigger getTweets via kUserDidLoginNotification
            }
        } else {
            NSLog(@"Error retrieving timeline %@", error);
        }
        [self.refreshControl endRefreshing];
    }];
}

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
    [self performSegueWithIdentifier:@"com.twitter.home.tweet.segue" sender:self];
}

- (void)showLoginScreen {
    [self performSegueWithIdentifier:@"com.twitter.home.login.segue" sender:self];
}

- (void)showHomeTab {
    [self.tabBarController setSelectedIndex:0];
}

- (void)showUserTab {
    [self.tabBarController setSelectedIndex:1];
}

#pragma mark - Navigation
 // In a storyboard-based application, you will often want to do a little preparation before navigation

 - (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
 // Get the new view controller using [segue destinationViewController].
 // Pass the selected object to the new view controller.
 
     if ([[segue identifier] isEqualToString:@"com.twitter.home.show.tweet.segue"])
     {
         ShowTweetTableViewController *vc = [segue destinationViewController];
         Tweet *tweet = [[TweetTimeline sharedInstance] getHomeTweetAtIndex:self.rowSelected];
         [vc setTweet:tweet];
     } else if ([[segue identifier] isEqualToString:@"com.twitter.home.reply.tweet.segue"]) {
         NewTweetViewController *vc = [segue destinationViewController];
         [vc setReplyTweet:self.replyTweet];
     } else if ([[segue identifier] isEqualToString:@"com.twitter.home.user.segue"]) {
         UserViewController *vc = [segue destinationViewController];
         [vc setUser:self.userToView];
     }
     
 }

@end
