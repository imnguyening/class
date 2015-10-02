//
//  TweetTimeline.m
//  Twitter
//
//  Created by Minh Nguyen on 9/26/15.
//  Copyright (c) 2015 Minh Nguyen. All rights reserved.
//

#import "TweetTimeline.h"

@interface TweetTimeline()

@property (nonatomic, strong) NSMutableArray *tweets;
@property (nonatomic, strong) NSMutableArray *userTweets;

@end

@implementation TweetTimeline

+ (TweetTimeline *) sharedInstance {
    static TweetTimeline* instance = nil;
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        if (instance == nil) {
            instance = [[TweetTimeline alloc] init];
        }
    });
    return instance;
}

- (void)homeTimelineWithParams:(NSDictionary *)params completion:(void (^)(TweetTimeline *timeline, NSError *error))completion {
    [[TwitterClient sharedInstance] homeTimelineWithParams:params completion:^(NSArray *tweets, NSError *error) {
        if (tweets != nil) {
            self.tweets = [NSMutableArray arrayWithArray:tweets];
            completion(self, nil);
        } else {
            completion(nil, error);
        }
    }];
}

- (void)userTimelineWithParams:(NSDictionary *)params completion:(void (^)(TweetTimeline *timeline, NSError *error))completion {
    [[TwitterClient sharedInstance] userTimelineWithParams:params completion:^(NSArray *tweets, NSError *error) {
        if (tweets != nil) {
            self.userTweets = [NSMutableArray arrayWithArray:tweets];
            completion(self, nil);
        } else {
            completion(nil, error);
        }
    }];
}

- (void)createTweetWithStatus:(NSString* )status completion:(void (^)(Tweet *tweet, NSError *error))completion {
    [[TwitterClient sharedInstance] updateStatusWithStatus:status completion:^(Tweet *tweet, NSError *error) {
        if (tweet != nil) {
            [self addTweet:tweet];
            completion(tweet,nil);
        } else {
            completion(nil, error);
        }
    }];
}

- (void)updateRetweetForTweet:(Tweet *)tweet completion:(void (^)(Tweet *tweet, NSError *error))completion {
    // Cannot retweet your own tweets
    User *user = [User currentUser];
    if ([tweet.user.screenName isEqualToString:user.screenName]) {
        completion(nil, [NSError errorWithDomain:@"com.twitter.error" code:403 userInfo:[[NSDictionary alloc] initWithObjectsAndKeys: @"cannot retweet your own tweets", @"error", nil]]);
        return;
    }
    
    if (tweet.retweeted == 0) {
        [[TwitterClient sharedInstance] retweetStatus:tweet.tweet_id completion:^(Tweet *myTweet, NSError *error) {
            if (tweet != nil) {
                tweet.retweeted = 1;
                [self updateTweet:tweet];
                [self addRetweet:myTweet];
                completion(tweet,nil);
            } else {
                completion(nil, error);
            }
        }];
    } else {
        //NSLog(@"removing reteweet for: %@", tweet.text);
        // Retrieve the tweet created for our retweet
        [[TwitterClient sharedInstance] getTweet:tweet.tweet_id completion:^(Tweet *tweet, NSError *error) {
            if (tweet && tweet.currentUserRetweet != nil) {
                Tweet *myTweet = tweet.currentUserRetweet;
                // Delete my tweet
                [[TwitterClient sharedInstance] destroyStatus:myTweet.tweet_id completion:^(Tweet *myTweet, NSError *error) {
                    if (myTweet) {
                        tweet.retweeted = 0;
                        [self updateTweet:tweet];
                        [self removeTweet:myTweet];
                        completion(tweet, nil);
                    } else {
                        completion(nil, error);
                    }
                }];
            } else {
                completion(nil, [NSError errorWithDomain:@"com.twitter.error" code:404 userInfo:[[NSDictionary alloc] initWithObjectsAndKeys:  @"currentUserRetweet not found", @"error", nil]]);
            }
        }];
    }
}

- (void)createTweetWithStatus:(NSString *)status inReplyToTweet:(Tweet*)tweet completion:(void (^)(Tweet *tweet, NSError *error))completion {
    [[TwitterClient sharedInstance] updateStatusWithStatus:status inReplyToStatus:tweet.tweet_id completion:^(Tweet *tweet, NSError *error) {
        if (tweet != nil) {
            [self addTweet:tweet];
            completion(tweet,nil);
        } else {
            completion(nil,error);
        }
    }];
}

- (void)deleteTweet:(Tweet *)tweet completion:(void (^)(Tweet *tweet, NSError *error))completion {
    [[TwitterClient sharedInstance] destroyStatus:tweet.tweet_id completion:^(Tweet *tweet, NSError *error) {
        if (tweet != nil) {
            [self removeTweet:tweet];
            completion(tweet,nil);
        } else {
            completion(nil, error);
        }
    }];
}


