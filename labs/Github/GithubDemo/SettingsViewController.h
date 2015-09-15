//
//  SettingsViewController.h
//  GithubDemo
//
//  Created by Minh Nguyen on 9/15/15.
//  Copyright (c) 2015 codepath. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GithubRepoSearchSettings.h"

@interface SettingsViewController : UIViewController

@property (nonatomic, strong) GithubRepoSearchSettings *searchSettings;

@end
