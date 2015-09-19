//
//  Filters.h
//  Yelp
//
//  Created by Minh Nguyen on 9/16/15.
//  Copyright (c) 2015 Minh Nguyen. All rights reserved.
//

#import <Foundation/Foundation.h>


#define FilterCategoriesArray [NSArray arrayWithObjects:@"afghani", @"newamerican", @"asianfusion", @"bbq", nil]
#define FilterCategoriesNamesArray [NSArray arrayWithObjects:@"Afghan", @"American, New", @"Asian Fusion", @"Barbeque", nil]

#define FiltersRadiusArray [NSArray arrayWithObjects: [NSNumber numberWithFloat:0], [NSNumber numberWithFloat:482.803f], [NSNumber numberWithFloat:1609.34f], [NSNumber numberWithFloat:8046.72f], [NSNumber numberWithFloat:40000.00f], nil]
#define FiltersDistanceNamesArray [NSArray arrayWithObjects:@"Auto", @".3 Miles", @"1 Mile", @"5 Miles", @"25 Miles", nil]

#define FiltersSortNamesArray [NSArray arrayWithObjects:@"Best Match",@"Distance",@"Highest Rated", nil]


@interface Filters : NSObject
//https://www.yelp.com/developers/documentation/v2/search_api

@property Boolean deals_filter;
@property float radius_filter; //The max value is 40000 meters (25 miles).
@property NSInteger sort; // 0=Best matched (default), 1=Distance, 2=Highest Rated.
// @property Boolean filterCategories;
@property NSInteger offset;
@property (nonatomic, strong) NSMutableArray *category_filter_array;

@property (nonatomic, strong) NSString *term;

@end
