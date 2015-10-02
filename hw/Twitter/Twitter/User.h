//
//  User.h
//  Twitter
//
//  Created by Minh Nguyen on 9/23/15.
//  Copyright (c) 2015 Minh Nguyen. All rights reserved.
//

#import <Foundation/Foundation.h>

extern NSString * const kCurrentUserKey;
extern NSString * const kUserDidLoginNotification;
extern NSString * const kUserDidLogoutNotification;

@interface User : NSObject

@property (nonatomic, strong) NSString *name;
@property (nonatomic, strong) NSString *screenName;
@property (nonatomic, strong) NSString *profileImageUrl;
@property (nonatomic, strong) NSString *bannerImageUrl;
@property (nonatomic, strong) NSString *tagline;
@property (nonatomic, strong) NSString *location;

@property (nonatomic, strong) NSString *followingCount;
@property (nonatomic, strong) NSString *followersCount;
@property (nonatomic, strong) NSString *tweetCount;

-(id)initWithDictionary:(NSDictionary *)dictionary;
@property (nonatomic,strong) NSDictionary *dictionary;

+(User *)currentUser;
+(void)setCurrentUser:(User *)currentUser;
+(void)logout;

@end
