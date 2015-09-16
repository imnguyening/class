//
//  ChatViewController.m
//  ChatClient
//
//  Created by Minh Nguyen on 9/16/15.
//  Copyright (c) 2015 Minh Nguyen. All rights reserved.
//

#import "ChatViewController.h"

@interface ChatViewController ()
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet UITextField *messageField;

@property (nonatomic, strong) NSArray *messages;

@end

@implementation ChatViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.tableView.rowHeight = UITableViewAutomaticDimension;
    self.tableView.estimatedRowHeight = UITableViewAutomaticDimension;
    // Do any additional setup after loading the view.
    [self fetchMessages];
    [NSTimer scheduledTimerWithTimeInterval:5 target:self selector:@selector(fetchMessages) userInfo:nil repeats:true];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
#pragma mark - UI

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [textField resignFirstResponder];
    [self sendMessage:self];
    return NO;
}

- (IBAction)sendMessage:(id)sender {
    if (self.messageField.text.length != 0) {
        PFObject *message = [PFObject objectWithClassName:@"Message"];
        message[@"text"] = self.messageField.text;
        message[@"user"] = self.user;
        
        [message saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
            if (succeeded) {
                // The object has been saved.
                NSLog(@"Message Sent");
                dispatch_async(dispatch_get_main_queue(), ^{
                    self.messageField.text = @"";
                    [self.messageField resignFirstResponder];
                });
                [self fetchMessages];
            } else {
                // There was a problem, check error.description
                NSLog(@"Error: %@", error.description);
            }
        }];
    }
}

- (void)fetchMessages {
    //NSLog(@"fetching");
    PFQuery * query = [[PFQuery alloc] initWithClassName:@"Message"];
    [query orderByDescending:@"createdAt"];
    [query includeKey:@"user"];
    //[query whereKey:@"user" equalTo:self.user];
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        if (!error) {
            dispatch_async(dispatch_get_main_queue(), ^{
                self.messages = objects;
                [self.tableView reloadData];
            });
        } else {
            
        }
    }];
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

#pragma mark - UITableView
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return self.messages.count;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue2 reuseIdentifier:nil];
    PFObject *msg = self.messages[indexPath.row];
    PFUser *user = msg[@"user"];
    NSString *username = @"";
    if (user) {
        username = user[@"username"];
    }
    //NSLog(@"%@", msg);
    if (username.length > 0) {
        cell.detailTextLabel.text = [NSString stringWithFormat:@"%@", msg[@"text"]];
        cell.textLabel.text = username;
    } else {
        cell.detailTextLabel.text = msg[@"text"];
        cell.textLabel.text = @"Anonymous";
    }
    
    return cell;
}

@end
