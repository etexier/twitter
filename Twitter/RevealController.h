//
//  ViewController.h
//  Twitter
//
//  Created by Emmanuel Texier on 2/26/15.
//  Copyright (c) 2015 Emmanuel Texier. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol RevealControllerDelegate<NSObject>
- (void)onPresentController:(UIViewController *)presentViewController previousController:(UIViewController *) previousController;

@end

@interface RevealController : UIViewController
@property (nonatomic, strong) UIViewController *currentController;
@property (nonatomic, strong) UIViewController *previousController;
@end
