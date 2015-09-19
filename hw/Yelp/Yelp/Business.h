//
//  Business.h
//  Yelp
//
//  Created by Minh Nguyen on 9/16/15.
//  Copyright (c) 2015 Minh Nguyen. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Business : NSObject

//@property (nonatomic, strong) YelpClient *client;
@property (nonatomic, strong) NSString *address;
@property (nonatomic, assign) float distance;
@property (nonatomic, strong) NSString *categories;
@property (nonatomic, strong) NSString *name;
@property (nonatomic, assign) NSInteger numReviews;

@property (nonatomic, strong) NSString *imageUrl;
@property (nonatomic, strong) NSString *ratingsImageUrl;


+ (NSArray *)businessWithDictionaries:(NSArray *)dictionaries;
- (id)initWithDictionary:(NSDictionary *)dictionary;

@end
