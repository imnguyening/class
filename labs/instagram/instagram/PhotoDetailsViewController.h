//
//  PhotoDetailsViewController.h
//  instagram
//
//  Created by Minh Nguyen on 9/14/15.
//  Copyright (c) 2015 Minh Nguyen. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface PhotoDetailsViewController : UIViewController

< UITableViewDelegate, UITableViewDataSource >
@property (strong, atomic) NSURL *url;
@property (weak, nonatomic) IBOutlet UITableView *myTableView;

@end
