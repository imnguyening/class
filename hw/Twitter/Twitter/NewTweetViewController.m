//
//  NewTweetViewController.m
//  Twitter
//
//  Created by Minh Nguyen on 9/25/15.
//  Copyright (c) 2015 Minh Nguyen. All rights reserved.
//

#import "NewTweetViewController.h"
#import "UIImageView+AFNetworking.h"

@interface NewTweetViewController ()
@property (weak, nonatomic) IBOutlet UIImageView *userImage;
@property (weak, nonatomic) IBOutlet UILabel *userName;
@property (weak, nonatomic) IBOutlet UILabel *userScreenName;
@property (weak, nonatomic) IBOutlet UITextView *tweetText;
@property (weak, nonatomic) IBOutlet UILabel *characterCount;

@end

@implementation NewTweetViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    User *user = [User currentUser];
    
    [self.userImage setImageWithURL:[NSURL URLWithString:user.profileImageUrl]];
    
    self.userName.text = user.name;
    self.userScreenName.text = [NSString stringWithFormat:@"@%@", user.screenName];
        
    if (self.replyTweet != nil) {
        self.tweetText.text = [NSString stringWithFormat:@"@%@ ", self.replyTweet.user.screenName];
        self.characterCount.text = [NSString stringWithFormat: @"%li", kMaxCharacterCount - self.tweetText.text.length];
    } else if (self.statusText != nil) {
        self.tweetText.text = [NSString stringWithFormat:@"%@ ", self.statusText];
        self.characterCount.text = [NSString stringWithFormat: @"%li", kMaxCharacterCount - self.tweetText.text.length];
    }

    self.tweetText.delegate = self;
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    [self.tweetText becomeFirstResponder];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (IBAction)sendTweet:(UIBarButtonItem *)sender {
    NSLog(@"tweeting");
    if (self.replyTweet != nil) {
        [[TweetTimeline sharedInstance] createTweetWithStatus:self.tweetText.text inReplyToTweet:self.replyTweet completion:^(Tweet *tweet, NSError *error) {
            if (tweet != nil) {
                [self.navigationController popToRootViewControllerAnimated:YES];
            } else {
                NSLog(@"Reply Tweet Error: %@", error);
            }
        }];
    } else {    
        [[TweetTimeline sharedInstance] createTweetWithStatus:self.tweetText.text completion:^(Tweet *tweet, NSError *error) {
            if (tweet != nil) {
                [self.navigationController popViewControllerAnimated:YES];
            } else {
                NSLog(@"Tweet Error: %@", error);
            }
        }];
    }
}

#pragma mark - UITextView
- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text {
    if (textView.text.length >= kMaxCharacterCount && text.length > 0) {
        return NO;
    }
    return YES;
}

- (void)textViewDidChange:(UITextView *)textView {
    if (self.tweetText.text.length > kMaxCharacterCount) {
        self.tweetText.text = [self.tweetText.text substringToIndex:kMaxCharacterCount];
    }
    
    self.characterCount.text = [NSString stringWithFormat: @"%li", kMaxCharacterCount - textView.text.length];
}

#pragma mark - Buttons

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
