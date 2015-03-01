//
//  LoginViewController.h
//  Twitter
//
//  Created by Emmanuel Texier on 2/28/15.
//  Copyright (c) 2015 Emmanuel Texier. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol RevealViewControllerDelegate;

@interface LoginViewController : UIViewController

@property(weak, nonatomic) id <RevealViewControllerDelegate> revealControllerDelegate;

- (instancetype)initWithFrontViewController:(UIViewController *)frontViewController;



@end
