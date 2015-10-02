//
//  Tweet.m
//  Twitter
//
//  Created by Minh Nguyen on 9/23/15.
//  Copyright (c) 2015 Minh Nguyen. All rights reserved.
//

#import "Tweet.h"
#import "TwitterClient.h"

NSString *const kNewTweetCreated = @"kNewTweetCreated";
NSString *const kTweetDeleted = @"kTweetDeleted";
NSString *const kTweetUpdated = @"kTweetUpdated";

NSString *const kNewUserTweetCreated = @"kNewUserTweetCreated";
NSString *const kUserTweetDeleted = @"kUserTweetDeleted";
NSString *const kUserTweetUpdated = @"kUserTweetUpdated";

NSInteger const kMaxCharacterCount = 140;

@implementation Tweet

-(id)initWithDictionary:(NSDictionary *)dictionary {
    self = [super init];
    
    if (self) {
        self.tweet_id = [NSString stringWithFormat:@"%@", dictionary[@"id"]]; //NSString is utterly stupid
        self.text = dictionary[@"text"];
        self.user = [[User alloc] initWithDictionary:dictionary[@"user"]];
        self.favorited = [dictionary[@"favorited"] integerValue];
        self.retweeted = [dictionary[@"retweeted"] integerValue];
        self.favorites = [dictionary[@"favorite_count"] integerValue];
        self.retweets = [dictionary[@"retweet_count"] integerValue];
        
        if (dictionary[@"in_reply_to_screen_name"] != nil && ![[NSString stringWithFormat:@"%@", dictionary[@"in_reply_to_screen_name"]] isEqualToString:@"<null>"]) {
            self.inReplyToScreenName = [NSString stringWithFormat:@"%@", dictionary[@"in_reply_to_screen_name"]];
        }
        
        if (dictionary[@"quoted_status"] != nil) {
            self.quotedTweet = [[Tweet alloc] initWithDictionary:dictionary[@"quoted_status"]];
        }

        if (dictionary[@"retweeted_status"] != nil) {
            self.retweetedTweet = [[Tweet alloc] initWithDictionary:dictionary[@"retweeted_status"]];
        }

        if (dictionary[@"current_user_retweet"] != nil) {
            self.currentUserRetweet = [[Tweet alloc] initWithDictionary:dictionary[@"current_user_retweet"]];
        }
        
        NSString *createdAt = dictionary[@"created_at"];
        NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
        formatter.dateFormat = @"EEE MMM d HH:mm:ss Z y";
        
        self.createdAt = [formatter dateFromString:createdAt];
    }
    
    return self;
}

+(NSArray *)tweetsWithArray:(NSArray *) array {
    NSMutableArray *tweets = [NSMutableArray array];
    
    for (NSDictionary *dictionary in array) {
        Tweet *tweet = [[Tweet alloc] initWithDictionary:dictionary];
        
        [tweets addObject:tweet];
    }
    
    return tweets;
}

-(NSString *)description {
    return [NSString stringWithFormat:@"id: %@\nuser: %@\ntext: %@\n", self.tweet_id, self.user.screenName, self.text];
}

@end
