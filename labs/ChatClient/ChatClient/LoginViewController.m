//
//  LoginViewController.m
//  ChatClient
//
//  Created by Minh Nguyen on 9/16/15.
//  Copyright (c) 2015 Minh Nguyen. All rights reserved.
//

#import "LoginViewController.h"

@interface LoginViewController ()
@property (weak, nonatomic) IBOutlet UITextField *emailField;
@property (weak, nonatomic) IBOutlet UITextField *passwordField;
@property (weak, nonatomic) IBOutlet UILabel *errorLabel;

@property (strong, nonatomic) PFUser *user;

@end

@implementation LoginViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)loginTapped:(id)sender {
    if (!self.validFields) {
        return;
    }
    
    [PFUser logInWithUsernameInBackground:self.emailField.text password:self.passwordField.text block:^(PFUser *user, NSError *error) {
            if (user) {
                // Do stuff after successful login.
                //NSLog(@"Login Ok");
                self.user = user;
                [self performSegueWithIdentifier:@"com.yahoo.login.success.segue" sender:self];
            } else {
                // The login failed. Check error to see why.
                NSString *errorString = [error userInfo][@"error"];   // Show the errorString somewhere and let the user try again.
                self.errorLabel.text = errorString;
            }
    }];
}

- (IBAction)signUpTapped:(id)sender {
    if (!self.validFields) {
        return;
    }
    
    PFUser * user = [[PFUser alloc] init];
    
    user.username = self.emailField.text;
    user.password = self.passwordField.text;
    
    [user signUpInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
        if (!error) {   // Hooray! Let them use the app now.
            self.user = user;
            [self performSegueWithIdentifier:@"com.yahoo.login.success.segue" sender:self];
        } else {
            NSString *errorString = [error userInfo][@"error"];   // Show the errorString somewhere and let the user try again.
            self.errorLabel.text = errorString;
        }
    }];
}

-(Boolean)validFields {
    if (self.emailField.text.length == 0 || self.passwordField.text.length == 0) {
        self.errorLabel.text = @"Username and Password are required.";
        return false;
    }
    
    return true;
}


#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([[segue identifier] isEqualToString:@"com.yahoo.login.success.segue"]) {
        // Get reference to the destination view controller
        UINavigationController *navController = (UINavigationController*)[segue destinationViewController];
        ChatViewController *vc = (ChatViewController*)[navController topViewController];
        [vc setUser:self.user];
    }
}


@end
