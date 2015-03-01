//
//  ViewController.h
//  Twitter
//
//  Created by Emmanuel Texier on 2/26/15.
//  Copyright (c) 2015 Emmanuel Texier. All rights reserved.
//

#import <UIKit/UIKit.h>


typedef NS_ENUM(NSInteger, MenuAction) {
    MenuActionHome = 0,
    MenuActionMentions,
    MenuActionProfile
};
@protocol RevealViewControllerDelegate <UIGestureRecognizerDelegate>
@required
- (void)onHorizontalPanGesture:(UIPanGestureRecognizer *)sender onController:(UIViewController *) controller ;
- (void)onNavigationBarLongPress:(UILongPressGestureRecognizer *) sender;

- (void)rightAndLeftSlideToController:(UIViewController *)controller;

- (void)slideOverToController:(UIViewController *)controller;

- (void)animateFrontPresentationWithCompletion:(void (^)(BOOL finished))completion;

- (void)animateRightSlide;





- (void)transitionToLoginController;
@end

@interface RevealViewController : UIViewController<RevealViewControllerDelegate>

@property (nonatomic, strong) UIViewController *frontViewController;
@property (nonatomic, strong) UIViewController *rearViewController;


@property(nonatomic, weak) NSArray *menuActions;

- (void)transitionToLoginController;



- (instancetype)initWithFrontViewController:(UIViewController *)frontViewController andRearController:(UIViewController *)rearViewController menuActions:(NSArray *)menuActions;

@end
