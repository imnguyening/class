//
//  User.m
//  Twitter
//
//  Created by Minh Nguyen on 9/23/15.
//  Copyright (c) 2015 Minh Nguyen. All rights reserved.
//

#import "User.h"
#import "TwitterClient.h"

NSString *const kCurrentUserKey = @"kCurrentUserKey";
NSString *const kUserDidLoginNotification = @"kUserDidLoginNotification";
NSString *const kUserDidLogoutNotification = @"kUserDidLogoutNotification";

@interface User()

@end

@implementation User

static User *_currentUser = nil;

-(id)initWithDictionary:(NSDictionary *)dictionary {
    self = [super init];
    
    if (self) {
        self.dictionary = dictionary;
        self.name = dictionary[@"name"];
        self.screenName = dictionary[@"screen_name"];
        self.profileImageUrl = dictionary[@"profile_image_url"];
        self.bannerImageUrl = dictionary[@"profile_banner_url"];
        self.tagline = dictionary[@"description"];
        self.location = dictionary[@"location"];
        
        self.followersCount = [NSString stringWithFormat:@"%@", dictionary[@"followers_count"]];
        //self.followingCount = [NSString stringWithFormat:@"%@", dictionary[@"following"]];
        self.followingCount = [NSString stringWithFormat:@"%@", dictionary[@"friends_count"]];
        self.tweetCount = [NSString stringWithFormat:@"%@", dictionary[@"statuses_count"]];
    }
    
    return self;
}

+(User *)currentUser {
    if (_currentUser == nil) {
        NSData *data = [[NSUserDefaults standardUserDefaults] objectForKey:kCurrentUserKey];
        
        if (data != nil) {
            NSDictionary *dictionary = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
            _currentUser = [[User alloc] initWithDictionary:dictionary];
        }
    }
    
    return _currentUser;
}

+(void)setCurrentUser:(User *)currentUser {
    _currentUser = currentUser;
    
    if (currentUser != nil) {
        NSData *data = [NSJSONSerialization dataWithJSONObject:currentUser.dictionary options:0 error:nil];
        [[NSUserDefaults standardUserDefaults] setObject:data forKey:kCurrentUserKey];
        [[NSNotificationCenter defaultCenter] postNotificationName:kUserDidLoginNotification object:nil];
    } else {
        [[NSUserDefaults standardUserDefaults] setObject:nil forKey:kCurrentUserKey];
    }
    
    [[NSUserDefaults standardUserDefaults] synchronize];
}

+(void)logout {
    [User setCurrentUser:nil];
    [[TwitterClient sharedInstance].requestSerializer removeAccessToken];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:kUserDidLogoutNotification object:nil];
}

@end
