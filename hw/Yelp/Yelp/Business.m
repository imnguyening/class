//
//  Business.m
//  Yelp
//
//  Created by Minh Nguyen on 9/16/15.
//  Copyright (c) 2015 Minh Nguyen. All rights reserved.
//

#import "Business.h"

@interface Business ()



@end

@implementation Business

- (id)initWithDictionary:(NSDictionary *)dictionary {
    self = [super init];
    if (self) {
        //NSLog(@"%@", dictionary);
        NSArray *categories = dictionary[@"categories"];
        NSMutableArray *categoryNames = [NSMutableArray array];
        [categories enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
            [categoryNames addObject:obj[0]];
        }];
        self.categories = [categoryNames componentsJoinedByString:@", "];
        
        self.name = dictionary[@"name"];
        self.imageUrl = dictionary[@"image_url"];
        
        NSString *street = @"";
        NSArray *loc = [dictionary valueForKeyPath:@"location.address"];
        if (loc.count > 0) {
            street = [dictionary valueForKeyPath:@"location.address"][0];
        }
        //NSString *street = [dictionary valueForKeyPath:@"location.address"][0];
        NSString *neighborhood = [dictionary valueForKeyPath:@"location.neighborhoods"][0];
        self.address = (street.length > 0) ? [NSString stringWithFormat:@"%@, %@", street, neighborhood] : neighborhood;
        
        self.numReviews = [dictionary[@"review_count"] integerValue];
        self.ratingsImageUrl = dictionary[@"rating_img_url"];
        float milesPerMeter = 0.000621371;
        self.distance = [dictionary[@"distance"] integerValue] *milesPerMeter;
    }
    
    return self;
}

+ (NSArray *)businessWithDictionaries:(NSArray *)dictionaries {
    
    // You can register for Yelp API keys here: http://www.yelp.com/developers/manage_api_keys
    NSMutableArray *businesses = [[NSMutableArray alloc] init];
    for (NSDictionary *dict in dictionaries) {
        Business *business = [[Business alloc] initWithDictionary:dict];
        [businesses addObject:business];
    }
    
    return businesses;
}

@end
