//
//  YelpTableViewCell.m
//  Yelp
//
//  Created by Minh Nguyen on 9/16/15.
//  Copyright (c) 2015 Minh Nguyen. All rights reserved.
//

#import "YelpTableViewCell.h"

@implementation YelpTableViewCell

- (void)awakeFromNib {
    // Initialization code
}

- (void)setBusiness:(Business *)business
{
    _business = business;
    [self updateBusiness];
}

// Could not get dynamic height to work with this function
- (void)updateBusiness
{
    [self.businessImage setImageWithURL:[NSURL URLWithString:_business.imageUrl]];
    [self.ratingsImage setImageWithURL:[NSURL URLWithString:_business.ratingsImageUrl]];
    
    self.businessImage.layer.cornerRadius = 5;
    self.businessImage.clipsToBounds = YES;
    
    self.nameLabel.text = _business.name;
    self.categoriesLabel.text = _business.categories;
    self.addressLabel.text = _business.address;
    self.distanceLabel.text = [NSString stringWithFormat:@"%.02f mi",_business.distance];
    self.reviewsLabel.text = [NSString stringWithFormat:@"Reviews: %li", _business.numReviews];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
