//
//  ViewController.m
//  Tinder
//
//  Created by Minh Nguyen on 9/18/15.
//  Copyright (c) 2015 Minh Nguyen. All rights reserved.
//

#import "ViewController.h"
#import "ProfileViewController.h"

@interface ViewController ()

@property CGPoint cardInitialCenter;
@property CGPoint cardOriginalCenter;
@property CGPoint pointStart;
@property (weak, nonatomic) IBOutlet UIImageView *profileImage;
@property Boolean isTopDrag;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.cardInitialCenter = self.profileImage.center;
    // Do any additional setup after loading the view, typically from a nib.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

static inline double radians (double degrees) {return degrees * M_PI/180;}

- (IBAction)onCardPanGesture:(UIPanGestureRecognizer *)sender {
    self.cardOriginalCenter = self.profileImage.center;
    //CGPoint point = [sender translationInView:self.view];
    CGPoint point = [sender locationInView:self.view];
    CGPoint velocity = [sender velocityInView: self.view];
    
    if (sender.state == UIGestureRecognizerStateBegan) {
        NSLog(@"Gesture began at: %f", point.y);
        self.pointStart = point;
        self.isTopDrag = (self.pointStart.y > self.cardInitialCenter.y) ? false : true;
        //sender.view.center = CGPointMake(self.trayOriginalCenter.x, self.trayOriginalCenter.y + point.y);
        
    } else if (sender.state == UIGestureRecognizerStateChanged) {
        //NSLog(@"Gesture changed at: %f", point.y);
        NSInteger xDiff = point.x - self.pointStart.x;
        NSInteger yDiff = point.y - self.pointStart.y;
        if (self.isTopDrag) {
            self.profileImage.transform = CGAffineTransformMakeRotation(radians(xDiff/2));
        } else {
            self.profileImage.transform = CGAffineTransformMakeRotation(radians(-xDiff/2));
        }
        
        
        //sender.view.center = CGPointMake(self.cardOriginalCenter.x + point.x, self.cardOriginalCenter.y + point.y);
        self.profileImage.center = CGPointMake(self.cardInitialCenter.x + xDiff, self.cardInitialCenter.y + yDiff);
    } else if (sender.state == UIGestureRecognizerStateEnded) {
        NSInteger xDiff = point.x - self.pointStart.x;
        NSInteger yDiff = point.y - self.pointStart.y;
        //NSLog(@"Gesture ended at: %f", point.y);
        NSLog(@"xDiff: %li", xDiff);
        NSLog(@"yDiff: %li", yDiff);
            
        if (xDiff > 50) {
            [UIView animateWithDuration:.7 delay:0 options:UIViewAnimationOptionCurveEaseOut animations:^{
                self.profileImage.center = CGPointMake(700, point.y);
            } completion:^(BOOL finished){
                [NSThread sleepForTimeInterval:1.0f];
                self.profileImage.center = self.cardInitialCenter;
                self.profileImage.transform = CGAffineTransformIdentity;
                
            }];
        } else if (xDiff < -50) {
            [UIView animateWithDuration:.7 delay:0 options:UIViewAnimationOptionCurveEaseOut animations:^{
                self.profileImage.center = CGPointMake(-700, point.y);
            } completion:^(BOOL finished){
                [NSThread sleepForTimeInterval:1.0f];
                self.profileImage.center = self.cardInitialCenter;
                self.profileImage.transform = CGAffineTransformIdentity;
            }];
        } else if (yDiff > 20) {
            self.profileImage.center = self.cardInitialCenter;
            self.profileImage.transform = CGAffineTransformIdentity;

            [UIView animateWithDuration:.3 delay:0 usingSpringWithDamping:.5 initialSpringVelocity:0 options:0 animations:^{
                self.profileImage.center = self.cardInitialCenter;
                ProfileViewController *vc2 = [self.storyboard instantiateViewControllerWithIdentifier:@"ProfileViewController"];
                vc2.theImage = self.profileImage.image;
                [self presentViewController:vc2 animated:YES completion:nil];
            } completion:^(BOOL finished) {}];
        } else {
            self.profileImage.center = self.cardInitialCenter;
            self.profileImage.transform = CGAffineTransformIdentity;
        }
        
        //[self presentViewController:vc2 animated:YES completion:nil];
        //[self dismissViewControllerAnimated:YES completion:nil];
            
        
    }
    //[sender setTranslation:CGPointMake(0,0) inView:sender.view];
}


@end
