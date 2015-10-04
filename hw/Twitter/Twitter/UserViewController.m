//
//  ProfileViewController.m
//  Twitter
//
//  Created by Minh Nguyen on 9/30/15.
//  Copyright (c) 2015 Minh Nguyen. All rights reserved.
//

#import "UserViewController.h"
#import "UserTableViewHeader.h"
#import "UserTableViewHeaderView.h"
#import "UIImageView+AFNetworking.h"
#import "ShowTweetTableViewController.h"
#import "NewTweetViewController.h"
#import "SWRevealViewController.h"

NSInteger const kMaxUserTimelineCount = 500;

@interface UserViewController ()
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) UserTableViewHeaderView *headerView;
@property (nonatomic, strong) UIRefreshControl *refreshControl;
@property (nonatomic, assign) NSInteger rowSelected;
@property (nonatomic, strong) Tweet *replyTweet;
@property (nonatomic, assign) BOOL getMoreTweetsActive;

@property (nonatomic, assign) BOOL isCurrentUser;
@property (nonatomic, strong) TweetTimeline *userTimeline;

@end

@implementation UserViewController
- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    UserTableViewHeader *header = [[UserTableViewHeader alloc] initWithNibName:@"UserTableViewHeader" bundle:nil];
    self.headerView = (UserTableViewHeaderView *)header.view;
    self.tableView.tableHeaderView = self.headerView;

    self.getMoreTweetsActive = false;
    if (!self.user) {
        self.user = [User currentUser];
    }
    
    if ([[User currentUser].screenName isEqualToString:self.user.screenName]) {
        // Setup for current user
        self.isCurrentUser = true;
        self.userTimeline = [TweetTimeline sharedInstance];

        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(newUserTweetCreated) name:kNewUserTweetCreated object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(userTweetDeleted) name:kUserTweetDeleted object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(userTweetUpdated) name:kUserTweetUpdated object:nil];
        
        UIBarButtonItem *item = [[UIBarButtonItem alloc] initWithTitle:@"Menu" style:UIBarButtonItemStylePlain target:self action:nil];

        SWRevealViewController *revealViewController = self.revealViewController;
        if ( revealViewController )
        {
            [item setTarget: self.revealViewController];
            [item setAction: @selector( revealToggle: )];
        }
        [self.navigationItem setLeftBarButtonItem:item animated:NO];
    } else {
        [self setTitle: [NSString stringWithFormat:@"@%@", self.user.screenName]];
        self.userTimeline = [[TweetTimeline alloc] init];
        self.isCurrentUser = false;
    }
    
    if (self.user == nil) {
        [self showLoginScreen];
        return;
    } else {
        [self getTweets];
    }
    
    [self.tableView registerNib:[UINib nibWithNibName:@"TweetTableViewCell" bundle:nil] forCellReuseIdentifier:@"com.yahoo.tweet.cell"];
    self.tableView.estimatedRowHeight = 133;
    self.tableView.rowHeight = UITableViewAutomaticDimension;
    
    self.refreshControl = [[UIRefreshControl alloc]init];
    [self.tableView setContentOffset:CGPointMake(0, self.refreshControl.frame.size.height) animated:YES];
    [self.tableView addSubview:self.refreshControl];
    [self.refreshControl addTarget:self action:@selector(getTweets) forControlEvents:UIControlEventValueChanged];
    
    [self setupHeader];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    if (self.isCurrentUser) {
        SWRevealViewController *revealViewController = self.revealViewController;
        if ( revealViewController )
        {
            [self.view addGestureRecognizer:self.revealViewController.panGestureRecognizer];
        }
    }
}

-(void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    if (self.isCurrentUser) {
        SWRevealViewController *revealViewController = self.revealViewController;
        if ( revealViewController )
        {
            [self.view removeGestureRecognizer:self.revealViewController.panGestureRecognizer];
        }
    }
}

-(void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
    [self sizeHeaderToFit];
}

