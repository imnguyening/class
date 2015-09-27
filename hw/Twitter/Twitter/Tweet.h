//
//  Tweet.h
//  Twitter
//
//  Created by Minh Nguyen on 9/23/15.
//  Copyright (c) 2015 Minh Nguyen. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "User.h"

extern NSString *const kNewTweetCreated;
extern NSString *const kTweetDeleted;
extern NSString *const kTweetUpdated;
extern NSInteger const kMaxCharacterCount;

@interface Tweet : NSObject

@property (nonatomic, strong) NSString *tweet_id;
@property (nonatomic, strong) NSString *text;
@property (nonatomic, strong) NSDate *createdAt;
@property (nonatomic, strong) User *user;

@property (nonatomic, assign) NSInteger favorited;
@property (nonatomic, assign) NSInteger retweeted;
@property (nonatomic, assign) NSInteger favorites;
@property (nonatomic, assign) NSInteger retweets;

// Embedded tweets
@property (nonatomic, strong) Tweet *quotedTweet;
@property (nonatomic, strong) Tweet *retweetedTweet;
@property (nonatomic, strong) Tweet *currentUserRetweet;

-(id)initWithDictionary:(NSDictionary *)dictionary;

+(NSArray *)tweetsWithArray:(NSArray *) array;

@end
