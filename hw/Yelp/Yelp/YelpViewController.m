//
//  YelpViewController.m
//  Yelp
//
//  Created by Minh Nguyen on 9/16/15.
//  Copyright (c) 2015 Minh Nguyen. All rights reserved.
//

#import "UIImageView+AFNetworking.h"
#import "YelpViewController.h"
#import "FiltersViewController.h"
#import "YelpClient.h"
#import "Business.h"
#import "Filters.h"
#import "YelpTableViewCell.h"

NSString * const kYelpConsumerKey = @"vxKwwcR_NMQ7WaEiQBK_CA";
NSString * const kYelpConsumerSecret = @"33QCvh5bIF5jIHR5klQr7RtBDhQ";
NSString * const kYelpToken = @"uRcRswHFYa1VkDrGV6LAW2F8clGh5JHV";
NSString * const kYelpTokenSecret = @"mqtKIxMIR4iBtBPZCmCLEb-Dz3Y";

@interface YelpViewController ()

@property (nonatomic, weak) UISearchBar *searchBar;
@property (nonatomic, weak) IBOutlet UIButton *filterButton;
@property (nonatomic, weak) IBOutlet UITableView *tableView;

@property (nonatomic, strong) YelpClient *client;
@property (nonatomic, strong) NSMutableArray *businesses;
@property (nonatomic, strong) Filters *filters;

@property (nonatomic, assign) Boolean moreSearchActive;

@end

@implementation YelpViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self.navigationController.navigationBar setTitleTextAttributes:
     @{NSForegroundColorAttributeName:[UIColor whiteColor]}];
    
    self.navigationController.navigationBar.tintColor = [UIColor whiteColor];
    self.navigationController.navigationBar.barStyle = UIBarStyleBlack;
    
    // Do any additional setup after loading the view, typically from a nib.
    UISearchBar *searchBar = [[UISearchBar alloc] init];
    [searchBar sizeToFit];
    self.navigationItem.titleView = searchBar;
    self.searchBar = searchBar;
    searchBar.tintColor = [UIColor colorWithWhite:1 alpha:1.0];
    searchBar.delegate = self;
    searchBar.placeholder = @"Businesses";
    
    UITapGestureRecognizer *tapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleTapFrom:)];
    [self.tableView addGestureRecognizer:tapGestureRecognizer];
    tapGestureRecognizer.delegate = self;
    
    UINib *movieCellNib = [UINib nibWithNibName:@"YelpTableViewCell" bundle:nil];
    [self.tableView registerNib:movieCellNib forCellReuseIdentifier:@"com.yahoo.yelp.cell"];
    self.tableView.estimatedRowHeight = 133;
    self.tableView.rowHeight = UITableViewAutomaticDimension;
    
    self.filters = [[Filters alloc] init];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(filtersSavedNotification:) name:FilterViewSavedNotification object:nil];
    //[self doSearch];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void) filtersSavedNotification:(NSNotification*)notification {
    [self doSearch];
}

#pragma mark - Network
- (void)doSearch {
    if (self.businesses.count > 0) {
        // Reset View
        NSIndexPath *top = [NSIndexPath indexPathForRow:0 inSection:0];
        [self.tableView scrollToRowAtIndexPath:top atScrollPosition:UITableViewScrollPositionTop animated:YES];
    }
    
    self.filters.term = self.searchBar.text;
    // You can register for Yelp API keys here: http://www.yelp.com/developers/manage_api_keys
    if (!self.client) {
        self.client = [[YelpClient alloc] initWithConsumerKey:kYelpConsumerKey consumerSecret:kYelpConsumerSecret accessToken:kYelpToken accessSecret:kYelpTokenSecret];
    }

    [self.client searchWithFilters:self.filters success:^(AFHTTPRequestOperation *operation, id response) {
        NSLog(@"response: %@", response);
        dispatch_async(dispatch_get_main_queue(), ^{
            self.businesses = [NSMutableArray arrayWithArray:[Business businessWithDictionaries:response[@"businesses"]]];
            [self.tableView reloadData];
        });
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"error: %@", [error description]);
    }];
}

- (void)doMoreSearch {
    self.moreSearchActive = true;
    //NSLog(@"doMoreSearch");
    UIView *tableFooterView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 320, 50)];
    UIActivityIndicatorView *loadingView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    [loadingView startAnimating];
    loadingView.center = tableFooterView.center;
    [tableFooterView addSubview:loadingView];
    self.tableView.tableFooterView = tableFooterView;
    
    self.filters.offset = self.filters.offset+1;
    [self.client searchWithFilters:self.filters success:^(AFHTTPRequestOperation *operation, id response) {
        //NSLog(@"response: %@", response);
        NSArray *moreBusinesses = [Business businessWithDictionaries:response[@"businesses"]];
        
        if (moreBusinesses.count > 0) {
            [self.businesses addObjectsFromArray:moreBusinesses];
        }
        self.moreSearchActive = false;
        dispatch_async(dispatch_get_main_queue(), ^{
            self.tableView.tableFooterView = nil;
            [self.tableView reloadData];
        });
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        self.moreSearchActive = false;
        self.tableView.tableFooterView = nil;
        NSLog(@"error: %@", [error description]);
    }];
}

#pragma mark - UITableView
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (self.businesses.count) {
        NSLog(@"Count: %li", self.businesses.count);
    }
    return self.businesses.count;
}

- (YelpTableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    Business *business = self.businesses[indexPath.row];
    YelpTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"com.yahoo.yelp.cell"];
    cell.business = business;
    
    if (!self.moreSearchActive && indexPath.row == self.businesses.count-1 && self.businesses.count %20 == 0) {
        [self doMoreSearch];
    }
    
    return cell;
}

#pragma mark - Navigation
- (IBAction)filtersTapped:(UIBarButtonItem *)sender {
    NSLog(@"settings");
    [self performSegueWithIdentifier:@"com.yahoo.yelp.filters.segue" sender:self];
}

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([[segue identifier] isEqualToString:@"com.yahoo.yelp.filters.segue"]) {
        // Get reference to the destination view controller
        FiltersViewController *vc = [segue destinationViewController];
        
        [vc setFilters:self.filters];
    }
}

#pragma mark - Search Bar
- (void)searchBarTextDidBeginEditing:(UISearchBar *)searchBar {
    //NSLog(@"Begin");
    [searchBar setShowsCancelButton:YES animated:YES];
}

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar {
    [self doSearch];
    [searchBar resignFirstResponder];
}

-(void)searchBarTextDidEndEditing:(UISearchBar *)searchBar {
    [searchBar setShowsCancelButton:NO animated:YES];
}

-(void)searchBarCancelButtonClicked:(UISearchBar *)searchBar {
    [searchBar resignFirstResponder];
}

#pragma mark - Gestures
- (void) handleTapFrom: (UITapGestureRecognizer *)recognizer
{
    //NSLog(@"tap");
    [self.searchBar resignFirstResponder];
}

@end
