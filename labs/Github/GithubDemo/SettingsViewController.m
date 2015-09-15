//
//  SettingsViewController.m
//  GithubDemo
//
//  Created by Minh Nguyen on 9/15/15.
//  Copyright (c) 2015 codepath. All rights reserved.
//

#import "SettingsViewController.h"

@interface SettingsViewController ()
@property (weak, nonatomic) IBOutlet UISlider *starsSlider;
@property (weak, nonatomic) IBOutlet UILabel *starsLabel;

@property (nonatomic) int stepValue;

@end

@implementation SettingsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self.navigationItem setTitle:@"Settings"];
    
    self.stepValue = 1.0;
    self.starsSlider.value = self.searchSettings.minStars;
    self.starsLabel.text = [NSString stringWithFormat:@"%li",self.searchSettings.minStars];
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

#pragma mark - UISlider
-(IBAction)valueChanged:(id)sender {
    // This determines which "step" the slider should be on. Here we're taking
    //   the current position of the slider and dividing by the `self.stepValue`
    //   to determine approximately which step we are on. Then we round to get to
    //   find which step we are closest to.
    float newStep = roundf((self.starsSlider.value) / self.stepValue);
    
    // Convert "steps" back to the context of the sliders values.
    self.starsSlider.value = newStep * self.stepValue;
    self.starsLabel.text = [NSString stringWithFormat:@"%i", (int)self.starsSlider.value];
}

#pragma mark - Save
- (IBAction)saveTapped:(UIBarButtonItem *)sender {
    self.searchSettings.minStars = self.starsSlider.value;
    [[NSNotificationCenter defaultCenter]
     postNotificationName:@"settingsSaved"
     object:self];
    [self.navigationController popViewControllerAnimated:YES];
}

@end
