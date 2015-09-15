//
//  PhotoViewController.m
//  instagram
//
//  Created by Minh Nguyen on 9/14/15.
//  Copyright (c) 2015 Minh Nguyen. All rights reserved.
//

#import "PhotoViewController.h"
#import "UIImageView+AFNetworking.h"
#import "PhotoTableViewCell.h"
#import "PhotoDetailsViewController.h"

@interface PhotoViewController ()
@property (weak, nonatomic) IBOutlet UITableView *myTableView;
@property (strong, atomic) NSArray *responseData;
@property (nonatomic, strong) UIRefreshControl *refreshControl;
@property NSInteger rowSelected;

@end


@implementation PhotoViewController

-(void)viewDidLoad {
    [super viewDidLoad];
    //UINib *movieCellNib = [UINib nibWithNibName:@"com.yahoo.photo.cell" bundle:nil];
    //[self.myTableView registerNib:movieCellNib forCellReuseIdentifier:@"com.yahoo.photo.cell"];
    
    self.myTableView.rowHeight = 320;
    
    self.refreshControl = [[UIRefreshControl alloc] init];
    [self.refreshControl addTarget:self action:@selector(onRefresh) forControlEvents:UIControlEventValueChanged];
    [self.myTableView insertSubview:self.refreshControl atIndex:0];
    
    NSURL *url = [NSURL URLWithString:@"https://api.instagram.com/v1/media/popular?client_id=9ddd1c5529524ab2a187ad3477be4672"];
    NSURLRequest *request = [[NSURLRequest alloc] initWithURL:url];
    [NSURLConnection sendAsynchronousRequest:request queue:[NSOperationQueue mainQueue] completionHandler:^(NSURLResponse *response, NSData *data, NSError *connectionError) {
        NSDictionary *responseDictionary = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
        self.responseData = [responseDictionary objectForKey:@"data"];
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
    NSLog(@"numberOfRowsInSection");
    if (self.responseData != nil) {
        NSLog(@"%li", self.responseData.count);
        return self.responseData.count;
    } else {
        return 0;
    }
    
}

- (PhotoTableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    PhotoTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"com.yahoo.photo.cell"];
    NSDictionary *dataObj = self.responseData[indexPath.row];
    NSString *urlStr = dataObj[@"images"][@"low_resolution"][@"url"];
    NSURL *url = [[NSURL alloc] initWithString:urlStr];
    
    [cell.myPhotoView setImageWithURL:url];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    self.rowSelected = indexPath.row;
    [self performSegueWithIdentifier:@"com.yahoo.image.segue" sender:self];
}

#pragma mark - Segue
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([[segue identifier] isEqualToString:@"com.yahoo.image.segue"]) {
        // Get reference to the destination view controller
        PhotoDetailsViewController *vc = [segue destinationViewController];
        
        // Pass any objects to the view controller here, like...
        //NSIndexPath *indexPath = [self.myTableView indexPathForCell:sender];
        
        NSDictionary *dataDict = self.responseData[self.rowSelected];
        NSString *urlStr = dataDict[@"images"][@"low_resolution"][@"url"];
        NSURL *url = [[NSURL alloc] initWithString:urlStr];
        NSLog(@"Tapped Row URL: %@", url);
        
        [vc setUrl:url];
    }
}

# pragma mark - Refresh
- (void)onRefresh {
    NSURL *url = [NSURL URLWithString:@"https://api.instagram.com/v1/media/popular?client_id=9ddd1c5529524ab2a187ad3477be4672"];
    NSURLRequest *request = [[NSURLRequest alloc] initWithURL:url];
    [NSURLConnection sendAsynchronousRequest:request queue:[NSOperationQueue mainQueue] completionHandler:^(NSURLResponse *response, NSData *data, NSError *connectionError) {
        NSDictionary *responseDictionary = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
        self.responseData = [responseDictionary objectForKey:@"data"];
        [self.myTableView reloadData];
        
        [self.refreshControl endRefreshing];
    }];
}


@end
