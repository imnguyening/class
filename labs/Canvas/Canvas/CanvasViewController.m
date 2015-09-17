//
//  CanvasViewController.m
//  Canvas
//
//  Created by Minh Nguyen on 9/17/15.
//  Copyright (c) 2015 Minh Nguyen. All rights reserved.
//

#import "CanvasViewController.h"

@interface CanvasViewController ()
@property (strong, nonatomic) IBOutlet UIView *mainView;
@property (weak, nonatomic) IBOutlet UIView *trayView;
@property CGPoint trayOriginalCenter;
@property CGPoint trayStart;
@property CGPoint trayEnd;

@property (strong, nonatomic) UIImageView *newlyCreatedFace;

@end

@implementation CanvasViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.trayStart = self.trayView.center;
    self.trayEnd = CGPointMake(self.trayStart.x, self.trayStart.y + 150);
    
    //UIPanGestureRecognizer* panGestureRecognizer = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(onTrayPanGesture:)];
    //[self.drawerView addGestureRecognizer:panGestureRecognizer];
    // Do any additional setup after loading the view.
}

- (IBAction)onFacesPanGesture:(UIPanGestureRecognizer *)sender {
    self.trayOriginalCenter = sender.view.center;
    CGPoint point = [sender translationInView: self.view];
    
    if (sender.state == UIGestureRecognizerStateBegan) {
        NSLog(@"Faces began at: %f", point.y);
        UIImageView *imageView = (UIImageView *)sender.view;
        self.newlyCreatedFace = [[UIImageView alloc] initWithImage:imageView.image];
        [self.mainView addSubview:self.newlyCreatedFace];
        self.newlyCreatedFace.center = CGPointMake(imageView.center.x, imageView.center.y + self.trayView.frame.origin.y);
    } else if (sender.state == UIGestureRecognizerStateChanged) {
        NSLog(@"Faces changed at: %f", point.y);
        self.newlyCreatedFace.center = CGPointMake(self.trayOriginalCenter.x + point.x, self.trayOriginalCenter.y + self.trayView.frame.origin.y + point.y);
    } else if (sender.state == UIGestureRecognizerStateEnded) {
        NSLog(@"Faces ended at: %f", point.y);
    }
}

- (IBAction)onTrayPanGesture:(UIPanGestureRecognizer *)sender {
    self.trayOriginalCenter = self.trayView.center;
    CGPoint point = [sender translationInView: self.view];
    CGPoint velocity = [sender velocityInView: self.view];

    if (sender.state == UIGestureRecognizerStateBegan) {
        NSLog(@"Gesture began at: %f", point.y);
        //sender.view.center = CGPointMake(self.trayOriginalCenter.x, self.trayOriginalCenter.y + point.y);
        
    } else if (sender.state == UIGestureRecognizerStateChanged) {
        NSLog(@"Gesture changed at: %f", point.y);
        sender.view.center = CGPointMake(self.trayOriginalCenter.x, self.trayOriginalCenter.y + point.y);
    } else if (sender.state == UIGestureRecognizerStateEnded) {
        NSLog(@"Gesture ended at: %f", point.y);
        
        [UIView animateWithDuration:.3 delay:0 usingSpringWithDamping:.5 initialSpringVelocity:0 options:0 animations:^{
             if (velocity.y > 0) {
                 self.trayView.center = self.trayEnd;
             } else {
                 self.trayView.center = self.trayStart;
             }
        } completion:^(BOOL finished) {}];
    }
    [sender setTranslation:CGPointMake(0,0) inView:sender.view];
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
