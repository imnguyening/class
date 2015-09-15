//
//  ViewController.m
//  tipCalculator
//
//  Created by Minh Nguyen on 9/14/15.
//  Copyright (c) 2015 Minh Nguyen. All rights reserved.
//

#import "ViewController.h"
#import "SettingsViewController.h"

@interface ViewController ()
@property (weak, nonatomic) IBOutlet UITextField *billTextField;
@property (weak, nonatomic) IBOutlet UILabel *tipLabel;
@property (weak, nonatomic) IBOutlet UILabel *totalLabel;
@property (weak, nonatomic) IBOutlet UISegmentedControl *amountSegment;

- (IBAction)onTap:(id)sender;
- (void)updateValues;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    [self updateValues];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Settings" style:UIBarButtonItemStylePlain target:self action:@selector(onSettingsButton)];
}

- (void)viewWillAppear:(BOOL)animated {
    NSLog(@"view will appear");
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    int intVal = [defaults integerForKey:@"tip_default"];
    self.amountSegment.selectedSegmentIndex = intVal;
    
}

- (void)onSettingsButton {
    [self.navigationController pushViewController:[[SettingsViewController alloc] init] animated:YES];
}

- (IBAction)onTap:(id)sender {
    [self.view endEditing:YES];
    [self updateValues];
}

- (void)updateValues {
    float billAmount = [self.billTextField.text floatValue];
    NSArray *tipValues = @[@(0.1), @(0.15), @(0.2)];
    float tipAmount = billAmount * [tipValues[self.amountSegment.selectedSegmentIndex] floatValue];
    float totalAmount = tipAmount + billAmount;
    
    self.tipLabel.text = [NSString stringWithFormat:@"$%0.2f",tipAmount];
    self.totalLabel.text = [NSString stringWithFormat:@"$%0.2f",totalAmount];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
