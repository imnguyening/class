//
//  TomatoesViewController.m
//  RottenTomatoes
//
//  Created by Minh Nguyen on 9/14/15.
//  Copyright (c) 2015 Minh Nguyen. All rights reserved.
//

#import "TomatoesViewController.h"
#import "UIImageView+AFNetworking.h"
#import "TomatoesTableViewCell.h"
#import "TomatoesDetailsViewController.h"
#import "RTMoviesModel.h"

@interface TomatoesViewController ()

@property (strong, nonatomic) UIRefreshControl *refreshControl;
@property (strong, nonatomic) NSArray *movies;
@property NSInteger rowSelected;
@property Boolean networkError;

@end

@implementation TomatoesViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    UINib *movieCellNib = [UINib nibWithNibName:@"TomatoesTableViewCell" bundle:nil];
    [self.myTableView registerNib:movieCellNib forCellReuseIdentifier:@"com.yahoo.tomatoes.cell"];
    self.myTableView.rowHeight = 81;
    
    self.refreshControl = [[UIRefreshControl alloc] init];
    [self.refreshControl addTarget:self action:@selector(onRefresh) forControlEvents:UIControlEventValueChanged];
    [self.myTableView insertSubview:self.refreshControl atIndex:0];
    
    [self.navigationItem setTitle:@"Rotten Tomatoes"];
    
    NSURL *url = [NSURL URLWithString:@"https://gist.githubusercontent.com/timothy1ee/d1778ca5b944ed974db0/raw/489d812c7ceeec0ac15ab77bf7c47849f2d1eb2b/gistfile1.json"];
    NSURLRequest *request = [[NSURLRequest alloc] initWithURL:url];
    [NSURLConnection sendAsynchronousRequest:request queue:[NSOperationQueue mainQueue] completionHandler:^(NSURLResponse *response, NSData *data, NSError *connectionError) {
        if (connectionError == nil) {
            NSDictionary *responseDictionary = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
            self.movies = [responseDictionary objectForKey:@"movies"];
            self.networkError = false;
        } else {
            self.movies = [[NSArray alloc] init];
            self.networkError = true;
        }
        [self.myTableView reloadData];
        //NSLog(@"response: %@", responseDictionary);
    }];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

# pragma mark - UITableView
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.movies.count;
}

- (TomatoesTableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    TomatoesTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"com.yahoo.tomatoes.cell"];
    
    NSDictionary *dataDict = self.movies[indexPath.row];
    RTMoviesModel *movie = [[RTMoviesModel alloc] initWithData:dataDict];
    
    cell.descriptionLabel.lineBreakMode = NSLineBreakByTruncatingTail;
    
    [cell.posterImage setImageWithURL:movie.poster_url];
    cell.titleLabel.text = [NSString stringWithFormat:@"%@ (%@)", movie.title, movie.year];
    cell.subTitleLabel.text = [NSString stringWithFormat:@"Rated: %@", movie.mpaa_rating];
    cell.descriptionLabel.text = movie.synopsis;
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    self.rowSelected = indexPath.row;
    [self performSegueWithIdentifier:@"com.yahoo.tomatoes.details.segue" sender:self];
}

-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    if (self.networkError) {
        return 60.0;
    } else {
        return 0;
    }
}

-(UIView*)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    UITableViewCell* headerCell = [tableView dequeueReusableCellWithIdentifier:@"com.yahoo.tomatoes.header.cell"];
    return headerCell;
}

# pragma mark - Refresh
- (void)onRefresh {
    NSURL *url = [NSURL URLWithString:@"https://gist.githubusercontent.com/timothy1ee/d1778ca5b944ed974db0/raw/489d812c7ceeec0ac15ab77bf7c47849f2d1eb2b/gistfile1.json"];
    NSURLRequest *request = [[NSURLRequest alloc] initWithURL:url];
    [NSURLConnection sendAsynchronousRequest:request queue:[NSOperationQueue mainQueue] completionHandler:^(NSURLResponse *response, NSData *data, NSError *connectionError) {
        if (connectionError == nil) {
            NSDictionary *responseDictionary = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
            self.movies = [responseDictionary objectForKey:@"movies"];
            self.networkError = false;
        } else {
            self.movies = [[NSArray alloc] init];
            self.networkError = true;
        }
        [self.myTableView reloadData];
        [self.refreshControl endRefreshing];
    }];
}

#pragma mark - Segue
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([[segue identifier] isEqualToString:@"com.yahoo.tomatoes.details.segue"]) {
        // Get reference to the destination view controller
        TomatoesDetailsViewController *vc = [segue destinationViewController];
        
        // Pass any objects to the view controller here, like...
        //NSIndexPath *indexPath = [self.myTableView indexPathForCell:sender];
        
        NSDictionary *dataDict = self.movies[self.rowSelected];
        RTMoviesModel *movie = [[RTMoviesModel alloc] initWithData:dataDict];
        
        [vc setMovie:movie];
    }
}

@end
