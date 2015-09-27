//
//  TwitterClient.h
//  Twitter
//
//  Created by Minh Nguyen on 9/23/15.
//  Copyright (c) 2015 Minh Nguyen. All rights reserved.
//

#import <BDBOAuth1RequestOperationManager.h>
#import "User.h"
#import "Tweet.h"

@interface TwitterClient : BDBOAuth1RequestOperationManager

+ (TwitterClient *) sharedInstance;
- (void)loginWithCompletion:(void (^)(User *user, NSError *error))completion;
- (void)openURL:(NSURL *)url;

- (void)homeTimelineWithParams:(NSDictionary *)params completion:(void (^)(NSArray *tweets, NSError *error))completion;
- (void)getTweet:(NSString *)tweet_id completion:(void (^)(Tweet *tweet, NSError *error))completion;

- (void)updateStatusWithStatus:(NSString *)status completion:(void (^)(Tweet *tweet, NSError *error))completion;
- (void)updateStatusWithStatus:(NSString *)status inReplyToStatus:(NSString*)status_id completion:(void (^)(Tweet *tweet, NSError *error))completion;
- (void)retweetStatus:(NSString *)status_id completion:(void (^)(Tweet *tweet, NSError *error))completion;
- (void)destroyStatus:(NSString *)status_id completion:(void (^)(Tweet *tweet, NSError *error))completion;

- (void)favoriteTweet:(NSString *)status_id completion:(void (^)(Tweet *tweet, NSError *error))completion;
- (void)unfavoriteTweet:(NSString *)status_id completion:(void (^)(Tweet *tweet, NSError *error))completion;

@end
