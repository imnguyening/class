//
//  FiltersViewController.h
//  Yelp
//
//  Created by Minh Nguyen on 9/17/15.
//  Copyright (c) 2015 Minh Nguyen. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Filters.h"

#define FilterViewSavedNotification @"FilterViewSavedNotification"

@interface FiltersViewController : UIViewController <UITableViewDataSource, UITableViewDelegate>

@property (nonatomic, strong) Filters * filters;

@end
