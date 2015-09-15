//
//  TomatoesViewController.h
//  RottenTomatoes
//
//  Created by Minh Nguyen on 9/14/15.
//  Copyright (c) 2015 Minh Nguyen. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface TomatoesViewController : UIViewController

< UITableViewDelegate, UITableViewDataSource >
@property (weak, nonatomic) IBOutlet UITableView *myTableView;

@end