- (void)updateFavoriteForTweet:(Tweet *)tweet completion:(void (^)(Tweet *tweet, NSError *error))completion {
    if (tweet.favorited == 0) {
        [[TwitterClient sharedInstance] favoriteTweet:tweet.tweet_id  completion:^(Tweet *tweet, NSError *error) {
            if (tweet != nil) {
                [self updateTweet:tweet];
                completion(tweet,nil);
            } else {
                completion(nil, error);
            }
        }];
    } else {
        [[TwitterClient sharedInstance] unfavoriteTweet:tweet.tweet_id  completion:^(Tweet *tweet, NSError *error) {
            if (tweet != nil) {
                [self updateTweet:tweet];
                completion(tweet,nil);
            } else {
                completion(nil, error);
            }
        }];
    }
}

#pragma mark - NSMutableArray
- (NSArray *)getHomeTweets {
    return [NSArray arrayWithArray:self.tweets];
}

- (Tweet *)getHomeTweetAtIndex: (NSInteger)index {
    if (self.tweets[index]) {
        return self.tweets[index];
    }
    return nil;
}

- (NSArray *)getUserTweets {
    return [NSArray arrayWithArray:self.userTweets];
}

- (Tweet *)getUserTweetAtIndex: (NSInteger)index {
    if (self.userTweets[index]) {
        return self.userTweets[index];
    }
    return nil;
}

- (void)addTweet:(Tweet *)tweet {
    TweetTimeline *shared = [TweetTimeline sharedInstance];
    [shared.tweets insertObject:tweet atIndex:0];
    [shared.userTweets insertObject:tweet atIndex:0];
    [[NSNotificationCenter defaultCenter] postNotificationName:kNewTweetCreated object:nil];
    [[NSNotificationCenter defaultCenter] postNotificationName:kNewUserTweetCreated object:nil];
}

#pragma mark - sharedInstance
// Helper functions to update the current user's home and my timeline
- (void)addRetweet:(Tweet *)tweet {
    //NSLog(@"Adding user retweet");
    TweetTimeline *shared = [TweetTimeline sharedInstance];
    [shared.userTweets insertObject:tweet atIndex:0];
    [[NSNotificationCenter defaultCenter] postNotificationName:kNewUserTweetCreated object:nil];
}

- (void)updateTweet:(Tweet *)tweet {
    TweetTimeline *shared = [TweetTimeline sharedInstance];
    for (NSInteger i=0;i<shared.tweets.count;i++) {
        Tweet *myTweet = shared.tweets[i];
        if ([myTweet.tweet_id isEqualToString:tweet.tweet_id]) {
            //NSLog(@"Updating tweet at index %li", i);
            self.tweets[i] = tweet;
            [[NSNotificationCenter defaultCenter] postNotificationName:kTweetUpdated object:nil];
            break;
        } else if (myTweet.retweetedTweet != nil && [myTweet.retweetedTweet.tweet_id isEqualToString:tweet.tweet_id]) {
            //NSLog(@"Updating retweeted tweet at index %li", i);
            myTweet.retweetedTweet = tweet;
            [[NSNotificationCenter defaultCenter] postNotificationName:kTweetUpdated object:nil];
            break;
        }
    }
    
    for (NSInteger i=0;i<shared.userTweets.count;i++) {
        Tweet *myTweet = shared.userTweets[i];
        if ([myTweet.tweet_id isEqualToString:tweet.tweet_id]) {
            //NSLog(@"Updating user tweet at index %li", i);
            self.userTweets[i] = tweet;
            [[NSNotificationCenter defaultCenter] postNotificationName:kUserTweetUpdated object:nil];
            break;
        } else if (myTweet.retweetedTweet != nil && [myTweet.retweetedTweet.tweet_id isEqualToString:tweet.tweet_id]) {
            //NSLog(@"Updating user retweeted at index %li", i);
            myTweet.retweetedTweet = tweet;
            [[NSNotificationCenter defaultCenter] postNotificationName:kUserTweetUpdated object:nil];
            break;
        }
    }
}

- (void)removeTweet:(Tweet *)tweet {
    TweetTimeline *shared = [TweetTimeline sharedInstance];
    for (NSInteger i=0;i<shared.tweets.count;i++) {
        Tweet *myTweet = shared.tweets[i];
        if ([tweet.tweet_id isEqualToString:myTweet.tweet_id]) {
            //NSLog(@"Removing tweet at index %li", i);
            [self.tweets removeObjectAtIndex:i];
            [[NSNotificationCenter defaultCenter] postNotificationName:kTweetDeleted object:nil];
            break;
        }
    }
    
    for (NSInteger i=0;i<shared.userTweets.count;i++) {
        Tweet *myTweet = shared.userTweets[i];
        if ([tweet.tweet_id isEqualToString:myTweet.tweet_id]) {
            NSLog(@"Removing user tweet at index %li", i);
            [self.userTweets removeObjectAtIndex:i];
            [[NSNotificationCenter defaultCenter] postNotificationName:kUserTweetDeleted object:nil];
            break;
        }
    }
}


@end
