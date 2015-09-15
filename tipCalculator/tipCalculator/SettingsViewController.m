//
//  SettingsViewController.m
//  tipCalculator
//
//  Created by Minh Nguyen on 9/14/15.
//  Copyright (c) 2015 Minh Nguyen. All rights reserved.
//

#import "SettingsViewController.h"

@interface SettingsViewController ()

@property (weak, nonatomic) IBOutlet UISegmentedControl *defaultTip;
- (IBAction)onTap:(id)sender;
@end

@implementation SettingsViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    int intVal = [defaults integerForKey:@"tip_default"];
    self.defaultTip.selectedSegmentIndex = intVal;
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)saveDefault {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setInteger:self.defaultTip.selectedSegmentIndex forKey:@"tip_default"];
    [defaults synchronize];
    
}

- (IBAction)onTap:(id)sender {
    [self saveDefault];
}
@end
