//
//  TomatoesDetailsViewController.m
//  RottenTomatoes
//
//  Created by Minh Nguyen on 9/14/15.
//  Copyright (c) 2015 Minh Nguyen. All rights reserved.
//

#import "TomatoesDetailsViewController.h"
#import "UIImageView+AFNetworking.h"

@interface TomatoesDetailsViewController ()
@property (weak, nonatomic) IBOutlet UIImageView *posterImage;

@property (weak, nonatomic) IBOutlet UIView *informationView;
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UILabel *criticLabel;
@property (weak, nonatomic) IBOutlet UILabel *ratingLabel;
@property (weak, nonatomic) IBOutlet UILabel *synopsisLabel;

@property Boolean expanded;
@end

@implementation TomatoesDetailsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.expanded = true;
    [self.navigationItem setTitle:self.movie.title];
    self.navigationController.navigationBar.translucent = YES;
    self.navigationController.navigationBar.alpha = .7;
    // Do any additional setup after loading the view.
    
    NSString *url = [NSString stringWithFormat:@"%@", self.movie.poster_url];
    NSRange range = [url rangeOfString:@".*cloudfront.net/" options:NSRegularExpressionSearch];
    if (range.location != NSNotFound) {
        url = [url stringByReplacingCharactersInRange:range withString:@"https://content6.flixster.com/"];
    }
    
    [self.posterImage setImageWithURL: self.movie.poster_url];
    [self.posterImage setImageWithURL: [NSURL URLWithString:url]];
    
    self.synopsisLabel.lineBreakMode = NSLineBreakByTruncatingTail;
    
    //[cell.posterImage setImageWithURL:movie.poster_url];
    self.titleLabel.text = [NSString stringWithFormat:@"%@ (%@)", self.movie.title, self.movie.year];
    self.ratingLabel.text = [NSString stringWithFormat:@"Rated: %@", self.movie.mpaa_rating];
    self.synopsisLabel.text = self.movie.synopsis;
    
    //self.informationView.userInteractionEnabled = YES;
    /*
    UIPanGestureRecognizer * pan = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(pan:)];
    pan.maximumNumberOfTouches = pan.minimumNumberOfTouches = 1;
    [self.informationView addGestureRecognizer:pan];
    */
    UITapGestureRecognizer *singleFingerTap =
    [[UITapGestureRecognizer alloc] initWithTarget:self
                                            action:@selector(handleSingleTap:)];
    [self.informationView addGestureRecognizer:singleFingerTap];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
 /*
- (void)pan:(UIPanGestureRecognizer *)aPan; {
    CGPoint currentPoint = [aPan locationInView:self.informationView];
    //NSLog(@"curr x: %f", currentPoint.x);
    //NSLog(@"curr y: %f", currentPoint.y);
    //float heightDiff = [aPan translationInView:self.informationView].y;
    //NSLog(@"%f", heightDiff);
    
    [UIView animateWithDuration:0.01f
                     animations:^{
                         CGRect oldFrame = self.informationView.frame;
                         self.informationView.frame = CGRectMake(oldFrame.origin.x, currentPoint.y, oldFrame.size.width, ([UIScreen mainScreen].bounds.size.height - currentPoint.y));
                         [self.view layoutIfNeeded];
                     }];
}
*/
- (void)handleSingleTap:(UITapGestureRecognizer *)recognizer {
    //CGPoint location = [recognizer locationInView:[recognizer.view superview]];
    
    [UIView animateWithDuration:0.5f
                     animations:^{
                         if (self.expanded) {
                             self.expanded = false;
                             CGRect oldFrame = self.informationView.frame;
                             oldFrame.origin.y = oldFrame.origin.y + 275;
                             self.informationView.frame = oldFrame;
                             [self.view layoutIfNeeded];
                         } else {
                             self.expanded = true;
                             CGRect oldFrame = self.informationView.frame;
                             oldFrame.origin.y = oldFrame.origin.y - 275;
                             self.informationView.frame = oldFrame;
                             [self.view layoutIfNeeded];
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

@end
