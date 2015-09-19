//
//  YelpTableViewCell.h
//  Yelp
//
//  Created by Minh Nguyen on 9/16/15.
//  Copyright (c) 2015 Minh Nguyen. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Business.h"
#import "UIImageView+AFNetworking.h"

@interface YelpTableViewCell : UITableViewCell
@property (nonatomic, strong) Business *business;

@property (weak, nonatomic) IBOutlet UILabel *nameLabel;
@property (weak, nonatomic) IBOutlet UILabel *distanceLabel;
@property (weak, nonatomic) IBOutlet UILabel *reviewsLabel;
@property (weak, nonatomic) IBOutlet UILabel *addressLabel;
@property (weak, nonatomic) IBOutlet UILabel *categoriesLabel;

@property (weak, nonatomic) IBOutlet UIImageView *businessImage;
@property (weak, nonatomic) IBOutlet UIImageView *ratingsImage;

@end