-(void)sizeHeaderToFit {
    UIView *header = self.tableView.tableHeaderView;
    [header setNeedsLayout];
    [header layoutIfNeeded];
    
    CGFloat height = [header systemLayoutSizeFittingSize:UILayoutFittingCompressedSize].height;
    CGRect frame = header.frame;
    frame.size.height = height;
    header.frame = frame;
    
    self.tableView.tableHeaderView = header;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - UITableView
-(void) setupHeader {
    self.headerView.userImage.layer.cornerRadius = 5.0;
    self.headerView.userImage.layer.borderColor = [[UIColor whiteColor] CGColor];
    self.headerView.userImage.layer.borderWidth = 2.0;
    self.headerView.userImage.layer.masksToBounds = YES;
    self.headerView.userImage.layer.zPosition = 100;
    
    [self.headerView.userImage setImageWithURL:[NSURL URLWithString:self.user.profileImageUrl]];
    [self.headerView.bannerImage setImageWithURL:[NSURL URLWithString:self.user.bannerImageUrl]];

    self.headerView.userName.text = self.user.name;
    self.headerView.userScreenName.text = [NSString stringWithFormat:@"@%@", self.user.screenName];
    self.headerView.tweetsLabel.text = self.user.tweetCount;
    self.headerView.followersLabel.text = self.user.followersCount;
    self.headerView.followingLabel.text = self.user.followingCount;
}

-(void) updateHeaderCounts {
    dispatch_async(dispatch_get_main_queue(), ^{
        //NSLog(@"Setup user count: %@", self.user.tweetCount);
        self.headerView.tweetsLabel.text = self.user.tweetCount;
        self.headerView.followersLabel.text = self.user.followersCount;
        self.headerView.followingLabel.text = self.user.followingCount;
    });
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if ([self.userTimeline getUserTweets].count) {
        NSLog(@"Count: %li", [self.userTimeline getUserTweets].count);
    }
    return [self.userTimeline getUserTweets].count;
}

- (TweetTableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    Tweet *tweet = [self.userTimeline getUserTweetAtIndex:indexPath.row];
    TweetTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier: @"com.yahoo.tweet.cell"];
    
    cell.tweet = tweet;
    cell.delegate = self;
    
    //Get more tweets if needed
    NSInteger currentCount = indexPath.row+1;
    if (currentCount == [self.userTimeline getUserTweets].count && self.getMoreTweetsActive == false && currentCount+20 < kMaxUserTimelineCount && currentCount < [self.user.tweetCount integerValue]) {
        [self getMoreTweets: currentCount+20];
    }
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    self.rowSelected = indexPath.row;
    [self performSegueWithIdentifier:@"com.twitter.user.show.tweet.segue" sender:self];
    [self.tableView deselectRowAtIndexPath:indexPath animated:YES];
}

- (void) newUserTweetCreated {
    if (self.isCurrentUser) {
        User *currentUser = [User currentUser];
        currentUser.tweetCount = [NSString stringWithFormat:@"%li",[currentUser.tweetCount integerValue] + 1];
        NSData *data = [NSJSONSerialization dataWithJSONObject:currentUser.dictionary options:0 error:nil];
        self.user = currentUser;
        [[NSUserDefaults standardUserDefaults] setObject:data forKey:kCurrentUserKey];
        [self updateHeaderCounts];
        [self.tableView reloadData];
    }
}

- (void) userTweetDeleted {
    if (self.isCurrentUser) {
        User *currentUser = [User currentUser];
        currentUser.tweetCount = [NSString stringWithFormat:@"%li",[currentUser.tweetCount integerValue] - 1];
        NSData *data = [NSJSONSerialization dataWithJSONObject:currentUser.dictionary options:0 error:nil];
        self.user = currentUser;
        [[NSUserDefaults standardUserDefaults] setObject:data forKey:kCurrentUserKey];
        [self updateHeaderCounts];
        [self.tableView reloadData];
    }
}

