//
//  RTMoviesModel.m
//  RottenTomatoes
//
//  Created by Minh Nguyen on 9/14/15.
//  Copyright (c) 2015 Minh Nguyen. All rights reserved.
//

#import "RTMoviesModel.h"

@interface RTMoviesModel ()

@end

@implementation RTMoviesModel

-(RTMoviesModel*) initWithData:(NSDictionary*) data {
    self.title = data[@"title"];
    self.synopsis = data[@"synopsis"];
    self.year = data[@"year"];
    self.runtime = data[@"runtime"];
    self.mpaa_rating = data[@"mpaa_rating"];
    self.release_theater = data[@"release_dates"][@"theater"];
    NSString *poster_url = data[@"posters"][@"original"];
    self.poster_url = [[NSURL alloc] initWithString:poster_url];
    
    return self;
}

@end
