//
//  ViewController.m
//  Twitter
//
//  Created by Emmanuel Texier on 2/26/15.
//  Copyright (c) 2015 Emmanuel Texier. All rights reserved.
//

#import "RevealViewController.h"
#import "RevealView.h"

@interface RevealViewController () {
    CGFloat duration;
    CGFloat delay;
    CGFloat springWithDamping;
    CGFloat initialSpringVelocity;
    CGFloat slideWidth;
//    [UIView animateWithDuration:0.5 delay:0 usingSpringWithDamping:0.6 initialSpringVelocity:0.2 options:UIViewAnimationOptionCurveEaseOut animations:^{

}

@property(nonatomic, strong) RevealView *contentView;

@end


@implementation RevealViewController

CGPoint originalFrontViewCenter;


- (instancetype)initWithFrontViewController:(UIViewController *)frontViewController
                          andRearController:(UIViewController *)rearViewController
                                menuActions:(NSArray *)menuActions {
    self = [super init];
    if (self) {
        self.frontViewController = frontViewController;
        self.rearViewController = rearViewController;
        self.menuActions = menuActions;
        duration = 0.7;
        delay = 0;
        springWithDamping = 0.6;
        initialSpringVelocity = 0.2;
        slideWidth = 100;
    }
    return self;
}

#pragma mark - UIViewController methods

- (void)loadView {
    // create a custom content view for the controller
    self.contentView = [[RevealView alloc] initWithFrame:[[UIScreen mainScreen] bounds] controller:self];

    // set the content view to resize along with its superview
    [self.contentView setAutoresizingMask:UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight];

    // set our contentView to the controllers view
    self.view = self.contentView;

//    self.contentView.backgroundColor = [UIColor blackColor];



    [self deployViewOfController:self.rearViewController inView:self.contentView.rearView];
    [self deployViewOfController:self.frontViewController inView:self.contentView.frontView];

    NSLog(@"loadView ended");
}

- (void)deployViewOfController:(UIViewController *)controller inView:(UIView *)view {
    NSLog(@"Deploying controller %@ in view %@", controller, view);
    if (!controller || !view)
        return;

    CGRect frame = view.bounds;

    UIView *controllerView = controller.view;
    controllerView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    controllerView.frame = frame;

    [view addSubview:controllerView];

}

- (void)undeployViewOfController:(UIViewController *)controller {
    [controller.view removeFromSuperview];
}


#pragma mark - RevealControllerDelegate method

- (void)onHorizontalPanGesture:(UIPanGestureRecognizer *)sender onController:(UIViewController *)controller {
    NSLog(@"Pan gesture in delegate");
    UIView *targetView = self.contentView.frontView; // the actual frontView container
    if (sender.state == UIGestureRecognizerStateBegan) {
        NSLog(@"Pan began");
        originalFrontViewCenter = targetView.center;
    } else if (sender.state == UIGestureRecognizerStateChanged) {
        NSLog(@"Pan changed");
        CGPoint translation = [sender translationInView:targetView];
        [self translateView:targetView translationX:translation.x fromCenter:originalFrontViewCenter];
    } else if (sender.state == UIGestureRecognizerStateEnded) {
        NSLog(@"Pan ended");
        CGPoint velocity = [sender velocityInView:targetView];
        if (velocity.x > 0) { // moving right
            [self partiallySlideController];
        } else { // moving left
            [self presentController];
        }

    }
}

- (void)translateView:(UIView *)targetView translationX:(CGFloat)x fromCenter:(CGPoint)center {
    CGFloat newX = center.x + x;
    CGFloat minX = [[UIScreen mainScreen] bounds].size.width / 2;
    if (newX < minX) {
        newX = minX;
    }
    targetView.center = CGPointMake(newX, center.y);
}

- (void)transitionToController:(UIViewController *)controller {
    UIView *targetView = self.contentView.frontView;
    NSLog(@"Transitioning to %@", controller);
    [UIView animateWithDuration:duration delay:delay usingSpringWithDamping:0.6 initialSpringVelocity:0.0 options:UIViewAnimationOptionCurveEaseOut animations:^{
        if (self.frontViewController != controller) { // not the controller on the side
            targetView.frame = CGRectMake(targetView.frame.size.width, 0, targetView.frame.size.width, targetView.frame.size.height);
        }
    }                completion:^(BOOL finished) {
        [self partiallyUnslideController:controller];
    }];

}

- (void)partiallySlideController {
    UIView *targetView = self.contentView.frontView;
    NSLog(@"Moving %@ in right slide mode", targetView);
    [UIView animateWithDuration:duration delay:delay usingSpringWithDamping:springWithDamping initialSpringVelocity:initialSpringVelocity options:UIViewAnimationOptionCurveEaseOut animations:^{
        targetView.frame = CGRectMake(targetView.frame.size.width - slideWidth, 0, targetView.frame.size.width, targetView.frame.size.height);
    }                completion:^(BOOL finished) {
    }];
}


- (void)onNavigationBarLongPress:(UILongPressGestureRecognizer *)sender {
    NSLog(@"Detected long press on %@", sender.view);
    [self transitionToController:(UIViewController *) self.menuActions[MenuActionProfile][@"controller"]];
}

- (void)presentController {
    NSLog(@"Moving in presentation mode");
    UIView *targetView = self.contentView.frontView;
    [UIView animateWithDuration:duration delay:delay usingSpringWithDamping:0.9 initialSpringVelocity:0.0 options:UIViewAnimationOptionCurveEaseOut animations:^{
        targetView.frame = CGRectMake(0, 0, targetView.frame.size.width, targetView.frame.size.height);
    }                completion:^(BOOL finished) {
    }];
}

- (void)partiallyUnslideController:(UIViewController *)presentedController {
    NSLog(@"RevealViewController : present controller %@", presentedController);
    NSLog(@"Current front view : %@", self.frontViewController);

    if (self.frontViewController != presentedController) { // not the controller on the side
        NSLog(@"Undeploying old controller %@", self.frontViewController);
        [self undeployViewOfController:self.frontViewController];
        [self deployViewOfController:presentedController inView:self.contentView.frontView];
        self.frontViewController = presentedController;
    } // else already on the side
    [self presentController];
}


- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer {
    NSLog(@"shouldRecognizeSimultaneouslyWithGestureRecognizer called");
    return YES;
}


@end
