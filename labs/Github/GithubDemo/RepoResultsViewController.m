//
//  RepoResultsViewController.m
//  GithubDemo
//
//  Created by Nicholas Aiwazian on 9/15/15.
//  Copyright © 2015 codepath. All rights reserved.
//

#import "UIImageView+AFNetworking.h"
#import "RepoResultsViewController.h"
#import "MBProgressHUD.h"
#import "GithubRepo.h"
#import "GithubRepoSearchSettings.h"
#import "RepoTableViewCell.h"
#import "SettingsViewController.h"

@interface RepoResultsViewController ()
@property (weak, nonatomic) IBOutlet UITableView *myTableView;
@property (nonatomic, strong) UISearchBar *searchBar;
@property (nonatomic, strong) GithubRepoSearchSettings *searchSettings;
@property (nonatomic, strong) NSArray* repos;
@property (weak, nonatomic) IBOutlet UINavigationItem *settingsBtn;

@end

@implementation RepoResultsViewController


- (void)viewDidLoad {
    [super viewDidLoad];

    UINib *movieCellNib = [UINib nibWithNibName:@"RepoTableViewCell" bundle:nil];
    [self.myTableView registerNib:movieCellNib forCellReuseIdentifier:@"com.yahoo.repo.cell"];
    self.myTableView.estimatedRowHeight = 133;
    self.myTableView.rowHeight = UITableViewAutomaticDimension;

    self.searchSettings = [[GithubRepoSearchSettings alloc] init];
    self.searchBar = [[UISearchBar alloc] init];
    self.searchBar.delegate = self;
    [self.searchBar sizeToFit];
    self.navigationItem.titleView = self.searchBar;
    [self doSearch];
    
    self.navigationItem.backBarButtonItem =
    [[UIBarButtonItem alloc] initWithTitle:@"Cancel"
                                      style:UIBarButtonItemStylePlain
                                     target:nil
                                     action:nil];
    
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(receiveSettingsSavedNotification:) name:@"settingsSaved" object:nil];
    
}

- (void)doSearch {
    NSLog(@"Min Stars: %li", self.searchSettings.minStars);
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    [GithubRepo fetchRepos:self.searchSettings successCallback:^(NSArray *repos) {
        self.repos = repos;
        /*
        for (GithubRepo *repo in repos) {
            NSLog(@"%@", [NSString stringWithFormat:
                   @"Name:%@\n\tStars:%ld\n\tForks:%ld,Owner:%@\n\tAvatar:%@\n\tDescription:%@\n\t",
                          repo.name,
                          repo.stars,
                          repo.forks,
                          repo.ownerHandle,
                          repo.ownerAvatarURL,
                          repo.desc
                   ]);
        }*/
        [MBProgressHUD hideHUDForView:self.view animated:YES];
        [self.myTableView reloadData];
    }];
}

- (BOOL)searchBarShouldBeginEditing:(UISearchBar *)searchBar {
    [self.searchBar setShowsCancelButton:YES animated:YES];
    return YES;
}

- (BOOL)searchBarShouldEndEditing:(UISearchBar *)searchBar {
    [self.searchBar setShowsCancelButton:NO animated:YES];
    return YES;
}

- (void)searchBarCancelButtonClicked:(UISearchBar *)searchBar {
    searchBar.text = @"";
    [searchBar resignFirstResponder];
}

- (void) searchBarSearchButtonClicked:(UISearchBar *)searchBar {
    self.searchSettings.searchString = searchBar.text;
    [searchBar resignFirstResponder];
    [self doSearch];
}


#pragma mark - Navigation
- (IBAction)settingsTapped:(UIBarButtonItem *)sender {
    NSLog(@"settings");
    [self performSegueWithIdentifier:@"com.yahoo.repos.settings.segue" sender:self];
}
// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([[segue identifier] isEqualToString:@"com.yahoo.repos.settings.segue"]) {
        // Get reference to the destination view controller
        SettingsViewController *vc = [segue destinationViewController];
        
        [vc setSearchSettings:self.searchSettings];
    }
}


#pragma mark - UITableView
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.repos.count;
}


- (RepoTableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    RepoTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"com.yahoo.repo.cell"];
    
    GithubRepo * repo = self.repos[indexPath.row];
    
    [cell.userImage setImageWithURL:[NSURL URLWithString:repo.ownerAvatarURL]];
    
    cell.titleLabel.text = repo.name;
    cell.userLabel.text = [NSString stringWithFormat:@"By %@", repo.ownerHandle];
    cell.descLabel.text = repo.desc;
    cell.starLabel.text = [NSString stringWithFormat:@"%li", repo.stars];
    cell.forkLabel.text = [NSString stringWithFormat:@"%li", repo.forks];
    
    return cell;
}

#pragma mark - NSNotifications
- (void) receiveSettingsSavedNotification:(NSNotification *) notification
{
    [self doSearch];
}

@end
