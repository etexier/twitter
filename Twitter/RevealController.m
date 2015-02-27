//
//  ViewController.m
//  Twitter
//
//  Created by Emmanuel Texier on 2/26/15.
//  Copyright (c) 2015 Emmanuel Texier. All rights reserved.
//

#import "RevealController.h"
#import "TweetsViewControllerDelegate.h"
#import "TweetsViewController.h"
#import "MenuViewController.h"


@interface RevealController () <TweetsViewControllerDelegate, RevealControllerDelegate>


- (void)onPanGesture:(UIPanGestureRecognizer *)sender onController:(TweetsViewController *)controller;

@end


@implementation RevealController

CGPoint originalTweetsViewCenter;


- (id)init {
    self = [super init];
    if (self) {


        // tweets view controller
        TweetsViewController *tvc = [[TweetsViewController alloc] init];
        tvc.tweetsViewControllerDelegate = self;
        self.currentController = tvc;

        NSLog(@"TweetsViewController's delegate is %@", tvc.tweetsViewControllerDelegate);

        // make current controller the tweets controller
        [self.view addSubview:tvc.view];
        [self addChildViewController:tvc];
        self.currentController = tvc;

        // menu view controller
        NSArray *menuActions =
                @[
                        @{@"name" : @"Account", @"controller" : NSNull.null},
                        @{@"name" : @"Settings", @"controller" : NSNull.null},
                        @{@"name" : @"Home", @"controller" : tvc}
                ];
        MenuViewController *mvc = [[MenuViewController alloc] initWithMenuActions:menuActions];
        [self.view addSubview:mvc.view];
        [self addChildViewController:mvc];
        mvc.revealControllerDelegate = self;
        self.previousController = mvc;


    }
    return self;
}


#pragma mark - TweetsViewController delegate method

- (void)onPanGesture:(UIPanGestureRecognizer *)sender onController:(TweetsViewController *)controller {
    NSLog(@"Pan gesture in delegate");
    CGPoint translation = [sender translationInView:sender.view];
    CGPoint velocity = [sender velocityInView:sender.view];

    if (sender.state == UIGestureRecognizerStateBegan) {
        NSLog(@"Pan began");
        originalTweetsViewCenter = sender.view.center;
    } else if (sender.state == UIGestureRecognizerStateChanged) {
        NSLog(@"Pan changed");
        sender.view.center = CGPointMake(originalTweetsViewCenter.x + translation.x, originalTweetsViewCenter.y);
    } else if (sender.state == UIGestureRecognizerStateEnded) {
        NSLog(@"Pan ended");
        if (velocity.x > 0) { // moving right
            [UIView animateWithDuration:0.5 delay:0 usingSpringWithDamping:0.6 initialSpringVelocity:0.2 options:UIViewAnimationOptionCurveEaseOut animations:^{
                sender.view.frame = CGRectMake(sender.view.frame.size.width - 50, 0, sender.view.frame.size.width, sender.view.frame.size.height);

            }                completion:^(BOOL finished) {
                //
            }];
        } else { // moving left

            [UIView animateWithDuration:0.5 delay:0 usingSpringWithDamping:0.6 initialSpringVelocity:0.2 options:UIViewAnimationOptionCurveEaseOut animations:^{
                //                CGRect frame = self.trayView.frame;
                //                frame.origin.y = 100;
                //                self.trayView.frame = frame;
                sender.view.frame = CGRectMake(0, 0, sender.view.frame.size.width, sender.view.frame.size.height);

            }                completion:^(BOOL finished) {
                //
            }];
        }


    }


}

- (void)onPresentController:(UIViewController *)presentedController
         previousController:(UIViewController *)currentController {
    NSLog(@"RevealController : present controller %@, previous: %@", presentedController, currentController);
    self.currentController = presentedController;
    self.previousController = currentController;
    [presentedController.view addSubview:currentController.view];
    [presentedController.view sendSubviewToBack:currentController.view];

    if ([[self.navigationController topViewController] isKindOfClass:presentedController.class]) {
        // just slide it back
        NSLog(@"Sliding current controller back %@", presentedController);

        [UIView animateWithDuration:10.0 delay:0.5 usingSpringWithDamping:0.6 initialSpringVelocity:0.2 options:UIViewAnimationOptionCurveEaseOut animations:^{

            presentedController.navigationController.view.frame =
                    CGRectMake(0, 0,
                            presentedController.navigationController.view.frame.size.width,
                            presentedController.navigationController.view.frame.size.height);

        }                completion:^(BOOL finished) {
            //
        }];


    } else {
        NSLog(@"Pushing current controller  %@", presentedController);
        [self.navigationController pushViewController:presentedController animated:YES];
    }


}


@end
