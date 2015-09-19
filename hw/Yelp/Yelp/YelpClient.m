//
//  YelpClient.m
//  Yelp
//
//  Created by Timothy Lee on 3/21/14.
//  Copyright (c) 2014 codepath. All rights reserved.
//

#import "YelpClient.h"

@implementation YelpClient

- (id)initWithConsumerKey:(NSString *)consumerKey consumerSecret:(NSString *)consumerSecret accessToken:(NSString *)accessToken accessSecret:(NSString *)accessSecret {
    NSURL *baseURL = [NSURL URLWithString:@"http://api.yelp.com/v2/"];
    self = [super initWithBaseURL:baseURL consumerKey:consumerKey consumerSecret:consumerSecret];
    if (self) {
        BDBOAuthToken *token = [BDBOAuthToken tokenWithToken:accessToken secret:accessSecret expiration:nil];
        [self.requestSerializer saveAccessToken:token];
    }
    return self;
}

- (AFHTTPRequestOperation *)searchWithFilters:(Filters *)filters success:(void (^)(AFHTTPRequestOperation *operation, id response))success failure:(void (^)(AFHTTPRequestOperation *operation, NSError *error))failure {
    
    // For additional parameters, see http://www.yelp.com/developers/documentation/v2/search_api
    NSDictionary *parameters = @{@"sort": [NSString stringWithFormat:@"%li", filters.sort], @"term": filters.term, @"ll" : @"37.774866,-122.394556"};
    NSMutableDictionary *mutableDictionary = [parameters mutableCopy];

    if (filters.radius_filter > 0) {
        mutableDictionary[@"radius_filter"] = [NSString stringWithFormat:@"%i", (int)filters.radius_filter];
    }
    
    if (filters.deals_filter) {
        mutableDictionary[@"deals_filter"] = [NSString stringWithFormat:@"1"];
    }
    
    NSMutableArray *categoryFilters = [[NSMutableArray alloc] init];
    NSArray *categories = FilterCategoriesArray;
    int i;
    for (i=0;i<filters.category_filter_array.count;i++) {
        if ([filters.category_filter_array[i] boolValue] == true) {
            [categoryFilters addObject:categories[i]];
        }
    }
    if (categoryFilters.count > 0) {
        NSString *categoryString = [categoryFilters componentsJoinedByString:@","];
        mutableDictionary[@"category_filter"] = categoryString;
    }
    
    if(filters.offset > 0) {
        mutableDictionary[@"offset"] = [NSString stringWithFormat:@"%i", (int)filters.offset];
    }
    
    //NSLog(@"radius: %@", mutableDictionary[@"radius_filter"]);
    //NSLog(@"categories: %@", mutableDictionary[@"category_filter"]);
    return [self GET:@"search" parameters:mutableDictionary success:success failure:failure];
}

@end
