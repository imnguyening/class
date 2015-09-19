//
//  Filters.m
//  Yelp
//
//  Created by Minh Nguyen on 9/16/15.
//  Copyright (c) 2015 Minh Nguyen. All rights reserved.
//

#import "Filters.h"

@implementation Filters

-(id)init {
    self.radius_filter = 0.0;
    self.deals_filter = false;
    //self.filterCategories = false;
    
    self.term = @"";
    self.sort = 0;
    self.offset = 0;
    self.category_filter_array = [NSMutableArray arrayWithObjects: [NSNumber numberWithBool:false], [NSNumber numberWithBool:false], [NSNumber numberWithBool:false], [NSNumber numberWithBool:false], nil];
    
    return self;
}

-(NSString* )description {
    return [NSString stringWithFormat:@"term: %@\nsort: %li\n", self.term, self.sort];
}

@end
