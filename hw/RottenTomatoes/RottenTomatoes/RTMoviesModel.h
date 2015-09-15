//
//  RTMoviesModel.h
//  RottenTomatoes
//
//  Created by Minh Nguyen on 9/14/15.
//  Copyright (c) 2015 Minh Nguyen. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface RTMoviesModel : NSObject

-(RTMoviesModel*) initWithData:(NSDictionary*) data;

@property (strong, nonatomic) NSString* title;
@property (strong, nonatomic) NSString* synopsis;
@property (strong, nonatomic) NSString* year;
@property (strong, nonatomic) NSString* runtime;
@property (strong, nonatomic) NSString* mpaa_rating;
@property (strong, nonatomic) NSString* release_theater;
@property (strong, nonatomic) NSURL* poster_url;

@end
