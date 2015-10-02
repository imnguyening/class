//
//  TweetTimeline.h
//  Twitter
//
//  Created by Minh Nguyen on 9/26/15.
//  Copyright (c) 2015 Minh Nguyen. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Tweet.h"
#import "User.h"
#import "TwitterClient.h"

@interface TweetTimeline : NSObject

+ (TweetTimeline *) sharedInstance;

- (void)homeTimelineWithParams:(NSDictionary *)params completion:(void (^)(TweetTimeline *timeline, NSError *error))completion;
- (void)userTimelineWithParams:(NSDictionary *)params completion:(void (^)(TweetTimeline *timeline, NSError *error))completion;
- (void)createTweetWithStatus:(NSString* )status completion:(void (^)(Tweet *tweet, NSError *error))completion;
- (void)updateRetweetForTweet:(Tweet *)tweet completion:(void (^)(Tweet *tweet, NSError *error))completion;
- (void)createTweetWithStatus:(NSString *)status inReplyToTweet:(Tweet*)tweet completion:(void (^)(Tweet *tweet, NSError *error))completion;
- (void)deleteTweet:(Tweet *)tweet completion:(void (^)(Tweet *tweet, NSError *error))completion;

- (void)updateFavoriteForTweet:(Tweet *)tweet completion:(void (^)(Tweet *tweet, NSError *error))completion;

- (NSArray *)getHomeTweets;
- (Tweet *)getHomeTweetAtIndex: (NSInteger)index;

- (NSArray *)getUserTweets;
- (Tweet *)getUserTweetAtIndex: (NSInteger)index;
@end
