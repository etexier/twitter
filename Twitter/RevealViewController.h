//
//  ViewController.h
//  Twitter
//
//  Created by Emmanuel Texier on 2/26/15.
//  Copyright (c) 2015 Emmanuel Texier. All rights reserved.
//

#import <UIKit/UIKit.h>


@protocol RevealViewControllerDelegate <UIGestureRecognizerDelegate>
@required
- (void)onPresentController:(UIViewController *)presentViewController;
- (void)onPanGesture:(UIPanGestureRecognizer *)sender onController:(UIViewController *) controller ;
@end

@interface RevealViewController : UIViewController<RevealViewControllerDelegate>

@property (nonatomic, strong) UIViewController *frontViewController;
@property (nonatomic, strong) UIViewController *rearViewController;

- (void)onPanGesture:(UIPanGestureRecognizer *)sender onController:(UIViewController *)controller;
- (void)onPresentController:(UIViewController *)presentViewController;

- (id)initWithFrontViewController:(UIViewController *)frontViewController andRearController:(UIViewController *)rearViewController;

@end
