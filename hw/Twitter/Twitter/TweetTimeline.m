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
- (NSArray *)getTweets {
    return [NSArray arrayWithArray:self.tweets];
}

- (Tweet *)getTweetAtIndex: (NSInteger)index {
    return self.tweets[index];
}

- (void)addTweet:(Tweet *)tweet {
    [self.tweets insertObject:tweet atIndex:0];
    [[NSNotificationCenter defaultCenter] postNotificationName:kNewTweetCreated object:nil];
}

- (void)updateTweet:(Tweet *)tweet {
    for (NSInteger i=0;i<self.tweets.count;i++) {
        Tweet *myTweet = self.tweets[i];
        if ([tweet.tweet_id isEqualToString:myTweet.tweet_id]) {
            //NSLog(@"Updating tweet at index %li", i);
            self.tweets[i] = tweet;
            [[NSNotificationCenter defaultCenter] postNotificationName:kTweetUpdated object:nil];
            break;
        }
    }
}

- (void)removeTweet:(Tweet *)tweet {
    for (NSInteger i=0;i<self.tweets.count;i++) {
        Tweet *myTweet = self.tweets[i];
        if ([tweet.tweet_id isEqualToString:myTweet.tweet_id]) {
            NSLog(@"Removing tweet at index %li", i);
            [self.tweets removeObjectAtIndex:i];
            [[NSNotificationCenter defaultCenter] postNotificationName:kTweetDeleted object:nil];
            break;
        }
    }
}


@end
