//
//  ViewController.m
//  Twitter
//
//  Created by Emmanuel Texier on 2/26/15.
//  Copyright (c) 2015 Emmanuel Texier. All rights reserved.
//

#import "ViewController.h"
#import "TweetsViewControllerDelegate.h"
#import "TweetsViewController.h"
#import "MenuViewController.h"

@interface ViewController () <TweetsViewControllerDelegate>
@property (nonatomic, strong) UIViewController *contentController;
@property (nonatomic, strong) MenuViewController *menuViewController;
@property (nonatomic, strong) TweetsViewController *tweetsViewController;

- (void)onPanGesture:(UIPanGestureRecognizer *)sender onController:(TweetsViewController *) controller;

@end


@implementation ViewController

CGPoint originalTweetsViewCenter;


-(id) init {
    self = [super init];
    if (self) {
        // tweets view controller
        TweetsViewController *tvc = [[TweetsViewController alloc] init];
        tvc.tweetViewControllerDelegate = self;
        UINavigationController *nvc = [[UINavigationController alloc] initWithRootViewController:tvc];
        nvc.navigationBar.translucent = NO; // so table view first row is not hidden behind it
        self.tweetsViewController = tvc;

        // menu view controller
        MenuViewController *mvc = [[MenuViewController alloc] init];
        [self.view addSubview:mvc.view];
        [self addChildViewController:mvc];
        self.menuViewController = mvc;
        

        // make current controller the tweets view controller's navigation controller
        self.contentController = nvc;
        [self.view addSubview:nvc.view];
        [self addChildViewController:nvc];
        
        
    }
    return self;
}
- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/



- (void)onPanGesture:(UIPanGestureRecognizer *)sender onController:(TweetsViewController *) controller {
    NSLog(@"Pan gesture in delegate");
    CGPoint translation = [sender translationInView:sender.view];
    CGPoint velocity = [sender velocityInView:sender.view];

    if (sender.state == UIGestureRecognizerStateBegan) {
        NSLog(@"Pan began");
        originalTweetsViewCenter = self.contentController.view.center;
    } else if (sender.state == UIGestureRecognizerStateChanged) {
        NSLog(@"Pan changed");
        self.contentController.view.center = CGPointMake(originalTweetsViewCenter.x + translation.x, originalTweetsViewCenter.y);
    } else if (sender.state == UIGestureRecognizerStateEnded) {
        NSLog(@"Pan ended");
        if (velocity.x > 0) { // moving right
            [UIView animateWithDuration:0.5 delay:0 usingSpringWithDamping:0.6 initialSpringVelocity:0.2 options:UIViewAnimationOptionCurveEaseOut animations:^{
                self.contentController.view.frame = CGRectMake(self.contentController.view.frame.size.width - 50, 0,  self.contentController.view.frame.size.width,  self.contentController.view.frame.size.height);
                
            } completion:^(BOOL finished) {
                //
            }];
        } else { // moving left
            
            [UIView animateWithDuration:0.5 delay:0 usingSpringWithDamping:0.6 initialSpringVelocity:0.2 options:UIViewAnimationOptionCurveEaseOut animations:^{
                //                CGRect frame = self.trayView.frame;
                //                frame.origin.y = 100;
                //                self.trayView.frame = frame;
                self.contentController.view.frame = CGRectMake(0, 0,  self.contentController.view.frame.size.width,  self.contentController.view.frame.size.height);
                
            } completion:^(BOOL finished) {
                //
            }];
        }

        
    }
    
    
    /*
     if(menuViewCtrl == nil){
     menuViewCtrl = self.storyboard?.instantiateViewControllerWithIdentifier("menuVC") as? MenuViewController
     
     self.view.insertSubview(menuViewCtrl!.view, atIndex: 0)
     self.addChildViewController(menuViewCtrl!)
     menuViewCtrl?.didMoveToParentViewController(mainViewCtrl)
     
     UIView.animateWithDuration(0.5, delay: 0, usingSpringWithDamping: 0.5, initialSpringVelocity: 0, options: UIViewAnimationOptions.CurveEaseOut, animations: {
     self.mainViewCtrl!.view.frame.origin.x = self.mainViewCtrl!.view.frame.width - 50
     }, completion: nil)
     }else{
     UIView.animateWithDuration(0.5, delay: 0, usingSpringWithDamping: 0.5, initialSpringVelocity: 0, options: UIViewAnimationOptions.CurveEaseIn, animations: {
     self.mainViewCtrl!.view.frame.origin.x = 0
     }, completion: {
     finished in
     
     self.menuViewCtrl!.view.removeFromSuperview()
     self.menuViewCtrl!.removeFromParentViewController()
     self.menuViewCtrl = nil
     })
     }
     
     */
}


@end
