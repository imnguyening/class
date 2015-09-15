//
//  PhotoDetailsViewController.m
//  instagram
//
//  Created by Minh Nguyen on 9/14/15.
//  Copyright (c) 2015 Minh Nguyen. All rights reserved.
//

#import "UIImageView+AFNetworking.h"
#import "PhotoDetailsViewController.h"
#import "PhotoDetailTableViewCell.h"

@implementation PhotoDetailsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.myTableView.rowHeight = 320;
    NSLog(@"url: %@", self.url);
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    NSLog(@"numberOfRowsInSection");
    return 1;
    
}

- (PhotoDetailTableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    PhotoDetailTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"com.yahoo.detail.photo.cell"];
        
    [cell.myPhotoView setImageWithURL:self.url];
    return cell;
}


@end