- (void) userTweetUpdated {
    if (self.isCurrentUser) {
        [self updateHeaderCounts];
        [self.tableView reloadData];
    }
}

- (void)reloadTable {
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.tableView reloadData];
    });
}

#pragma mark - TweetTableViewCell
- (void)replyToTweet:(Tweet *)tweet {
    self.replyTweet = tweet;
    [self performSegueWithIdentifier:@"com.twitter.user.reply.tweet.segue" sender:self];
}

- (void)viewUserProfile:(User *)user {
    User *currentUser = [User currentUser];
    
    if ([currentUser.screenName isEqualToString:user.screenName]) {
        [self shakeView];
    } else {
        UserViewController *vc = [self.storyboard instantiateViewControllerWithIdentifier:@"UserProfileScene"];
        vc.user = user;
        [self.navigationController pushViewController:vc animated:YES];
    }
}

#pragma mark - Actions
- (IBAction)tweetPressed:(UIBarButtonItem*)sender {
    [self performSegueWithIdentifier:@"com.twitter.user.tweet.segue" sender:self];
}

- (void)showLoginScreen {
    [self performSegueWithIdentifier:@"com.twitter.user.login.segue" sender:self];
}

- (void)getTweets {
    NSMutableDictionary *params = [NSMutableDictionary dictionaryWithDictionary:@{@"screen_name": [NSString stringWithFormat:@"%@",self.user.screenName]}];
    [self.userTimeline userTimelineWithParams:params completion:^(TweetTimeline *timeline, NSError *error) {
        if (timeline != nil) {
            if (self.isCurrentUser) {
                // Update counts for currentUser
                Tweet *tweet = [timeline getUserTweetAtIndex:0];
                
                if (tweet) {
                    User *updateUser = tweet.user;
                    self.user = updateUser;
                    
                    NSData *data = [NSJSONSerialization dataWithJSONObject:updateUser.dictionary options:0 error:nil];
                    [[NSUserDefaults standardUserDefaults] setObject:data forKey:kCurrentUserKey];
                }
                [self setupHeader];
            }
            [self.tableView reloadData];
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
        
        NSMutableDictionary *params = [NSMutableDictionary dictionaryWithDictionary:@{@"count": [NSString stringWithFormat:@"%li",count], @"screen_name": [NSString stringWithFormat:@"%@",self.user.screenName]}];
        [self.userTimeline userTimelineWithParams:params completion:^(TweetTimeline *timeline, NSError *error) {
            if (timeline != nil) {
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


#pragma mark - Navigation
// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
    if ([[segue identifier] isEqualToString:@"com.twitter.user.show.tweet.segue"])
    {
        ShowTweetTableViewController *vc = [segue destinationViewController];
        Tweet *tweet = [self.userTimeline getUserTweetAtIndex:self.rowSelected];
        [vc setTweet:tweet];
    } else if ([[segue identifier] isEqualToString:@"com.twitter.user.reply.tweet.segue"]) {
        NewTweetViewController *vc = [segue destinationViewController];
        [vc setReplyTweet:self.replyTweet];
    } else if ([[segue identifier] isEqualToString:@"com.twitter.user.tweet.segue"] && !self.isCurrentUser) {
        NewTweetViewController *vc = [segue destinationViewController];
        [vc setStatusText:[NSString stringWithFormat:@"@%@",self.user.screenName]];
    }
}

#pragma mark - Animations
-(void)shakeView {
    self.view.transform = CGAffineTransformMakeTranslation(-5, 0);
    [UIView animateWithDuration:0.4 delay:0.0 usingSpringWithDamping:0.3 initialSpringVelocity:.3 options:UIViewAnimationOptionCurveEaseInOut animations:^{
        self.view.transform = CGAffineTransformIdentity;
    } completion:nil];
}

-(void)dealloc {
    
}

@end
