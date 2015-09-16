//
//  ChatViewController.h
//  ChatClient
//
//  Created by Minh Nguyen on 9/16/15.
//  Copyright (c) 2015 Minh Nguyen. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Parse/Parse.h>

@interface ChatViewController : UIViewController <UITableViewDataSource, UITableViewDelegate>

@property (nonatomic, strong) PFUser* user;

@end
