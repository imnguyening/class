//
//  SideMenuViewController.m
//  Twitter
//
//  Created by Minh Nguyen on 9/30/15.
//  Copyright (c) 2015 Minh Nguyen. All rights reserved.
//

#import "SideMenuViewController.h"
#import "SideMenuHeaderView.h"
#import "SWRevealViewController.h"
#import "HomeViewController.h"
#import "UIImageView+AFNetworking.h"
#import "User.h"

@interface SideMenuViewController ()
@property (weak, nonatomic) IBOutlet UITableView *tableView;

@end

@implementation SideMenuViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    SWRevealViewController *revealController = [self revealViewController];
    [revealController tapGestureRecognizer];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(showLoginScreen) name:kUserDidLogoutNotification object:nil];
    
    [self.tableView registerNib:[UINib nibWithNibName:@"SideMenuHeaderView" bundle:nil] forHeaderFooterViewReuseIdentifier:@"SideMenuHeaderView"];
    self.tableView.sectionHeaderHeight = UITableViewAutomaticDimension;
    self.tableView.estimatedSectionHeaderHeight = 88;
    self.tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self.tableView reloadData];
}

-(void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - UITableView
- (UITableViewHeaderFooterView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    SideMenuHeaderView *header = [tableView dequeueReusableHeaderFooterViewWithIdentifier:@"SideMenuHeaderView"];
    
    User *currentUser = [User currentUser];
    
    [header.userImage setImageWithURL:[NSURL URLWithString:currentUser.profileImageUrl]];
    header.userImage.layer.cornerRadius = 5.0;
    header.userImage.layer.masksToBounds = YES;
    
    header.userName.text = currentUser.name;
    header.userScreenName.text = [NSString stringWithFormat:@"@%@" ,currentUser.screenName];
    
    return header;
}


- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 3;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"cell"];//UITableViewCell(style: UITableViewCellStyle.Default, reuseIdentifier: cellIdentifier)
    
    switch (indexPath.row) {
        case 0:
            cell.textLabel.text = @"Home Timeline";
            break;
        case 1:
            cell.textLabel.text = @"My Timeline";
            break;
        case 2:
            cell.textLabel.text = @"Sign Out";
            break;
        default:
            break;
    }
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    switch (indexPath.row) {
        case 0:
            [self.revealViewController revealToggleAnimated:YES];
            [[NSNotificationCenter defaultCenter] postNotificationName:kShowHomeTab object:nil];
            break;
        case 1:
            [self.revealViewController revealToggleAnimated:YES];
            [[NSNotificationCenter defaultCenter] postNotificationName:kShowUserTab object:nil];
            break;
        case 2:
            [User logout];
            [self.revealViewController revealToggleAnimated:YES];
            break;
        default:
            break;
    }
    
    [self.tableView deselectRowAtIndexPath:indexPath animated:YES];
}

#pragma mark - Navigation
- (void)showLoginScreen {
    [self performSegueWithIdentifier:@"com.twitter.login.segue" sender:self];
}


// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}


@end
